###################### ADMIN PASSWORDS NOTIFICATIONS ######################

$DAYS = <# NUMBER OF DAYS #>
$DomainAdmins = Get-ADGroupMember -Identity "Domain Admins" | Get-ADUser -Properties DisplayName, Enabled, pwdLastSet | Where-Object { $_.Enabled -eq $true -and $_.UserPrincipalName -ne $null}
$EnterpriseAdmins = Get-ADGroupMember -Identity "Enterprise Admins" | Get-ADUser -Properties DisplayName, Enabled, pwdLastSet | Where-Object { $_.Enabled -eq $true -and $_.UserPrincipalName -ne $null}
$users = $DomainAdmins + $EnterpriseAdmins
$badUsers = @()
$AdminOldPass = "Domain.com admin accounts that haven't reset password in $DAYS days`n`n"
foreach($user in $users){
    $PasswordSetDate = [datetime]::FromFileTimeUtc($user.pwdLastSet)
    if ($PasswordSetDate -le (Get-Date).Date.AddDays(-$DAYS)) {
        $daysSince = $PasswordSetDate - (Get-Date)
        $AdminOldPass += "Display Name:      $($user.Name)`n"
        $AdminOldPass += "Password Set Date: $($PasswordSetDate.DateTime)`n"
        $AdminOldPass += "Days Since Set:    $(($daysSince.Days).ToString().Replace('-',''))`n`n"
        $badUsers += $user
    }
}
$AdminOldPass += "Please update your admin account password.`n`n"
$AdminOldPass += "Thank you for your attention to this matter.`n"

if (0 -lt $badUsers.Count) {
    $AuthUser = "DoNotReply@Domain.com"
    $AuthPass = "**********************"
    $To = "DistributionName@Domain.com"
    $ToName = "DistributionName"
    $From = "DoNotReply@Domain.com"
    $FromName = "DoNotReply"
    $Subject = "Admin accounts that have not reset password in $DAYS days"
    $Body = $AdminOldPass
    $MailServer = "mail.Domain.com"
    $ServerPort = "587"

    Send-Email -AuthUser $AuthUser -AuthPass $AuthPass `
        -EmailTo $To -EmailToName $ToName `
        -EmailFrom $From -EmailFromName $FromName `
        -EmailCc $Cc -CcName $CcName `
        -Subject $Subject -Body $Body `
        -SmtpServer $MailServer -SmtpPort $ServerPort
}
