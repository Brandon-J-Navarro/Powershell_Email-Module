AfterAll {
    Remove-Module EmailModule -Force -ErrorAction SilentlyContinue
    if (Test-Path $Global:TestDrive) {
        Remove-Item $Global:TestDrive -Recurse -Force -ErrorAction SilentlyContinue
    }
}
