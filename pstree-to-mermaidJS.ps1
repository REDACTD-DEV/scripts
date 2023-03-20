param (
    [string]$PSTreeFile
)

# Reads in the contents of $PSTreeFile, skips the first two lines, removes any empty lines, and converts the remaining content into a CSV format with a tab delimiter.
$CSV = Get-Content $PSTreeFile | Select-Object -skip 2 | Where-Object {$_ -ne ""} | ConvertFrom-Csv -Delimiter "`t" | Select-Object ImageFileName,PID,PPID,CreateTime,Depth

# Create a new file to hold the MermaidJS code
new-item -Path . -Name "MermaidJS"

# Add the initial MermaidJS code to the output file
Write-Output "graph LR" >> MermaidJS

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

    # Count the number of asterisks in the PID column to determine the depth level
    $charcount = ($line.PID.ToCharArray() | Where-Object {$_ -eq '*'} | Measure-Object).Count
    $line.Depth = $charcount

    # Remove asterisks and whitespace from the PID column
    $line.PID = $line.PID -replace '\*', ''
    $line.PID = $line.PID -replace '\s', ''

    # Write comments in the MermaidJS file
    Write-Output "`t %% PPID: $($line.ppid), PID: $($line.pid),  ImageFileName: $($line.ImageFileName), CreateTime: $($line.CreateTime), Depth: $($line.Depth)" >> .\MermaidJS

    # Generate a MermaidJS node for the current process
    Write-Output "`t $($line.ppid) -- $($line.CreateTime) ---> $($line.pid)($($line.ImageFileName)):::Depth$($line.Depth)" >> .\MermaidJS
} 
