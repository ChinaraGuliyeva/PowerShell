# Prompt the user to enter a folder path
$folderPath = Read-Host "Enter the folder path"

# Regular expression pattern to match years after 2000 (2001 to 2099)
$yearPattern = "20\d{2}"

# Check if the entered path is valid
if (Test-Path -Path $folderPath -PathType Container) {
    # Get a list of files within the specified folder
    $files = Get-ChildItem -Path $folderPath -File

    # Display the list of files
    if ($files.Count -gt 0) {
        # Get the current directory where the script is located
        $scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path

        # Combine the script directory with the new folder name
        $newFolderPath = Join-Path -Path $scriptDirectory -ChildPath "Sorted_Photos"

        # Check if the new folder already exists
        if (Test-Path -Path $newFolderPath -PathType Container) {
            Write-Host "The folder 'sorted Photos' already exists."
        } else {
            # Create the new folder
            New-Item -Path $newFolderPath -ItemType Directory
            Write-Host "The folder 'Sorted_Photos' has been created."
        }
        Write-Host "Files in the folder:"
        foreach ($file in $files) {
            Write-Host $file.Name
            $fileMatches = [regex]::Matches($file.Name, $yearPattern)
            if ($fileMatches.Count -gt 0) {
                Write-Host "File $($file.Name) contains a year: $($fileMatches[0].Value)"
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