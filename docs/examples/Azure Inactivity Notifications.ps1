###################### AZURE INACTIVITY NOTIFICATIONS ######################

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
