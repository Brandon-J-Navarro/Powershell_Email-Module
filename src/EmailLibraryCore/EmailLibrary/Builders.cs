using MimeKit;
using System.Net;
using System.Security;
using static EmailLibrary.Log;

namespace EmailLibrary
{
    internal class Builders
    {
        static internal NetworkCredential CreateAuthCreds(string userName, object password)
        {
            Debug("Creating authentication credentials...");
            NetworkCredential credentials = password switch
            {
                string stringPassword => new NetworkCredential(userName, stringPassword),
                SecureString securePassword => new NetworkCredential(userName, securePassword),
                _ => throw new ArgumentException("Password must be either string or SecureString", nameof(password)),
            };
            string typeName = password.GetType().Name;
            Debug($"Using Authentication Password of Type {typeName} to create Credentials.");
            Debug("Authentication credentials created.");
            return credentials;
        }

        static internal MimeMessage BuildMailMessage(MimeMessage mailMessage, string emailAddress, string? emailName,string mailboxLine)
        {
            if (mailboxLine.Equals("FROM"))
            {
                Debug($"Building '{mailboxLine}' address");
                mailMessage.From.Add(string.IsNullOrEmpty(emailName) ? new MailboxAddress(emailAddress, emailAddress) : new MailboxAddress(emailName, emailAddress));
                var displayName = !string.IsNullOrEmpty(emailName) ? emailName : emailAddress;
                if (string.IsNullOrEmpty(emailName))
                {
                    Debug($"No '{mailboxLine}' Name Added, set to string.Empty.");
                }
                Debug($"Added '{mailboxLine}' recipient(s). Name: {displayName} Email: {emailAddress}");
                return mailMessage;
            }
            else
            {
                Debug($"Building '{mailboxLine}' address(es)");
                var EmailRecipient = emailAddress.Split(';');
                if (string.IsNullOrEmpty(emailName))
                {
                    Debug($"'{mailboxLine}' Name is NULL or Empty String using Email Address as the Name");
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
                        Debug($"Added '{mailboxLine}' recipient(s). Name: {EmailRecipient[i]} Email: {EmailRecipient[i]}");
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
                            Debug($"The Amount of Name(s) and Eamil Address(es) do not match, using Email Address as the Name");
                            Debug($"Added '{mailboxLine}' recipient(s). Name: {EmailRecipient[i]} Email: {EmailRecipient[i]}");
                        }
                        else if (EmailRecipientName.Length == EmailRecipient.Length)
                        {
                            if (mailboxLine.Equals("TO"))
                            {
                                mailMessage.To.Add(new MailboxAddress(EmailRecipientName[i], EmailRecipient[i]));
                            }
                            else if (mailboxLine.Equals("CC"))
                            {
                                mailMessage.Cc.Add(new MailboxAddress(EmailRecipientName[i], EmailRecipient[i]));
                            }
                            else if (mailboxLine.Equals("BCC"))
                            {
                                mailMessage.Bcc.Add(new MailboxAddress(EmailRecipientName[i], EmailRecipient[i]));
                            }
                            Debug($"Added '{mailboxLine}' recipients. Name: {EmailRecipientName[i]} Email: {EmailRecipient[i]}");
                        }
                    }
                }
                return mailMessage;
            }
        }
    }
}
