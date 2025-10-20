if ($PSEdition -eq 'Core') {
    Get-ChildItem -Path $PSScriptRoot\lib\Core\ -Filter *.dll | ForEach-Object {
        Try {
            Add-Type -Path $_.FullName -ErrorAction Stop
        } Catch {
            Write-Warning "Could not load assembly: $_"
        }
    }
} else {
    Get-ChildItem -Path $PSScriptRoot\lib\Desktop\ -Exclude 'System.Formats.Asn1.dll' | where-object Extension -EQ '.dll' | ForEach-Object {
        Try {
            Add-Type -Path $_.FullName -ErrorAction Stop
        } Catch {
            Write-Warning "Could not load assembly: $_"
        }
    }
}

function Get-Banner{
    write-host -fore DarkGreen "    ____           _ __  __  ___        __     __    "
    write-host -fore DarkGreen "   / __/_ _  ___ _(_/ / /  |/  /__  ___/ /_ __/ /__  "
    write-host -fore DarkGreen "  / _//  ' \/ _ '/ / / / /|_/ / _ \/ _  / // / / -_) "
    write-host -fore DarkGreen " /___/_/_/_/\_,_/_/_/ /_/  /_/\___/\_,_/\_,_/_/\__/  "

    write-host -no "Cmdlets available:"
    write-host -no " "
    write-host -fore Yellow "Send-Email"

    write-host -no "Get help for Send-Email cmdlet:"
    write-host -no " "
    write-host -fore Yellow "Get-Help Send-Email or Send-Email -?"
}
Get-Banner
