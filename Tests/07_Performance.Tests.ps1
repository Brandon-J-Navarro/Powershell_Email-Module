Describe "Send-Email - Performance" {
    BeforeEach { [EmailCommands]::Reset() }

    It "Should execute Send-Email within 500ms for normal parameters" {
        $Params = @{
            AuthUser="a"; AuthPass="b"; EmailTo="c"; EmailFrom="d"; Subject="s"; Body="b"; SmtpServer="s"
        }
        Measure-Command { Send-Email @Params }.TotalMilliseconds | Should -BeLessThan 500
    }

    It "Should handle 100 sequential emails without throwing" {
        for ($i=0; $i -lt 100; $i++) {
            { Send-Email -AuthUser "a" -AuthPass "b" -EmailTo "c$i@test.com" -EmailFrom "d@test.com" `
                -Subject "Test $i" -Body "Body $i" -SmtpServer "s" } | Should -Not -Throw
        }
    }
}
