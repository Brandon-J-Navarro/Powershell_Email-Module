// EmailLibrary.cs Console App .Net 8
using EmailLibrary;
using MailKit.Security;
using Microsoft.AspNetCore.StaticFiles;
using Microsoft.Extensions.Configuration;
using MimeKit;
using System.Net;
using System.Runtime.InteropServices;
using System.Security;

public class EmailCommands
{
    private static readonly IConfiguration _configuration = Startup.BuildConfiguation();

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

        mailMessage = BuildMailMessage(mailMessage, emailFrom, fromName, "FROM");
#if DEBUG
        Console.WriteLine("[DEBUG] Successfully added FROM.");
#endif

        mailMessage = BuildMailMessage(mailMessage, emailTo, toName, "TO");
#if DEBUG
        Console.WriteLine("[DEBUG] Successfully added TO recipients.");
#endif

        if (!(string.IsNullOrEmpty(emailCc)))
        {
            mailMessage = BuildMailMessage(mailMessage, emailCc, ccName, "CC");
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
            mailMessage = BuildMailMessage(mailMessage, emailBcc, bccName, "BCC");
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

        using var smtpClient = new MailKit.Net.Smtp.SmtpClient();
#if DEBUG
        Console.WriteLine("[DEBUG] Connecting to SMTP server...");
#endif

#if DEBUG
        Console.WriteLine($"[DEBUG] MailServer: {mailServer}:{serverPort}");
#endif

        if (Environment.GetEnvironmentVariable("CI") == "true" && RuntimeInformation.IsOSPlatform(OSPlatform.OSX))
        {
            smtpClient.ServerCertificateValidationCallback = (sender, certificate, chain, sslPolicyErrors) =>
            {
#if DEBUG
                Console.WriteLine("[DEBUG] macOS CI detected – bypassing partial revocation SSL errors.");
#endif
                if (sslPolicyErrors == System.Net.Security.SslPolicyErrors.RemoteCertificateChainErrors &&
                    chain?.ChainStatus?.Any(s => s.Status == System.Security.Cryptography.X509Certificates.X509ChainStatusFlags.RevocationStatusUnknown) == true)
                {
                    return true;
                }

                return sslPolicyErrors == System.Net.Security.SslPolicyErrors.None;
            };
        }

        smtpClient.Connect(mailServer, serverPort, SecureSocketOptions.StartTls);
#if DEBUG
        Console.WriteLine("[DEBUG] Connected to SMTP server.");
        Console.WriteLine($"[DEBUG] Is Connected: {smtpClient.IsConnected}");
        Console.WriteLine($"[DEBUG] Is Encrypted: {smtpClient.IsEncrypted}");
        Console.WriteLine($"[DEBUG] Is Secure: {smtpClient.IsSecure}");
        Console.WriteLine($"[DEBUG] Ssl Cipher Algorithm: {smtpClient.SslCipherAlgorithm}");
        Console.WriteLine($"[DEBUG] Ssl Cipher Suite: {smtpClient.SslCipherSuite}");
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
        return mailSent;
    }

    static private NetworkCredential CreateAuthCreds(string userName, object password)
    {
#if DEBUG
        Console.WriteLine("[DEBUG] Creating authentication credentials...");
#endif
        NetworkCredential credentials = password switch
        {
            string stringPassword => new NetworkCredential(userName, stringPassword),
            SecureString securePassword => new NetworkCredential(userName, securePassword),
            _ => throw new ArgumentException("Password must be either string or SecureString", nameof(password)),
        };
        if (password is string)
        {
#if DEBUG
            Console.WriteLine($"[DEBUG] Using Authentication Password of Type string to create Credentials.");
#endif
        }
        else if (password is SecureString)
        {
#if DEBUG
            Console.WriteLine($"[DEBUG] Using Authentication Password of Type SecureString to create Credentials.");
#endif
        }
#if DEBUG
        Console.WriteLine("[DEBUG] Authentication credentials created.");
#endif
        return credentials;
    }

    static internal MimeMessage BuildMailMessage(MimeMessage mailMessage, string emailAddress, string? emailName, string mailboxLine)
    {
        if (mailboxLine.Equals("FROM"))
        {
#if DEBUG
            Console.WriteLine($"[DEBUG] Building '{mailboxLine}' address");
#endif
            mailMessage.From.Add(string.IsNullOrEmpty(emailName)
                ? new MailboxAddress(emailAddress, emailAddress)
                : new MailboxAddress(emailName, emailAddress));

            if (!(string.IsNullOrEmpty(emailName)))
            {
#if DEBUG
                Console.WriteLine($"[DEBUG] Added '{mailboxLine}' recipient(s). Name: {emailName} Email: {emailAddress}");
#endif
            }
            else
            {
#if DEBUG
                Console.WriteLine($"[DEBUG] No '{mailboxLine}' Name Added, set to string.Empty.");
                Console.WriteLine($"[DEBUG] Added '{mailboxLine}' recipient(s). Name: {emailAddress} Email: {emailAddress}");
#endif
            }

            return mailMessage;
        }
        else
        {
#if DEBUG
            Console.WriteLine($"[DEBUG] Building '{mailboxLine}' address(es)");
#endif
            var EmailRecipient = emailAddress.Split(';');
            if (string.IsNullOrEmpty(emailName))
            {
#if DEBUG
                Console.WriteLine($"[DEBUG] '{mailboxLine}' Name is NULL or Empty String using Email Address as the Name");
#endif
                for (int i = 0; i < EmailRecipient.Length; i++)
                {
                    if (mailboxLine.Equals("TO"))
                    {
                        mailMessage.To.Add(new MailboxAddress(EmailRecipient[i], EmailRecipient[i]));
                    }
                    else if (mailboxLine.Equals("CC"))
                    {
                        mailMessage.Cc.Add(new MailboxAddress(EmailRecipient[i], EmailRecipient[i]));
                    }
                    else if (mailboxLine.Equals("BCC"))
                    {
                        mailMessage.Bcc.Add(new MailboxAddress(EmailRecipient[i], EmailRecipient[i]));
                    }
#if DEBUG
                    Console.WriteLine($"[DEBUG] Added '{mailboxLine}' recipient(s). Name: {EmailRecipient[i]} Email: {EmailRecipient[i]}");
#endif
                }
            }
            else
            {
                var EmailRecipientName = emailName.Split(';');
                for (int i = 0; i < EmailRecipient.Length; i++)
                {
                    if (EmailRecipientName.Length < EmailRecipient.Length || EmailRecipientName.Length > EmailRecipient.Length)
                    {
                        if (mailboxLine.Equals("TO"))
                        {
                            mailMessage.To.Add(new MailboxAddress(EmailRecipient[i], EmailRecipient[i]));
                        }
                        else if (mailboxLine.Equals("CC"))
                        {
                            mailMessage.Cc.Add(new MailboxAddress(EmailRecipient[i], EmailRecipient[i]));
                        }
                        else if (mailboxLine.Equals("BCC"))
                        {
                            mailMessage.Bcc.Add(new MailboxAddress(EmailRecipient[i], EmailRecipient[i]));
                        }
#if DEBUG
                        Console.WriteLine($"[DEBUG] The Amount of Name(s) and Eamil Address(es) do not match, using Email Address as the Name");
                        Console.WriteLine($"[DEBUG] Added '{mailboxLine}' recipient(s). Name: {EmailRecipient[i]} Email: {EmailRecipient[i]}");
#endif
                    }
                    else if (EmailRecipientName.Length == EmailRecipient.Length)
                    {
                        if (mailboxLine.Equals("TO"))
                        {
                            mailMessage.To.Add(new MailboxAddress(EmailRecipient[i], EmailRecipient[i]));
                        }
                        else if (mailboxLine.Equals("CC"))
                        {
                            mailMessage.Cc.Add(new MailboxAddress(EmailRecipient[i], EmailRecipient[i]));
                        }
                        else if (mailboxLine.Equals("BCC"))
                        {
                            mailMessage.Bcc.Add(new MailboxAddress(EmailRecipient[i], EmailRecipient[i]));
                        }
#if DEBUG
                        Console.WriteLine($"[DEBUG] Added '{mailboxLine}' recipients. Name: {EmailRecipientName[i]} Email: {EmailRecipient[i]}");
#endif
                    }
                }
            }
            return mailMessage;
        }
    }

    static void Main(string[] args)
    {
#if DEBUG
        Console.WriteLine("[DEBUG] Loading configuration values...");
#endif
        string AuthUser = _configuration["EmailParameters:AuthUser"];
        object AuthPass = _configuration["EmailParameters:AuthPass"];
        string EmailTo = _configuration["EmailParameters:EmailTo"];
        string EmailToName = _configuration["EmailParameters:EmailToName"];
        string EmailFrom = _configuration["EmailParameters:EmailFrom"];
        string EmailFromName = _configuration["EmailParameters:EmailFromName"];
        string Subject = _configuration["EmailParameters:Subject"];
        string Body = _configuration["EmailParameters:Body"];
        string SmtpServer = _configuration["EmailParameters:SmtpServer"];
        string SmtpPort = _configuration["EmailParameters:SmtpPort"];
        string EmailCc = _configuration["EmailParameters:EmailCc"];
        string CcName = _configuration["EmailParameters:CcName"];
        string EmailBcc = _configuration["EmailParameters:EmailBcc"];
        string BccName = _configuration["EmailParameters:BccName"];
        string EmailAttachment = _configuration["EmailParameters:EmailAttachment"];
        string EmailPriority = _configuration["EmailParameters:EmailPriority"];
        string EmailImportance = _configuration["EmailParameters:EmailImportance"];
#if DEBUG
        Console.WriteLine("[DEBUG] Configuration loaded. Beginning SendEmail call...");
#endif
        SendEmail(
            AuthUser,
            AuthPass,
            EmailTo,
            EmailToName,
            EmailFrom,
            EmailFromName,
            Subject,
            Body,
            SmtpServer,
            Convert.ToInt16(SmtpPort),
            EmailCc,
            CcName,
            EmailBcc,
            BccName,
            EmailAttachment,
            EmailPriority,
            EmailImportance
        );
#if DEBUG
        Console.WriteLine("[DEBUG] Email process completed.");
#endif
    }
}
