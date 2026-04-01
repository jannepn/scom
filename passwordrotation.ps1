New-SCOMManagementGroupConnection -ComputerName localhost

$domain = Get-ADDomain | select netbiosname -ExpandProperty netbiosname
$accounts = Get-SCOMRunAsAccount | Where-Object {($_.AccountType -eq "SCOMWindowsCredentialSecureData" -or $_.AccountType -eq "SCOMActionAccountSecureData") -and $_.domain -eq "$($domain)"}


$actioncred = $accounts | Where-Object {$_.accounttype -eq "SCOMActionAccountSecureData"}
$windowscred = $accounts | Where-Object {$_.accounttype -eq "SCOMWindowsCredentialSecureData"}

foreach ($account in $windowscred)
{
    $PW = [System.Web.Security.Membership]::GeneratePassword(21,3)
     # The password as it is now:
    write-host "$($account.name) has new password: $PW"
     # Converted to SecureString
    $SecurePass = $PW | ConvertTo-SecureString -AsPlainText -Force
    $aduser = get-aduser $account.UserName
    Set-ADAccountPassword $aduser -NewPassword $SecurePass 


    $UserName = "$($domain)\$($account.username)"
    $NewCred = New-Object System.Management.Automation.PSCredential $UserName, $SecurePass

    Get-SCOMRunAsAccount -Name "$($account.name)" | Update-SCOMRunAsAccount -RunAsCredential $NewCred 
    if (($actioncred | Where-Object {$_.username -eq "$($account.username)"}).count -gt 0)
    {
        write-host "$($account.name) has an action account as well" -ForegroundColor red
        $actioncredaccount = $actioncred | Where-Object {$_.username -eq "$($account.username)"}
        $SecurePass = $PW | ConvertTo-SecureString -AsPlainText -Force
        $NewCred = New-Object System.Management.Automation.PSCredential $UserName, $SecurePass
        Get-SCOMRunAsAccount -Name "$($actioncredaccount.name)" | Update-SCOMRunAsAccount -RunAsCredential $NewCred 
    }
    
}


foreach ($account in $actioncred)
{
    if (($windowscred | Where-Object {$_.username -eq "$($account.username)"}).count -lt 0)
    {
        $PW = [System.Web.Security.Membership]::GeneratePassword(21,3)
         # The password as it is now:
        write-host "$($account.name) has new password: $PW"
         # Converted to SecureString
        $SecurePass = $PW | ConvertTo-SecureString -AsPlainText -Force
            $aduser = get-aduser $account.UserName
        Set-ADAccountPassword $aduser -NewPassword $SecurePass -WhatIf


        $UserName = "$($domain)\$($account.username)"
        $NewCred = New-Object System.Management.Automation.PSCredential $UserName, $SecurePass

        Get-SCOMRunAsAccount -Name "$($account.name)" | Update-SCOMRunAsAccount -RunAsCredential $NewCred 
        if (($actioncred | Where-Object {$_.username -eq "$($account.username)"}).count -gt 0)
        {
            $SecurePass = $PW | ConvertTo-SecureString -AsPlainText -Force
            write-host "$($account.name) has an action account as well" -ForegroundColor red
            $actioncredaccount = $actioncred | Where-Object {$_.username -eq "$($account.username)"}
            $NewCred = New-Object System.Management.Automation.PSCredential $UserName, $SecurePass
            Get-SCOMRunAsAccount -Name "$($actioncredaccount.name)" | Update-SCOMRunAsAccount -RunAsCredential $NewCred
        }
    }    
}
