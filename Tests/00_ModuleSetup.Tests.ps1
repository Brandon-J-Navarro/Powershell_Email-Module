BeforeAll {
    # Create a temporary test drive
    $Global:TestDrive = Join-Path $env:TEMP "EmailModuleTest"
    New-Item -Path $Global:TestDrive -ItemType Directory -Force | Out-Null

    # Create mock library folders
    $Global:CorePath = Join-Path $Global:TestDrive "lib\Core"
    $Global:DesktopPath = Join-Path $Global:TestDrive "lib\Desktop"
    New-Item -Path $Global:CorePath -ItemType Directory -Force | Out-Null
    New-Item -Path $Global:DesktopPath -ItemType Directory -Force | Out-Null

    # Create mock DLLs
    "Mock DLL Content" | Out-File -FilePath (Join-Path $Global:CorePath "TestCore.dll")
    "Mock DLL Content" | Out-File -FilePath (Join-Path $Global:CorePath "MimeKit.dll")
    "Mock DLL Content" | Out-File -FilePath (Join-Path $Global:DesktopPath "TestDesktop.dll")
    "Mock DLL Content" | Out-File -FilePath (Join-Path $Global:DesktopPath "System.Formats.Asn1.dll")

    # Define global EmailCommands mock if not already defined
    if (-not ([System.Management.Automation.PSTypeName]'EmailCommands').Type) {
        Add-Type -TypeDefinition @"
            public class EmailCommands
            {
                public static bool LastCallSuccessful = true;
                public static string LastAuthUser = "";
                public static string LastAuthPass = "";
                public static string LastEmailTo = "";
                public static string LastEmailToName = "";
                public static string LastEmailFrom = "";
                public static string LastEmailFromName = "";
                public static string LastSubject = "";
                public static string LastBody = "";
                public static string LastSmtpServer = "";
                public static int LastSmtpPort = 0;

                public static void SendEmail(string authUser, string authPass, string emailTo,
                    string emailToName, string emailFrom, string emailFromName, string subject,
                    string body, string smtpServer, int smtpPort)
                {
                    if (string.IsNullOrEmpty(authUser)) throw new System.ArgumentException("AuthUser cannot be null or empty");
                    if (string.IsNullOrEmpty(authPass)) throw new System.ArgumentException("AuthPass cannot be null or empty");
                    if (string.IsNullOrEmpty(emailTo)) throw new System.ArgumentException("EmailTo cannot be null or empty");
                    if (string.IsNullOrEmpty(emailFrom)) throw new System.ArgumentException("EmailFrom cannot be null or empty");
                    if (string.IsNullOrEmpty(subject)) throw new System.ArgumentException("Subject cannot be null or empty");
                    if (string.IsNullOrEmpty(body)) throw new System.ArgumentException("Body cannot be null or empty");
                    if (string.IsNullOrEmpty(smtpServer)) throw new System.ArgumentException("SmtpServer cannot be null or empty");
                    if (smtpPort <= 0) throw new System.ArgumentException("SmtpPort must be greater than 0");

                    LastAuthUser = authUser; LastAuthPass = authPass; LastEmailTo = emailTo
                    LastEmailToName = emailToName; LastEmailFrom = emailFrom; LastEmailFromName = emailFromName
                    LastSubject = subject; LastBody = body; LastSmtpServer = smtpServer; LastSmtpPort = smtpPort

                    if (!LastCallSuccessful) { throw new System.Exception("Simulated email sending failure"); }
                }

                public static void Reset()
                {
                    LastCallSuccessful = true; LastAuthUser = ""; LastAuthPass = ""
                    LastEmailTo = ""; LastEmailToName = ""; LastEmailFrom = ""; LastEmailFromName = ""
                    LastSubject = ""; LastBody = ""; LastSmtpServer = ""; LastSmtpPort = 0
                }
            }
"@ -IgnoreWarnings
    }

    # Import module under test
    $Global:ModulePath = Join-Path $PSScriptRoot "EmailModule.psm1"
    Import-Module $Global:ModulePath -Force
}
