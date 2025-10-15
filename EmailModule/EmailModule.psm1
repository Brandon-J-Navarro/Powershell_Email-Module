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
