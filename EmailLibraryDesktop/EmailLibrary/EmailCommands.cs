// EmailCommands.cs
using MimeKit;
using MailKit.Security;
public class EmailCommands
{
    public static void SendEmail(
        string authUser,
        string authPass,
        object[] emailTo,
        object[]? toName,
        object[]? emailCc,
        object[]? ccName,
        object[]? emailBcc,
        object[]? bccName,
        string? emailAttachment,
        string emailFrom,
        string? fromName,
        string? emailSubject,
        string? emailBody,
        string mailServer,
        int serverPort)
    {
        var mailMessage = new MimeMessage();
        mailMessage.From.Add(string.IsNullOrEmpty(fromName)
            ? new MailboxAddress(emailFrom, emailFrom)
            : new MailboxAddress(fromName, emailFrom));

        for (int i = 0; i < emailTo.Length; i++)
        {
            mailMessage.To.Add(string.IsNullOrEmpty(toName[i].ToString())
                ? new MailboxAddress(emailTo[i].ToString(), emailTo[i].ToString())
                : new MailboxAddress(toName[i].ToString(), emailTo[i].ToString()));
        }

        if (emailCc != null)
        {
            for (int i = 0; i < emailCc.Length; i++)
            {
                mailMessage.Cc.Add(string.IsNullOrEmpty(ccName[i].ToString())
                    ? new MailboxAddress(emailCc[i].ToString(), emailCc[i].ToString())
                    : new MailboxAddress(ccName[i].ToString(), emailCc[i].ToString()));
            }
        }

        if (emailBcc != null)
        {
            for (int i = 0; i < emailTo.Length; i++)
            {
                mailMessage.Bcc.Add(string.IsNullOrEmpty(bccName[i].ToString())
                    ? new MailboxAddress(emailBcc[i].ToString(), emailBcc[i].ToString())
                    : new MailboxAddress(bccName[i].ToString(), emailBcc[i].ToString()));
            }
        }

        mailMessage.Subject = emailSubject ?? string.Empty;

        if (emailAttachment != null)
        {
            var body = new TextPart("plain")
            {
                Text = emailBody ?? string.Empty
            };

            // create an image attachment for the file located at path
            var attachment = new MimePart("image", "gif")
            {
                Content = new MimeContent(File.OpenRead(emailAttachment), ContentEncoding.Default),
                ContentDisposition = new ContentDisposition(ContentDisposition.Attachment),
                ContentTransferEncoding = ContentEncoding.Base64,
                FileName = Path.GetFileName(emailAttachment)
            };

            // now create the multipart/mixed container to hold the message text and the
            // image attachment
            var multipart = new Multipart("mixed");
            multipart.Add(body);
            multipart.Add(attachment);

            // now set the multipart/mixed as the message body
            mailMessage.Body = multipart;
        }
        else
        {
            mailMessage.Body = new TextPart("plain")
            {
                Text = emailBody ?? string.Empty
            };
        }

        using (var smtpClient = new MailKit.Net.Smtp.SmtpClient())
        {
            smtpClient.Connect(mailServer, serverPort, SecureSocketOptions.StartTls);
            smtpClient.Authenticate(authUser, authPass);
            smtpClient.Send(mailMessage);
            smtpClient.Disconnect(true);
        }
        // var smtpClient = new MailKit.Net.Smtp.SmtpClient();
        // smtpClient.Connect(_EmailMailServer, _EmailServerPort, SecureSocketOptions.StartTls);
        // smtpClient.Authenticate(_AuthUser, _AuthPass);
        // smtpClient.Send(mailMessage);
        // smtpClient.Disconnect(true);
        // smtpClient.Dispose();
    }
}
