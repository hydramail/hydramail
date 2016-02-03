#accept one input after the command
param([string]$domain)

#run this in exchange powershell
Add-PSSnapin *exchange*

#create a wildcard address from the domain
$wildcard = "*@" + $domain

#get the list of distribution groups with that domain
$groups = Get-DistributionGroup -ResultSize Unlimited | where {$_.grouptype -like "Universal"} | where {$_.primarysmtpaddress -like $wildcard}

#loop through the distribution groups and pull out the users
foreach ($group in $groups){
$group.name
get-distributiongroup -identity $group.name | get-distributiongroupmember | ft primarysmtpaddress
}
