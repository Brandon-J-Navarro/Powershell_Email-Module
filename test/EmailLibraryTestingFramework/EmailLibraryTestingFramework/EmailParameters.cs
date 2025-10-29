using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EmailLibraryTestingFramework
{
    public class EmailParameters
    {
        public string AuthUser { get; set; }
        public string AuthPass  { get; set; }
        public string EmailTo  { get; set; }
        public string EmailToName  { get; set; }
        public string EmailFrom  { get; set; }
        public string EmailFromName  { get; set; }
        public string Subject  { get; set; }
        public string Body  { get; set; }
        public string SmtpServer  { get; set; }
        public int SmtpPort  { get; set; }
        public string EmailCc  { get; set; }
        public string CcName  { get; set; }
        public string EmailBcc  { get; set; }
        public string BccName  { get; set; }
        public string EmailAttachment  { get; set; }
        public string EmailPriority  { get; set; }
        public string EmailImportance  { get; set; }
    }
}
