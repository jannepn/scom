


#search from name only
#display all subscriptions
$namn = read-host "Vilken subscriber söker du efter?"
$id = Get-SCOMNotificationSubscriber -Name "$namn" | select id -ExpandProperty id

$subscrip = Get-SCOMNotificationSubscription

foreach ($s in $subscrip)
{
    $subname = $s.DisplayName
    $to = $s.ToRecipients
    $cc = $s.CcRecipients
    $bcc = $s.bCcRecipients
    foreach ($t in $to)
    {
        $id2 = $t.id
        if ($id2 -eq $id)
        {
            write-host "$namn is in $subname"
        }
    }
}


#search for email in all subscribers
$subscriber = Get-SCOMNotificationSubscriber 
$subscrip = Get-SCOMNotificationSubscription
$email = read-host "Ange epostadress att söka efter"
foreach ($s in $subscriber) {
    foreach ($d in $s.devices) {
        if ($d.address -like "*$email*") {
            write-host "Email: $email exists in subscriber $($s.Name)" -ForegroundColor Green
            $id = $s.id
foreach ($sub in $subscrip) {
                foreach ($t in $sub.ToRecipients) {
                    if ($t.id -eq $id) {
                        write-host "The $($s.Name) subscriber is in $($sub.DisplayName) subscriptions"
                    }
                }
            }
        }
    }
}



#create new subscriber
Add-SCOMNotificationSubscriber -Name "Mr new guy" -DeviceList "nowhere@somewhere.com"



#replace subscriber
$subscriber = Get-SCOMNotificationSubscriber "janne test"
$id = $subscriber.Id
$subscrip = Get-SCOMNotificationSubscription
$replacewith = Get-SCOMNotificationSubscriber "mr new guy"
$email = "mr new guy"

foreach ($s in $subscrip)
{
    $subname = $s.DisplayName
    $to = $s.ToRecipients
    $toupdate = Get-SCOMNotificationSubscription $subname
    foreach ($t in $to)
    {
        $id2 = $t.id
        if ($id2 -eq $id)
        {
            write-host "Subscriber: $namn is in Subscription: $subname"
            $toupdate.ToRecipients.Add($replacewith)
            $toupdate.ToRecipients.Remove($subscriber)
            $toupdate.update()       
        }
    }
}



#get unused subscribers

 $subscribersunused = Get-SCOMNotificationSubscriber | select id,name

 foreach ($sunused in $subscribersunused)
 {
        $subscrip = Get-SCOMNotificationSubscription
        $isinuse = 0
        $id = $sunused.id
        foreach ($s in $subscrip)
        {
            $to = $s.ToRecipients
            foreach ($t in $to)
            {
                $id2 = $t.id
                if ($id2 -eq $id)
                {
                     $isinuse++
                }
            }
        }
        if ($isinuse -eq 0)
        {
            write-host "$($sunused.id) is not used in any subscription and can be removed."
        }
}
