Describe "Send-Email - Execution" {
    BeforeEach { [EmailCommands]::Reset() }

    It "Should pass all parameters correctly to EmailCommands.SendEmail" {
        $TestParams = @{
            AuthUser="a"; AuthPass="b"; EmailTo="c"; EmailToName="d"; EmailFrom="e"
            EmailFromName="f"; Subject="subj"; Body="body"; SmtpServer="s"; SmtpPort=465
        }
        Send-Email @TestParams

        foreach ($key in $TestParams.Keys) {
            $MockValue = [EmailCommands]::("Last" + $key)
            $MockValue | Should -Be $TestParams[$key]
        }
    }

    It "Should throw exception when EmailCommands fails" {
        [EmailCommands]::LastCallSuccessful = $false
        { Send-Email -AuthUser "a" -AuthPass "b" -EmailTo "c" -EmailFrom "d" -Subject "s" -Body "b" -SmtpServer "s" } | Should -Throw "*Simulated email sending failure*"
    }
}
