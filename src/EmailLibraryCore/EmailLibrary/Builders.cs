using MimeKit;
using System.Net;
using System.Security;

namespace EmailLibrary
{
    internal class Builders
    {
        static internal NetworkCredential CreateAuthCreds(string userName, object password)
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

        static internal MimeMessage BuildMailMessage(MimeMessage mailMessage, string emailAddress, string? emailName,string mailboxLine)
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
    }
}
