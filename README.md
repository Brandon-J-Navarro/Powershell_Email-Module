```
╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
║  ███████╗███╗   ███╗ █████╗ ██╗██╗        ███╗   ███╗ ██████╗ ██████╗ ██╗   ██╗██╗     ███████╗  ║
║  ██╔════╝████╗ ████║██╔══██╗██║██║        ████╗ ████║██╔═══██╗██╔══██╗██║   ██║██║     ██╔════╝  ║
║  █████╗  ██╔████╔██║███████║██║██║        ██╔████╔██║██║   ██║██║  ██║██║   ██║██║     █████╗    ║
║  ██╔══╝  ██║╚██╔╝██║██╔══██║██║██║        ██║╚██╔╝██║██║   ██║██║  ██║██║   ██║██║     ██╔══╝    ║
║  ███████╗██║ ╚═╝ ██║██║  ██║██║███████╗   ██║ ╚═╝ ██║╚██████╔╝██████╔╝╚██████╔╝███████╗███████╗  ║
║  ╚══════╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚══════╝   ╚═╝     ╚═╝ ╚═════╝ ╚═════╝  ╚═════╝ ╚══════╝╚══════╝  ║
╚══════════════════════════════════════════════════════════════════════════════════════════════════╝
```
Powershell Module to send Email using MailKit, MimeKit and STARTTLS

[![Build and Test PowerShell Module](https://github.com/Brandon-J-Navarro/Powershell_Email-Module/actions/workflows/tests.yml/badge.svg?branch=working)](https://github.com/Brandon-J-Navarro/Powershell_Email-Module/actions/workflows/tests.yml)
[![Build, Package, and Release](https://github.com/Brandon-J-Navarro/Powershell_Email-Module/actions/workflows/main.yml/badge.svg?branch=main)](https://github.com/Brandon-J-Navarro/Powershell_Email-Module/actions/workflows/main.yml)

<!-- 
[![.Net](https://img.shields.io/badge/.NET-5C2D91?style=for-the-badge&logo=.net&logoColor=white)]()

[![Visual Studio Code](https://img.shields.io/badge/Visual%20Studio%20Code-0078d7.svg?style=for-the-badge&logo=visual-studio-code&logoColor=white)]()

[![Visual Studio](https://img.shields.io/badge/Visual%20Studio-5C2D91.svg?style=for-the-badge&logo=visual-studio&logoColor=white)]()

[![C#](https://img.shields.io/badge/c%23-%23239120.svg?style=for-the-badge&logo=csharp&logoColor=white)]()

[![PowerShell](https://img.shields.io/badge/PowerShell-%235391FE.svg?style=for-the-badge&logo=powershell&logoColor=white)]()

[![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)]()

[![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)]()

[![macOS](https://img.shields.io/badge/mac%20os-000000?style=for-the-badge&logo=macos&logoColor=F0F0F0)]()

[![Git](https://img.shields.io/badge/git-%23F05033.svg?style=for-the-badge&logo=git&logoColor=white)]()

[![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)]()

[![GitHub Actions](https://img.shields.io/badge/github%20actions-%232671E5.svg?style=for-the-badge&logo=githubactions&logoColor=white)]()

[![Microsoft Learn](https://img.shields.io/badge/Microsoft_Learn-258ffa?style=for-the-badge&logo=microsoft&logoColor=white)]()

[![YAML](https://img.shields.io/badge/yaml-%23ffffff.svg?style=for-the-badge&logo=yaml&logoColor=151515)]()

[![Windows Terminal](https://img.shields.io/badge/Windows%20Terminal-%234D4D4D.svg?style=for-the-badge&logo=windows-terminal&logoColor=white)]()

[![Licence](https://img.shields.io/github/license/Ileriayo/markdown-badges?style=for-the-badge)](./LICENSE) 
-->


<!-- 
https://github.com/henriquesebastiao/badges
https://github.com/inttter/md-badges
https://github.com/MichaelCurrin/badge-generator
https://shields.io/
 -->







> Note: Tested with Exchange Server, and Mailcow.

> Note: MacOS Automated Test Failed and is currently to my knowledge not supported

> Release: 1.0.4 All Parameters are required

> Release: 1.0.5 EmailToName, and EmailFromName are NULLABLE

### About
Originally I wrote this in .NET 8 but in order to have it available and work on a wider range of windows machines ( Servers, VMs, Desktops, etc. ) that did not have Powershell Core installed, I recompiled it in .NET Framework 4.7.2, allowing it to be ran with Windows Powershell (Desktop) and Powershell Core. I ended up packaging them both into the same module on import it will look at the $PSEdition that is being ran an import the appropriate libraries.

- Compatible PSEditions: Windows PowerShell', 'PowerShell Core'
- Minimum Powershell version: 'Windows PowerShell 5.1'
- DotNet Framework Version: '.NET Framework 4.7.2'

## PSGallery
1. Download from <a href="https://www.powershellgallery.com/packages/EmailModule/" target="_blank">PSGallery</a><br>
`Install-Module -Name EmailModule -Repository PSGallery`
2. Import the Module `Import-Module EmailModule`
3. Define your variables / Run the `Send-Email` Cmdlets
4. To update run `Update-Module -Name EmailModule -Repository PSGallery`

## Build from Source
- Guide in the <a href="https://github.com/Brandon-J-Navarro/Powershell_Email-Module/wiki/Build-from-source">Wiki</a>

## GitHib Release (ZIP)
1. Download the <a href="https://github.com/Brandon-J-Navarro/Powershell_Email-Module/releases/latest">Lastest Release</a>
2. Since it is a ZIP download from the web you might what have to "Unblock" it in the properties.<br>
` Get-ChildItem $env:USERPROFILE\Downloads\EmailModule.zip | Unblock-File `
3. Extract `EmailModule.zip`
4. Place the EmailModule folder where it is accessible to `$env:PSModulePath`
5. Import the Module `Import-Module "PATH\TO\EmailModule\EmailModule.psm1"`
6. Define your variables / Run the `Send-Email` Cmdlets

#
```powershell
Import-Module EmailModule
 
# Username and Password to authenticate to the Mail Server
    $AuthUser = "DoNotReply@Domain.com"
    $AuthPass = "YourPasswordHere"
# To Address
    $To = "Email@Domain.com"
    $ToName = "Name"
# From Address
    $From = "DoNotReply@Domain.com"
    $FromName = "DoNotReply"
# Email Content
    $Subject = "This is a test"
    $Body = "test, Test, TEST!, Email Module"
# Mail Server FQDN and Port
    $MailServer = "Mail.Domain.com"
    $ServerPort = "587"
 
Send-Email -AuthUser $AuthUser -AuthPass $AuthPass `
    -EmailTo $To -EmailToName $ToName `
    -EmailFrom $From -EmailFromName $FromName `
    -Subject $Subject -Body $Body `
    -SmtpServer $MailServer -SmtpPort $ServerPort
```
