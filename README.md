# Powershell_Email-Module
Powershell Module to send Email using MailKit, MimeKit and STARTTLS
> Note: Only Tested with Exchange Server, need to test with other mail servers

### About
Originally I wrote this in .NET 8 but in order to have it available and work on a wider range of windows machines ( Servers, VMs, Desktops, etc. ) I recompiled it in .NET Framework 4.7.2, allowing it to be ran with Windows Powershell and Powershell Core. I can also put out the .NET 8 Version out, needs to be tested for use with other operating systems outside of windows.

```
dotnet nuget verify '$env:USERPROFILE\Documents\Github\Powershell_Email-Module\EmailLibrary\packages\MailKit.4.14.1\MailKit.4.14.1.nupkg'
Verifying MailKit.4.14.1

Signature type: Repository
  Subject Name: CN=NuGet.org Repository by Microsoft, O=NuGet.org Repository by Microsoft, L=Redmond, S=Washington, C=US
  SHA256 hash: 1F4B311D9ACC115C8DC8018B5A49E00FCE6DA8E2855F9F014CA6F34570BC482D
  Valid from: 2/22/2024 7:00:00 PM to 5/18/2027 7:59:59 PM
```

```
dotnet nuget verify '$env:USERPROFILE\Documents\Github\Powershell_Email-Module\EmailLibrary\packages\MimeKit.4.14.0\MimeKit.4.14.0.nupkg'
Verifying MimeKit.4.14.0

Signature type: Repository
  Subject Name: CN=NuGet.org Repository by Microsoft, O=NuGet.org Repository by Microsoft, L=Redmond, S=Washington, C=US
  SHA256 hash: 1F4B311D9ACC115C8DC8018B5A49E00FCE6DA8E2855F9F014CA6F34570BC482D
  Valid from: 2/22/2024 7:00:00 PM to 5/18/2027 7:59:59 PM
```

```powershell
Get-FileHash -LiteralPath "$env:USERPROFILE\Documents\Github\Powershell_Email-Module\EmailLibrary\EmailLibrary\bin\Release\EmailLibrary.dll" -Algorithm SHA256 | fl *

Algorithm : SHA256
Hash      : D9AB6EEF0E0B0BA6489275699BC49196375C7B3FB16C971E2E9162A559D1262D
Path      : $env:USERPROFILE\Documents\Github\Powershell_Email-Module\EmailLibrary\EmailLibrary\bin\Release\EmailLibrary.dll
```

- Compatible PSEditions: Windows PowerShell', 'PowerShell Core'
- Minimum Powershell version: 'Windows PowerShell 5.1'
- DotNet FrameworkV ersion: '.NET Framework 4.7.2'

## How to use
1. Download the <a href="https://github.com/Brandon-J-Navarro/Powershell_Email-Module/releases/latest">Lastest Release</a>
2. Extract `EmailModule.zip`
3. Place the EmailModule folder your typical Powershell Modules directory 
4. Import the Module
5. Define your variables / Run the `Send-Email` Cmdlets


```powershell
Import-Module "$env:USERPROFILE\Documents\Github\Powershell_Email-Module\EmailLibrary\EmailModule\EmailModule.psm1"
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
