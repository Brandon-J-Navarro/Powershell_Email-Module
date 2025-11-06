# Get-Help Send-Email -Full

### NAME
    Send-Email

### SYNOPSIS
    Sends an email message through an SMTP server with authentication using a compiled .NET email handler.


### SYNTAX
    Send-Email -AuthUser <String> -AuthPass <Object> -EmailTo <String> [-EmailToName <String>] -EmailFrom <String>
    [-EmailFromName <String>] [-Subject <String>] [-Body <String>] -SmtpServer <String> [-SmtpPort <Int32>] [-EmailCc
    <Object>] [-CcName <Object>] [-EmailBcc <Object>] [-BccName <Object>] [-EmailAttachment <String>] [-EmailPriority
    <Object>] [-EmailImportance <Object>] [<CommonParameters>]

    Send-Email -Credential <PSCredential> -EmailTo <String> [-EmailToName <String>] -EmailFrom <String>
    [-EmailFromName <String>] [-Subject <String>] [-Body <String>] -SmtpServer <String> [-SmtpPort <Int32>] [-EmailCc
    <Object>] [-CcName <Object>] [-EmailBcc <Object>] [-BccName <Object>] [-EmailAttachment <String>] [-EmailPriority
    <Object>] [-EmailImportance <Object>] [<CommonParameters>]


### DESCRIPTION
The Send-Email function provides an interface for sending email messages through SMTP using
a .NET assembly that leverages the MimeKit and MailKit libraries. The underlying .NET class
`EmailCommands` (defined in the module's EmailLibrary.dll) handles message creation,
authentication, and secure transmission using STARTTLS.

The Send-Email function provides a simple way to send email messages from PowerShell scripts.
It supports SMTP authentication using username/password or PSCredential objects, and allows you to specify
the sender, recipients (To/CC/BCC), subject, body, attachments, and message priority/importance.

The supporting script `EmailModule.Libraries.ps1` dynamically loads the correct set of .NET assemblies
depending on the current PowerShell edition:

- When running on `PowerShell Core`, assemblies are loaded from:
    .\lib\net8.0\
- When running on `Windows PowerShell (Desktop)`, assemblies are loaded from:
    .\lib\net472\

This design ensures cross-platform compatibility and supports secure, authenticated email delivery
from PowerShell scripts or automation environments.

This PowerShell function serves as a wrapper that passes all user-supplied parameters to the
EmailLibrary.dll assembly that contains the `EmailCommands` class and static method
[EmailCommands]::SendEmail(), which constructs a MIME-compliant message and sends it
using MailKit's SmtpClient class. The connection is secured with STARTTLS, and credentials are
authenticated using the provided username and password.


### PARAMETERS
- ## AuthUser `<String>`
        Specifies the username used to authenticate to the SMTP server.
        This is typically the sender's email address (EmailFrom).

        Required?                    true
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

- ## AuthPass `<Object>`
        Specifies the password used to authenticate to the SMTP server.
        Accepts Plain Text of type 'System.String' or Secure Strings of type 'System.Security.SecureString'
        Consider using secure option such as: ConvertTo-SecureString "YourPasswordHere" -AsPlainText -Force

        Required?                    true
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

- ## Credential `<PSCredential>`
        Specifies the PSCredential object containing the username and password for SMTP authentication.
        This is an alternative to using AuthUser and AuthPass parameters separately.
        Create using: Get-Credential or New-Object System.Management.Automation.PSCredential

        Required?                    true
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

- ## EmailTo `<String>`
        Specifies the recipient's email address(es). Multiple recipients can be separated by semicolons (;).
        Examples: "user@example.com" or "user1@example.com;user2@example.com;user3@example.com"

        Required?                    true
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

- ## EmailToName `<String>`
        Specifies the display name(s) of the recipients separated by semicolons (;).
        Should correspond to EmailTo parameter. If the number of names does not match the number of email addresses,
        or if not provided, the email addresses will be used as display names.
        Examples: "John Doe" or "John Doe;Jane Smith;Bob Wilson"

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

- ## EmailFrom `<String>`
        Specifies the sender's email address.
        Example: "noreply@company.com"

        Required?                    true
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

- ## EmailFromName `<String>`
        Specifies the display name of the sender. If not provided, email address will be used.
        Example: "Company Notifications" or "IT Department"

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

- ## Subject `<String>`
        Specifies the subject line of the email.
        Example: "System Alert" or "Weekly Report"

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

- ## Body `<String>`
        Specifies the body content of the email message.
        The message is sent as plain text.
        Example: "This is a test message from the automation system."

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

- ## SmtpServer `<String>`
        Specifies the hostname or fully qualified domain name (FQDN) of the SMTP server to connect to.
        Examples: "smtp.gmail.com", "mail.company.com", "smtp.office365.com"

        Required?                    true
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

- ## SmtpPort `<Int32>`
        Specifies the TCP port number used for the SMTP connection. The default is 587.
        Supports any port that supports STARTTLS encryption for secure email transmission.
        Common ports: 25 (may support STARTTLS), 587 (STARTTLS standard), 465 (legacy SSL, if STARTTLS available)

        Required?                    false
        Position?                    named
        Default value                587
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

- ## EmailCc `<Object>`
        Specifies additional recipients to include in the Carbon Copy (CC) field.
        Multiple recipients can be separated by semicolons (;).
        Examples: "manager@company.com" or "manager@company.com;supervisor@company.com"

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

- ## CcName `<Object>`
        Specifies the display names for the CC recipients separated by semicolons (;).
        Should correspond to the EmailCc parameter. If the number of names does not match the number of email
        addresses,
        or if not provided, the email addresses will be used as display names.
        Examples: "Manager Name" or "Manager Name;Supervisor Name"

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

- ## EmailBcc `<Object>`
        Specifies additional recipients to include in the Blind Carbon Copy (BCC) field.
        Multiple recipients can be separated by semicolons (;).
        Examples: "audit@company.com" or "audit@company.com;backup@company.com"

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

- ## BccName `<Object>`
        Specifies the display names for the BCC recipients separated by semicolons (;).
        Should correspond to the EmailBcc parameter. If the number of names does not match the number of email
        addresses,
        or if not provided, the email addresses will be used as display names.
        Examples: "Audit Team" or "Audit Team;Backup Admin"

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

- ## EmailAttachment `<String>`
        Specifies the file path to an attachment to include with the email.
        Only a single attachment is supported. File must exist and be accessible.
        Examples: "C:\Reports\monthly_report.pdf" or "\\server\share\document.xlsx"

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

- ## EmailPriority `<Object>`
        Specifies the priority level of the email message. The default is Normal.
        Valid values are "NonUrgent", "Normal", or "Urgent" (case-insensitive).

        Required?                    false
        Position?                    named
        Default value                Normal
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

- ## EmailImportance `<Object>`
        Specifies the importance level of the email message. The default is Normal.
        Valid values are "Low", "Normal", or "High" (case-insensitive).

        Required?                    false
        Position?                    named
        Default value                Normal
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

- ## `<CommonParameters>`
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

### INPUTS
    None.
    All input must be supplied through parameters.


### OUTPUTS
    None.
    This function does not return an object. The result of execution is the successful transmission


### NOTES

        Assembly information:
            - Primary assembly:  EmailLibrary.dll
            - Class:             EmailCommands
            - Namespace:         (global)
            - Dependencies:
                • MimeKit.dll
                • MailKit.dll
                • BouncyCastle.Cryptography.dll
                • System.Security.Cryptography.Pkcs.dll (Core only)
                • Additional .NET support libraries (Desktop only)
            - Encryption:        STARTTLS via MailKit.Security.SecureSocketOptions.StartTls
            - Auto-loader:       EmailModule.Libraries.ps1
            - Library paths:
                EmailModule\lib\net8.0\ → PowerShell Core
                EmailModule\lib\net472\ → Windows PowerShell Desktop

        All assemblies are automatically imported when the module is loaded.
        If a DLL fails to load, a warning will be displayed.

        The function relies on a .NET class implemented in C#, defined as:
        public static class EmailCommands
        {
            public static void SendEmail(...) { ... }
        }

        This class uses:
            - MimeKit for constructing MIME messages.
            - MailKit.Net.Smtp.SmtpClient for sending messages securely.
            - SecureSocketOptions.StartTls for encryption.

        Both MimeKit and MailKit must be available in the environment or included within the module's DLL.

###    -------------------------- EXAMPLE 1 --------------------------
```Powershell
    PS > # Basic email with username/password authentication

    Send-Email -AuthUser "sender@company.com" -AuthPass "password123" `
            -EmailTo "recipient@company.com" -EmailFrom "sender@company.com" `
            -Subject "Test Email" -Body "This is a test message." `
            -SmtpServer "smtp.company.com" -SmtpPort 587
```



###    -------------------------- EXAMPLE 2 --------------------------
```Powershell
    PS > # Email with display names for sender and recipient

    Send-Email -AuthUser "noreply@company.com" -AuthPass "securepassword" `
            -EmailTo "john.doe@company.com" -EmailToName "John Doe" `
            -EmailFrom "noreply@company.com" -EmailFromName "IT Department" `
            -Subject "System Maintenance Notice" `
            -Body "Scheduled maintenance will occur this weekend." `
            -SmtpServer "mail.company.com"
```



###    -------------------------- EXAMPLE 3 --------------------------
```Powershell
    PS > # Multiple recipients with semicolon separation

    Send-Email -AuthUser "alerts@company.com" -AuthPass "alertpass" `
            -EmailTo "admin1@company.com;admin2@company.com;admin3@company.com" `
            -EmailToName "Admin One;Admin Two;Admin Three" `
            -EmailFrom "alerts@company.com" -EmailFromName "System Alerts" `
            -Subject "Server Alert" -Body "Server CPU usage is high." `
            -SmtpServer "smtp.company.com"
```



###    -------------------------- EXAMPLE 4 --------------------------
```Powershell
    PS > # Email with CC and BCC recipients

    Send-Email -AuthUser "reports@company.com" -AuthPass "reportpass" `
            -EmailTo "manager@company.com" -EmailToName "Department Manager" `
            -EmailCc "supervisor@company.com" -CcName "Supervisor" `
            -EmailBcc "audit@company.com" -BccName "Audit Team" `
            -EmailFrom "reports@company.com" -EmailFromName "Reporting System" `
            -Subject "Monthly Report" -Body "Please find the monthly report attached." `
            -EmailAttachment "C:\Reports\monthly_report.pdf" `
            -SmtpServer "smtp.company.com"
```



###    -------------------------- EXAMPLE 5 --------------------------
```Powershell
    PS > # Using PSCredential for authentication

    $cred = Get-Credential -UserName "service@company.com"
    Send-Email -Credential $cred `
            -EmailTo "support@company.com" `
            -EmailFrom "service@company.com" `
            -Subject "Service Status" -Body "All services are running normally." `
            -SmtpServer "smtp.company.com"
```



###    -------------------------- EXAMPLE 6 --------------------------
```Powershell
    PS > # Using SecureString for password

    $securePass = ConvertTo-SecureString "mypassword" -AsPlainText -Force
    Send-Email -AuthUser "automation@company.com" -AuthPass $securePass `
            -EmailTo "admin@company.com" `
            -EmailFrom "automation@company.com" `
            -Subject "Backup Complete" -Body "Daily backup completed successfully." `
            -SmtpServer "smtp.company.com"
```



###    -------------------------- EXAMPLE 7 --------------------------
```Powershell
    PS > # Email with priority and importance settings

    Send-Email -AuthUser "critical@company.com" -AuthPass "criticalpass" `
            -EmailTo "oncall@company.com" `
            -EmailFrom "critical@company.com" `
            -Subject "URGENT: System Down" -Body "Primary server is not responding." `
            -SmtpServer "smtp.company.com" `
            -EmailPriority "Urgent" -EmailImportance "High"
```



###    -------------------------- EXAMPLE 8 --------------------------
```Powershell
    PS > # Using variables for reusable configuration

    $mailConfig = @{
        AuthUser = "notifications@company.com"
        AuthPass = "notifypass"
        EmailFrom = "notifications@company.com"
        EmailFromName = "Company Notifications"
        SmtpServer = "smtp.company.com"
        SmtpPort = 587
    }

    Send-Email @mailConfig `
            -EmailTo "team@company.com" `
            -Subject "Weekly Update" `
            -Body "This week's summary is attached." `
            -EmailAttachment "C:\Reports\weekly_summary.xlsx"
```



###    -------------------------- EXAMPLE 9 --------------------------
```Powershell
    PS > # Office 365/Outlook.com configuration

    Send-Email -AuthUser "user@outlook.com" -AuthPass "apppassword" `
            -EmailTo "recipient@domain.com" `
            -EmailFrom "user@outlook.com" `
            -Subject "Test from Office 365" `
            -Body "Testing email via Office 365 SMTP." `
            -SmtpServer "smtp-mail.outlook.com" -SmtpPort 587
```



###    -------------------------- EXAMPLE 10 --------------------------
```Powershell
    PS > # Gmail configuration (requires app password)

    Send-Email -AuthUser "user@gmail.com" -AuthPass "apppassword" `
            -EmailTo "recipient@domain.com" `
            -EmailFrom "user@gmail.com" `
            -Subject "Test from Gmail" `
            -Body "Testing email via Gmail SMTP." `
            -SmtpServer "smtp.gmail.com" -SmtpPort 587
```



###    -------------------------- EXAMPLE 11 --------------------------
```Powershell
    PS > # Error handling with try-catch

    try {
        Send-Email -AuthUser "sender@company.com" -AuthPass "password" `
                -EmailTo "recipient@company.com" `
                -EmailFrom "sender@company.com" `
                -Subject "Test Email" -Body "Test message" `
                -SmtpServer "smtp.company.com"
        Write-Output "Email sent successfully!"
    catch {
        Write-Error "Failed to send email: $($_.Exception.Message)"
    }
```



###    -------------------------- EXAMPLE 12 --------------------------
```Powershell
    PS > # Mismatched names example (names will be stripped, emails used as display names)

    # This will work - emails will be used as display names since count doesn't match
    Send-Email -AuthUser "sender@company.com" -AuthPass "password" `
            -EmailTo "user1@company.com;user2@company.com;user3@company.com" `
            -EmailToName "User One;User Two" `
            -EmailFrom "sender@company.com" `
            -Subject "Name Mismatch Example" `
            -Body "Only first two names provided, all emails will use addresses as display names." `
            -SmtpServer "smtp.company.com"
```




RELATED LINKS
- [Source Code](https://github.com/Brandon-J-Navarro/Powershell_Email-Module)
- [PSGallery](https://www.powershellgallery.com/packages/EmailModule/)
- [MimeKit](https://github.com/jstedfast/MimeKit)
- [MailKit](https://github.com/jstedfast/MailKit)
