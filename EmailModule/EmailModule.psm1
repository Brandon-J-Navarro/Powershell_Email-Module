# Load the DLLs
Get-ChildItem -Path $PSScriptRoot -Filter *.dll -Exclude 'System.Formats.Asn1.dll' -Recurse | ForEach-Object {
    Try {
        Add-Type -Path $_.FullName -ErrorAction Stop
    } Catch {
        Write-Warning "Could not load assembly: $_"
    }
}

function Send-Email {
    param (
        [string]$AuthUser,
        [string]$AuthPass,
        [string]$EmailTo,
        [string]$EmailToName,
        [string]$EmailFrom,
        [string]$EmailFromName,
        [string]$Subject,
        [string]$Body,
        [string]$SmtpServer,
        [int]$SmtpPort = 587
    )

    [EmailCommands]::SendEmail($AuthUser, $AuthPass, $EmailTo, $EmailToName, $EmailFrom, $EmailFromName, $Subject, $Body, $SmtpServer, $SmtpPort)
}
