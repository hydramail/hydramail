
#####################
#                   #
#  Snapshot Report  #
#      ns1.ovh      #
#                   #
#####################



################
#  HTML Style  #
################

$a = "<style>"
$a = $a + "BODY{background-color:#fff; font-family: verdana; font-size:12px;color:#565b5c;}"
$a = $a + "TABLE{border-width: 1px;border-style: solid;border-color:#bebebe;border-collapse: collapse;text-align: center;}"
$a = $a + "TH{border-width: 1px;padding: 6px;border-style: solid;border-color:#ddd;background-color: #ccc;color:#444;font-weight: normal;}"
$a = $a + "TD{border-width: 1px;padding: 6px;border-style: solid;border-color:#ddd;}"

$a = $a + '
button.accordion {
    background-color: #ddd;
    color: #444;
    cursor: pointer;
    padding: 18px;
    width: 100%;
    border: none;
    text-align: left;
    outline: none;
    font-size: 15px;
    transition: 0.4s;
}

button.accordion.active, button.accordion:hover {
    background-color: #ccc;
}

button.accordion:after {
    content: "\02795";
    font-size: 13px;
    color: #777;
    float: right;
    margin-left: 5px;
}

button.accordion.active:after {
    content: "\2796";
}

div.panel {
    padding: 0 18px;
    background-color: white;
    max-height: 0;
    overflow: hidden;
    transition: 0.6s ease-in-out;
    opacity: 0;
}

div.panel.show {
    opacity: 1;
    max-height: 1000000px;
}
'



$a = $a + "</style>"



################
#  Connecting  #
################


#import the PowerCLI Module if not already in use
If ( ! (Get-module VMware.VimAutomation.Core )) {

Import-Module VMware.VimAutomation.Core

}


Write-Host "vCenter Data Collector"
Write-Host ""

#connect to the correct pod
Write-Host "Options"
Write-Host "-------"
Write-Host "1 - VC1"
Write-Host "2 - VC2"
Write-Host "3 - DRVC"

$pod = Read-Host "What Datacenter are you connecting to?" 

#podconnect is the connection string for the vcenter
$podconnect = "VC1"

#lovely set of if statements to set the mod to the connect to the correct vcenter
if ($pod -eq "2"){$podconnect = "VC2"}
if ($pod -eq "3"){$podconnect = "DRVC"}


Write-Host "vCenter Data Collector"
Write-Host ""


#connect to the correct server
Write-Host "Connecting to " $podconnect
Connect-VIServer $podconnect


$b = '<img src="">'
$b += "</br>"
$b += '<h1>Snapshot Report</h1>'
$b += "</br>"
$b += '<h2>vCenter: ' + $podconnect + '</h2>'
$b += "</br></br>"





############
#  Get-VM  #
############

$getvm = Get-VM



###############
#  Snapshots  #
###############


#get all vms that have snapshots older than 2 days
$snapshots = $getvm | Get-Snapshot | Where {$_.Created -lt (Get-Date).AddDays(-2)}

#define the array for the snapshots
$snapshot_array = @()

foreach ($snapshot in $snapshots){

    #define the object
    $snapshot_object = New-Object -TypeName PSObject

	$sizeGB = [math]::Round(($snapshot.SizeMB / 1024),2)
	
    #add them to an object
    $snapshot_object | Add-Member -Name 'VM' -MemberType Noteproperty -Value $snapshot.VM
    $snapshot_object | Add-Member -Name 'Snapshot' -MemberType Noteproperty -Value $snapshot.Name
    $snapshot_object | Add-Member -Name 'Created' -MemberType Noteproperty -Value $snapshot.Created
    $snapshot_object | Add-Member -Name 'Size (GB)' -MemberType Noteproperty -Value $sizeGB

    #add the objects to an array
    $snapshot_array += $snapshot_object
}


Write-Output "Host Overview"
$snapshot_array | ft -autosize
$html_snapshot_array = $snapshot_array | ConvertTo-HTML -Fragment

$s_count = $snapshot_array.Count

$b += '<h2>' + $s_count + ' Snapshots</h2>'
$b += '<button class="accordion">Snapshots</button>'
$b += '<div class="panel">'

$b += '<p>' + $html_snapshot_array + '</p>'
$b += '</div>'





###################
#  Consolidation  #
###################

#get all vms that require consolidation
$consolodations = $getvm | where {$_.ExtensionData.Runtime.consolidationNeeded}

#define the array for the snapshots
$consolidation_array = @()

foreach ($consolodation in $consolodations){

    #define the object
    $consolidation_object = New-Object -TypeName PSObject

    #add them to an object
    $consolidation_object | Add-Member -Name 'VM' -MemberType Noteproperty -Value $consolodation.Name

    #add the objects to an array
    $consolidation_array += $consolidation_object
	
}



Write-Output "Consolidation Overview"
$consolidation_array | ft -autosize
$html_consolidation_array = $consolidation_array | ConvertTo-HTML -Fragment

$c_count = $consolidation_array.Count

$b += '<h2>' + $c_count + ' Consolidations</h2>'
$b += '<button class="accordion">Consolidation</button>'
$b += '<div class="panel">'

$b += '<p>' + $html_consolidation_array + '</p>'
$b += '</div>'





############
#  Footer  #
############

$b += '
<script>
/* Toggle between adding and removing the "active" and "show" classes when the user clicks on one of the "Section" buttons. The "active" class is used to add a background color to the current button when its belonging panel is open. The "show" class is used to open the specific accordion panel */
var acc = document.getElementsByClassName("accordion");
var i;

for (i = 0; i < acc.length; i++) {
    acc[i].onclick = function(){
        this.classList.toggle("active");
        this.nextElementSibling.classList.toggle("show");
    }
}
</script>
'

$file = "C:\andy\output\snapshot-consolidation-review.html"

$file

ConvertTo-HTML -head $a -Body $b -Title "Snapshot Review" | Out-File $file

Invoke-Item $file
