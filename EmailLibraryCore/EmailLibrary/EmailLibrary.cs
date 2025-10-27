// EmailLibrary.cs dotNET Core 8.0
using MailKit.Security;
using Microsoft.AspNetCore.StaticFiles;
using MimeKit;
using System.Net;
using System.Security;

public class EmailCommands
{
    public static void SendEmail(
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
            //mailMessage.Subject = emailSubject ?? string.Empty;
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
            //    var body = new TextPart("plain")
            //    {
            //        Text = emailBody ?? string.Empty
            //    };

            //    // create an image attachment for the file located at path
            //    const string DefaultContentType = "application/octet-stream";
            //    var provider = new FileExtensionContentTypeProvider();
            //    if (!provider.TryGetContentType(emailAttachment, out string contentType))
            //    {
            //        contentType = DefaultContentType;
            //    }

            //    var attachment = new MimePart(contentType)
            //    {
            //        Content = new MimeContent(File.OpenRead(emailAttachment), ContentEncoding.Default),
            //        ContentDisposition = new ContentDisposition(ContentDisposition.Attachment),
            //        ContentTransferEncoding = ContentEncoding.Base64,
            //        FileName = Path.GetFileName(emailAttachment)
            //    };

            //    // now create the multipart/mixed container to hold the message text and the
            //    // image attachment
            //    var multipart = new Multipart("mixed");
            //    multipart.Add(body);
            //    multipart.Add(attachment);

            //    // now set the multipart/mixed as the message body
            //    mailMessage.Body = multipart;
            //}
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
        //Console.WriteLine($"[DEBUG] Is Connected: {smtpClient.IsConnected}");
        //Console.WriteLine($"[DEBUG] Is Encrypted: {smtpClient.IsEncrypted}");
        //Console.WriteLine($"[DEBUG] Is Secure: {smtpClient.IsSecure}");
        //Console.WriteLine($"[DEBUG] Protocol: {smtpClient.Protocol}");
        //Console.WriteLine($"[DEBUG] Ssl Cipher Algorithm: {smtpClient.SslCipherAlgorithm}");
        //Console.WriteLine($"[DEBUG] Ssl Cipher Suite: {smtpClient.SslCipherSuite}");
        //Console.WriteLine($"[DEBUG] Ssl Hash Algorithm: {smtpClient.SslHashAlgorithm}");
        //Console.WriteLine($"[DEBUG] Ssl Protocol: {smtpClient.SslProtocol}");
#endif

        var mailSent = smtpClient.Send(mailMessage);
#if DEBUG
        Console.WriteLine("[DEBUG] Email sent successfully.");
        Console.WriteLine($"[DEBUG] {mailSent}");
#else
        Console.WriteLine($"[Response]: {mailSent}");
#endif

        smtpClient.Disconnect(true);
#if DEBUG
        Console.WriteLine("[DEBUG] SMTP client disconnected.");
#endif
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

    static private MimeMessage BuildMailMessageFrom(MimeMessage mailMessage, string emailFrom, string? fromName)
    {
#if DEBUG
        Console.WriteLine("[DEBUG] Building 'From' address");
#endif
        mailMessage.From.Add(string.IsNullOrEmpty(fromName)
            ? new MailboxAddress(emailFrom, emailFrom)
            : new MailboxAddress(fromName, emailFrom));

        if (!(string.IsNullOrEmpty(fromName)))
        {
#if DEBUG
            Console.WriteLine($"[DEBUG] Added FROM recipient(s). Name: {fromName} Email: {emailFrom}");
#endif
        }
        else
        {
#if DEBUG
            Console.WriteLine("[DEBUG] No FROM Name Added, set to string.Empty.");
            Console.WriteLine($"[DEBUG] Added FROM recipient(s). Name: {emailFrom} Email: {emailFrom}");
#endif
        }

        return mailMessage;
    }

    static private MimeMessage BuildMailMessageTo(MimeMessage mailMessage, string emailTo, string? toName)
    {
#if DEBUG
        Console.WriteLine("[DEBUG] Building 'To' address(es)");
#endif
        var EmailRecipientTo = emailTo.Split(';');
        if (string.IsNullOrEmpty(toName))
        {
#if DEBUG
            Console.WriteLine($"[DEBUG] TO Name is NULL or Empty String using Email Address as the Name");
#endif
            for (int i = 0; i < EmailRecipientTo.Length; i++)
            {
#if DEBUG
                Console.WriteLine($"[DEBUG] Added TO recipient(s). Name: {EmailRecipientTo[i]} Email: {EmailRecipientTo[i]}");
#endif
                mailMessage.To.Add(new MailboxAddress(EmailRecipientTo[i], EmailRecipientTo[i]));
            }
        }
        else
        {
            var EmailRecipientToName = toName.Split(';');
            for (int i = 0; i < EmailRecipientTo.Length; i++)
            {
                if (EmailRecipientToName.Length < EmailRecipientTo.Length || EmailRecipientToName.Length > EmailRecipientTo.Length)
                {
#if DEBUG
                    Console.WriteLine($"[DEBUG] The Amount of Name(s) and Eamil Address(es) do not match, using Email Address as the Name");
                    Console.WriteLine($"[DEBUG] Added TO recipient(s). Name: {EmailRecipientTo[i]} Email: {EmailRecipientTo[i]}");
#endif
                    mailMessage.To.Add(new MailboxAddress(EmailRecipientTo[i], EmailRecipientTo[i]));
                }
                else if (EmailRecipientToName.Length == EmailRecipientTo.Length)
                {
#if DEBUG
                    Console.WriteLine($"[DEBUG] Added TO recipient(s). Name: {EmailRecipientToName[i]} Email: {EmailRecipientTo[i]}");
#endif
                    mailMessage.To.Add(new MailboxAddress(EmailRecipientToName[i], EmailRecipientTo[i]));
                }
            }
        }
        return mailMessage;
    }

    static private MimeMessage BuildMailMessageCc(MimeMessage mailMessage, string emailCc, string? ccName)
    {
#if DEBUG
        Console.WriteLine("[DEBUG] Building 'CC' address(es)}");
#endif

        var EmailRecipientCc = emailCc.Split(';');
        if (string.IsNullOrEmpty(ccName))
        {
#if DEBUG
            Console.WriteLine($"[DEBUG] CC Name is NULL or Empty String using Email Address as the Name");
#endif
            for (int i = 0; i < EmailRecipientCc.Length; i++)
            {
#if DEBUG
                Console.WriteLine($"[DEBUG] Added CC recipient(s). Name: {EmailRecipientCc[i]} Email: {EmailRecipientCc[i]}");
#endif
                mailMessage.To.Add(new MailboxAddress(EmailRecipientCc[i], EmailRecipientCc[i]));
            }
        }
        else
        {
            var EmailRecipientCcName = ccName.Split(';');
            for (int i = 0; i < EmailRecipientCc.Length; i++)
            {
                if (EmailRecipientCcName.Length < EmailRecipientCc.Length || EmailRecipientCcName.Length > EmailRecipientCc.Length)
                {
#if DEBUG
                    Console.WriteLine($"[DEBUG] The Amount of Name(s) and Eamil Address(es) do not match, using Email Address as the Name");
                    Console.WriteLine($"[DEBUG] Added CC recipient(s). Name: {EmailRecipientCc[i]} Email: {EmailRecipientCc[i]}");
#endif
                    mailMessage.To.Add(new MailboxAddress(EmailRecipientCc[i], EmailRecipientCc[i]));
                }
                else if (EmailRecipientCcName.Length == EmailRecipientCc.Length)
                {
#if DEBUG
                    Console.WriteLine($"[DEBUG] Added CC recipients. Name: {EmailRecipientCcName[i]} Email: {EmailRecipientCc[i]}");
#endif
                    mailMessage.To.Add(new MailboxAddress(EmailRecipientCcName[i], EmailRecipientCc[i]));
                }
            }
        }
        return mailMessage;
    }

    static private MimeMessage BuildMailMessageBcc(MimeMessage mailMessage, string emailBcc, string? bccName)
    {
#if DEBUG
        Console.WriteLine("[DEBUG] Building 'BCC' address(es)");
#endif

        var EmailRecipientBcc = emailBcc.Split(';');
        if (string.IsNullOrEmpty(bccName))
        {
#if DEBUG
            Console.WriteLine($"[DEBUG] BCC Name is NULL or Empty String using Email Address as the Name");
#endif
            for (int i = 0; i < EmailRecipientBcc.Length; i++)
            {
#if DEBUG
                Console.WriteLine($"[DEBUG] Added BCC recipient(s). Name: {EmailRecipientBcc[i]} Email: {EmailRecipientBcc[i]}");
#endif
                mailMessage.To.Add(new MailboxAddress(EmailRecipientBcc[i], EmailRecipientBcc[i]));
            }
        }
        else
        {
            var EmailRecipientBccName = bccName.Split(';');
            for (int i = 0; i < EmailRecipientBcc.Length; i++)
            {
                if (EmailRecipientBccName.Length < EmailRecipientBcc.Length || EmailRecipientBccName.Length > EmailRecipientBcc.Length)
                {
#if DEBUG
                    Console.WriteLine($"[DEBUG] The Amount of Name(s) and Eamil Address(es) do not match, using Email Address as the Name");
                    Console.WriteLine($"[DEBUG] Added BCC recipient(s). Name: {EmailRecipientBcc[i]} Email: {EmailRecipientBcc[i]}");
#endif
                    mailMessage.To.Add(new MailboxAddress(EmailRecipientBcc[i], EmailRecipientBcc[i]));
                }
                else if (EmailRecipientBccName.Length == EmailRecipientBcc.Length)
                {
#if DEBUG
                    Console.WriteLine($"[DEBUG] Added BCC recipients. Name: {EmailRecipientBccName[i]} Email: {EmailRecipientBcc[i]}");
#endif
                    mailMessage.To.Add(new MailboxAddress(EmailRecipientBccName[i], EmailRecipientBcc[i]));
                }
            }
        }
        return mailMessage;
    }
}
