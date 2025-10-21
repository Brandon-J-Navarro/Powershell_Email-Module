# EmailModule.Integration.Tests.ps1

BeforeAll {
    # Determine module path (one level up from Tests folder)
    $ModulePath = Join-Path $PSScriptRoot '..\EmailModule.psm1'
    $LibPath = Join-Path $PSScriptRoot '..\lib'

    if (-not (Test-Path $LibPath)) {
        Write-Warning "Integration tests skipped - lib directory not found"
        return
    }

    Import-Module $ModulePath -Force
}

Describe "EmailModule Integration Tests" -Tag "Integration" {

    #
    # Context 1: PowerShell Core (Cross-platform)
    #
    Context "Assembly Loading on PowerShell Core" {
        BeforeEach {
            Mock Get-Variable -ParameterFilter { $Name -eq 'PSEdition' } -MockWith {
                [pscustomobject]@{ Value = 'Core' }
            }
        }

        It "Should load required assemblies for Core edition" {
            $ExpectedPath = Join-Path $PSScriptRoot '..\lib\Core'

            if (Test-Path $ExpectedPath) {
                $Assemblies = Get-ChildItem -Path $ExpectedPath -Filter "*.dll"
                $Assemblies.Count | Should -BeGreaterThan 0

                { [EmailCommands] } | Should -Not -Throw
            } else {
                Set-ItResult -Pending -Because "Expected Core library path does not exist"
            }
        }
    }

    #
    # Context 2: Windows PowerShell Desktop
    #
    Context "Assembly Loading on Windows PowerShell (Desktop)" {
        BeforeEach {
            Mock Get-Variable -ParameterFilter { $Name -eq 'PSEdition' } -MockWith {
                [pscustomobject]@{ Value = 'Desktop' }
            }
        }

        It "Should load required assemblies for Desktop edition" {
            $ExpectedPath = Join-Path $PSScriptRoot '..\lib\Desktop'

            if (Test-Path $ExpectedPath) {
                $Assemblies = Get-ChildItem -Path $ExpectedPath -Filter "*.dll"
                $Assemblies.Count | Should -BeGreaterThan 0

                { [EmailCommands] } | Should -Not -Throw
            } else {
                Set-ItResult -Pending -Because "Expected Desktop library path does not exist"
            }
        }
    }

    #
    # Shared validation (runs regardless of edition)
    #
    Context "Shared assembly behavior" {
        It "Should have EmailCommands class available" {
            { [EmailCommands] } | Should -Not -Throw
        }

        It "Should have SendEmail method available" {
            $Methods = [EmailCommands].GetMethods() | Where-Object { $_.Name -eq 'SendEmail' }
            $Methods.Count | Should -BeGreaterThan 0
        }
    }
}
