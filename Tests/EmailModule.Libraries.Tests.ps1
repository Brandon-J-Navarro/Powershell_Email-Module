# EmailModule.Libraries.Tests.ps1

BeforeAll {
    # Create mock directory structure and files for testing
    $TestDrive = $TestDrive
    $MockScriptRoot = Join-Path $TestDrive "MockModule"
    New-Item -Path $MockScriptRoot -ItemType Directory -Force
    
    # Create mock lib directories
    $CoreLibPath = Join-Path $MockScriptRoot "lib\Core"
    $DesktopLibPath = Join-Path $MockScriptRoot "lib\Desktop"
    New-Item -Path $CoreLibPath -ItemType Directory -Force
    New-Item -Path $DesktopLibPath -ItemType Directory -Force
    
    # Create mock DLL files
    New-Item -Path (Join-Path $CoreLibPath "TestAssembly1.dll") -ItemType File -Force
    New-Item -Path (Join-Path $CoreLibPath "TestAssembly2.dll") -ItemType File -Force
    New-Item -Path (Join-Path $CoreLibPath "MimeKit.dll") -ItemType File -Force
    
    New-Item -Path (Join-Path $DesktopLibPath "TestAssembly1.dll") -ItemType File -Force
    New-Item -Path (Join-Path $DesktopLibPath "TestAssembly2.dll") -ItemType File -Force
    New-Item -Path (Join-Path $DesktopLibPath "System.Formats.Asn1.dll") -ItemType File -Force
    New-Item -Path (Join-Path $DesktopLibPath "MimeKit.dll") -ItemType File -Force
    New-Item -Path (Join-Path $DesktopLibPath "NotADll.txt") -ItemType File -Force
    
    # Create a modified version of the Libraries script for testing
    $TestLibrariesScript = @"
# Modified version for testing - uses mock paths and Add-Type simulation
`$PSScriptRoot = '$MockScriptRoot'

# Mock Add-Type to avoid actually loading assemblies in tests
function Mock-AddType {
    param([string]`$Path, [string]`$ErrorAction)
    
    # Simulate failure for specific test files
    if (`$Path -like "*TestAssembly2.dll") {
        throw "Simulated assembly load failure"
    }
    
    # Track what was "loaded"
    if (-not `$global:MockLoadedAssemblies) {
        `$global:MockLoadedAssemblies = @()
    }
    `$global:MockLoadedAssemblies += `$Path
}

# Replace Add-Type with our mock
if (-not `$global:OriginalAddType) {
    `$global:OriginalAddType = Get-Command Add-Type
}

# Override Add-Type for this test
Set-Alias -Name Add-Type -Value Mock-AddType -Scope Global -Force

if (`$PSEdition -eq 'Core') {
    Get-ChildItem -Path `$PSScriptRoot\lib\Core\ -Filter *.dll | ForEach-Object {
        Try {
            Add-Type -Path `$_.FullName -ErrorAction Stop
        } Catch {
            Write-Warning "Could not load assembly: `$_"
        }
    }
} else {
    Get-ChildItem -Path `$PSScriptRoot\lib\Desktop\ -Exclude 'System.Formats.Asn1.dll' | where-object Extension -EQ '.dll' | ForEach-Object {
        Try {
            Add-Type -Path `$_.FullName -ErrorAction Stop
        } Catch {
            Write-Warning "Could not load assembly: `$_"
        }
    }
}

function Get-Banner{
    write-host -fore DarkGreen "    ____           _ __  __  ___        __     __    "
    write-host -fore DarkGreen "   / __/_ _  ___ _(_/ / /  |/  /__  ___/ /_ **/ /**  "
    write-host -fore DarkGreen "  / _//  ' \/_ '/ / / / /|_/ / _\/_  / // / / -_) "
    write-host -fore DarkGreen " /___/_/_/_/\_,_/_/_/ /_/  /_/\___/\_,_/\_,_/_/\__/  "
  
    write-host -no "Cmdlets available:"
    write-host -no " "
    write-host -fore Yellow "Send-Email"
  
    write-host -no "Get help for Send-Email cmdlet:"
    write-host -no " "
    write-host -fore Yellow "Get-Help Send-Email or Send-Email -?"
}
"@
    
    $TestLibrariesPath = Join-Path $MockScriptRoot "EmailModule.Libraries.ps1"
    Set-Content -Path $TestLibrariesPath -Value $TestLibrariesScript
    
    # Initialize global tracking variable
    $global:MockLoadedAssemblies = @()
}

Describe "EmailModule.Libraries.ps1 - PowerShell Core Edition" {
    BeforeEach {
        # Clear the mock loaded assemblies tracking
        $global:MockLoadedAssemblies = @()
        
        # Force PSEdition to Core for this test
        $global:OriginalPSEdition = $PSEdition
        Set-Variable -Name PSEdition -Value 'Core' -Scope Global -Force
    }
    
    AfterEach {
        # Restore original PSEdition
        if ($global:OriginalPSEdition) {
            Set-Variable -Name PSEdition -Value $global:OriginalPSEdition -Scope Global -Force
        }
    }
    
    Context "Core Edition Assembly Loading" {
        It "Should load assemblies from Core directory when PSEdition is Core" {
            # Execute the libraries script
            & (Join-Path $MockScriptRoot "EmailModule.Libraries.ps1")
            
            # Check that Core assemblies were loaded
            $CorePath = Join-Path $MockScriptRoot "lib\Core"
            $global:MockLoadedAssemblies | Should -Contain (Join-Path $CorePath "TestAssembly1.dll")
            $global:MockLoadedAssemblies | Should -Contain (Join-Path $CorePath "MimeKit.dll")
        }
        
        It "Should not load assemblies from Desktop directory when PSEdition is Core" {
            # Execute the libraries script
            & (Join-Path $MockScriptRoot "EmailModule.Libraries.ps1")
            
            # Check that Desktop assemblies were NOT loaded
            $DesktopPath = Join-Path $MockScriptRoot "lib\Desktop"
            $global:MockLoadedAssemblies | Should -Not -Contain (Join-Path $DesktopPath "TestAssembly1.dll")
        }
        
        It "Should attempt to load all DLL files in Core directory" {
            # Execute the libraries script
            $Output = & (Join-Path $MockScriptRoot "EmailModule.Libraries.ps1") 3>&1
            
            # Should have attempted to load 3 DLLs (TestAssembly1, TestAssembly2, MimeKit)
            # TestAssembly2 should fail and generate a warning
            $Warnings = $Output | Where-Object { $_ -is [System.Management.Automation.WarningRecord] }
            $Warnings | Should -Not -BeNullOrEmpty
            $Warnings[0].Message | Should -Match "Could not load assembly.*TestAssembly2"
        }
        
        It "Should filter only .dll files from Core directory" {
            # Add a non-DLL file to Core directory
            New-Item -Path (Join-Path $MockScriptRoot "lib\Core\NotADll.txt") -ItemType File -Force
            
            # Execute the libraries script
            & (Join-Path $MockScriptRoot "EmailModule.Libraries.ps1")
            
            # Should not attempt to load the .txt file
            $global:MockLoadedAssemblies | Should -Not -Contain (Join-Path $MockScriptRoot "lib\Core\NotADll.txt")
        }
    }
}

Describe "EmailModule.Libraries.ps1 - Desktop Edition" {
    BeforeEach {
        # Clear the mock loaded assemblies tracking
        $global:MockLoadedAssemblies = @()
        
        # Force PSEdition to Desktop for this test
        $global:OriginalPSEdition = $PSEdition
        Set-Variable -Name PSEdition -Value 'Desktop' -Scope Global -Force
    }
    
    AfterEach {
        # Restore original PSEdition
        if ($global:OriginalPSEdition) {
            Set-Variable -Name PSEdition -Value $global:OriginalPSEdition -Scope Global -Force
        }
    }
    
    Context "Desktop Edition Assembly Loading" {
        It "Should load assemblies from Desktop directory when PSEdition is Desktop" {
            # Execute the libraries script
            & (Join-Path $MockScriptRoot "EmailModule.Libraries.ps1")
            
            # Check that Desktop assemblies were loaded
            $DesktopPath = Join-Path $MockScriptRoot "lib\Desktop"
            $global:MockLoadedAssemblies | Should -Contain (Join-Path $DesktopPath "TestAssembly1.dll")
            $global:MockLoadedAssemblies | Should -Contain (Join-Path $DesktopPath "MimeKit.dll")
        }
        
        It "Should not load assemblies from Core directory when PSEdition is Desktop" {
            # Execute the libraries script
            & (Join-Path $MockScriptRoot "EmailModule.Libraries.ps1")
            
            # Check that Core assemblies were NOT loaded
            $CorePath = Join-Path $MockScriptRoot "lib\Core"
            $global:MockLoadedAssemblies | Should -Not -Contain (Join-Path $CorePath "TestAssembly1.dll")
        }
        
        It "Should exclude System.Formats.Asn1.dll from Desktop directory" {
            # Execute the libraries script
            & (Join-Path $MockScriptRoot "EmailModule.Libraries.ps1")
            
            # Check that System.Formats.Asn1.dll was NOT loaded
            $DesktopPath = Join-Path $MockScriptRoot "lib\Desktop"
            $global:MockLoadedAssemblies | Should -Not -Contain (Join-Path $DesktopPath "System.Formats.Asn1.dll")
        }
        
        It "Should filter only .dll files and exclude non-DLL files" {
            # Execute the libraries script
            & (Join-Path $MockScriptRoot "EmailModule.Libraries.ps1")
            
            # Should not load the .txt file
            $global:MockLoadedAssemblies | Should -Not -Contain (Join-Path $MockScriptRoot "lib\Desktop\NotADll.txt")
        }
        
        It "Should handle assembly loading failures gracefully" {
            # Execute the libraries script (TestAssembly2.dll will fail to load)
            $Output = & (Join-Path $MockScriptRoot "EmailModule.Libraries.ps1") 3>&1
            
            # Should generate a warning for the failed assembly
            $Warnings = $Output | Where-Object { $_ -is [System.Management.Automation.WarningRecord] }
            $Warnings | Should -Not -BeNullOrEmpty
            $Warnings[0].Message | Should -Match "Could not load assembly.*TestAssembly2"
        }
    }
}

Describe "Get-Banner Function" {
    Context "Banner Display" {
        It "Should execute Get-Banner without errors" {
            # Execute the libraries script to define Get-Banner
            & (Join-Path $MockScriptRoot "EmailModule.Libraries.ps1")
            
            { Get-Banner } | Should -Not -Throw
        }
        
        It "Should output banner content" {
            # Execute the libraries script to define Get-Banner
            & (Join-Path $MockScriptRoot "EmailModule.Libraries.ps1")
            
            # Capture the output
            $Output = Get-Banner | Out-String
            $Output | Should -Not -BeNullOrEmpty
        }
        
        It "Should mention Send-Email cmdlet in banner" {
            # Execute the libraries script to define Get-Banner
            & (Join-Path $MockScriptRoot "EmailModule.Libraries.ps1")
            
            # Capture the output and check for Send-Email mention
            $Output = Get-Banner 6>&1 | Out-String
            $Output | Should -Match "Send-Email"
        }
    }
}

Describe "Error Handling and Edge Cases" {
    Context "Missing Directories" {
        BeforeEach {
            $global:MockLoadedAssemblies = @()
        }
        
        It "Should handle missing Core lib directory gracefully" {
            # Remove the Core directory
            Remove-Item -Path (Join-Path $MockScriptRoot "lib\Core") -Recurse -Force
            
            # Force PSEdition to Core
            Set-Variable -Name PSEdition -Value 'Core' -Scope Global -Force
            
            # Should not throw an error
            { & (Join-Path $MockScriptRoot "EmailModule.Libraries.ps1") } | Should -Not -Throw
        }
        
        It "Should handle missing Desktop lib directory gracefully" {
            # Remove the Desktop directory
            Remove-Item -Path (Join-Path $MockScriptRoot "lib\Desktop") -Recurse -Force
            
            # Force PSEdition to Desktop
            Set-Variable -Name PSEdition -Value 'Desktop' -Scope Global -Force
            
            # Should not throw an error
            { & (Join-Path $MockScriptRoot "EmailModule.Libraries.ps1") } | Should -Not -Throw
        }
        
        It "Should handle empty lib directories gracefully" {
            # Clear all files from directories
            Get-ChildItem -Path (Join-Path $MockScriptRoot "lib\Core") | Remove-Item -Force
            Get-ChildItem -Path (Join-Path $MockScriptRoot "lib\Desktop") | Remove-Item -Force
            
            # Should not throw an error
            { & (Join-Path $MockScriptRoot "EmailModule.Libraries.ps1") } | Should -Not -Throw
            
            # Should not load any assemblies
            $global:MockLoadedAssemblies | Should -BeNullOrEmpty
        }
    }
}

AfterAll {
    # Restore original Add-Type command
    if ($global:OriginalAddType) {
        Set-Alias -Name Add-Type -Value $global:OriginalAddType.Name -Scope Global -Force
    }
    
    # Clean up global variables
    Remove-Variable -Name MockLoadedAssemblies -Scope Global -ErrorAction SilentlyContinue
    Remove-Variable -Name OriginalAddType -Scope Global -ErrorAction SilentlyContinue
    Remove-Variable -Name OriginalPSEdition -Scope Global -ErrorAction SilentlyContinue
    
    # Restore PSEdition if it was modified
    if ($global:OriginalPSEdition) {
        Set-Variable -Name PSEdition -Value $global:OriginalPSEdition -Scope Global -Force
    }
}
