# EmailModule.Libraries.ps1
[CmdletBinding()]
param(
    [Parameter(Position=0, Mandatory=$false)]
    [boolean]$DisableVersionCheck = $false
)


function Get-Banner {
    [CmdletBinding()]
    param(
        [Parameter(Position=0, Mandatory=$false)]
        [boolean]$DisableVersionCheck = $false
    )

    $LatestVersion = $null
    if (-not $DisableVersionCheck) {
        if ($IsLinux -or $IsMacOS) {
            $CurrentVersion = $PSScriptRoot.Split("/")
        } else {
            $CurrentVersion = $PSScriptRoot.Split("\")
        }
        $CurrentVersion = $CurrentVersion | Select-Object -Last 1
        if ($CurrentVersion -notlike "*.*.*") {
            $LatestVersion = $null
        } else {
            try {
                if ( $(if ($IsLinux -or $IsMacOS) {
                    Test-Connection "powershellgallery.com"
                } else{
                    Test-NetConnection "powershellgallery.com"
                }) ) {
                    $LatestVersion = Invoke-WebRequest -Uri "https://www.powershellgallery.com/packages/EmailModule/" -ErrorAction Stop
                    $LatestVersion = $LatestVersion.Links | Where-Object {$_.'outerHTML' -like '*(current version)*'}
                    $LatestVersion = $LatestVersion.href.replace('/packages/EmailModule/','')
                    if ( $LatestVersion -lt $CurrentVersion) {
                        $LatestVersion = $null
                    }
                }
            } catch { }
        }
    }



    $newVersion =  ("
    A new EmailModule stable release is available: v{0}
    Upgrade now, or check out the release page at:
    https://www.powershellgallery.com/packages/EmailModule/{0}" -f $LatestVersion
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

Get-Banner -DisableVersionCheck $DisableVersionCheck

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
        'Microsoft.Net.Http.Headers.dll',
        'Microsoft.AspNetCore.StaticFiles.dll'
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
