// EmailLibrary.cs Console App .Net 8
using EmailLibrary;
using Microsoft.Extensions.Configuration;


namespace EmailLibraryTestingCore
{
    class Program
    {
        private static readonly IConfiguration _configuration = Startup.BuildConfiguation();
        static int Main(string[] args)
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
            string EmailCc = _configuration["EmailParameters:EmailCc"];
            string CcName = _configuration["EmailParameters:CcName"];
            string EmailBcc = _configuration["EmailParameters:EmailBcc"];
            string BccName = _configuration["EmailParameters:BccName"];
            string EmailAttachment = _configuration["EmailParameters:EmailAttachment"];
            string EmailPriority = _configuration["EmailParameters:EmailPriority"];
            string EmailImportance = _configuration["EmailParameters:EmailImportance"];
            try
            {
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
