Import-Module "$PSScriptRoot/../EmailModule.psd1" -Force

Describe 'Send-Email Function' {
    It 'Exports successfully' {
        (Get-Command Send-Email).Name | Should -Be 'Send-Email'
    }

    It 'Throws an error for missing parameters' {
        { Send-Email } | Should -Throw
    }
}
