<#----------------------------------------------------  

Gather last IP for computer from AD      
-----------------------------------

I wanted a tool to find the last known IP Addresses
of machine accounts in Active Directory. Sorting them 
by their address also gave me an idication of where
they are located on the network.

Its a simple script but has been very useful

V1.0 P.Sanders 13/2/2023 - initial cut

#>

$computer = @()
$PCvsIP = @()
$OutPath = $PSScriptRoot+"\rawip.txt"

$computers = Get-ADComputer -Filter *

foreach ($computer in $computers)

{
    
    $LastIP = (Get-ADComputer $Computer.Name -Properties IPv4Address).IPv4Address

    if ($LastIP -eq $null) {Write-Host $computer.Name, "No IP Record"}

    else {
        
        Write-Host $computer.Name, $LastIP 
        $PCvsIP += $computer.Name + " " + $LastIP
    
    }
    
}

# write computername and ipaddress to file, sort by ipaddress
# -----------------------------------------------------------

$PCvsIP | Sort-Object -Property { [System.Net.IPAddress]$_.Split(' ')[1] } | Set-Content $OutPath
