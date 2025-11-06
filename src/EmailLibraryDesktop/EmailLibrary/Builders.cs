using Microsoft.AspNetCore.StaticFiles;
using MimeKit;
using System;
using System.IO;
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
                _ => throw new ArgumentException("Password must be either string or SecureString", nameof(password))
            };
            string typeName = password.GetType().Name;
            Debug($"Using Authentication Password of Type {typeName} to create Credentials.");
            Debug("Authentication credentials created.");
            return credentials;
        }

        public enum MailboxType
        {
            From,
            To,
            Cc,
            Bcc
        }

        static internal MimeMessage AddRecipients(MimeMessage mailMessage, string emails, string names, MailboxType mailboxType, bool isRequired = false)
        {
            if ((string.IsNullOrEmpty(emails) || string.IsNullOrWhiteSpace(emails)) && isRequired == true)
            {
                throw new Exception($"Address line \"{mailboxType}\" is empty and is required");
            }
            else if (!string.IsNullOrEmpty(emails) && !string.IsNullOrWhiteSpace(emails))
            {
                mailMessage = BuildMailMessage(mailMessage, emails, names, mailboxType);
                Debug($"Successfully added {mailboxType}{(isRequired ? "." : " recipients.")}");
                return mailMessage;
            }
            else
            {
                Debug($"No {mailboxType} Added.");
                return mailMessage;
            }
        }

        static internal MimeMessage BuildMailMessage(MimeMessage mailMessage, string emailAddress, string? emailName, MailboxType mailboxType)
        {
            // Get the appropriate address list based on mailbox type
            var addressList = mailboxType switch
            {
                MailboxType.From => mailMessage.From,
                MailboxType.To => mailMessage.To,
                MailboxType.Cc => mailMessage.Cc,
                MailboxType.Bcc => mailMessage.Bcc,
                _ => throw new ArgumentException($"Unknown mailbox type: {mailboxType}")
            };

            var typeName = mailboxType.ToString().ToUpper();
            Debug($"Building '{typeName}' address(es)");

            // Split email addresses and names by semicolon
            var emailRecipients = emailAddress.Split(';', (char)StringSplitOptions.RemoveEmptyEntries);
            var emailNames = emailName?.Split(';', (char)StringSplitOptions.RemoveEmptyEntries) ?? new string[0];

            // If names and emails don't match, use email addresses as names
            if (emailNames.Length != emailRecipients.Length)
            {
                emailNames = emailRecipients;
                Debug($"The amount of Name(s) and Email Address(es) do not match, using Email Address as the Name");
            }

            // Add each recipient to the address list
            for (int i = 0; i < emailRecipients.Length; i++)
            {
                var email = emailRecipients[i].Trim();
                var name = emailNames[i].Trim();

                // Use email as display name if name is empty
                var displayName = !string.IsNullOrEmpty(name) ? name : email;

                // Add to the address list
                addressList.Add(new MailboxAddress(displayName, email));
                Debug($"Added '{typeName}' recipient(s). Name: {displayName} Email: {email}");
            }
            return mailMessage;
        }

        static internal MimeMessage SetEmailBody(MimeMessage mailMessage, string emailBody, string emailAttachment)
        {
            if (!string.IsNullOrEmpty(emailAttachment))
            {
                Debug($"Attachment found: {emailAttachment}");
                mailMessage.Body = CreateMultipartBody(emailBody, emailAttachment);
                Debug("Set multipart message (body + attachments) as email body.");
            }
            else
            {
                mailMessage.Body = CreateTextBody(emailBody);
            }
            Debug(string.IsNullOrEmpty(emailBody)
                ? "No BODY Added, set to string.Empty."
                : $"BODY Added: {emailBody}");
            return mailMessage;
        }

        private static TextPart CreateTextBody(string emailBody)
        {
            return new TextPart("plain")
            {
                Text = emailBody ?? string.Empty
            };
        }

        private static Multipart CreateMultipartBody(string emailBody, string emailAttachment)
        {
            var body = CreateTextBody(emailBody);
            var multipart = new Multipart("mixed");
            multipart.Add(body);
            Debug("Created multipart container and added email body.");
            multipart = TryAddAttachment(multipart, emailAttachment);
            return multipart;
        }

        private static Multipart TryAddAttachment(Multipart multipart, string emailAttachment)
        {
            if (!File.Exists(emailAttachment))
            {
                Debug($"Attachment file not found at path: {emailAttachment}");
                return multipart;
            }
            Debug($"Attachment file exists at path: {emailAttachment}");
            var contentType = GetContentType(emailAttachment);
            var attachment = CreateAttachment(emailAttachment, contentType);
            multipart.Add(attachment);
            Debug("Added attachment to multipart message.");
            return multipart;
        }

        private static string GetContentType(string filePath)
        {
            const string DefaultContentType = "application/octet-stream";
            var provider = new FileExtensionContentTypeProvider();
            if (!provider.TryGetContentType(filePath, out string contentType))
            {
                Debug($"Could not determine MIME type for '{filePath}'. Defaulting to '{DefaultContentType}'.");
                return DefaultContentType;
            }
            Debug($"Determined MIME type for '{filePath}': {contentType}");
            return contentType;
        }

        private static MimePart CreateAttachment(string filePath, string contentType)
        {
            var stream = File.OpenRead(filePath);
            Debug($"Opened file stream for attachment: {filePath}");
            var attachment = new MimePart(contentType)
            {
                Content = new MimeContent(stream, ContentEncoding.Default),
                ContentDisposition = new ContentDisposition(ContentDisposition.Attachment),
                ContentTransferEncoding = ContentEncoding.Base64,
                FileName = Path.GetFileName(filePath)
            };
            Debug($"Created MimePart for attachment: {attachment.FileName}");
            return attachment;
        }
    }
}
