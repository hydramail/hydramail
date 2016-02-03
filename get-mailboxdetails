#accept one input after the command
param([string]$domain)

#run this in exchange powershell
Add-PSSnapin *exchange*

#create a wildcard address from the domain
$wildcard = "*@" + $domain

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
$object | Add-Member -Name 'Count' -MemberType Noteproperty -Value $count
$object | Add-Member -Name 'Size' -MemberType Noteproperty -Value $size
$object | Add-Member -Name 'Last Logon' -MemberType Noteproperty -Value $logon
$array += $object

}
#print the array
$array
