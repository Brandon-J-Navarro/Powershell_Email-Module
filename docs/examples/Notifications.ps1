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

###################### INACTIVITY NOTIFICATIONS ######################

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

###################### INACTIVITY NOTIFICATIONS ######################

$DAYS = <# NUMBER OF DAYS #>
$client_secret = <# Azure MicrosoftGraph Enterprise Application Application ID Client Secret #>
$method = "POST" 
$tenant = <# Azure Directory ID #>
$client_id <# Azure MicrosoftGraph Enterprise Application Application ID #>
$uri = "https://login.microsoftonline.com/$tenant/oauth2/v2.0/token"
$body = @{
    client_id = $client_id
    tenant = $tenant
    scope = 'https://graph.microsoft.com/.default'
    client_secret = $client_secret
    grant_type = 'client_credentials'
}

$response = Invoke-RestMethod -Uri $uri -Method $method -Body $body
$token = $response.access_token
Connect-MgGraph -Environment Global -AccessToken (ConvertTo-SecureString $token -AsPlainText -Force) -NoWelcome
$users = Get-MgUser -All -Property "DisplayName", "UserPrincipalName", "SignInActivity", "AccountEnabled", "MemberOf", "OnPremisesSyncEnabled"
$userData = @()

foreach ($user in $users) {
    $lastLoginDate = $user.SignInActivity.LastSignInDateTime
    $userData += [PSCustomObject]@{
        Id                = $user.Id
        UserPrincipalName = $user.UserPrincipalName
        DisplayName       = $user.DisplayName
        LastLoginDate     = $lastLoginDate
        AccountEnabled    = $user.AccountEnabled
        OnPremisesSyncEnabled    = $user.OnPremisesSyncEnabled
    }
}

$InactiveUsers = $userData | Where-Object { $_.LastLoginDate.Date -le (Get-Date).Date.AddDays(-$DAYS) -and $_.AccountEnabled -eq $true }
if (0 -lt $InactiveUsers.UserPrincipalName.Count) {
    $DisabledMessage = "Azure accounts disabled for $DAYS days of inactivity`n`n"
    for ($i = 0; $i -lt $InactiveUsers.UserPrincipalName.Count; $i++) {
        $params = @{
            AccountEnabled = $false
        }
        Update-MgUser -UserId $InactiveUsers[$i].Id -BodyParameter $params -WhatIf # What if, NOT disabling user or removing group
        $DisabledMessage += "Display Name:    $($InactiveUsers[$i].DisplayName)`n"
        $DisabledMessage += "Last Login Date: $($InactiveUsers[$i].LastLoginDate.DateTime)`n"
        $DisabledMessage += "Date Disabled:   $((Get-Date).DateTime)`n`n"
        $Groups = Get-MgUserMemberOf -UserId $($InactiveUsers[$i].Id) -Property "Id", "displayName"
        for ($j = 0; $j -lt $Groups.Id.Count; $j++) {
            Remove-MgGroupMemberByRef -GroupId $Groups[$j].Id -DirectoryObjectId $InactiveUsers[$i].Id -WhatIf # What if, NOT disabling user or removing group
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
    $Subject = "Azure accounts disabled for $DAYS days of inactivity"
    $Body = $DisabledMessage
    $MailServer = "mail.Domain.com"
    $ServerPort = "587"

    Send-Email -AuthUser $AuthUser -AuthPass $AuthPass `
        -EmailTo $To -EmailToName $ToName `
        -EmailFrom $From -EmailFromName $FromName `
        -Subject $Subject -Body $Body `
        -SmtpServer $MailServer -SmtpPort $ServerPort
}

###################### PASSWORDS NOTIFICATIONS ######################

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
