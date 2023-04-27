#Baselining script
$EZToolsDirectory = Read-Host "Specify location of RECmd"
$InputDirectory = Read-Host "Specify base search location"
$OutputDirectory = Read-Host "Specify output location"
Set-Location $EZToolsDirectory
.\RECmd.exe -d $InputDirectory --bn .\BatchExamples\InstalledSoftware.reb  --csv $OutputDirectory
.\RECmd.exe -d $InputDirectory --bn .\BatchExamples\BasicSystemInfo.reb  --csv $OutputDirectory
