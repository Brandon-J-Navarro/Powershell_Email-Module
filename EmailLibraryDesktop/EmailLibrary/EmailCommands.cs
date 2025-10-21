// EmailCommands.cs
using MimeKit;
using MailKit.Security;
public class EmailCommands
{
    public static void SendEmail(string _AuthUser, string _AuthPass, string _EmailTo,
        string? _EmailToName, string _EmailFrom, string? _EmailFromName, string _EmailSubject,
        string _EmailBody, string _EmailMailServer, int _EmailServerPort)
    {
        var mailMessage = new MimeMessage();
        mailMessage.From.Add(string.IsNullOrEmpty(_EmailFromName) 
        ? new MailboxAddress(_EmailFrom, _EmailFrom) 
        : new MailboxAddress(_EmailFromName, _EmailFrom));

        mailMessage.To.Add(string.IsNullOrEmpty(_EmailToName)
        ? new MailboxAddress(_EmailTo, _EmailTo)
        : new MailboxAddress(_EmailToName, _EmailTo));

        mailMessage.Subject = _EmailSubject;
        mailMessage.Body = new TextPart("plain")
        {
            Text = _EmailBody
        };
        var smtpClient = new MailKit.Net.Smtp.SmtpClient();
        smtpClient.Connect(_EmailMailServer, _EmailServerPort, SecureSocketOptions.StartTls);
        smtpClient.Authenticate(_AuthUser, _AuthPass);
        smtpClient.Send(mailMessage);
        smtpClient.Disconnect(true);
    }
}
