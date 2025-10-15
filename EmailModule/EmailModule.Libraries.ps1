if ($PSEdition -eq 'Core') {
    Get-ChildItem -Path $PSScriptRoot\Lib\Core\ -Filter *.dll | ForEach-Object {
        Try {
            Add-Type -Path $_.FullName -ErrorAction Stop
        } Catch {
            Write-Warning "Could not load assembly: $_"
        }
    }
} else { 
    Get-ChildItem -Path $PSScriptRoot\Lib\Desktop\ -Filter *.dll -Exclude 'System.Formats.Asn1.dll' | ForEach-Object {
        Try {
            Add-Type -Path $_.FullName -ErrorAction Stop
        } Catch {
            Write-Warning "Could not load assembly: $_"
        }
    }
}
