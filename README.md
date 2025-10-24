<!-- - [About](#about)
- [Installation](#installation)
  - [PSGallery](#psgallery)
  - [GitHub Release (ZIP)](#github-release-zip)
  - [Build from Source](#build-from-source)
- [Examples](#examples)
  - [Basic Usage](#basic-usage-usernamepassword-authentication)
  - [PSCredential Authentication](#using-pscredential-authentication)
  - [Multiple Recipients](#multiple-recipients-with-cc-and-bcc)
  - [Email with Attachments](#email-with-attachment-and-priority)
  - [Using SecureString](#using-securestring-for-password)
- [Release Notes](#release-notes) -->

<div align="center">

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

Powershell Module to send Email using <a href="https://github.com/jstedfast/MailKit" style="color:white">MailKit</a>, <a href="https://github.com/jstedfast/MimeKit" style="color:white">MimeKit</a> and STARTTLS

[![GitHub License](https://img.shields.io/github/license/Brandon-J-Navarro/Powershell_Email-Module?color=blue)](https://github.com/Brandon-J-Navarro/Powershell_Email-Module/blob/main/LICENSE)&nbsp; 
[![issues - badge-generator](https://img.shields.io/github/issues/Brandon-J-Navarro/Powershell_Email-Module?color=red)](https://github.com/Brandon-J-Navarro/Powershell_Email-Module/issues)&nbsp; 
[![GitHub Tag](https://img.shields.io/github/v/tag/Brandon-J-Navarro/Powershell_Email-Module)](https://github.com/Brandon-J-Navarro/Powershell_Email-Module/tags)

[![Build, Package, and Release](https://github.com/Brandon-J-Navarro/Powershell_Email-Module/actions/workflows/main.yml/badge.svg?branch=main)](https://github.com/Brandon-J-Navarro/Powershell_Email-Module/actions/workflows/main.yml)&nbsp; 
[![Build and Test PowerShell Module](https://github.com/Brandon-J-Navarro/Powershell_Email-Module/actions/workflows/tests.yml/badge.svg?branch=testing)](https://github.com/Brandon-J-Navarro/Powershell_Email-Module/actions/workflows/tests.yml)

![Static Badge](https://img.shields.io/badge/Linux-Passing-gree?logo=linux&logoColor=white)&nbsp; 
![Windows](https://custom-icon-badges.demolab.com/badge/Windows-Passing-gree?logo=windows11&logoColor=white)&nbsp; 
![macOS](https://img.shields.io/badge/macOS-Failing-red?logo=apple&logoColor=white)

</div>

### [Release Notes](#release-notes)

> Note: MacOS Failed GitHub Actions Automated Test and is currently not officially supported

## About
Originally I wrote this in .NET 8 but in order to have it available and work on a wider range of windows machines ( Servers, VMs, Desktops, etc. ) that did not have Powershell Core installed, I recompiled it in .NET Framework 4.7.2, allowing it to be ran with Windows Powershell (Desktop) and Powershell Core. I ended up packaging them both into the same module on import it will look at the $PSEdition that is being ran an import the appropriate libraries.

- Compatible PSEditions: Windows PowerShell', 'PowerShell Core'
- Minimum Powershell version: 'Windows PowerShell 5.1'
- DotNet Framework Version: '.NET Framework 4.7.2'
- Tested with Microsoft Exchange Sever 2019 CU 15 and mailcow: dockerized 2025-09c

## PSGallery [![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/EmailModule)](https://www.powershellgallery.com/packages/EmailModule/)&nbsp; [![PowerShell Gallery Downloads](https://img.shields.io/powershellgallery/dt/EmailModule?color=blue)](https://www.powershellgallery.com/packages/EmailModule/)

1. Download from <a href="https://www.powershellgallery.com/packages/EmailModule/" target="_blank">PSGallery</a><br>
`Install-Module -Name EmailModule -Repository PSGallery`
2. Import the Module `Import-Module EmailModule`
3. Define your variables / Run the `Send-Email` Cmdlets
4. To update run `Update-Module -Name EmailModule -Repository PSGallery`
#

## GitHub Release (ZIP) [![GitHub Release](https://img.shields.io/github/v/release/Brandon-J-Navarro/Powershell_Email-Module)](https://github.com/Brandon-J-Navarro/Powershell_Email-Module/releases)

1. Download the <a href="https://github.com/Brandon-J-Navarro/Powershell_Email-Module/releases/latest">Latest Release</a>
2. Since it is a ZIP download from the web you might what have to "Unblock" it in the properties.<br>
` Get-ChildItem $env:USERPROFILE\Downloads\EmailModule.zip | Unblock-File `
3. Extract `EmailModule.zip`
4. Place the EmailModule folder where it is accessible to `$env:PSModulePath`
5. Import the Module `Import-Module "PATH\TO\EmailModule\EmailModule.psm1"`
6. Define your variables / Run the `Send-Email` Cmdlets

## Build from Source
- Guide in the <a href="https://github.com/Brandon-J-Navarro/Powershell_Email-Module/wiki/Build-from-source">Wiki</a>

#
### Basic Usage (Username/Password Authentication)
```powershell
$AuthUser = "DoNotReply@Domain.com"
$AuthPass = "YourPasswordHere"
$To = "Email@Domain.com"
$ToName = "Recipient Name"
$From = "DoNotReply@Domain.com"
$FromName = "DoNotReply"
$Subject = "This is a test"
$Body = "test, Test, TEST!, Email Module"
$MailServer = "Mail.Domain.com"
$ServerPort = "587"

Send-Email -AuthUser $AuthUser -AuthPass $AuthPass `
    -EmailTo $To -EmailToName $ToName `
    -EmailFrom $From -EmailFromName $FromName `
    -Subject $Subject -Body $Body `
    -SmtpServer $MailServer -SmtpPort $ServerPort
```

### Create credential object
```powershell
$Credential = Get-Credential -UserName "service@domain.com"

Send-Email -Credential $Credential `
    -EmailTo "recipient@domain.com" `
    -EmailFrom "service@domain.com" `
    -Subject "Test Email" -Body "This is a test message." `
    -SmtpServer "mail.domain.com"
```

### Multiple recipients separated by semicolons
```powershell
$To = "user1@domain.com;user2@domain.com;user3@domain.com"
$ToNames = "User One;User Two;User Three"
$Cc = "manager@domain.com;supervisor@domain.com"
$CcNames = "Manager;Supervisor"
$Bcc = "audit@domain.com"
$BccNames = "Audit Team"

Send-Email -AuthUser "sender@domain.com" -AuthPass "password" `
    -EmailTo $To -EmailToName $ToNames `
    -EmailCc $Cc -CcName $CcNames `
    -EmailBcc $Bcc -BccName $BccNames `
    -EmailFrom "sender@domain.com" `
    -Subject "Team Notification" -Body "Important team update." `
    -SmtpServer "mail.domain.com"
```

### Email with Attachment and Priority
```powershell
Send-Email -AuthUser "reports@domain.com" -AuthPass "password" `
    -EmailTo "manager@domain.com" `
    -EmailFrom "reports@domain.com" `
    -Subject "Monthly Report" -Body "Please find the monthly report attached." `
    -EmailAttachment "C:\Reports\monthly_report.pdf" `
    -EmailPriority "Urgent" -EmailImportance "High" `
    -SmtpServer "mail.domain.com"
```

### Using SecureString for Password
```powershell
$SecurePass = ConvertTo-SecureString "YourPassword" -AsPlainText -Force

Send-Email -AuthUser "secure@domain.com" -AuthPass $SecurePass `
    -EmailTo "recipient@domain.com" `
    -EmailFrom "secure@domain.com" `
    -Subject "Secure Email" -Body "This email uses a secure password." `
    -SmtpServer "mail.domain.com"
```

## Release Notes
- Release: 1.0.6 
    - Added multiple parameter sets for authentication:
        - 'UserPass' parameter set using AuthUser and AuthPass
        - 'PSCredential' parameter set using Credential object
    - Enhanced AuthPass parameter to accept both plain text strings and SecureString objects
    - Added PSCredential parameter as alternative authentication method
    - Added Carbon Copy (CC) support:
        - EmailCc parameter for CC recipients (supports multiple addresses separated by ';')
        - CcName parameter for CC recipient display names
    - Added Blind Carbon Copy (BCC) support:
        - EmailBcc parameter for BCC recipients (supports multiple addresses separated by ';')
        - BccName parameter for BCC recipient display names
    - Enhanced recipient handling:
        - EmailTo parameter now supports multiple recipients separated by ';'
        - EmailToName parameter supports multiple names separated by ';'
        - Automatic fallback to email addresses when name count doesn't match address count
    - Added email attachment support with EmailAttachment parameter
    - Added EmailPriority parameter with values: NonUrgent, Normal, Urgent
    - Added EmailImportance parameter with values: Low, Normal, High
    - Subject and body are NULLABLE
    - Updated nuspec file generation to address warnings and missing files in nuget pack
        - Added dependencies
        - Added readme metadata
        - Updated license metadata
        - Added repository metadata
    - Change dll directories to address nuget pack warnings
        - lib\Core → lib\net8.0
        - lib\Desktop → lib\net472
    - Added License and Readme Property and Item Groups to csproj files

- Release: 1.0.5
    - EmailToName, and EmailFromName are NULLABLE

- Release: 1.0.4
    - All Parameters are required
