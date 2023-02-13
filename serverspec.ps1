
<#

Paulies speghetti factory 1/2/2021

Change the -Searchbase to an OU of your liking
Program loops through all servers in OU
Tells you following in Report.html

-Name of Server
-OS Version
-Number of CPU sockets
-Number of CPU cores
-Assigned Ram
-Total Disk

#>

[array]$Serverlist = Get-ADComputer -Filter * -SearchBase "OU=Servers, DC=xxx, DC=xxx, DC=xxx, DC=xx" | where {($_.DistinguishedName -notlike "*Ou to ignore*")}

Remove-Item -Path $PSScriptRoot\report.html
$header = '<TABLE width=100% border=1 style="background-color:CCCCCC"><TR><TD width=10%><B>Server Name</B></TD><TD width=50%><B>OS Version</B></TD><TD width=10%><B>Sockets</B></TD><TD width=10%><B>Cores</B></TD><TD width=10%><B>Ram[GB]</B></TD><TD width=10%><B>Total Disk[GB]</B></TD></TR></TABLE>'
Add-Content -Path $PSScriptRoot\report.html -value $header
$num = 1

foreach ($servername in $Serverlist) {

   $version = try {invoke-command -computername $Servername.name {WMIC OS Get Name} -ErrorAction Stop | Select-string -Pattern 'Windows Server'} catch { $ServerVersion = "Denied, Check WinRM" }

   if ($Serverversion -notlike "Denied*") {
   
      $ServerVersion = $version.line.Substring(0,($version.line.IndexOf('|C:\')))
      $cpu = invoke-command -computername $servername.name {Get-CimInstance -ClassName 'Win32_Processor' | Select-Object -Property 'DeviceID', 'Name', 'NumberOfCores'}
      $ram = invoke-command -computername $servername.name {(Get-WmiObject -class "cim_physicalmemory" | Measure-Object -Property Capacity -Sum).Sum}; $ram = [math]::Round($ram/1gb) 
      $disk = invoke-command -computername $servername.name {(Get-WmiObject Win32_LogicalDisk | Measure-Object -Sum size).sum}; $disk = [math]::Round($disk/1gb)
      $sockets = $cpu.DeviceID.count
      
      } else {
       
      $cpu = ""; $ram = ""; $disk =""

      }  

   if ($num % 2) {$colour = 'style=background-color:ffffff'} else {$colour = 'style=background-color:ffffcc'}
   $server = '<TABLE width=100% border=1 ' + $colour + '><TR><TD width=10%>' + $servername.name + '</TD><TD width=50%>' + $serverversion + '</TD><TD width=10%>' + $sockets + '</TD><TD width=10%>' + $cpu.numberofcores+ '</TD><TD width=10%>' + $ram + '</TD><TD width=10%>' + $disk + '</TD></TR>'
   write-host "Examining server" $num "of" $Serverlist.Count 
   Add-Content -Path $PSScriptRoot\report.html -value $server 
      
   $Serverversion = ""; $sqlversion = ""; $num++
            
}
