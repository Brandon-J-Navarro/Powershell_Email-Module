# Custom C# Powershell Module

1. Write you CSharp Code
2. In the terminal run `dotnet new classlib -n <NAME>`
    > Replace the generated Class1.cs with your own .cs file or place your code within it
3. Add any "USING" packages in your code in the terminal with `dotnet add <NAME> package <PACKAGE>`
4. Compile with `dotnet build <NAME>`
5. Create PowerShell Module folder
6. Add your compiled dll into the folder along with any dlls (packages) used in your code
7. Write your PowerShell Code
8. Test

### SEE EXAMPLE BELOW


```csharp
// EmailCommands.cs
using MimeKit;
using MailKit.Security;
public class EmailCommands
{
    public static void SendEmail(string _AuthUser, string _AuthPass, string _EmailTo,
        string _EmailToName, string _EmailFrom, string _EmailFromName, string _EmailSubject,
        string _EmailBody, string _EmailMailServer, int _EmailServerPort)
    {
        var mailMessage = new MimeMessage();
        mailMessage.From.Add(new MailboxAddress(_EmailFromName, _EmailFrom));
        mailMessage.To.Add(new MailboxAddress(_EmailToName, _EmailTo));
        mailMessage.Subject = _EmailSubject;
        mailMessage.Body = new TextPart("plain")
        {
            Text = _EmailBody
        };
        using var smtpClient = new MailKit.Net.Smtp.SmtpClient();
        smtpClient.Connect(_EmailMailServer, _EmailServerPort, SecureSocketOptions.StartTls);
        smtpClient.Authenticate(_AuthUser, _AuthPass);
        smtpClient.Send(mailMessage);
        smtpClient.Disconnect(true);
    }
}
```

### Compile it using .NET SDK:
```bash
dotnet new classlib -n EmailLib
```
> Replace the generated "Class1.cs" with your "EmailCommands.cs"
`
```bash
dotnet add EmailLib package MailKit
```
```bash
dotnet add EmailLib package MimeKit
```
```bash
dotnet build EmailLib
```

### The DLL will be in:
EmailLib\bin\Debug\net8.0\EmailLib.dll

### Create the following folder
```bash
EmailModule\
├── EmailModule.psm1
├── EmailLib.dll
├── MimeKit.dll
├── MailKit.dll
```
### Run the following to create the EmailModule.psd1 file
```powershell
New-ModuleManifest -Path .\EmailModule\EmailModule.psd1 -RootModule "EmailModule.psm1" -ModuleVersion "1.0" -Author "Brandon Navarro"
```

```bash
EmailModule\
├── EmailModule.psm1
├── EmailModule.psd1
├── EmailLib.dll
├── MimeKit.dll
├── MailKit.dll
```
### Create the EmailModule.psm1 File
```powershell
    # Load the DLLs
Get-ChildItem -Path $PSScriptRoot -Filter *.dll | ForEach-Object {
    Try {
        Add-Type -Path $_.FullName -ErrorAction Stop
    } Catch {
        Write-Warning "Could not load assembly: $_.Name"
    }
}

function Send-Email {
    param (
        [string]$AuthUser,
        [string]$AuthPass,
        [string]$EmailTo,
        [string]$EmailToName,
        [string]$EmailFrom,
        [string]$EmailFromName,
        [string]$Subject,
        [string]$Body,
        [string]$SmtpServer,
        [int]$SmtpPort = 587
    )

    [EmailCommands]::SendEmail($AuthUser, $AuthPass, $EmailTo, $EmailToName, $EmailFrom, $EmailFromName, $Subject, $Body, $SmtpServer, $SmtpPort)
}
```
### Test
```powershell
Import-Module "C:\Path\To\EmailModule"

$AuthUser   = "In_Put_Values_Here"
$AuthPass   = "In_Put_Values_Here"
$To         = "In_Put_Values_Here"
$ToName     = "In_Put_Values_Here"
$From       = "In_Put_Values_Here"
$FromName   = "In_Put_Values_Here"
$Subject    = "In_Put_Values_Here"
$Body       = "In_Put_Values_Here"
$MailServer = "In_Put_Values_Here"
$ServerPort = "In_Put_Values_Here"

Send-Email -AuthUser $AuthUser -AuthPass $AuthPass `
    -EmailTo $To -EmailToName $ToName `
    -EmailFrom $From -EmailFromName $FromName `
    -Subject $Subject -Body $Body `
    -SmtpServer $MailServer -SmtpPort $ServerPort
```
