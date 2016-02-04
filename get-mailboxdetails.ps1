#accepts the flags -domain and -database
for ( $i = 0; $i -lt $args.count; $i++ ) {
    if ($args[ $i ] -eq "-domain"){ $strDomain=$args[ $i+1 ]}
    if ($args[ $i ] -eq "-database"){ $strDatabase=$args[ $i+1 ]}
}

#run this in exchange powershell
Add-PSSnapin *exchange*


if ($strDomain -ne $null)
{

#create a wildcard address from the domain
$wildcard = "*@" + $strDomain

#get the data and put it in an array
$array = @()
get-mailbox -identity $wildcard -resultsize unlimited | foreach-object {
$dname=$_.DisplayName
$email = $_.primarysmtpaddress
$size=(Get-MailboxStatistics -identity $_).totalitemsize
$count=(Get-MailboxStatistics -identity $_).itemcount
$logon=(Get-MailboxStatistics -identity $_).lastlogontime
$email = $email.Local + "@" + $email.Domain
$object = New-Object -TypeName PSObject
$object | Add-Member -Name 'Email' -MemberType Noteproperty -Value $email
$object | Add-Member -Name 'Domain' -MemberType Noteproperty -Value $strDomain
$object | Add-Member -Name 'Count' -MemberType Noteproperty -Value $count
$object | Add-Member -Name 'Size' -MemberType Noteproperty -Value $size
$object | Add-Member -Name 'Last Logon' -MemberType Noteproperty -Value $logon
$array += $object
}
#print the array
$array | Format-Table
}



if ($strDatabase -ne $null)
{

#pull out the count value for how many enabled domains are on each database
$strDomainList1 = Get-Mailbox -Database $strDatabase  |? {$_.useraccountcontrol -notlike "*accountdisabled*"}

$strDomainList2 = $strDomainList1.CustomAttribute1
$strDomainList2 = $strDomainList2 |  ? { $_ } | sort -uniq

foreach ($strDomain3 in $strDomainList2)
{

}



foreach ($strDomain2 in $strDomainList2)
{

#create a wildcard address from the domain
$wildcard2 = "*@" + $strDomain2

#get the data and put it in an array
$array2 = @()
get-mailbox -identity $wildcard2 -resultsize unlimited | foreach-object {
$dname=$_.DisplayName
$email = $_.primarysmtpaddress
$size=(Get-MailboxStatistics -identity $_).totalitemsize
$count=(Get-MailboxStatistics -identity $_).itemcount
$logon=(Get-MailboxStatistics -identity $_).lastlogontime
$email = $email.Local + "@" + $email.Domain
$object2 = New-Object -TypeName PSObject
$object2 | Add-Member -Name 'Email' -MemberType Noteproperty -Value $email
$object2 | Add-Member -Name 'Domain' -MemberType Noteproperty -Value $strDomain2
$object2 | Add-Member -Name 'Count' -MemberType Noteproperty -Value $count
$object2 | Add-Member -Name 'Size' -MemberType Noteproperty -Value $size
$object2 | Add-Member -Name 'Last Logon' -MemberType Noteproperty -Value $logon
$array2 += $object2
}
#print the array
$array2 | Format-Table
}

}
