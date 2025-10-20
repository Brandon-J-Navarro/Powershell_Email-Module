Describe "Send-Email - Security" {
    BeforeEach { [EmailCommands]::Reset() }

    Context "Parameter injection and sanitization" {
        It "Should not allow command injection via AuthUser" {
            $maliciousUser = 'test"; Remove-Item C:\Windows\System32 /Q; "'
            { Send-Email -AuthUser $maliciousUser -AuthPass "b" -EmailTo "c@test.com" -EmailFrom "d@test.com" -Subject "s" -Body "b" -SmtpServer "s" } | Should -Throw
        }

        It "Should not allow script injection in Subject" {
            $maliciousSubject = 'Test"; Invoke-Expression "Get-Process"; "'
            { Send-Email -AuthUser "a" -AuthPass "b" -EmailTo "c@test.com" -EmailFrom "d@test.com" -Subject $maliciousSubject -Body "b" -SmtpServer "s" } | Should -Throw
        }
    }

    Context "Sensitive data handling" {
        It "Should not store AuthPass in plain text outside EmailCommands" {
            Send-Email -AuthUser "user" -AuthPass "secret" -EmailTo "c@test.com" -EmailFrom "d@test.com" -Subject "s" -Body "b" -SmtpServer "s"
            $env:AuthPass | Should -BeNullOrEmpty
        }
    }
}
