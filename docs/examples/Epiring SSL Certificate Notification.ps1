###################### EXPIRING SSL CERTIFICATE NOTIFICATIONS ######################

$DAYS = <# NUMBER OF DAYS #>
$Thumbprint = <# CERTIFICATE THUMBPRINT #>
$Certificate = Get-ChildItem -Path "Cert:\LocalMachine\WebHosting" | Where-Object Thumbprint -EQ $Thumbprint

if ($Certificate.NotAfter -le (Get-Date).Date.AddDays($DAYS)) {
    $EmailBody = "Certificate $($Certificate.FriendlyName) Expires Within $DAYS days `n`n"
    $EmailBody += "FriendlyName: $($Certificate.FriendlyName) `n"
    $EmailBody += "Subject:      $($Certificate.Subject) `n"
    $EmailBody += "Thumbprint:   $($Certificate.thumbprint) `n"
    $EmailBody += "SerialNumber: $($Certificate.SerialNumber) `n"
    $EmailBody += "NotBefore:    $($Certificate.NotBefore) `n"
    $EmailBody += "NotAfter:     $($Certificate.NotAfter) `n"
    $EmailBody += "Issuer:       $($Certificate.Issuer) `n"

    $AuthUser = "DoNotReply@Domain.com"
    $AuthPass = "**********************"
    $To = "DistributionName@Domain.com"
    $ToName = "DistributionName"
    $From = "DoNotReply@Domain.com"
    $FromName = "DoNotReply"
    $Subject = "SSL Certificate Expires Within $DAYS days"
    $Body = $EmailBody
    $MailServer = "mail.Domain.com"
    $ServerPort = "587"

    Send-Email -AuthUser $AuthUser -AuthPass $AuthPass `
        -EmailTo $To -EmailToName $ToName `
        -EmailFrom $From -EmailFromName $FromName `
        -Subject $Subject -Body $Body `
        -SmtpServer $MailServer -SmtpPort $ServerPort
} 
