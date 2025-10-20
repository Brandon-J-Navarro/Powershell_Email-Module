# Powershell_Email-Module
```
╔═════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
║               ███████╗███╗   ███╗ █████╗ ██╗██╗             ███╗   ███╗ ██████╗ ██████╗ ██╗   ██╗██╗     ███████╗               ║
║               ██╔════╝████╗ ████║██╔══██╗██║██║             ████╗ ████║██╔═══██╗██╔══██╗██║   ██║██║     ██╔════╝               ║
║               █████╗  ██╔████╔██║███████║██║██║             ██╔████╔██║██║   ██║██║  ██║██║   ██║██║     █████╗                 ║
║               ██╔══╝  ██║╚██╔╝██║██╔══██║██║██║             ██║╚██╔╝██║██║   ██║██║  ██║██║   ██║██║     ██╔══╝                 ║
║               ███████╗██║ ╚═╝ ██║██║  ██║██║███████╗        ██║ ╚═╝ ██║╚██████╔╝██████╔╝╚██████╔╝███████╗███████╗               ║
║               ╚══════╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚══════╝        ╚═╝     ╚═╝ ╚═════╝ ╚═════╝  ╚═════╝ ╚══════╝╚══════╝               ║
╚═════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝
```
Powershell Module to send Email using MailKit, MimeKit and STARTTLS
> Note: Tested with Exchange Server, and Mailcow.

> Note: MacOS Automated Test Failed

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
