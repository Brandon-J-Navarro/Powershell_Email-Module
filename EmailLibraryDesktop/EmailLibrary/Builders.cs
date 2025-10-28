using MimeKit;
using System;
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

        static internal MimeMessage BuildMailMessageFrom(MimeMessage mailMessage, string emailFrom, string? fromName)
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

        static internal MimeMessage BuildMailMessageTo(MimeMessage mailMessage, string emailTo, string? toName)
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

        static internal MimeMessage BuildMailMessageCc(MimeMessage mailMessage, string emailCc, string? ccName)
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

        static internal MimeMessage BuildMailMessageBcc(MimeMessage mailMessage, string emailBcc, string? bccName)
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
}
