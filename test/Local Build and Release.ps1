# Build / Release for local testing
Clear-Host
if (Test-Path ".\release\"){
    Remove-Item -Path .\release -Recurse -Force
}

$LatestVersion = Invoke-WebRequest -Uri "https://www.powershellgallery.com/packages/EmailModule/" -ErrorAction Stop
$LatestVersion = $LatestVersion.Links | Where-Object {$_.'outerHTML' -like '*(current version)*'}
$LatestVersion = $LatestVersion.href.replace('/packages/EmailModule/','')
$LatestVersion = $LatestVersion.split('.')
$NewBuild = [int]$LatestVersion[2]
$NewBuild++
$NewVersion = $LatestVersion[0] + "." + $LatestVersion[1] + "." + $NewBuild
$NewVersion

nuget restore .\src\EmailLibraryDesktop\EmailLibrary.sln

msbuild .\src\EmailLibraryDesktop\EmailLibrary.sln /p:Configuration=Release /p:Platform="Any CPU" /p:TargetFrameworkVersion="v4.7.2"

New-Item -ItemType Directory -Path release | Out-Null;
New-Item -ItemType Directory -Path .\release\EmailModule | Out-Null;
New-Item -ItemType Directory -Path .\release\EmailModule\$NewVersion | Out-Null;
New-Item -ItemType Directory -Path .\release\EmailModule\$NewVersion\lib | Out-Null;
New-Item -ItemType Directory -Path .\release\EmailModule\$NewVersion\lib\net8.0 | Out-Null;
New-Item -ItemType Directory -Path .\release\EmailModule\$NewVersion\lib\net472 | Out-Null;

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
Get-ChildItem -path ".\src\EmailLibraryDesktop\EmailLibrary\bin\Release\" -Recurse -Exclude "*.pdb" | Where-Object { $_.Name -notin $exclude } | ForEach-Object {
    Copy-Item $_ -Destination ".\release\EmailModule\$NewVersion\lib\net472\"
}

dotnet restore .\src\EmailLibraryCore\EmailLibrary\EmailLibrary.csproj

dotnet publish .\src\EmailLibraryCore\EmailLibrary\EmailLibrary.csproj --configuration Release --no-restore --output publish

Get-ChildItem -path ".\publish\" -Exclude "*.pdb" | Where-Object Attributes -ne Directory | ForEach-Object {
    Copy-Item $_ -Destination ".\release\EmailModule\$NewVersion\lib\net8.0\"
}

Remove-Item -Path .\publish -Recurse -Force


$files = @('.\EmailModule.psd1','.\EmailModule.psm1','.\EmailModule.Libraries.ps1',".\EmailModule.nuspec",".\EmailModule.$NewVersion.nupkg")
Get-ChildItem -Path ".\release\EmailModule\$NewVersion\" -Recurse -File | ForEach-Object { 
    $files += $_.FullName.ToString().Replace("D:\a\Powershell_Email-Module\Powershell_Email-Module\release\EmailModule\$NewVersion",'.') 
}

$moduleSettings = @{
    Path = ".\release\EmailModule\$NewVersion\EmailModule.psd1"

    # Script module or binary module file associated with this manifest.
    RootModule = 'EmailModule.psm1'

    # Version number of this module.
    ModuleVersion = $NewVersion

    # Supported PSEditions
    CompatiblePSEditions = @('Desktop','Core')

    # ID used to uniquely identify this module
    GUID = '6f8c4c8a-6e0d-4139-836c-f798b30ada92'

    # Author of this module
    Author = 'Brandon Navarro'

    # Company or vendor of this module
    CompanyName = 'None'

    # Copyright statement for this module
    Copyright = '(c) Brandon Navarro. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'Powershell Module to send Email using MailKit, MimeKit and STARTTLS'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    DotNetFrameworkVersion = '4.7.2'

    # Processor architecture (None, X86, Amd64) required by this module
    ProcessorArchitecture = 'None'

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    ScriptsToProcess = @('EmailModule.Libraries.ps1')

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = 'Send-Email'

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = 'Send-Email'

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @()

    # List of all files packaged with this module
    FileList = $files

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    Tags        = @('Desktop','Core','Email','StartTLS')
    LicenseUri  = 'https://github.com/Brandon-J-Navarro/Powershell_Email-Module/blob/main/LICENSE'
    ProjectUri  = 'https://github.com/Brandon-J-Navarro/Powershell_Email-Module'
    IconUri     = 'https://github.com/Brandon-J-Navarro/'
    ReleaseNotes = 'Visit GitHub repo for release note / change log'
}
New-ModuleManifest @moduleSettings


Copy-Item -Path ".\src\EmailModule\EmailModule.Libraries.ps1" -Destination ".\release\EmailModule\$NewVersion\"
Copy-Item -Path ".\src\EmailModule\EmailModule.psm1" -Destination ".\release\EmailModule\$NewVersion\"
Copy-Item -Path ".\README.md" -Destination ".\release\EmailModule\$NewVersion\"
Copy-Item -Path ".\LICENSE" -Destination ".\release\EmailModule\$NewVersion\"

@"
<?xml version="1.0" encoding="utf-8"?>
<package xmlns="http://schemas.microsoft.com/packaging/2013/05/nuspec.xsd">
<metadata>
    <id>EmailModule</id>
    <version>$NewVersion</version>
    <title>EmailModule</title>
    <authors>Brandon Navarro</authors>
    <owners>Brandon Navarro</owners>
    <requireLicenseAcceptance>false</requireLicenseAcceptance>
    <license type="file">LICENSE</license>
    <projectUrl>https://github.com/Brandon-J-Navarro/Powershell_Email-Module</projectUrl>
    <repository type="git" url="https://github.com/Brandon-J-Navarro/Powershell_Email-Module.git" branch="main"/>
    <description>Powershell Module to send Email using MailKit, MimeKit and STARTTLS</description>
    <summary>A brief summary of your module.</summary>
    <releaseNotes>Visit GitHub repo for release note / change log</releaseNotes>
    <readme>README.md</readme>
    <copyright>(c) Brandon Navarro. All rights reserved.</copyright>
    <tags>Desktop Core Email StartTLS</tags>
    <dependencies>
    <group targetFramework=".NETFramework4.7.2">
        <dependency id="BouncyCastle.Cryptography" version="2.0.0.0" />
        <dependency id="EmailLibrary" version="1.0.0.0" />
        <dependency id="MailKit" version="4.14.0.0" />
        <dependency id="MimeKit" version="4.14.0.0" />
        <dependency id="System.Buffers" version="4.0.4.0" />
        <dependency id="System.Formats.Asn1" version="8.0.0.1" />
        <dependency id="System.Memory" version="4.0.2.0" />
        <dependency id="System.Numerics.Vectors" version="4.1.5.0" />
        <dependency id="System.Runtime.CompilerServices.Unsafe" version="6.0.1.0" />
        <dependency id="System.Threading.Tasks.Extensions" version="4.2.1.0" />
        <dependency id="System.ValueTuple" version="4.0.3.0" />
    </group>
    <group targetFramework="net8.0">
        <dependency id="BouncyCastle.Cryptography" version="2.0.0.0" />
        <dependency id="EmailLibrary" version="1.0.0.0" />
        <dependency id="MailKit" version="4.14.1" />
        <dependency id="MimeKit" version="4.14.0" />
        <dependency id="System.Security.Cryptography.Pkcs" version="8.0.0.0" />
    </group>
    </dependencies>
</metadata>
<files>
    <file src=".\**" target="\" />
</files>
</package>
"@ | Out-File -FilePath ".\release\EmailModule\$NewVersion\EmailModule.nuspec"

nuget pack .\release\EmailModule\$NewVersion\EmailModule.nuspec -Properties Configuration=Release -OutputDirectory ".\release\EmailModule\$NewVersion\"

# Import-Module ./Powershell_Email-Module/release/EmailModule/ -ArgumentList $true
# Import-Module ".\Powershell_Email-Module\release\EmailModule"-ArgumentList $true
