Get-Content -Path .\edit.csv | Select-Object -skip 2 | Where-Object {$_ -ne ""} | set-content -Path .\edit-remove-preamble.csv
$CSV = Import-Csv -path .\edit-remove-preamble.csv -Delimiter "`t" | Select-Object ImageFileName,PID,PPID,CreateTime
new-item -Path . -Name "MermaidJS"
Write-Output "graph TD" >> MermaidJS
foreach($line in $CSV) {
    Write-Output "`t $($line.ppid) -- $($line.CreateTime) ---> $($line.pid)($($line.ImageFileName))" >> .\MermaidJS
} 
