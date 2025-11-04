# EmailModule.Libraries.ps1

function Get-Banner {
    $versionText1 =  "
    Check PSGallery for the latest release:"
    $versionText2 = "        Update-Module EmailModule"

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
    $host.ui.RawUI.ForegroundColor = $OriginalForeground
    Write-Output $versionText1
    $host.ui.RawUI.ForegroundColor = "Yellow"
    Write-Output $versionText2
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

Get-Banner

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
