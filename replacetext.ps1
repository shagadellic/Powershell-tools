<# 

Recurse through $PathName and change every instance of foo to bar in all ini files discovered 
This tool was great for some bulk config updates

#>

$filenames = (Get-ChildItem -path $PathName -Recurse | Where-Object {$_.Name -match ".ini"}).FullName 

foreach ($file in $filenames) {

    Write-Host 'Updating', $file
    ((Get-Content -path $file -Raw) -replace 'foo','bar') | Set-Content $file
    
} 
