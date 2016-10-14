###########################
#    Get-TimeDrift.ps1    #
#    ntp0.ovh ntp1.ovh    #
#     Andrew Mcshane      #
###########################


#   not to be used to get actual time drift but rather 
#   used to compare the time drift of multiple servers 
#   based on their drift relative to an external source

#   WinRM needs to be enabled on the remote servers


#empty array of servers
$servers = @()

#fill up the array (replace this with your own servers)
$servers += "server1.ns1.ovh"
$servers += "server2.ns1.ovh"
$servers += "server3.ns1.ovh"

#get info for progress bar
$n = $servers.Count
$i = 1

#array that will be populated by the results
$time_catcher = @()

#loop through each server
foreach ($server in $servers)
{
    #progress bar 
    Write-Progress -Activity “Calculating Time Drift” -status “Server $i of $n” -percentComplete ($i / $n*100)

    #invoke the Get-TimeDrift funtion on remote servers
    $invoke = Invoke-Command -Computer $server -ScriptBlock {
        
        function Get-TimeDrift
        {

        #get time sources (unix format) and parse as a double
        $my_unix_time = [int][double]::Parse($(Get-Date -date (Get-Date).ToUniversalTime()-uformat %s))
        $ext_unix_time = [int][double]::Parse($((New-Object System.Net.WebClient).DownloadString("http://ntp0.ovh")))

        #define when the beginning of time was
        $beginning_of_time = New-Object -Type DateTime -ArgumentList 1970, 1, 1, 0, 0, 0, 0

        #get a pretty time based on how long it has been since the beginning of time
        $my_time = $beginning_of_time.AddSeconds($my_unix_time)
        $ext_time = $beginning_of_time.AddSeconds($ext_unix_time)

        #get the difference between my time and the reference time
        $time_difference = New-TimeSpan -start $ext_time -End $my_time
         
        #define the output
        Return $time_difference.TotalSeconds

        }
        
        #call the function
        Get-TimeDrift

    }

    #get the drift
    $drift = $invoke

    #create a nice object to output to
    $time_catcher_object = New-Object -TypeName PSObject

    #add some things to the object
    $time_catcher_object | Add-Member -Name 'Server' -MemberType Noteproperty -Value $server
    $time_catcher_object | Add-Member -Name 'Drift (seconds)' -MemberType Noteproperty -Value $drift

    #add the object to an array
    $time_catcher += $time_catcher_object

}


$time_catcher
