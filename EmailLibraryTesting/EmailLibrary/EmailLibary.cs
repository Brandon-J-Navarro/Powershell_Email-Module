// EmailLibrary.cs
using EmailLibrary;
using MailKit.Security;
using Microsoft.AspNetCore.StaticFiles;
using Microsoft.Extensions.Configuration;
using MimeKit;
using System.Net;
using System.Security;

public class EmailCommands
{
    private static readonly IConfiguration _configuration = Startup.BuildConfiguation();
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
        NetworkCredential credentials = CreateAuthCreds(authUser, authPass);
        var mailMessage = new MimeMessage();
        mailMessage = BuildMailMessageFrom(mailMessage, emailFrom, fromName);
        mailMessage = BuildMailMessageTo(mailMessage, emailTo, toName);
        if (emailCc != null)
        {
            mailMessage = BuildMailMessageCc(mailMessage, emailCc, ccName);
        }
        if (emailBcc != null)
        {
            mailMessage = BuildMailMessageBcc(mailMessage, emailBcc, bccName);
        }
        if (emailPriority != null)
        {
            mailMessage.Priority = (MessagePriority)System.Enum.Parse(typeof(MessagePriority), emailPriority);
        }
        if (emailImportance != null)
        {
            mailMessage.Importance = (MessageImportance)System.Enum.Parse(typeof(MessagePriority), emailImportance);
        }
        mailMessage.Subject = emailSubject ?? string.Empty;
        if (emailAttachment != null)
        {
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
        }
        else
        {
            mailMessage.Body = new TextPart("plain")
            {
                Text = emailBody ?? string.Empty
            };
        }

        using var smtpClient = new MailKit.Net.Smtp.SmtpClient();
        smtpClient.Connect(mailServer, serverPort, SecureSocketOptions.StartTls);
        smtpClient.Authenticate(credentials);
        smtpClient.Send(mailMessage);
        smtpClient.Disconnect(true);
    }

    static private NetworkCredential CreateAuthCreds(string userName, object password)
    {
        NetworkCredential credentials;
        switch (password)
        {
            case string stringPassword:
                credentials = new NetworkCredential(userName, stringPassword);
                break;
            case SecureString securePassword:
                credentials = new NetworkCredential(userName, securePassword);
                break;
            default:
                throw new ArgumentException("Password must be either string or SecureString", nameof(password));
        }
        return credentials;
    }
    static private MimeMessage BuildMailMessageFrom(MimeMessage mailMessage, string emailFrom, string? fromName)
    {
        mailMessage.From.Add(string.IsNullOrEmpty(fromName)
            ? new MailboxAddress(emailFrom, emailFrom)
            : new MailboxAddress(fromName, emailFrom));
        return mailMessage;
    }
    static private MimeMessage BuildMailMessageTo(MimeMessage mailMessage, string emailTo, string? toName)
    {
        var EmailRecipientTo = emailTo.Split(';');
        var EmailRecipientToName = toName.Split(';');
        for (int i = 0; i < EmailRecipientTo.Length; i++)
        {
            if (EmailRecipientToName.Length < EmailRecipientTo.Length || EmailRecipientToName.Length > EmailRecipientTo.Length)
            {
                mailMessage.To.Add(new MailboxAddress(EmailRecipientTo[i], EmailRecipientTo[i]));
            }
            else if (EmailRecipientToName.Length == EmailRecipientTo.Length)
            {
                mailMessage.To.Add(new MailboxAddress(EmailRecipientToName[i], EmailRecipientTo[i]));
            }
        }
        return mailMessage;
    }
    static private MimeMessage BuildMailMessageCc(MimeMessage mailMessage, string emailCc, string? ccName)
    {
        var EmailRecipientCc = emailCc.Split(";");
        var EmailRecipientCcName = ccName.Split(';');
        for (int i = 0; i < EmailRecipientCc.Length; i++)
        {
            if (EmailRecipientCcName.Length < EmailRecipientCc.Length || EmailRecipientCcName.Length > EmailRecipientCc.Length)
            {
                mailMessage.Cc.Add(new MailboxAddress(EmailRecipientCc[i], EmailRecipientCc[i]));
            }
            else if (EmailRecipientCcName.Length == EmailRecipientCc.Length)
            {
                mailMessage.Cc.Add(new MailboxAddress(EmailRecipientCcName[i], EmailRecipientCc[i]));
            }
        }
        return mailMessage;
    }
    static private MimeMessage BuildMailMessageBcc(MimeMessage mailMessage, string emailBcc, string? bccName)
    {
        var EmailRecipientCc = emailBcc.Split(";");
        var EmailRecipientCcName = bccName.Split(';');
        for (int i = 0; i < EmailRecipientCc.Length; i++)
        {
            if (EmailRecipientCcName.Length < EmailRecipientCc.Length || EmailRecipientCcName.Length > EmailRecipientCc.Length)
            {
                mailMessage.Cc.Add(new MailboxAddress(EmailRecipientCc[i], EmailRecipientCc[i]));
            }
            else if (EmailRecipientCcName.Length == EmailRecipientCc.Length)
            {
                mailMessage.Cc.Add(new MailboxAddress(EmailRecipientCcName[i], EmailRecipientCc[i]));
            }
        }
        return mailMessage;
    }
    static void Main(string[] args)
    {
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
        //string EmailCc = _configuration["EmailParameters:EmailCc"];
        //string CcName = _configuration["EmailParameters:CcName"];
        //string EmailBcc = _configuration["EmailParameters:EmailBcc"];
        //string BccName = _configuration["EmailParameters:BccName"];
        //string EmailAttachment = _configuration["EmailParameters:EmailAttachment"];
        //string EmailPriority = _configuration["EmailParameters:EmailPriority"];
        //string EmailImportance = _configuration["EmailParameters:EmailImportance"];
        string EmailCc = null;
        string CcName = null;
        string EmailBcc = null;
        string BccName = null;
        string EmailAttachment = null;
        string EmailPriority = null;
        string EmailImportance = null;
        SendEmail(
            authUser: AuthUser,
            authPass: AuthPass,
            emailTo: EmailTo,
            toName: EmailToName,
            emailFrom: EmailFrom,
            fromName: EmailFromName,
            emailSubject: Subject,
            emailBody: Body,
            mailServer: SmtpServer,
            serverPort: Convert.ToInt16(SmtpPort),
            EmailCc,
            CcName,
            EmailBcc,
            BccName,
            EmailAttachment,
            EmailPriority,
            EmailImportance
        );
    }
}
