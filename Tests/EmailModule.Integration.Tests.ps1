# EmailModule.Integration.Tests.ps1

BeforeAll {
    # Only run these tests if the actual module assemblies are present
    $ModulePath = Join-Path $PSScriptRoot "EmailModule.psm1"
    $LibPath = Join-Path $PSScriptRoot "lib"
    
    if (-not (Test-Path $LibPath)) {
        Write-Warning "Integration tests skipped - lib directory not found"
        return
    }
    
    Import-Module $ModulePath -Force
}

Describe "EmailModule Integration Tests" -Tag "Integration" {
    
    Context "Assembly Loading" {
        
        It "Should load required assemblies for current PowerShell edition" {
            if ($PSEdition -eq 'Core') {
                $ExpectedPath = Join-Path $PSScriptRoot "lib\Core"
            } else {
                $ExpectedPath = Join-Path $PSScriptRoot "lib\Desktop"
            }
            
            if (Test-Path $ExpectedPath) {
                $Assemblies = Get-ChildItem -Path $ExpectedPath -Filter "*.dll"
                $Assemblies.Count | Should -BeGreaterThan 0
                
                # Check if EmailCommands class is available
                { [EmailCommands] } | Should -Not -Throw
            } else {
                Set-ItResult -Pending -Because "Expected library path does not exist"
            }
        }
        
        It "Should have EmailCommands class available" {
            { [EmailCommands] } | Should -Not -Throw
        }
        
        It "Should have SendEmail method available" {
            $Methods = [EmailCommands].GetMethods() | Where-Object { $_.Name -eq 'SendEmail' }
            $Methods.Count | Should -BeGreaterThan 0
        }
    }
}s
