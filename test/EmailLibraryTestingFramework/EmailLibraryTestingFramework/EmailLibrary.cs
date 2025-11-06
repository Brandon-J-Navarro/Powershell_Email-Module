using System;
using System.IO;
using EmailLibrary;

namespace EmailLibraryTestingFramework
{
    class Program
    {
        static int Main(string[] args)
        {
            string jsonFilePath = "..\\..\\appSetting.json";
            string jsonContent = File.ReadAllText(jsonFilePath);
            EmailParameters emailParameters = System.Text.Json.JsonSerializer.Deserialize<EmailParameters>(jsonContent);

            string AuthUser = emailParameters.AuthUser;
            object AuthPass = emailParameters.AuthPass;
            string EmailTo = emailParameters.EmailTo;
            string EmailToName = emailParameters.EmailToName;
            string EmailFrom = emailParameters.EmailFrom;
            string EmailFromName = emailParameters.EmailFromName;
            string Subject = emailParameters.Subject;
            string Body = emailParameters.Body;
            string SmtpServer = emailParameters.SmtpServer;
            int SmtpPort = emailParameters.SmtpPort;
            string EmailCc = emailParameters.EmailCc;
            string CcName = emailParameters.CcName;
            string EmailBcc = emailParameters.EmailBcc;
            string BccName = emailParameters.BccName;
            string EmailAttachment = emailParameters.EmailAttachment;
            string EmailPriority = emailParameters.EmailPriority;
            string EmailImportance = emailParameters.EmailImportance;
            try
            {
                // Call into the desktop/framework library directly
                EmailCommands.SendEmail(
                    AuthUser,
                    AuthPass,
                    EmailTo,
                    EmailToName,
                    EmailFrom,
                    EmailFromName,
                    Subject,
                    Body,
                    SmtpServer,
                    Convert.ToInt16(SmtpPort),
                    EmailCc,
                    CcName,
                    EmailBcc,
                    BccName,
                    EmailAttachment,
                    EmailPriority,
                    EmailImportance
                );
                return 0;
            }
            catch (Exception ex)
            {
                Console.Error.WriteLine(ex);
                return -1;
            }
        }
    }
}
