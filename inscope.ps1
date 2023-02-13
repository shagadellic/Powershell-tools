<#

This file uses the output of PCLastIP to determine what machines
in the file are inscope of a CDIR provided on the command line.

This was helpful to me dertermining the site that a machine
was located

P.Sanders v1.0 - initial cut, still a work in progress

#>

Function Check-IPInCDIR

{
    param (

        [string]$ipAddress,
        [string]$cidr
    )

    $ip = [System.Net.IPAddress]::Parse($ipAddress)
    $ipBytes = $ip.GetAddressBytes()

    $cidrParts = $cidr.Split("/")
    $cidrAddress = [System.Net.IPAddress]::Parse($cidrParts[0])
    $cidrBytes = $cidrAddress.GetAddressBytes()

    $maskLength = [Convert]::ToInt32($cidrParts[1])
    $mask = [Convert]::ToInt32("1" * $maskLength + "0" * (32 - $maskLength), 2)

    $cidrStart = ($cidrBytes[0] * 256 + $cidrBytes[1]) * 256 + $cidrBytes[2] * 256 + $cidrBytes[3]
    $cidrEnd = $cidrStart + [Math]::Pow(2, 32 - $maskLength) - 1

    $ipInt = ($ipBytes[0] * 256 + $ipBytes[1]) * 256 + $ipBytes[2] * 256 + $ipBytes[3]

    if ($ipInt -ge $cidrStart -and $ipInt -le $cidrEnd) {

        Write-Host $name $ip "address is within the CDIR range."

    }

    else {

        #Write-Host "The IP address is outside the CDIR range."
    }

}

$inputFile = Get-Content -Path $PSScriptRoot\"rawip.txt"

$CDir = $Args[0]

foreach ($Record in $inputFile) {

    $columns = $Record -split ' '
    $name = $columns[0]
    $ip = $columns[1]

    Check-IPInCDIR -ipAddress $ip -cidr $CDir

}
