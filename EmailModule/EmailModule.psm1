. $PSScriptRoot\EmailModule.Libraries.ps1

function Send-Email {
    param (
        [Parameter(Mandatory = $true)]
        [string]
        # Specifies the username used to authenticate to the SMTP server.
        # This is typically the sender's email address (EmailFrom).
        $AuthUser,
        
        [Parameter(Mandatory = $true)]
        [string]
        # Specifies the password used to authenticate to the SMTP server.
        # Use secure methods (e.g. `Get-Credential`)to protect sensitive data when possible.
        $AuthPass,
        
        [Parameter(Mandatory = $true)]
        [string]
        # Specifies the recipient's email address.
        $EmailTo,
        
        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [string]
        # Specifies the display name of the recipient. Optional - if not provided, email address will be used.
        $EmailToName,
        
        [Parameter(Mandatory = $true)]   # You might want to change this to $false too
        [string]
        # Specifies the sender's email address.
        $EmailFrom,
        
        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [string]
        # Specifies the display name of the sender. Optional - if not provided, email address will be used.
        $EmailFromName,
        
        [Parameter(Mandatory = $true)]
        [string]
        # Specifies the subject line of the email.
        $Subject,
        
        [Parameter(Mandatory = $true)]
        [string]
        # Specifies the body content of the email message.
        # The message is sent as plain text.
        $Body,
        
        [Parameter(Mandatory = $true)]
        [string]
        # Specifies the hostname or fully qualified domain name (FQDN) of the SMTP server to connect to.
        $SmtpServer,
        
        [int]
        # Specifies the TCP port number used for the SMTP connection. The default is 587.
        $SmtpPort = 587
    )

    [EmailCommands]::SendEmail($AuthUser, $AuthPass, $EmailTo, $EmailToName, $EmailFrom, $EmailFromName, $Subject, $Body, $SmtpServer, $SmtpPort)

    <#
    .SYNOPSIS
    Sends an email message through an SMTP server with authentication using a compiled .NET email handler.

    .DESCRIPTION
    The Send-Email function provides an interface for sending email messages through SMTP using
    a .NET assembly that leverages the MimeKit and MailKit libraries. The underlying .NET class
    `EmailCommands` (defined in the module's EmailLibrary.dll) handles message creation,
    authentication, and secure transmission using STARTTLS.

    The Send-Email function provides a simple way to send email messages from PowerShell scripts.
    It supports SMTP authentication using a username and password, and allows you to specify
    the sender, recipient, subject, and body of the email.

    The supporting script `EmailModule.Libraries.ps1` dynamically loads the correct set of .NET assemblies
    depending on the current PowerShell edition:

    - When running on `PowerShell Core`, assemblies are loaded from:
        .\lib\Core\
    - When running on `Windows PowerShell (Desktop)`, assemblies are loaded from:
        .\lib\Desktop\

    This design ensures cross-platform compatibility and supports secure, authenticated email delivery
    from PowerShell scripts or automation environments.

    This PowerShell function serves as a wrapper that passes all user-supplied parameters to the
    EmailLibrary.dll assembly that contains the `EmailCommands` class and static method
    [EmailCommands]::SendEmail(), which constructs a MIME-compliant message and sends it
    using MailKit’s SmtpClient class. The connection is secured with STARTTLS, and credentials are
    authenticated using the provided username and password.

    .INPUTS
    None.
    All input must be supplied through parameters.

    .OUTPUTS
    None.
    This function does not return an object. The result of execution is the successful transmission

    .NOTES
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
            D:\lib\Core\      → PowerShell Core
            D:\lib\Desktop\   → Windows PowerShell Desktop

    All assemblies are automatically imported when the module is loaded.
    If a DLL fails to load, a warning will be displayed.

    The function relies on a .NET class implemented in C#, defined as:

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

    This class uses:
        - MimeKit for constructing MIME messages.
        - MailKit.Net.Smtp.SmtpClient for sending messages securely.
        - SecureSocketOptions.StartTls for encryption.

    Both MimeKit and MailKit must be available in the environment or included within the module's DLL.

    .EXAMPLE
    # Example usage:

    PS> $AuthUser =     "DoNotReply@Domain.com"
    PS> $AuthPass =     "YourPasswordHere"
    PS> $To =           "Recipient@Domain.com"
    PS> $ToName =       "Recipient Name"
    PS> $From =         "DoNotReply@Domain.com"
    PS> $FromName =     "Automation Service"
    PS> $Subject =      "System Notification"
    PS> $Body =         "This is a test email sent from the Email Module."
    PS> $MailServer =   "mail.domain.com"
    PS> $ServerPort =   587

    PS> Send-Email -AuthUser $AuthUser -AuthPass $AuthPass `
            -EmailTo $To -EmailToName $ToName `
            -EmailFrom $From -EmailFromName $FromName `
            -Subject $Subject -Body $Body `
            -SmtpServer $MailServer -SmtpPort $ServerPort

    .LINK
    Source Code: https://github.com/Brandon-J-Navarro/Powershell_Email-Module

    .LINK
    PSGallery: https://www.powershellgallery.com/packages/EmailModule/

    .LINK
    MimeKit: https://github.com/jstedfast/MimeKit

    .LINK
    MailKit: https://github.com/jstedfast/MailKit
    #>
}

Export-ModuleMember Send-Email
