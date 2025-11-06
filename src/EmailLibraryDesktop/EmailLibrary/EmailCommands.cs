// EmailCommands.cs .dotNET Framework 4.7.2
using MailKit.Security;
using Microsoft.AspNetCore.StaticFiles;
using MimeKit;
using System;
using System.IO;
using System.Linq;
using System.Net;
using System.Runtime.InteropServices;
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

        mailMessage = BuildMailMessage(mailMessage, emailFrom, fromName, "FROM");
        Debug("Successfully added FROM.");

        mailMessage = BuildMailMessage(mailMessage, emailTo, toName, "TO");
        Debug("Successfully added TO recipients.");

        if (!(string.IsNullOrEmpty(emailCc)))
        {
            mailMessage = BuildMailMessage(mailMessage, emailCc, ccName, "CC");
        }
        Debug(!string.IsNullOrEmpty(emailCc) ? "Successfully added CC recipients." : "No CC Added.");

        if (!(string.IsNullOrEmpty(emailBcc)))
        {
            mailMessage = BuildMailMessage(mailMessage, emailBcc, bccName, "BCC");
        }
        Debug(!string.IsNullOrEmpty(emailBcc) ? "Successfully added BCC recipients." : "No BCC Added.");

        if (!(string.IsNullOrEmpty(emailPriority)))
        {
            mailMessage.Priority = (MessagePriority)System.Enum.Parse(typeof(MessagePriority), emailPriority);
        }
        Debug(!string.IsNullOrEmpty(emailPriority) ? $"Email PRIORITY set to: {emailPriority}" : "No PRIORITY set.");

        if (!string.IsNullOrEmpty(emailImportance))
        {
            mailMessage.Importance = (MessageImportance)System.Enum.Parse(typeof(MessageImportance), emailImportance);
        }
        Debug(!string.IsNullOrEmpty(emailImportance) ? $"Email IMPORTANCE set to: {emailImportance}" : "No IMPORTANCE set.");

        mailMessage.Subject = emailSubject ?? string.Empty;
        Debug(string.IsNullOrEmpty(emailSubject) ? "No SUBJECT Added, set to string.Empty." : $"SUBJECT Added: {emailSubject}");

        if (!(string.IsNullOrEmpty(emailAttachment)))
        {
            Debug($"Attachment found: {emailAttachment} (currently not attached in this version)");
            var body = new TextPart("plain")
            {
                Text = emailBody ?? string.Empty
            };

            var multipart = new Multipart("mixed");
            multipart.Add(body);
            Debug("Created multipart container and added email body.");

            if (!string.IsNullOrEmpty(emailAttachment) && File.Exists(emailAttachment))
            {
                Debug($"Attachment file exists at path: {emailAttachment}");
                const string DefaultContentType = "application/octet-stream";
                var provider = new FileExtensionContentTypeProvider();

                if (!provider.TryGetContentType(emailAttachment, out string contentType))
                {
                    Debug($"Could not determine MIME type for '{emailAttachment}'. Defaulting to '{DefaultContentType}'.");
                    contentType = DefaultContentType;
                }
                else
                {
                    Debug($"Determined MIME type for '{emailAttachment}': {contentType}");
                }

                var stream = File.OpenRead(emailAttachment);
                Debug($"Opened file stream for attachment: {emailAttachment}");

                var attachment = new MimePart(contentType)
                {
                    Content = new MimeContent(stream, ContentEncoding.Default),
                    ContentDisposition = new ContentDisposition(ContentDisposition.Attachment),
                    ContentTransferEncoding = ContentEncoding.Base64,
                    FileName = Path.GetFileName(emailAttachment)
                };
                Debug($"Created MimePart for attachment: {attachment.FileName}");

                multipart.Add(attachment);
                Debug("Added attachment to multipart message.");
            }
            else
            {
                Debug($"Attachment file not found at path: {emailAttachment}");
            }
            mailMessage.Body = multipart;
            Debug("Set multipart message (body + attachments) as email body.");

            Debug(string.IsNullOrEmpty(emailBody) ? "No BODY Added, set to string.Empty." : $"BODY Added: {emailBody}");
        }
        else
        {
            mailMessage.Body = new TextPart("plain")
            {
                Text = emailBody ?? string.Empty
            };
            Debug(string.IsNullOrEmpty(emailBody)
                ? "No BODY Added, set to string.Empty."
                : $"BODY Added: {emailBody}");
        }


        Debug("Email composed successfully.");
        Debug("Mail Message contents.");
        Debug($"{mailMessage}");

        var smtpClient = new MailKit.Net.Smtp.SmtpClient();
        Debug("Connecting to SMTP server...");
        Debug($"MailServer: {mailServer}:{serverPort}");

        if (Environment.GetEnvironmentVariable("CI") == "true" && RuntimeInformation.IsOSPlatform(OSPlatform.OSX))
        {
            smtpClient.ServerCertificateValidationCallback = (sender, certificate, chain, sslPolicyErrors) =>
            {
                Debug("macOS CI detected – bypassing partial revocation SSL errors.");
                if (sslPolicyErrors == System.Net.Security.SslPolicyErrors.RemoteCertificateChainErrors &&
                    chain?.ChainStatus?.Any(s => s.Status == System.Security.Cryptography.X509Certificates.X509ChainStatusFlags.RevocationStatusUnknown) == true)
                {
                    return true;
                }
                return sslPolicyErrors == System.Net.Security.SslPolicyErrors.None;
            };
        }

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
