<#
.SYNOPSIS
    This script scans a specified folder and displays the files larger than a minimum size.

.DESCRIPTION
    The script recursively scans a specified folder and lists the Folders that exceed the minimum size threshold.
    Hidden folders are also included in the scanning process.

.PARAMETER FolderPath
    Specifies the path of the folder to scan.

.PARAMETER MinimumSize
    Specifies the minimum folder size in bytes. Folders larger than this size will be displayed.

.LINK
    Written by: Venkat Naveen
    GitHub: venkatnaveenb
#>

param (
    [Parameter(Position = 0)]
    [string]$FolderPath = 'C:\',

    [Parameter(Position = 1)]
    [int]$MinimumSize = '2'
)

Function GetFolderSize {
    param (
       [string]$FolderPath
    )
   
   $folderSize = (Get-ChildItem -Path $FolderPath -Recurse -Force -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum 
   $folderSizeGB = [math]::Round($folderSize / 1GB, 2)
   return $folderSizeGB
}
   
try {
    # Iterate through each logical disk to get information
    $DiskInfo = Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }
    foreach ($disk in $DiskInfo) {
        $DeviceID = $disk.DeviceID
        $DiskSize = [math]::Round($disk.Size / 1GB, 2)
        $DiskFreeSpace = [math]::Round($disk.FreeSpace / 1GB, 2)
        
        Write-Host "Drive: $DeviceID"
        Write-Host "DiskSize: $DiskSize GB"
        Write-Host "DiskFreeSpace: $DiskFreeSpace GB"
    }

    Write-Host "Scan Folder: $FolderPath"
    Write-Host "MinimumSize: $MinimumSize GB"
    
    # Scan Folders larger than the minimum size, including hidden folders
    Get-ChildItem -Path $FolderPath -Directory -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
        $folderPath = $_.FullName
        
        $FolderSize = GetFolderSize $folderPath

        if ($FolderSize -gt [math]::Round($MinimumSize / 1GB, 2)) {
            Write-Host "$FolderSize GB - $folderPath"
        }
    }
}
catch {
    Write-Error "$_"
}
