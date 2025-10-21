Describe "EmailModule - Module Loading" {
    It "Should load the module without errors" {
        { Import-Module $Global:ModulePath -Force } | Should -Not -Throw
    }

    It "Should export only Send-Email function" {
        $ExportedCommands = Get-Command -Module EmailModule
        $ExportedCommands.Count | Should -Be 1
        $ExportedCommands.Name | Should -Be "Send-Email"
    }

    It "Should have Get-Banner available internally" {
        { Get-Banner } | Should -Not -Throw
    }
}
