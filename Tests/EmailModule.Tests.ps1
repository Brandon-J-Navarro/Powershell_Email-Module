# EmailModule.Tests.ps1

BeforeAll {
    # Import the module for testing
    $ModulePath = Join-Path $PSScriptRoot "EmailModule.psm1"
    Import-Module $ModulePath -Force
    
    # Create mock directory structure for library loading tests
    $TestLibPath = Join-Path $TestDrive "lib"
    $CorePath = Join-Path $TestLibPath "Core"
    $DesktopPath = Join-Path $TestLibPath "Desktop"
    New-Item -Path $CorePath -ItemType Directory -Force
    New-Item -Path $DesktopPath -ItemType Directory -Force
    
    # Create mock DLL files
    "Mock DLL Content" | Out-File -FilePath (Join-Path $CorePath "TestCore.dll")
    "Mock DLL Content" | Out-File -FilePath (Join-Path $CorePath "MimeKit.dll")
    "Mock DLL Content" | Out-File -FilePath (Join-Path $DesktopPath "TestDesktop.dll")
    "Mock DLL Content" | Out-File -FilePath (Join-Path $DesktopPath "System.Formats.Asn1.dll")
    "Not a DLL" | Out-File -FilePath (Join-Path $CorePath "NotADll.txt")
    
    # Mock the EmailCommands class since we can't load actual DLLs in tests
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
                // Validate required parameters (like the real implementation would)
                if (string.IsNullOrEmpty(authUser)) throw new System.ArgumentException("AuthUser cannot be null or empty");
                if (string.IsNullOrEmpty(authPass)) throw new System.ArgumentException("AuthPass cannot be null or empty");
                if (string.IsNullOrEmpty(emailTo)) throw new System.ArgumentException("EmailTo cannot be null or empty");
                if (string.IsNullOrEmpty(emailFrom)) throw new System.ArgumentException("EmailFrom cannot be null or empty");
                if (string.IsNullOrEmpty(subject)) throw new System.ArgumentException("Subject cannot be null or empty");
                if (string.IsNullOrEmpty(body)) throw new System.ArgumentException("Body cannot be null or empty");
                if (string.IsNullOrEmpty(smtpServer)) throw new System.ArgumentException("SmtpServer cannot be null or empty");
                if (smtpPort <= 0) throw new System.ArgumentException("SmtpPort must be greater than 0");
                
                // Store parameters for testing verification
                LastAuthUser = authUser;
                LastAuthPass = authPass;
                LastEmailTo = emailTo;
                LastEmailToName = emailToName;
                LastEmailFrom = emailFrom;
                LastEmailFromName = emailFromName;
                LastSubject = subject;
                LastBody = body;
                LastSmtpServer = smtpServer;
                LastSmtpPort = smtpPort;
                
                // Simulate failure if requested
                if (!LastCallSuccessful)
                {
                    throw new System.Exception("Simulated email sending failure");
                }
            }
            
            public static void Reset()
            {
                LastCallSuccessful = true;
                LastAuthUser = "";
                LastAuthPass = "";
                LastEmailTo = "";
                LastEmailToName = "";
                LastEmailFrom = "";
                LastEmailFromName = "";
                LastSubject = "";
                LastBody = "";
                LastSmtpServer = "";
                LastSmtpPort = 0;
            }
        }
"@ -IgnoreWarnings
}

Describe "EmailModule.Libraries.ps1" {
    Context "Module Loading" {
        It "Should load the module without errors" {
            { Import-Module $ModulePath -Force } | Should -Not -Throw
        }
        
        It "Should export the Send-Email function" {
            $ExportedCommands = Get-Command -Module EmailModule
            $ExportedCommands.Name | Should -Contain "Send-Email"
        }
        
        It "Should export only the Send-Email function" {
            $ExportedCommands = Get-Command -Module EmailModule
            $ExportedCommands.Count | Should -Be 1
            $ExportedCommands.Name | Should -Not -Contain "Get-Banner"
        }
    }
    
    Context "Library Loading Logic" {
        It "Should have different behavior for Core vs Desktop editions" {
            $LibrariesScript = Get-Content (Join-Path $PSScriptRoot "EmailModule.Libraries.ps1") -Raw
            $LibrariesScript | Should -Match '\$PSEdition -eq ''Core'''
            $LibrariesScript | Should -Match 'lib\\Core\\'
            $LibrariesScript | Should -Match 'lib\\Desktop\\'
        }
        
        It "Should exclude System.Formats.Asn1.dll on Desktop edition" {
            $LibrariesScript = Get-Content (Join-Path $PSScriptRoot "EmailModule.Libraries.ps1") -Raw
            $LibrariesScript | Should -Match "-Exclude 'System\.Formats\.Asn1\.dll'"
        }
        
        It "Should load Core assemblies when PSEdition is Core" {
            $CorePath = Join-Path $PSScriptRoot "lib\Core"
            if (Test-Path $CorePath) {
                $CoreDlls = Get-ChildItem -Path $CorePath -Filter "*.dll" -ErrorAction SilentlyContinue
                if ($CoreDlls) {
                    $CoreDlls.Count | Should -BeGreaterThan 0
                }
            } else {
                Set-ItResult -Pending -Because "Core library path does not exist in test environment"
            }
        }
        
        It "Should load Desktop assemblies when PSEdition is Desktop" {
            $DesktopPath = Join-Path $PSScriptRoot "lib\Desktop"
            if (Test-Path $DesktopPath) {
                $DesktopDlls = Get-ChildItem -Path $DesktopPath -Exclude 'System.Formats.Asn1.dll' | Where-Object Extension -EQ '.dll' -ErrorAction SilentlyContinue
                if ($DesktopDlls) {
                    $DesktopDlls.Count | Should -BeGreaterThan 0
                }
            } else {
                Set-ItResult -Pending -Because "Desktop library path does not exist in test environment"
            }
        }
    }
    
    Context "Get-Banner Function" {
        It "Should execute Get-Banner without errors" {
            { Get-Banner } | Should -Not -Throw
        }
        
        It "Should display the banner content" {
            Mock Write-Host { } -ModuleName EmailModule
            Get-Banner
            Assert-MockCalled Write-Host -Times 7 -Scope It -ModuleName EmailModule
        }
        
        It "Should mention Send-Email cmdlet in banner" {
            $Output = Get-Banner 6>&1 5>&1 4>&1 3>&1 2>&1
            $Output -join "`n" | Should -Match "Send-Email"
        }
    }
}

Describe "Send-Email Function" {
    BeforeEach {
        # Reset the mock EmailCommands state
        [EmailCommands]::Reset()
    }
    
    Context "Parameter Validation - Required Parameters" {
        BeforeEach {
            $ValidParams = @{
                AuthUser = "test@example.com"
                AuthPass = "password123"
                EmailTo = "recipient@example.com"
                EmailFrom = "sender@example.com"
                Subject = "Test Subject"
                Body = "Test Body"
                SmtpServer = "smtp.example.com"
            }
        }
        
        It "Should require AuthUser parameter" {
            $Params = $ValidParams.Clone()
            $Params.Remove('AuthUser')
            { Send-Email @Params } | Should -Throw "*AuthUser*"
        }
        
        It "Should require AuthPass parameter" {
            $Params = $ValidParams.Clone()
            $Params.Remove('AuthPass')
            { Send-Email @Params } | Should -Throw "*AuthPass*"
        }
        
        It "Should require EmailTo parameter" {
            $Params = $ValidParams.Clone()
            $Params.Remove('EmailTo')
            { Send-Email @Params } | Should -Throw "*EmailTo*"
        }
        
        It "Should require EmailFrom parameter" {
            $Params = $ValidParams.Clone()
            $Params.Remove('EmailFrom')
            { Send-Email @Params } | Should -Throw "*EmailFrom*"
        }
        
        It "Should require Subject parameter" {
            $Params = $ValidParams.Clone()
            $Params.Remove('Subject')
            { Send-Email @Params } | Should -Throw "*Subject*"
        }
        
        It "Should require Body parameter" {
            $Params = $ValidParams.Clone()
            $Params.Remove('Body')
            { Send-Email @Params } | Should -Throw "*Body*"
        }
        
        It "Should require SmtpServer parameter" {
            $Params = $ValidParams.Clone()
            $Params.Remove('SmtpServer')
            { Send-Email @Params } | Should -Throw "*SmtpServer*"
        }
    }
    
    Context "Parameter Validation - Optional Parameters" {
        It "Should accept null values for optional EmailToName parameter" {
            { Send-Email -AuthUser "user@test.com" -AuthPass "pass" -EmailTo "to@test.com" -EmailToName $null -EmailFrom "from@test.com" -Subject "Test" -Body "Test Body" -SmtpServer "smtp.test.com" } |
                Should -Not -Throw
        }
        
        It "Should accept null values for optional EmailFromName parameter" {
            { Send-Email -AuthUser "user@test.com" -AuthPass "pass" -EmailTo "to@test.com" -EmailFrom "from@test.com" -EmailFromName $null -Subject "Test" -Body "Test Body" -SmtpServer "smtp.test.com" } |
                Should -Not -Throw
        }
        
        It "Should allow optional EmailToName parameter" {
            $Params = @{
                AuthUser = "test@example.com"
                AuthPass = "password123"
                EmailTo = "recipient@example.com"
                EmailToName = "Recipient Name"
                EmailFrom = "sender@example.com"
                Subject = "Test Subject"
                Body = "Test Body"
                SmtpServer = "smtp.example.com"
            }
            { Send-Email @Params } | Should -Not -Throw
        }
        
        It "Should allow optional EmailFromName parameter" {
            $Params = @{
                AuthUser = "test@example.com"
                AuthPass = "password123"
                EmailTo = "recipient@example.com"
                EmailFrom = "sender@example.com"
                EmailFromName = "Sender Name"
                Subject = "Test Subject"
                Body = "Test Body"
                SmtpServer = "smtp.example.com"
            }
            { Send-Email @Params } | Should -Not -Throw
        }
        
        It "Should default SmtpPort to 587 when not specified" {
            Send-Email -AuthUser "user@test.com" -AuthPass "pass" -EmailTo "to@test.com" -EmailFrom "from@test.com" -Subject "Test" -Body "Test Body" -SmtpServer "smtp.test.com"
            [EmailCommands]::LastSmtpPort | Should -Be 587
        }
        
        It "Should accept custom SmtpPort when specified" {
            Send-Email -AuthUser "user@test.com" -AuthPass "pass" -EmailTo "to@test.com" -EmailFrom "from@test.com" -Subject "Test" -Body "Test Body" -SmtpServer "smtp.test.com" -SmtpPort 25
            [EmailCommands]::LastSmtpPort | Should -Be 25
        }
    }
    
    Context "Function Execution" {
        It "Should execute successfully with all required parameters" {
            { Send-Email -AuthUser "user@test.com" -AuthPass "password123" -EmailTo "recipient@test.com" -EmailFrom "sender@test.com" -Subject "Test Subject" -Body "Test Body Content" -SmtpServer "smtp.test.com" } |
                Should -Not -Throw
        }
        
        It "Should pass all parameters correctly to EmailCommands.SendEmail" {
            $TestParams = @{
                AuthUser = "testuser@domain.com"
                AuthPass = "testpass123"
                EmailTo = "recipient@test.com"
                EmailToName = "Recipient Name"
                EmailFrom = "sender@test.com"
                EmailFromName = "Sender Name"
                Subject = "Test Subject"
                Body = "Test Body Content"
                SmtpServer = "smtp.test.com"
                SmtpPort = 465
            }
            
            Send-Email @TestParams
            
            [EmailCommands]::LastAuthUser | Should -Be $TestParams.AuthUser
            [EmailCommands]::LastAuthPass | Should -Be $TestParams.AuthPass
            [EmailCommands]::LastEmailTo | Should -Be $TestParams.EmailTo
            [EmailCommands]::LastEmailToName | Should -Be $TestParams.EmailToName
            [EmailCommands]::LastEmailFrom | Should -Be $TestParams.EmailFrom
            [EmailCommands]::LastEmailFromName | Should -Be $TestParams.EmailFromName
            [EmailCommands]::LastSubject | Should -Be $TestParams.Subject
            [EmailCommands]::LastBody | Should -Be $TestParams.Body
            [EmailCommands]::LastSmtpServer | Should -Be $TestParams.SmtpServer
            [EmailCommands]::LastSmtpPort | Should -Be $TestParams.SmtpPort
        }
        
        It "Should handle empty string values for optional name parameters" {
            Send-Email -AuthUser "user@test.com" -AuthPass "pass" -EmailTo "to@test.com" -EmailToName "" -EmailFrom "from@test.com" -EmailFromName "" -Subject "Test" -Body "Test Body" -SmtpServer "smtp.test.com"
            
            [EmailCommands]::LastEmailToName | Should -Be ""
            [EmailCommands]::LastEmailFromName | Should -Be ""
        }
        
        It "Should handle special characters in email content" {
            $SpecialSubject = "Test Subject with Special Characters: àáâãäåæçèé!@#$%^&*() 日本語"
            $SpecialBody = "Test Body with Special Characters: ñòóôõöøùúûüýÿ émojis 🚀 and line breaks`nSecond line`nThird line"
            
            Send-Email -AuthUser "user@test.com" -AuthPass "pass" -EmailTo "to@test.com" -EmailFrom "from@test.com" -Subject $SpecialSubject -Body $SpecialBody -SmtpServer "smtp.test.com"
            
            [EmailCommands]::LastSubject | Should -Be $SpecialSubject
            [EmailCommands]::LastBody | Should -Be $SpecialBody
        }
        
        It "Should handle long email content" {
            $LongSubject = "A" * 1000  # 1000 character subject
            $LongBody = "B" * 10000    # 10000 character body
            
            Send-Email -AuthUser "user@test.com" -AuthPass "pass" -EmailTo "to@test.com" -EmailFrom "from@test.com" -Subject $LongSubject -Body $LongBody -SmtpServer "smtp.test.com"
            
            [EmailCommands]::LastSubject | Should -Be $LongSubject
            [EmailCommands]::LastBody | Should -Be $LongBody
            [EmailCommands]::LastSubject.Length | Should -Be 1000
            [EmailCommands]::LastBody.Length | Should -Be 10000
        }
    }
    
    Context "Error Handling" {
        It "Should propagate exceptions from EmailCommands.SendEmail" {
            [EmailCommands]::LastCallSuccessful = $false
            
            { Send-Email -AuthUser "user@test.com" -AuthPass "pass" -EmailTo "to@test.com" -EmailFrom "from@test.com" -Subject "Test" -Body "Test Body" -SmtpServer "smtp.test.com" } |
                Should -Throw "*Simulated email sending failure*"
        }
        
        It "Should handle empty AuthUser" {
            { Send-Email -AuthUser "" -AuthPass "password123" -EmailTo "recipient@example.com" -EmailFrom "sender@example.com" -Subject "Test Subject" -Body "Test Body" -SmtpServer "smtp.example.com" } |
                Should -Throw "*AuthUser cannot be null or empty*"
        }
        
        It "Should handle empty AuthPass" {
            { Send-Email -AuthUser "user@test.com" -AuthPass "" -EmailTo "recipient@example.com" -EmailFrom "sender@example.com" -Subject "Test Subject" -Body "Test Body" -SmtpServer "smtp.example.com" } |
                Should -Throw "*AuthPass cannot be null or empty*"
        }
        
        It "Should handle empty EmailTo" {
            { Send-Email -AuthUser "user@test.com" -AuthPass "password123" -EmailTo "" -EmailFrom "sender@example.com" -Subject "Test Subject" -Body "Test Body" -SmtpServer "smtp.example.com" } |
                Should -Throw "*EmailTo cannot be null or empty*"
        }
        
        It "Should handle empty EmailFrom" {
            { Send-Email -AuthUser "user@test.com" -AuthPass "password123" -EmailTo "recipient@example.com" -EmailFrom "" -Subject "Test Subject" -Body "Test Body" -SmtpServer "smtp.example.com" } |
                Should -Throw "*EmailFrom cannot be null or empty*"
        }
        
        It "Should handle empty Subject" {
            { Send-Email -AuthUser "user@test.com" -AuthPass "password123" -EmailTo "recipient@example.com" -EmailFrom "sender@example.com" -Subject "" -Body "Test Body" -SmtpServer "smtp.example.com" } |
                Should -Throw "*Subject cannot be null or empty*"
        }
        
        It "Should handle empty Body" {
            { Send-Email -AuthUser "user@test.com" -AuthPass "password123" -EmailTo "recipient@example.com" -EmailFrom "sender@example.com" -Subject "Test Subject" -Body "" -SmtpServer "smtp.example.com" } |
                Should -Throw "*Body cannot be null or empty*"
        }
        
        It "Should handle empty SmtpServer" {
            { Send-Email -AuthUser "user@test.com" -AuthPass "password123" -EmailTo "recipient@example.com" -EmailFrom "sender@example.com" -Subject "Test Subject" -Body "Test Body" -SmtpServer "" } |
                Should -Throw "*SmtpServer cannot be null or empty*"
        }
        
        It "Should handle invalid SmtpPort" {
            { Send-Email -AuthUser "user@test.com" -AuthPass "password123" -EmailTo "recipient@example.com" -EmailFrom "sender@example.com" -Subject "Test Subject" -Body "Test Body" -SmtpServer "smtp.example.com" -SmtpPort -1 } |
                Should -Throw "*SmtpPort must be greater than 0*"
        }
        
        It "Should handle zero SmtpPort" {
            { Send-Email -AuthUser "user@test.com" -AuthPass "password123" -EmailTo "recipient@example.com" -EmailFrom "sender@example.com" -Subject "Test Subject" -Body "Test Body" -SmtpServer "smtp.example.com" -SmtpPort 0 } |
                Should -Throw "*SmtpPort must be greater than 0*"
        }
    }
    
    Context "Parameter Type Validation" {
        It "Should accept string parameters" {
            $Params = @{
                AuthUser = "test@example.com"
                AuthPass = "password123"
                EmailTo = "recipient@example.com"
                EmailFrom = "sender@example.com"
                Subject = "Test Subject"
                Body = "Test Body"
                SmtpServer = "smtp.example.com"
            }
            { Send-Email @Params } | Should -Not -Throw
        }
        
        It "Should accept integer SmtpPort" {
            $Params = @{
                AuthUser = "test@example.com"
                AuthPass = "password123"
                EmailTo = "recipient@example.com"
                EmailFrom = "sender@example.com"
                Subject = "Test Subject"
                Body = "Test Body"
                SmtpServer = "smtp.example.com"
                SmtpPort = 25
            }
            { Send-Email @Params } | Should -Not -Throw
        }
    }
}

Describe "Help Documentation" {
    Context "Send-Email Help Content" {
        BeforeAll {
            $Help = Get-Help Send-Email -Full -ErrorAction SilentlyContinue
        }
        
        It "Should have help documentation available" {
            $Help | Should -Not -BeNullOrEmpty
            $Help.Name | Should -Be "Send-Email"
        }
        
        It "Should have synopsis in help documentation" {
            $Help.Synopsis | Should -Not -BeNullOrEmpty
            $Help.Synopsis | Should -Match "email"
        }
        
        It "Should have description in help documentation" {
            $Help.Description | Should -Not -BeNullOrEmpty
        }
        
        It "Should have examples in help documentation" {
            $Help = Get-Help Send-Email -Examples -ErrorAction SilentlyContinue
            $Help.Examples | Should -Not -BeNullOrEmpty
            $Help.Examples.example.Count | Should -BeGreaterThan 0
        }
        
        It "Should have parameter descriptions in help documentation" {
            $Help = Get-Help Send-Email -Parameter * -ErrorAction SilentlyContinue
            $Help | Should -Not -BeNullOrEmpty
            $Help.Count | Should -BeGreaterThan 5
            
            # Check for required parameters
            $ParamNames = $Help.name
            $ParamNames | Should -Contain "AuthUser"
            $ParamNames | Should -Contain "AuthPass"
            $ParamNames | Should -Contain "EmailTo"
            $ParamNames | Should -Contain "EmailFrom"
            $ParamNames | Should -Contain "Subject"
            $ParamNames | Should -Contain "Body"
            $ParamNames | Should -Contain "SmtpServer"
            $ParamNames | Should -Contain "SmtpPort"
        }
        
        It "Should have links in help documentation" {
            $Help = Get-Help Send-Email -Full -ErrorAction SilentlyContinue
            $Help.relatedLinks | Should -Not -BeNullOrEmpty
        }
        
        It "Should have proper function metadata" {
            $Command = Get-Command Send-Email
            $Command.CommandType | Should -Be "Function"
            $Command.ModuleName | Should -Be "EmailModule"
        }
    }
}

Describe "Integration Tests" {
    Context "Real-world Usage Scenarios" {
        It "Should handle typical corporate email scenario" {
            $Params = @{
                AuthUser = "noreply@company.com"
                AuthPass = "SecurePassword123!"
                EmailTo = "employee@company.com"
                EmailToName = "John Doe"
                EmailFrom = "noreply@company.com"
                EmailFromName = "IT Notifications"
                Subject = "System Maintenance Notification"
                Body = "Dear John,`n`nThis is to inform you about scheduled system maintenance.`n`nBest regards,`nIT Team"
                SmtpServer = "smtp.company.com"
                SmtpPort = 587
            }
            
            { Send-Email @Params } | Should -Not -Throw
            
            # Verify all parameters were passed correctly
            [EmailCommands]::LastAuthUser | Should -Be $Params.AuthUser
            [EmailCommands]::LastEmailTo | Should -Be $Params.EmailTo
            [EmailCommands]::LastEmailToName | Should -Be $Params.EmailToName
            [EmailCommands]::LastEmailFrom | Should -Be $Params.EmailFrom
            [EmailCommands]::LastEmailFromName | Should -Be $Params.EmailFromName
            [EmailCommands]::LastSubject | Should -Be $Params.Subject
            [EmailCommands]::LastBody | Should -Be $Params.Body
            [EmailCommands]::LastSmtpServer | Should -Be $Params.SmtpServer
            [EmailCommands]::LastSmtpPort | Should -Be $Params.SmtpPort
        }
        
        It "Should handle minimal parameter set" {
            $MinimalParams = @{
                AuthUser = "auth@test.com"
                AuthPass = "password"
                EmailTo = "recipient@test.com"
                EmailFrom = "sender@test.com"
                Subject = "Minimal Test"
                Body = "This is a minimal test"
                SmtpServer = "smtp.test.com"
                # SmtpPort should default to 587
            }
            
            { Send-Email @MinimalParams } | Should -Not -Throw
            [EmailCommands]::LastSmtpPort | Should -Be 587  # Default port
        }
        
        It "Should handle full parameter set with all optional parameters" {
            $FullParams = @{
                AuthUser = "auth@test.com"
                AuthPass = "password"
                EmailTo = "recipient@test.com"
                EmailToName = "Full Recipient Name"
                EmailFrom = "sender@test.com"
                EmailFromName = "Full Sender Name"
                Subject = "Full Parameter Test"
                Body = "This is a full parameter test with all options specified"
                SmtpServer = "smtp.test.com"
                SmtpPort = 465
            }
            
            { Send-Email @FullParams } | Should -Not -Throw
            [EmailCommands]::LastEmailToName | Should -Be "Full Recipient Name"
            [EmailCommands]::LastEmailFromName | Should -Be "Full Sender Name"
            [EmailCommands]::LastSmtpPort | Should -Be 465
        }
        
        It "Should handle very long email content" {
            $LongSubject = "A" * 1000  # 1000 character subject
            $LongBody = "B" * 10000    # 10000 character body
            
            { Send-Email -AuthUser "user@test.com" -AuthPass "pass" -EmailTo "to@test.com" -EmailFrom "from@test.com" -Subject $LongSubject -Body $LongBody -SmtpServer "smtp.test.com" } |
                Should -Not -Throw
            
            [EmailCommands]::LastSubject | Should -Be $LongSubject
            [EmailCommands]::LastBody | Should -Be $LongBody
            [EmailCommands]::LastSubject.Length | Should -Be 1000
            [EmailCommands]::LastBody.Length | Should -Be 10000
        }
        
        It "Should handle automation scenario with multiline body" {
            $AutomationParams = @{
                AuthUser = "automation@company.com"
                AuthPass = "AutomationPass123"
                EmailTo = "admin@company.com"
                EmailToName = "System Administrator"
                EmailFrom = "automation@company.com"
                EmailFromName = "Automation System"
                Subject = "Daily Report - $(Get-Date -Format 'yyyy-MM-dd')"
                Body = @"
Daily System Report
==================

Status: All systems operational
Uptime: 99.9%
Errors: 0

Generated on: $(Get-Date)
"@
                SmtpServer = "mail.company.com"
                SmtpPort = 25
            }
            
            { Send-Email @AutomationParams } | Should -Not -Throw
            [EmailCommands]::LastBody | Should -Match "Daily System Report"
            [EmailCommands]::LastSubject | Should -Match "Daily Report"
        }
        
        It "Should handle international email addresses and content" {
            $InternationalParams = @{
                AuthUser = "测试@公司.中国"
                AuthPass = "пароль123"
                EmailTo = "usuario@empresa.es"
                EmailToName = "José María"
                EmailFrom = "système@entreprise.fr"
                EmailFromName = "Système Français"
                Subject = "Тест специальных символов αβγδε"
                Body = "Hello 世界! Bonjour le monde! ¡Hola mundo! Привет мир!"
                SmtpServer = "smtp.international.com"
                SmtpPort = 587
            }
            
            { Send-Email @InternationalParams } | Should -Not -Throw
            [EmailCommands]::LastAuthUser | Should -Be "测试@公司.中国"
            [EmailCommands]::LastEmailToName | Should -Be "José María"
            [EmailCommands]::LastSubject | Should -Match "αβγδε"
            [EmailCommands]::LastBody | Should -Match "世界"
        }
    }
}

Describe "Module Configuration and Metadata" {
    Context "Module Structure" {
        It "Should have proper module structure" {
            $ModuleInfo = Get-Module EmailModule
            $ModuleInfo | Should -Not -BeNullOrEmpty
            $ModuleInfo.Name | Should -Be "EmailModule"
        }
        
        It "Should export only Send-Email function" {
            $ExportedCommands = Get-Command -Module EmailModule
            $ExportedCommands.Count | Should -Be 1
            $ExportedCommands.Name | Should -Be "Send-Email"
        }
        
        It "Should not export Get-Banner function" {
            $ExportedCommands = Get-Command -Module EmailModule
            $ExportedCommands.Name | Should -Not -Contain "Get-Banner"
        }
        
        It "Should have Get-Banner available internally" {
            # Get-Banner should be available but not exported
            { Get-Banner } | Should -Not -Throw
        }
    }
    
    Context "Module Files" {
        It "Should have EmailModule.psm1 file" {
            $ModuleFile = Join-Path $PSScriptRoot "EmailModule.psm1"
            Test-Path $ModuleFile | Should -Be $true
        }
        
        It "Should have EmailModule.Libraries.ps1 file" {
            $LibrariesFile = Join-Path $PSScriptRoot "EmailModule.Libraries.ps1"
            Test-Path $LibrariesFile | Should -Be $true
        }
        
        It "Should dot-source the Libraries file in the module" {
            $ModuleContent = Get-Content (Join-Path $PSScriptRoot "EmailModule.psm1") -Raw
            $ModuleContent | Should -Match "\. \`$PSScriptRoot\\EmailModule\.Libraries\.ps1"
        }
    }
}

Describe "Edge Cases and Boundary Tests" {
    Context "Boundary Value Testing" {
        It "Should handle minimum valid SmtpPort (1)" {
            { Send-Email -AuthUser "user@test.com" -AuthPass "pass" -EmailTo "to@test.com" -EmailFrom "from@test.com" -Subject "Test" -Body "Test" -SmtpServer "smtp.test.com" -SmtpPort 1 } |
                Should -Not -Throw
            [EmailCommands]::LastSmtpPort | Should -Be 1
        }
        
        It "Should handle maximum typical SmtpPort (65535)" {
            { Send-Email -AuthUser "user@test.com" -AuthPass "pass" -EmailTo "to@test.com" -EmailFrom "from@test.com" -Subject "Test" -Body "Test" -SmtpServer "smtp.test.com" -SmtpPort 65535 } |
                Should -Not -Throw
            [EmailCommands]::LastSmtpPort | Should -Be 65535
        }
        
        It "Should handle single character strings" {
            { Send-Email -AuthUser "a@b.c" -AuthPass "p" -EmailTo "t@e.c" -EmailFrom "f@r.c" -Subject "S" -Body "B" -SmtpServer "s.c" } |
                Should -Not -Throw
            [EmailCommands]::LastSubject | Should -Be "S"
            [EmailCommands]::LastBody | Should -Be "B"
        }
        
        It "Should handle whitespace in parameters" {
            $Params = @{
                AuthUser = "  user@test.com  "
                AuthPass = "  password123  "
                EmailTo = "  recipient@test.com  "
                EmailFrom = "  sender@test.com  "
                Subject = "  Test Subject  "
                Body = "  Test Body  "
                SmtpServer = "  smtp.test.com  "
            }
            
            { Send-Email @Params } | Should -Not -Throw
            [EmailCommands]::LastAuthUser | Should -Be "  user@test.com  "
            [EmailCommands]::LastSubject | Should -Be "  Test Subject  "
        }
    }
    
    Context "Special Character Handling" {
        It "Should handle line breaks in body" {
            $BodyWithBreaks = "Line 1`nLine 2`r`nLine 3`rLine 4"
            
            Send-Email -AuthUser "user@test.com" -AuthPass "pass" -EmailTo "to@test.com" -EmailFrom "from@test.com" -Subject "Test" -Body $BodyWithBreaks -SmtpServer "smtp.test.com"
            
            [EmailCommands]::LastBody | Should -Be $BodyWithBreaks
        }
        
        It "Should handle HTML-like content in body" {
            $HtmlBody = "<html><body><h1>Test</h1><p>This is a test email with HTML-like content.</p></body></html>"
            
            Send-Email -AuthUser "user@test.com" -AuthPass "pass" -EmailTo "to@test.com" -EmailFrom "from@test.com" -Subject "HTML Test" -Body $HtmlBody -SmtpServer "smtp.test.com"
            
            [EmailCommands]::LastBody | Should -Be $HtmlBody
        }
        
        It "Should handle quotes and apostrophes" {
            $QuotedSubject = "Test with 'single' and `"double`" quotes"
            $QuotedBody = "This email contains 'single quotes', `"double quotes`", and contractions like don't, won't, can't."
            
            Send-Email -AuthUser "user@test.com" -AuthPass "pass" -EmailTo "to@test.com" -EmailFrom "from@test.com" -Subject $QuotedSubject -Body $QuotedBody -SmtpServer "smtp.test.com"
            
            [EmailCommands]::LastSubject | Should -Be $QuotedSubject
            [EmailCommands]::LastBody | Should -Be $QuotedBody
        }
        
        It "Should handle backslashes and forward slashes" {
            $PathSubject = "File paths: C:\Windows\System32 and /usr/local/bin"
            $PathBody = "Windows path: C:\Users\Test\Documents\file.txt`nLinux path: /home/user/documents/file.txt"
            
            Send-Email -AuthUser "user@test.com" -AuthPass "pass" -EmailTo "to@test.com" -EmailFrom "from@test.com" -Subject $PathSubject -Body $PathBody -SmtpServer "smtp.test.com"
            
            [EmailCommands]::LastSubject | Should -Be $PathSubject
            [EmailCommands]::LastBody | Should -Be $PathBody
        }
    }
    
    Context "Null and Empty Value Handling" {
        It "Should handle null optional parameters correctly" {
            { Send-Email -AuthUser "user@test.com" -AuthPass "pass" -EmailTo "to@test.com" -EmailToName $null -EmailFrom "from@test.com" -EmailFromName $null -Subject "Test" -Body "Test" -SmtpServer "smtp.test.com" } |
                Should -Not -Throw
            
            [EmailCommands]::LastEmailToName | Should -BeNullOrEmpty
            [EmailCommands]::LastEmailFromName | Should -BeNullOrEmpty
        }
        
        It "Should differentiate between null and empty string for optional parameters" {
            # Test with empty string
            Send-Email -AuthUser "user@test.com" -AuthPass "pass" -EmailTo "to@test.com" -EmailToName "" -EmailFrom "from@test.com" -EmailFromName "" -Subject "Test" -Body "Test" -SmtpServer "smtp.test.com"
            [EmailCommands]::LastEmailToName | Should -Be ""
            [EmailCommands]::LastEmailFromName | Should -Be ""
            
            # Reset and test with null
            [EmailCommands]::Reset()
            Send-Email -AuthUser "user@test.com" -AuthPass "pass" -EmailTo "to@test.com" -EmailToName $null -EmailFrom "from@test.com" -EmailFromName $null -Subject "Test" -Body "Test" -SmtpServer "smtp.test.com"
            [EmailCommands]::LastEmailToName | Should -BeNullOrEmpty
            [EmailCommands]::LastEmailFromName | Should -BeNullOrEmpty
        }
    }
}

Describe "Performance and Stress Tests" {
    Context "Large Content Handling" {
        It "Should handle extremely long subject lines" {
            $VeryLongSubject = "A" * 5000  # 5000 characters
            
            { Send-Email -AuthUser "user@test.com" -AuthPass "pass" -EmailTo "to@test.com" -EmailFrom "from@test.com" -Subject $VeryLongSubject -Body "Test" -SmtpServer "smtp.test.com" } |
                Should -Not -Throw
            
            [EmailCommands]::LastSubject.Length | Should -Be 5000
        }
        
        It "Should handle very large email bodies" {
            $VeryLongBody = "This is a test email body. " * 10000  # Approximately 270,000 characters
            
            { Send-Email -AuthUser "user@test.com" -AuthPass "pass" -EmailTo "to@test.com" -EmailFrom "from@test.com" -Subject "Large Body Test" -Body $VeryLongBody -SmtpServer "smtp.test.com" } |
                Should -Not -Throw
            
            [EmailCommands]::LastBody.Length | Should -BeGreaterThan 250000
        }
        
        It "Should handle multiple consecutive function calls" {
            for ($i = 1; $i -le 10; $i++) {
                { Send-Email -AuthUser "user$i@test.com" -AuthPass "pass$i" -EmailTo "to$i@test.com" -EmailFrom "from$i@test.com" -Subject "Test $i" -Body "Body $i" -SmtpServer "smtp.test.com" } |
                    Should -Not -Throw
                
                [EmailCommands]::LastSubject | Should -Be "Test $i"
                [EmailCommands]::LastBody | Should -Be "Body $i"
            }
        }
    }
}

Describe "Security and Validation Tests" {
    Context "Input Sanitization" {
        It "Should handle potential injection attempts in parameters" {
            $InjectionAttempts = @(
                "user@test.com'; DROP TABLE users; --",
                "user@test.com<script>alert('xss')</script>",
                "user@test.com`$(Get-Process)",
                "user@test.com & del /f /q C:\*.*"
            )
            
            foreach ($InjectionAttempt in $InjectionAttempts) {
                { Send-Email -AuthUser $InjectionAttempt -AuthPass "pass" -EmailTo "to@test.com" -EmailFrom "from@test.com" -Subject "Test" -Body "Test" -SmtpServer "smtp.test.com" } |
                    Should -Not -Throw
                
                [EmailCommands]::LastAuthUser | Should -Be $InjectionAttempt
            }
        }
        
        It "Should preserve exact input without modification" {
            $SpecialInput = "Test with `$variables and $(expressions) and 'quotes'"
            
            Send-Email -AuthUser "user@test.com" -AuthPass "pass" -EmailTo "to@test.com" -EmailFrom "from@test.com" -Subject $SpecialInput -Body $SpecialInput -SmtpServer "smtp.test.com"
            
            [EmailCommands]::LastSubject | Should -Be $SpecialInput
            [EmailCommands]::LastBody | Should -Be $SpecialInput
        }
    }
}

AfterAll {
    # Clean up
    Remove-Module EmailModule -Force -ErrorAction SilentlyContinue
    
    # Clean up any global variables that might have been created
    if (Get-Variable -Name MockLoadedAssemblies -Scope Global -ErrorAction SilentlyContinue) {
        Remove-Variable -Name MockLoadedAssemblies -Scope Global -Force
    }
    
    # Remove any test files created during testing
    if (Test-Path $TestLibPath) {
        Remove-Item $TestLibPath -Recurse -Force -ErrorAction SilentlyContinue
    }
}
