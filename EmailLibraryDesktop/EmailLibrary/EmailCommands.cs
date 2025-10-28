// EmailCommands.cs .dotNET Framework 4.7.2
using MimeKit;
using MailKit.Security;
using System.Net;
using System;
using Microsoft.AspNetCore.StaticFiles;
using System.IO;
using static EmailLibrary.Builders;

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
#if DEBUG
        Console.WriteLine("[DEBUG] Starting SendEmail...");
#endif

        NetworkCredential credentials = CreateAuthCreds(authUser, authPass);
#if DEBUG
        Console.WriteLine("[DEBUG] Credentials created successfully.");
#endif

        var mailMessage = new MimeMessage();
#if DEBUG
        Console.WriteLine("[DEBUG] Creating Mail Message...");
#endif

        mailMessage = BuildMailMessageFrom(mailMessage, emailFrom, fromName);
#if DEBUG
        Console.WriteLine("[DEBUG] Successfully added FROM.");
#endif

        mailMessage = BuildMailMessageTo(mailMessage, emailTo, toName);
#if DEBUG
        Console.WriteLine("[DEBUG] Successfully added TO recipients.");
#endif

        if (!(string.IsNullOrEmpty(emailCc)))
        {
            mailMessage = BuildMailMessageCc(mailMessage, emailCc, ccName);
#if DEBUG
            Console.WriteLine("[DEBUG] Successfully added CC recipients.");
#endif
        }
        else
        {
#if DEBUG
            Console.WriteLine("[DEBUG] No CC Added.");
#endif
        }

        if (!(string.IsNullOrEmpty(emailBcc)))
        {
            mailMessage = BuildMailMessageBcc(mailMessage, emailBcc, bccName);
#if DEBUG
            Console.WriteLine("[DEBUG] Successfully added BCC recipients.");
#endif
        }
        else
        {
#if DEBUG
            Console.WriteLine("[DEBUG] No BCC Added.");
#endif
        }

        if (!(string.IsNullOrEmpty(emailPriority)))
        {
            mailMessage.Priority = (MessagePriority)System.Enum.Parse(typeof(MessagePriority), emailPriority);
#if DEBUG

            Console.WriteLine($"[DEBUG] Email PRIORITY set to: {emailPriority}");
#endif
        }
        else
        {
#if DEBUG
            Console.WriteLine("[DEBUG] No PRIORITY set.");
#endif
        }

        if (!(string.IsNullOrEmpty(emailImportance)))
        {
            mailMessage.Importance = (MessageImportance)System.Enum.Parse(typeof(MessageImportance), emailImportance);
#if DEBUG
            Console.WriteLine($"[DEBUG] Email IMPORTANCE set to: {emailImportance}");
#endif
        }
        else
        {
#if DEBUG
            Console.WriteLine("[DEBUG] No IMPORTANCE set.");
#endif
        }

        if (!(string.IsNullOrEmpty(emailSubject)))
        {
            mailMessage.Subject = emailSubject;
#if DEBUG
            Console.WriteLine($"[DEBUG] SUBJECT Added: {emailSubject}");
#endif
        }
        else
        {
            mailMessage.Subject = string.Empty;
#if DEBUG
            Console.WriteLine("[DEBUG] No SUBJECT Added, set to string.Empty.");
#endif
        }

        if (!(string.IsNullOrEmpty(emailAttachment)))
        {
#if DEBUG
            Console.WriteLine($"[DEBUG] Attachment found: {emailAttachment} (currently not attached in this version)");
#endif
            var body = new TextPart("plain")
            {
                Text = emailBody ?? string.Empty
            };

            var multipart = new Multipart("mixed");
            multipart.Add(body);
#if DEBUG
            Console.WriteLine("[DEBUG] Created multipart container and added email body.");
#endif

            if (!string.IsNullOrEmpty(emailAttachment) && File.Exists(emailAttachment))
            {
#if DEBUG
                Console.WriteLine($"[DEBUG] Attachment file exists at path: {emailAttachment}");
#endif
                const string DefaultContentType = "application/octet-stream";
                var provider = new FileExtensionContentTypeProvider();

                if (!provider.TryGetContentType(emailAttachment, out string contentType))
                {
#if DEBUG
                    Console.WriteLine($"[DEBUG] Could not determine MIME type for '{emailAttachment}'. Defaulting to '{DefaultContentType}'.");
#endif
                    contentType = DefaultContentType;
                }
                else
                {
#if DEBUG
                    Console.WriteLine($"[DEBUG] Determined MIME type for '{emailAttachment}': {contentType}");
#endif
                }

                var stream = File.OpenRead(emailAttachment);
#if DEBUG
                Console.WriteLine($"[DEBUG] Opened file stream for attachment: {emailAttachment}");
#endif

                var attachment = new MimePart(contentType)
                {
                    Content = new MimeContent(stream, ContentEncoding.Default),
                    ContentDisposition = new ContentDisposition(ContentDisposition.Attachment),
                    ContentTransferEncoding = ContentEncoding.Base64,
                    FileName = Path.GetFileName(emailAttachment)
                };
#if DEBUG
                Console.WriteLine($"[DEBUG] Created MimePart for attachment: {attachment.FileName}");
#endif

                multipart.Add(attachment);
#if DEBUG
                Console.WriteLine("[DEBUG] Added attachment to multipart message.");
#endif
            }
            else
            {
#if DEBUG
                Console.WriteLine($"[DEBUG] Attachment file not found at path: {emailAttachment}");
#endif
            }
            mailMessage.Body = multipart;
#if DEBUG
            Console.WriteLine("[DEBUG] Set multipart message (body + attachments) as email body.");
#endif

            if (!(string.IsNullOrEmpty(emailBody)))
            {
#if DEBUG
                Console.WriteLine($"[DEBUG] BODY Added: {emailBody}");
#endif
            }
            else
            {
#if DEBUG
                Console.WriteLine("[DEBUG] No BODY Added, set to string.Empty.");
#endif
            }
        }
        else
        {
            mailMessage.Body = new TextPart("plain")
            {
                Text = emailBody ?? string.Empty
            };
            if (!(string.IsNullOrEmpty(emailBody)))
            {
#if DEBUG
                Console.WriteLine($"[DEBUG] BODY Added: {emailBody}");
#endif
            }
            else
            {
#if DEBUG
                Console.WriteLine("[DEBUG] No BODY Added, set to string.Empty.");
#endif
            }
        }


#if DEBUG
        Console.WriteLine("[DEBUG] Email composed successfully.");
        Console.WriteLine("[DEBUG] Mail Message contents.");
        Console.WriteLine($"[DEBUG] {mailMessage}");
#endif

        var smtpClient = new MailKit.Net.Smtp.SmtpClient();
#if DEBUG
        Console.WriteLine("[DEBUG] Connecting to SMTP server...");
#endif

#if DEBUG
        Console.WriteLine($"[DEBUG] MailServer: {mailServer}:{serverPort}");
#endif

        smtpClient.Connect(mailServer, serverPort, SecureSocketOptions.StartTls);
#if DEBUG
        Console.WriteLine("[DEBUG] Connected to SMTP server.");
        Console.WriteLine($"[DEBUG] Is Connected: {smtpClient.IsConnected}");
        Console.WriteLine($"[DEBUG] Is Encrypted: {smtpClient.IsEncrypted}");
        Console.WriteLine($"[DEBUG] Is Secure: {smtpClient.IsSecure}");
        Console.WriteLine($"[DEBUG] Ssl Cipher Algorithm: {smtpClient.SslCipherAlgorithm}");
        Console.WriteLine($"[DEBUG] Ssl Hash Algorithm: {smtpClient.SslHashAlgorithm}");
        Console.WriteLine($"[DEBUG] Ssl Protocol: {smtpClient.SslProtocol}");
#endif

        smtpClient.Authenticate(credentials);
#if DEBUG
        Console.WriteLine("[DEBUG] Authenticated successfully.");
        Console.WriteLine($"[DEBUG] Is Authenticated: {smtpClient.IsAuthenticated}");
#endif

        var mailSent = smtpClient.Send(mailMessage);
#if DEBUG
        Console.WriteLine("[DEBUG] Email sent successfully.");
        Console.WriteLine($"[DEBUG] {mailSent}");
#endif

        smtpClient.Disconnect(true);
#if DEBUG
        Console.WriteLine("[DEBUG] SMTP client disconnected.");
#endif

        smtpClient.Dispose();
#if DEBUG
        Console.WriteLine("[DEBUG] SMTP client disposed.");
#endif

        return mailSent;
    }
}
