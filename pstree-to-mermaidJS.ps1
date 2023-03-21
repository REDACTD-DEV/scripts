param (
    [string]$PSTreeFile,
    [string]$ProcessID
)

# Reads in the contents of $PSTreeFile, skips the first two lines, removes any empty lines, and converts the remaining content into a CSV format with a tab delimiter.
$CSV = Get-Content $PSTreeFile | Select-Object -skip 2 | Where-Object {$_ -ne ""} | ConvertFrom-Csv -Delimiter "`t" | Select-Object ImageFileName,PID,PPID,CreateTime,Depth,ExitTime,Index

$index=0
foreach($line in $CSV){
    # Count the number of asterisks in the PID column to determine the depth level
    $charcount = ($line.PID.ToCharArray() | Where-Object {$_ -eq '*'} | Measure-Object).Count
    $line.Depth = $charcount

    # Remove asterisks and whitespace from the PID column
    $line.PID = $line.PID -replace '\*', ''
    $line.PID = $line.PID -replace '\s', ''
    $line.index = $index
    $index++
}

#Add an astericks to the ImageFileName for all processes that have an exit time
foreach($line in $CSV){     
    if($line.ExitTime -ne "N/A"){
        $line.ImageFileName += "*" 
    }
}

if($ProcessID -ne $null){
    # Find all parent PIDs for the specified PID
    $CurrentProcess = $ProcessID
    $parentPIDs = @()
    $depth = $CSV | Where-Object pid -eq $CurrentProcess | Select-Object -ExpandProperty depth
    while ($depth -gt 0){
        $parent = $CSV | Where-Object pid -eq $CurrentProcess | Select-Object -ExpandProperty PPID
        $parentPIDs += $parent
        $CurrentProcess = $parent
        $depth--
    }

    # Find all child PIDs for the specified PID
    $CurrentProcess = $ProcessID
    $ChildPIDs = @()
    $depth = $CSV | Where-Object pid -eq $CurrentProcess | Select-Object -ExpandProperty depth
    $CurrentProcessIndex = ($CSV | Where-Object {$_.pid -eq $CurrentProcess}) | Select-Object -ExpandProperty Index
    $child = ($CSV | Where-Object {$_.index -eq $CurrentProcessIndex + 1}) | Select-Object
    while($child.Depth -gt $depth){
        $ChildPIDs += $child.pid
        $CurrentProcessIndex++
        $child = ($CSV | Where-Object {$_.index -eq $CurrentProcessIndex + 1}) | Select-Object
    }

    # Combine parent, child, and current process IDs into a unique list
    $PIDList = $parentPIDs + $ChildPIDs + $ProcessID
    $PIDList = $PIDList | Select-Object -Unique

    # Create an empty array for the custom process tree
    $CustomPSTree = @()

    # Loop through each process ID and add it to the custom process tree
    foreach($process in $PIDList){
        $process = ($CSV | Where-Object {$_.pid -eq $process}) | Select-Object
        $CustomPSTree += $process
    }

    # Sort the custom process tree array by the "Index" property
    $CustomPSTree = $CustomPSTree | Sort-Object -Property Index

    # Update the original CSV variable with the custom process tree
    $CSV = $CustomPSTree
}

# Create a new file to hold the MermaidJS code
new-item -Path . -Name "MermaidJS"

# Add the initial MermaidJS code to the output file
Write-Output "graph TD" >> MermaidJS

# Define CSS classes for each depth level, with different colors
Write-Output "`t classDef Depth0 fill:#FFB6C1,color:#000" >> MermaidJS  # Pink
Write-Output "`t classDef Depth1 fill:#FFDAB9,color:#000" >> MermaidJS  # Peach
Write-Output "`t classDef Depth2 fill:#FFFFE0,color:#000" >> MermaidJS  # Yellow
Write-Output "`t classDef Depth3 fill:#98FB98,color:#000" >> MermaidJS  # Green
Write-Output "`t classDef Depth4 fill:#00FFFF,color:#000" >> MermaidJS  # Cyan
Write-Output "`t classDef Depth5 fill:#B0C4DE,color:#000" >> MermaidJS  # Blue
Write-Output "`t classDef Depth6 fill:#EE82EE,color:#000" >> MermaidJS  # Purple
Write-Output "`t classDef Depth7 fill:#FFA07A,color:#000" >> MermaidJS  # Orange

# Loop through each line of the CSV file
foreach($line in $CSV) {
    # Write comments in the MermaidJS file
    Write-Output "`t %% PPID: $($line.ppid), PID: $($line.pid),  ImageFileName: $($line.ImageFileName), CreateTime: $($line.CreateTime), Depth: $($line.Depth)" >> .\MermaidJS

    # Generate a MermaidJS node for the current process
    Write-Output "`t $($line.ppid) -- $($line.CreateTime) ---> $($line.pid)($($line.ImageFileName)):::Depth$($line.Depth)" >> .\MermaidJS
} 
