// EmailCommands.cs
using MimeKit;
using MailKit.Security;
public class EmailCommands
{
    public static void SendEmail(
        string authUser,
        string authPass,
        string emailTo,
        string? emailToName,
        string emailFrom,
        string? emailFromName,
        string? emailSubject,
        string? emailBody,
        string emailMailServer,
        int emailServerPort)
    {
        var mailMessage = new MimeMessage();
        mailMessage.From.Add(string.IsNullOrEmpty(emailFromName)
            ? new MailboxAddress(emailFrom, emailFrom)
            : new MailboxAddress(emailFromName, emailFrom));

        mailMessage.To.Add(string.IsNullOrEmpty(emailToName)
            ? new MailboxAddress(emailTo, emailTo)
            : new MailboxAddress(emailToName, emailTo));

        if (!string.IsNullOrEmpty(emailSubject))
        {
            mailMessage.Subject = emailSubject;
        }

        mailMessage.Body = new TextPart("plain")
        {
            Text = emailBody ?? string.Empty
        };

        var smtpClient = new SmtpClient();
        smtpClient.Connect(emailMailServer, emailServerPort, SecureSocketOptions.StartTls);
        smtpClient.Authenticate(authUser, authPass);
        smtpClient.Send(mailMessage);
        smtpClient.Disconnect(true);
        smtpClient.Dispose();
    }
}
