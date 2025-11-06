// EmailCommands.cs .dotNET Framework 4.7.2
using EmailLibrary;
using MailKit.Security;
using MimeKit;
using System;
using System.Net;
using static EmailLibrary.Builders;
using static EmailLibrary.Log;

public class EmailCommands
{
    public static object SendEmail(
        string authUser, object authPass,
        string emailTo, string? toName,
        string emailFrom, string? fromName,
        string? emailSubject, string? emailBody,
        string mailServer, int serverPort,
        string? emailCc, string? ccName,
        string? emailBcc, string? bccName,
        string? emailAttachment, string? emailPriority,
        string? emailImportance)
    {
        Debug("Starting SendEmail...");

        NetworkCredential credentials = CreateAuthCreds(authUser, authPass);
        Debug("Credentials created successfully.");

        var mailMessage = new MimeMessage();
        Debug("Creating Mail Message...");

        AddRecipients(mailMessage, emailFrom, fromName, MailboxType.From, true);
        AddRecipients(mailMessage, emailTo, toName, MailboxType.To, true);
        AddRecipients(mailMessage, emailCc, ccName, MailboxType.Cc, false);
        AddRecipients(mailMessage, emailBcc, bccName, MailboxType.Bcc, false);

        if (!string.IsNullOrEmpty(emailPriority))
            mailMessage.Priority = (MessagePriority)Enum.Parse(typeof(MessagePriority), emailPriority);
        if (!string.IsNullOrEmpty(emailImportance))
            mailMessage.Importance = (MessageImportance)Enum.Parse(typeof(MessageImportance), emailImportance);
        mailMessage.Subject = emailSubject ?? string.Empty;

        Debug($"Email PRIORITY {(!string.IsNullOrEmpty(emailPriority) ? $"set to: {emailPriority}" : "not set.")}");
        Debug($"Email IMPORTANCE {(!string.IsNullOrEmpty(emailImportance) ? $"set to: {emailImportance}" : "not set.")}");
        Debug($"{(string.IsNullOrEmpty(emailSubject) ? "No SUBJECT Added, set to string.Empty." : $"SUBJECT Added: {emailSubject}")}");

        mailMessage = SetEmailBody(mailMessage, emailBody, emailAttachment);

        Debug("Email composed successfully.");
        Debug("Mail Message contents.");
        Debug($"{mailMessage}");

        using var smtpClient = new MailKit.Net.Smtp.SmtpClient();
        Debug("Connecting to SMTP server...");
        Debug($"MailServer: {mailServer}:{serverPort}");

        smtpClient.Connect(mailServer, serverPort, SecureSocketOptions.StartTls);
        Debug("Connected to SMTP server.");
        Debug($"Is Connected: {smtpClient.IsConnected}");
        Debug($"Is Encrypted: {smtpClient.IsEncrypted}");
        Debug($"Is Secure: {smtpClient.IsSecure}");
        Debug($"Ssl Cipher Algorithm: {smtpClient.SslCipherAlgorithm}");
        Debug($"Ssl Hash Algorithm: {smtpClient.SslHashAlgorithm}");
        Debug($"Ssl Protocol: {smtpClient.SslProtocol}");

        smtpClient.Authenticate(credentials);
        Debug("Authenticated successfully.");
        Debug($"Is Authenticated: {smtpClient.IsAuthenticated}");

        var mailSent = smtpClient.Send(mailMessage);
        Debug("Email sent successfully.");
        Debug($"{mailSent}");

        smtpClient.Disconnect(true);
        Debug("SMTP client disconnected.");

        smtpClient.Dispose();
        Debug("SMTP client disposed.");

        return mailSent;
    }
}
