Describe "Send-Email - Parameter Validation" {
    BeforeEach { [EmailCommands]::Reset() }

    Context "Required parameters" {
        $RequiredParams = @{
            AuthUser = "test@example.com"; AuthPass = "pass"; EmailTo = "a@b.com"; EmailFrom = "c@d.com"
            Subject = "Test"; Body = "Body"; SmtpServer = "smtp.test.com"
        }

        foreach ($param in $RequiredParams.Keys) {
            It "Should require $param" {
                $Params = $RequiredParams.Clone()
                $Params.Remove($param)
                { Send-Email @Params } | Should -Throw "*$param*"
            }
        }
    }

    Context "Optional parameters" {
        It "Should accept null for EmailToName and EmailFromName" {
            { Send-Email -AuthUser "user@test.com" -AuthPass "pass" -EmailTo "to@test.com" `
                -EmailToName $null -EmailFrom "from@test.com" -EmailFromName $null `
                -Subject "Test" -Body "Test" -SmtpServer "smtp.test.com" } | Should -Not -Throw
        }

        It "Should default SmtpPort to 587" {
            Send-Email -AuthUser "u" -AuthPass "p" -EmailTo "t" -EmailFrom "f" -Subject "S" -Body "B" -SmtpServer "s"
            [EmailCommands]::LastSmtpPort | Should -Be 587
        }
    }
}
