$folderPath = Read-Host "Enter the folder path"
$yearPattern = "20\d{2}"

if (Test-Path -Path $folderPath -PathType Container) {
    $files = Get-ChildItem -Path $folderPath -File

    if ($files.Count -gt 0) {
        $newFolderPath = Join-Path -Path $folderPath -ChildPath "Sorted_Photos"

        if (Test-Path -Path $newFolderPath -PathType Container) {
            Write-Host "The folder 'sorted Photos' already exists."
        } else {
            New-Item -Path $newFolderPath -ItemType Directory
            Write-Host "The folder 'Sorted_Photos' has been created."
        }
        Write-Host "Files in the folder:"
        foreach ($file in $files) {
            Write-Host $file.Name
            $fileMatches = [regex]::Matches($file.Name, $yearPattern)
            
            if ($fileMatches.Count -gt 0) {
                $year = $fileMatches[0].Value
                $targetDirectory = Join-Path -Path $newFolderPath -ChildPath $year
                
                if (-not (Test-Path -Path $targetDirectory -PathType Container)) {
                    New-Item -Path $targetDirectory -ItemType Directory
                }
        
                $targetFilePath = Join-Path -Path $targetDirectory -ChildPath $file.Name

                Copy-Item -Path $file.FullName -Destination $targetFilePath -Force        
                Write-Host "File $($file.Name) containing year $year has been copied to $targetDirectory."
            } else {
                Write-Host "File $($file.Name) does not contain a year."
            }
        }
    } else {
        Write-Host "No files found in the folder."
    }
} else {
    Write-Host "Invalid folder path."
}

Read-Host -Prompt "Press Enter to exit"