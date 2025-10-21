Describe "EmailModule - Help" {
    Context "Send-Email help output" {
        It "Should display full help without errors" {
            { Get-Help Send-Email -Full } | Should -Not -Throw
        }

        It "Should contain parameter descriptions" {
            $helpText = Get-Help Send-Email -Full | Out-String
            $helpText | Should -Match "AuthUser"
            $helpText | Should -Match "EmailTo"
            $helpText | Should -Match "Subject"
            $helpText | Should -Match "Body"
        }
    }

    Context "Get-Help short description" {
        It "Should display synopsis" {
            $synopsis = (Get-Help Send-Email).Synopsis
            $synopsis | Should -Not -BeNullOrEmpty
        }
    }
}
