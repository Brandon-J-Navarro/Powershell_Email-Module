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
        
        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [string]
        # Specifies the subject line of the email.
        $Subject,
        
        [Parameter(Mandatory = $false)]
        [AllowNull()]
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
        $SmtpPort = 587,

        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [object]
        $EmailCc = $null,

        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [object]
        $CcName = $null,

        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [object]
        $EmailBcc = $null,

        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [object]
        $BccName = $null,

        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [string]
        $EmailAttachment = $null
    )

    [EmailCommands]::SendEmail(
        $AuthUser,
        $AuthPass,
        $EmailTo,
        $EmailToName,
        $EmailFrom,
        $EmailFromName,
        $Subject,
        $Body,
        $SmtpServer,
        $SmtpPort,
        $EmailCc,
        $CcName,
        $EmailBcc,
        $BccName,
        $EmailAttachment
    )

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
        .\lib\net8.0\
    - When running on `Windows PowerShell (Desktop)`, assemblies are loaded from:
        .\lib\net472\

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
            EmailModule\lib\net8.0\      → PowerShell Core
            EmailModule\lib\net472\   → Windows PowerShell Desktop

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

    .EXAMPLE
    # Example usage:

    PS> $AuthUser =     "DoNotReply@Domain.com"
    PS> $AuthPass =     "YourPasswordHere"
    PS> $To =           "Recipient@Domain.com"
    PS> $From =         "DoNotReply@Domain.com"
    PS> $Subject =      "System Notification"
    PS> $Body =         "This is a test email sent from the Email Module."
    PS> $MailServer =   "mail.domain.com"
    PS> $ServerPort =   587

    Send-Email -AuthUser $AuthUser -AuthPass $AuthPass `
        -EmailTo $To -EmailFrom $From  `
        -Subject $Subject -Body $Body `
        -SmtpServer $MailServer -SmtpPort $ServerPort

    .EXAMPLE

    PS> $AuthUser =     "DoNotReply@Domain.com"
    PS> $AuthPass =     "YourPasswordHere"
    PS> $To =           "Recipient1@Domain.com;Recipient2@Domain.com"
    PS> $ToName =       "Recipient1;Recipient2"
    PS> $From =         "DoNotReply@Domain.com"
    PS> $FromName =     "Automation Service"
    PS> $Subject =      "System Notification"
    PS> $Body =         "This is a test email sent from the Email Module."
    PS> $MailServer =   "mail.domain.com"
    PS> $ServerPort =   587
    PS> $Cc =           "Recipient3@Domain.com"
    PS> $CcName =       "Recipient3"
    PS> $Bcc =          "Recipient4@Domain.com"
    PS> $BccName =      "Recipient4"


    Send-Email -AuthUser $AuthUser -AuthPass $AuthPass `
        -EmailTo $To -EmailToName $ToName `
        -EmailFrom $From -EmailFromName $FromName `
        -Subject $Subject -Body $Body `
        -SmtpServer $MailServer -SmtpPort $ServerPort `
        -EmailCc $Cc -CcName $CcName `
        -EmailBcc $Bcc -BccName $BccName `
        -EmailAttachment $null


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


# Show banner after module is imported (optional)
if (-not (Test-Path variable:global:EmailModule_BannerShown)) {
    $global:EmailModule_BannerShown = $true
    Get-Banner
}
