###################### DOMAIN INACTIVITY NOTIFICATIONS ######################

$DAYS = <# NUMBER OF DAYS #>
$LastLogonDate = Get-ADUser -Filter { Enabled -eq $True -and PasswordNeverExpires -eq $False } -SearchScope OneLevel -SearchBase ('OU=Users,DC=Domain,DC=com') -Properties LastLogonDate | Where-Object { $_.LastLogonDate -le (Get-Date).Date.AddDays(-$DAYS) } | Select-Object Name, SamAccountName, LastLogonDate

if (0 -lt $LastLogonDate.SamAccountName.Count) {
    $DisabledMessage = "Domain accounts disabled for $DAYS days of inactivity`n`n"
    for ($i = 0; $i -lt $LastLogonDate.SamAccountName.Count; $i++) {
        Disable-ADAccount -Identity $LastLogonDate[$i].SamAccountName -Verbose -WhatIf # What if, NOT disabling user or removing group
        $DisabledMessage += "Display Name:    $($LastLogonDate[$i].Name)`n"
        $DisabledMessage += "Last Login Date: $($LastLogonDate[$i].LastLogonDate.DateTime)`n"
        $DisabledMessage += "Date Disabled:   $((Get-Date).DateTime)`n`n"
        $UserGroups = Get-ADPrincipalGroupMembership -Identity $LastLogonDate[$i].SamAccountName
        for ($j = 0; $j -lt $UserGroups.SamAccountName.Count; $j++) {
            Remove-ADGroupMember -Identity $UserGroups[$j].SamAccountName -Members $LastLogonDate[$i].SamAccountName -WhatIf # What if, NOT disabling user or removing group
        }
    }
    $DisabledMessage  += "Please have you supervisor contact the System Administrator to reactive your account`n`n"
    $DisabledMessage  += "Thank you for your attention to this matter.`n"

    $AuthUser = "DoNotReply@Domain.com"
    $AuthPass = "**********************"
    $To = "DistributionName@Domain.com"
    $ToName = "DistributionName"
    $From = "DoNotReply@Domain.com"
    $FromName = "DoNotReply"
    $Subject = "Domain accounts disabled for $DAYS days of inactivity"
    $Body = $DisabledMessage
    $MailServer = "mail.Domain.com"
    $ServerPort = "587"

    Send-Email -AuthUser $AuthUser -AuthPass $AuthPass `
        -EmailTo $To -EmailToName $ToName `
        -EmailFrom $From -EmailFromName $FromName `
        -Subject $Subject -Body $Body `
        -SmtpServer $MailServer -SmtpPort $ServerPort
}
