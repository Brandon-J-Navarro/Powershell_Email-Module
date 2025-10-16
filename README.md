# Powershell_Email-Module
Powershell Module to send Email using MailKit, MimeKit and STARTTLS
> Note: Tested with Exchange Server, and Mailcow, need to test with other mail servers.

> Note: Tested with Windows 11 on Windows Powershell (Desktop) and Powershell (Core). 
Also Tested with WSL2 Ubuntu 22.04.5 LTS om Powershell (Core).

### About
Originally I wrote this in .NET 8 but in order to have it available and work on a wider range of windows machines ( Servers, VMs, Desktops, etc. ) I recompiled it in .NET Framework 4.7.2, allowing it to be ran with Windows Powershell and Powershell Core. I can also put out the .NET 8 Version out, needs to be tested for use with other operating systems outside of windows.

- Compatible PSEditions: Windows PowerShell', 'PowerShell Core'
- Minimum Powershell version: 'Windows PowerShell 5.1'
- DotNet Framework Version: '.NET Framework 4.7.2'

## How to use
1. Download the <a href="https://github.com/Brandon-J-Navarro/Powershell_Email-Module/releases/latest">Lastest Release</a>
2. Since it is a ZIP download from the web you might what have to "Unblock" it in the properties (Looking into also publishing it to Powershell Gallery)
3. Extract `EmailModule.zip`
4. Place the EmailModule folder your typical Powershell Modules directory 
5. Import the Module
6. Define your variables / Run the `Send-Email` Cmdlets


```powershell
Import-Module "PATH\TO\EmailModule"
```

```powershell
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
$Body = "test, Test, TEST!, dotnet Framework Email Module"

# Mail Server FQDN and Port
$MailServer = "Mail.Domain.com"
$ServerPort = "587"
```

```powershell
Send-Email -AuthUser $AuthUser -AuthPass $AuthPass `
    -EmailTo $To -EmailToName $ToName `
    -EmailFrom $From -EmailFromName $FromName `
    -Subject $Subject -Body $Body `
    -SmtpServer $MailServer -SmtpPort $ServerPort
```
