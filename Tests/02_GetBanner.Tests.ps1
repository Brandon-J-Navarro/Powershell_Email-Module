Describe "EmailModule - Get-Banner" {
    It "Should execute Get-Banner without errors" {
        { Get-Banner } | Should -Not -Throw
    }

    It "Should display Send-Email in banner" {
        Mock Write-Host { } -ModuleName EmailModule
        Get-Banner
        Assert-MockCalled Write-Host -Times 7 -Scope It -ModuleName EmailModule
    }
}
