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
