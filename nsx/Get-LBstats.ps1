###############################
#                             #
# NSX Loadbalancer Statistics #
#                             #
#       Andrew Mcshane        #
#           ns1.ovh           #
#                             #
###############################



# pull in some arguments, this is the edge-id of the loadbalancer
$edge_id = $Args[0]

$nsx_ip = "10.10.10.109"

# ignore self signed SSLs on your NSX Manager
add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

# get some sweet credentials
$credential = Get-Credential
$user = $credential.GetNetworkCredential().username
$pass = $credential.GetNetworkCredential().password

# encode it to the correct format to use REST Basic Auth 
$pair = "${user}:${pass}"
$bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
$base64 = [System.Convert]::ToBase64String($bytes)
$basicAuthValue = "Basic $base64"
$headers = @{ Authorization = $basicAuthValue }

# define the URLs you will be querying
$edge_config_uri = "https://$nsx_ip/api/4.0/edges/$edge_id/loadbalancer/config"
$edge_app_uri = "https://$nsx_ip/api/4.0/edges/$edge_id/loadbalancer/config/applicationprofiles"
$edge_statistics_uri = "https://$nsx_ip/api/4.0/edges/$edge_id/loadbalancer/statistics"
$edge_monitor_uri = "https://$nsx_ip/api/4.0/edges/$edge_id/loadbalancer/config/monitors"

# make your requests
$config_request = Invoke-WebRequest -Uri $edge_config_uri -Headers $headers -Method GET
$statistics_request = Invoke-WebRequest -Uri $edge_statistics_uri -Headers $headers -Method GET
$app_request = Invoke-WebRequest -Uri $edge_app_uri -Headers $headers -Method GET
$monitor_request = Invoke-WebRequest -Uri $edge_monitor_uri -Headers $headers -Method GET

# parse the xml
[xml]$config_response = $config_request.Content
[xml]$statistics_response = $statistics_request.Content
[xml]$app_response = $app_request.Content
[xml]$monitor_response = $monitor_request.Content

# go through each pool on the loadbalancer
$lb_stats = @()
$lb_pools = $statistics_response.ChildNodes.pool.name
$p = 0
foreach ($lb_pool in $lb_pools)
{
    # get the members in the pool
    $p++
    $lb_members = $statistics_response.ChildNodes.pool[$p].member.name
    $m = 0
    $lb_pool_stats = @()


    # get the url that is being monitored on the backend along with the protocol
    $lb_monitors = $monitor_response.ChildNodes.monitor.type
    $mon = 0
    $mon_url = ""
    $mon_proto = ""
    foreach ($lb_monitor in $lb_monitors)
    {
        $mon++
        if ($lb_monitor.ToLower() -eq $lb_pool.ToLower())
        {
            $mon_url = $monitor_response.ChildNodes.monitor[$mon].url
            $mon_proto = $monitor_response.ChildNodes.monitor[$mon].type
        }

    }

    # get the backend servers along with the stats
    foreach ($lb_member in $lb_members)
    {
        

        $member = $statistics_response.ChildNodes.pool[$p].member[$m]


        $lb_pool_object = New-Object –TypeName PSObject
    
        $lb_pool_object | Add-Member –MemberType NoteProperty –Name Name –Value $member.name
        $lb_pool_object | Add-Member –MemberType NoteProperty –Name IP –Value $member.ipaddress
        $lb_pool_object | Add-Member –MemberType NoteProperty –Name status –Value $member.status
        $lb_pool_object | Add-Member –MemberType NoteProperty –Name curSessions –Value $member.curSessions
        $lb_pool_object | Add-Member –MemberType NoteProperty –Name totalSessions –Value $member.totalSessions
        $lb_pool_object | Add-Member –MemberType NoteProperty –Name bytesIn –Value $member.bytesIn
        $lb_pool_object | Add-Member –MemberType NoteProperty –Name bytesOut –Value $member.bytesOut

        $lb_pool_stats += $lb_pool_object
        $m++

    }

    # nice little bit of code to create an underline the exact length of a variable
    $underline_lb_pool = "-" * ($lb_pool | Measure-Object -Character).Characters
    
    # output the data and make it look pretty
    Write-Host ""
    Write-Host ""
    $lb_pool
    $underline_lb_pool
    $mon_proto + "://IP-Address" + $mon_url  
    $lb_pool_stats | sort Name | ft    

}


