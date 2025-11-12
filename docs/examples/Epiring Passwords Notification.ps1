###################### EXPIRING PASSWORDS NOTIFICATIONS ######################

$DAYS = <# NUMBER OF DAYS #>
$PasswordExpirationDate = Get-ADUser -Filter { Enabled -eq $True -and PasswordNeverExpires -eq $False } -SearchScope OneLevel -SearchBase ('OU=Users,DC=Domain,DC=com') -Properties 'DisplayName', 'msDS-UserPasswordExpiryTimeComputed' | Select-Object -Property 'displayName', @{Name = 'ExpirationDate'; Expression = { [datetime]::FromFileTime($_.'msDS-UserPasswordExpiryTimeComputed') } } | Where-Object { $_.ExpirationDate -le (Get-Date).Date.AddDays($DAYS) } | Select-Object DisplayName, ExpirationDate

if (0 -lt $PasswordExpirationDate.displayName.Count) {
    $EmailBody = "Domain accounts with passwords expiring within $DAYS days `n`n"
    for ($i = 0; $i -lt $PasswordExpirationDate.displayName.Count; $i++) {
        $EmailBody += "Display Name:    $($PasswordExpirationDate[$i].DisplayName)`n"
        $EmailBody += "Expiration Date: $($PasswordExpirationDate[$i].ExpirationDate.DateTime)`n`n"
    }
    $EmailBody += "To reset your Domain password go to the link below and select forgot password`n" 
    $EmailBody += "https://passwordreset.microsoftonline.com/`n`n"
    $EmailBody += "Thank you for your attention to this matter.`n"

    $AuthUser = "DoNotReply@Domain.com"
    $AuthPass = "**********************"
    $To = "DistributionName@Domain.com"
    $ToName = "DistributionName"
    $From = "DoNotReply@Domain.com"
    $FromName = "DoNotReply"
    $Subject = "Domain accounts with passwords expiring within $DAYS days"
    $Body = $EmailBody
    $MailServer = "mail.Domain.com"
    $ServerPort = "587"

    Send-Email -AuthUser $AuthUser -AuthPass $AuthPass `
        -EmailTo $To -EmailToName $ToName `
        -EmailFrom $From -EmailFromName $FromName `
        -Subject $Subject -Body $Body `
        -SmtpServer $MailServer -SmtpPort $ServerPort
}
