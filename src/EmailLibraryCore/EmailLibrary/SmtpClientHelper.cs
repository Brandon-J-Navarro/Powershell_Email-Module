using MailKit.Net.Smtp;
using System.Net.Security;
using System.Runtime.InteropServices;
using System.Security.Cryptography.X509Certificates;
using static EmailLibrary.Log;

namespace EmailLibrary
{
    internal static class SmtpClientHelper
    {
        public static void ConfigureForEnvironment(SmtpClient smtpClient)
        {
            smtpClient.ServerCertificateValidationCallback = ValidateCertificateForMacOsCi;
        }

        private static bool IsMacOsCiEnvironment()
        {
            return Environment.GetEnvironmentVariable("CI") == "true" && RuntimeInformation.IsOSPlatform(OSPlatform.OSX);
        }

        private static bool ValidateCertificateForMacOsCi(object sender, X509Certificate certificate, X509Chain chain, SslPolicyErrors sslPolicyErrors)
        {
            if (sslPolicyErrors == SslPolicyErrors.RemoteCertificateChainErrors &&
                chain?.ChainStatus?.Any(s => s.Status == X509ChainStatusFlags.RevocationStatusUnknown) == true)
            {
                return true;
            }
            return sslPolicyErrors == SslPolicyErrors.None;
        }
    }
}
