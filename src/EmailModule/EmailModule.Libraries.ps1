# EmailModule.Libraries.ps1
if ($PSEdition -eq 'Core') {
    Get-ChildItem -Path (Join-Path $PSScriptRoot 'lib/net8.0') -Filter *.dll |
    ForEach-Object {
        try {
            Add-Type -Path $_.FullName -ErrorAction Stop
        } catch {
            Write-Warning "Could not load assembly: $($_.FullName)"
        }
    }
} else {
    $exclude = @(
        'System.Formats.Asn1.dll',
        'Microsoft.Bcl.AsyncInterfaces.dll',
        'Microsoft.Extensions.DependencyInjection.Abstractions.dll',
        'Microsoft.Extensions.Hosting.Abstractions.dll',
        'Microsoft.Extensions.Logging.Abstractions.dll',
        'Microsoft.Extensions.Primitives.dll',
        'System.Diagnostics.DiagnosticSource.dll',
        'System.Text.Encodings.Web.dll',
        'Microsoft.Extensions.WebEncoders.dll',
        'Microsoft.AspNetCore.Http.Abstractions.dll',
        'Microsoft.AspNetCore.Http.Features.dll',
        'Microsoft.Extensions.FileProviders.Abstractions.dll',
        'Microsoft.Net.Http.Headers.dll'
    )
    Get-ChildItem -Path (Join-Path $PSScriptRoot 'lib/net472') -Filter *.dll |
    Where-Object  { $_.Name -notin $exclude } |
    ForEach-Object {
        $Name = $_.FullName
        try {
            Add-Type -Path $_.FullName -ErrorAction Stop
        } catch {
            Write-Warning "Could not load assembly: $Name. $_"
        }
    }
}


# not on powershell desktop
    $ps = [System.Management.Automation.PowerShell]::Create()
    $ps.AddScript({ Get-Date }) | Out-Null
    $awaitable = $ps.InvokeAsync()
    $result = $awaitable.GetAwaiter().GetResult()
    $result

function Get-LatestVersion {
    try {
        $LatestVersion = powershell.exe -Command {Find-Module -Name EmailModule} -ErrorAction Stop
    }
    catch {
        return $null
    }

    $CurrentVersion = Get-Module -Name EmailModule

    if ($LatestVersion -gt $CurrentVersion.Version) {
        return $LatestVersion
    } else {
        return $null
    }
}

function Get-Banner {
    $LatestVersion = Get-LatestVersion
    $newVersion =  ("
    A new EmailModule stable release is available: v{0}.{1}.{2}
    Upgrade now, or check out the release page at:
    https://www.powershellgallery.com/packages/EmailModule/{0}.{1}.{2}" -f $LatestVersion.Version.Major,$LatestVersion.Version.Minor,$LatestVersion.Version.Build
    )
    $Banner = "
        ____           _ __  __  ___        __     __    
       / __/_ _  ___ _(_/ / /  |/  /__  ___/ /_ __/ /__  
      / _//  ' \/ _ '/ / / / /|_/ / _ \/ _  / // / / -_) 
     /___/_/_/_/\_,_/_/_/ /_/  /_/\___/\_,_/\_,_/_/\__/  "

    $helpText1 = "
    Cmdlets available: "
    $helpText2 = "        Send-Email"
    $helpText3 = "    Get help for Send-Email cmdlet: "
    $helpText4 = "        Get-Help Send-Email or Send-Email -?
    "
    $OriginalForeground = $host.ui.RawUI.ForegroundColor
    if ($null -ne $LatestVersion) {
        $host.ui.RawUI.ForegroundColor = "Yellow"
        Write-Output $newVersion 
    }
    $host.ui.RawUI.ForegroundColor = $OriginalForeground
    Write-Output $Banner
    Write-Output $helpText1
    $host.ui.RawUI.ForegroundColor = "Yellow"
    Write-Output $helpText2
    $host.ui.RawUI.ForegroundColor = $OriginalForeground
    Write-Output $helpText3
    $host.ui.RawUI.ForegroundColor = "Yellow"
    Write-Output $helpText4
    $host.ui.RawUI.ForegroundColor = $OriginalForeground
}
$LatestVersion = Invoke-WebRequest -Uri "https://www.powershellgallery.com/packages/EmailModule/" -ErrorAction Stop
$LatestVersion = $LatestVersion.Links | Where-Object {$_.'outerHTML' -like '*(current version)*'}
$LatestVersion = $LatestVersion.href.replace('/packages/EmailModule/','')
