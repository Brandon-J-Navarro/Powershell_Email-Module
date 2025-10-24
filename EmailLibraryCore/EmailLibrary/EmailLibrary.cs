// EmailLibrary.cs
using MailKit.Security;
using MimeKit;
using Microsoft.AspNetCore.StaticFiles;
public class EmailCommands
{
    public static void SendEmail(
        string authUser, string authPass,
        string emailTo, string? toName,
        string emailFrom, string? fromName,
        string? emailSubject, string? emailBody,
        string mailServer, int serverPort,
        string? emailCc, string? ccName,
        string? emailBcc, string? bccName,
        string? emailAttachment)
    {
        var mailMessage = new MimeMessage();
        mailMessage.From.Add(string.IsNullOrEmpty(fromName)
            ? new MailboxAddress(emailFrom, emailFrom)
            : new MailboxAddress(fromName, emailFrom));

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

        if (emailCc != null)
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
        }

        if (emailBcc != null)
        {
            var EmailRecipientBcc = emailBcc.Split(";");
            var EmailRecipientBccName = bccName.Split(';');
            for (int i = 0; i < EmailRecipientBcc.Length; i++)
            {
                if (EmailRecipientBccName.Length < EmailRecipientBcc.Length || EmailRecipientBccName.Length > EmailRecipientBcc.Length)
                {
                    mailMessage.Bcc.Add(new MailboxAddress(EmailRecipientBcc[i], EmailRecipientBcc[i]));
                }
                else if (EmailRecipientBccName.Length == EmailRecipientBcc.Length)
                {
                    mailMessage.Bcc.Add(new MailboxAddress(EmailRecipientBccName[i], EmailRecipientBcc[i]));
                }
            }
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
        smtpClient.Authenticate(authUser, authPass);
        smtpClient.Send(mailMessage);
        smtpClient.Disconnect(true);
    }
}
