Describe "Send-Email - Edge Cases" {
    BeforeEach { [EmailCommands]::Reset() }

    Context "Empty strings or whitespace parameters" {
        $Params = @{
            AuthUser=" "; AuthPass=" "; EmailTo=" "; EmailFrom=" "; Subject=" "; Body=" "; SmtpServer=" "
        }

        foreach ($key in $Params.Keys) {
            It "Should throw for whitespace $key" {
                $TestParams = @{
                    AuthUser="a"; AuthPass="b"; EmailTo="c"; EmailFrom="d"; Subject="s"; Body="b"; SmtpServer="s"
                }
                $TestParams[$key] = " "
                { Send-Email @TestParams } | Should -Throw "*$key*"
            }
        }
    }

    Context "Invalid SMTP port" {
        It "Should throw for 0 port" {
            { Send-Email -AuthUser "a" -AuthPass "b" -EmailTo "c" -EmailFrom "d" -Subject "s" -Body "b" -SmtpServer "s" -SmtpPort 0 } | Should -Throw "*SmtpPort*"
        }

        It "Should throw for negative port" {
            { Send-Email -AuthUser "a" -AuthPass "b" -EmailTo "c" -EmailFrom "d" -Subject "s" -Body "b" -SmtpServer "s" -SmtpPort -25 } | Should -Throw "*SmtpPort*"
        }
    }

    Context "Special characters in subject and body" {
        It "Should accept unicode and symbols" {
            $Subject = "Test 📨 ✔"
            $Body = "Body with symbols ✨🔥💌"
            { Send-Email -AuthUser "a" -AuthPass "b" -EmailTo "c" -EmailFrom "d" -Subject $Subject -Body $Body -SmtpServer "s" } | Should -Not -Throw
        }
    }
}
