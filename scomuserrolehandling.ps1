$users = Get-SCOMUserRole | select users -ExpandProperty users

$domain = Get-ADDomain | select netbiosname -ExpandProperty netbiosname

$datum = (get-date).AddDays(-365)

Write-host "Verify that these users still needs access:"

foreach ($u in $users)
{
    if($u -like "*$domain*")
    {
        $usernamn = $u.substring(7)
        get-aduser $usernamn -Properties * | Where-Object {$_.lastlogondate -lt $datum -or $_.enabled -eq $false} | select name,lastlogondate,enabled

    }
}





$role = add-SCOMUserRole -DisplayName "ReadOnly - AppTeam" -ReadOnlyOperator -Description "Read-only access for Application Team"

$members = "$($domain)\zzzz0001"

$group = Get-SCOMGroup -DisplayName "Appteam"

$role | set-SCOMUserRole -User ($role.users + "$members")

$role | set-SCOMUserRole -GroupScope $group



