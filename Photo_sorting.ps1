Add-Type -AssemblyName System.Windows.Forms

function Show-SuccessDialog {
    $result = [System.Windows.Forms.MessageBox]::Show("Files sorted successfully", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}
function Show-ErrorDialog {
    $result = [System.Windows.Forms.MessageBox]::Show("An error occurred. Please try again.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
}


$yearPattern = "20\d{2}"
$form = New-Object System.Windows.Forms.Form
$form.Text = "Custom Folder Dialog"
$form.Width = 400
$form.Height = 200

$label = New-Object System.Windows.Forms.Label
$label.Text = "Select the source directory:"
$label.Location = New-Object System.Drawing.Point(10, 20)
$label.Width = $form.Width - 20
$label.Font = New-Object System.Drawing.Font("Arial", 14, [System.Drawing.FontStyle]::Bold)

$folderBrowserButton = New-Object System.Windows.Forms.Button
$folderBrowserButton.Text = "Choose Folder"
$folderBrowserButton.Location = New-Object System.Drawing.Point(100, 80)
$folderBrowserButton.Width = 200
$folderBrowserButton.Font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Regular)
$folderBrowserButton.Add_Click({
    $openFolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $openFolderDialog.Description = "Select the source directory"
    $result = $openFolderDialog.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $selectedFolder = $openFolderDialog.SelectedPath
        Write-Host "Selected Folder: $selectedFolder"
        $folderPath = $openFolderDialog.SelectedPath

    $files = Get-ChildItem -Path $folderPath -File

    if ($files.Count -gt 0) {
        $newFolderPath = Join-Path -Path $folderPath -ChildPath "Sorted Photos"

        if (Test-Path -Path $newFolderPath -PathType Container) {
            Write-Host "The folder 'sorted Photos' already exists."
        } else {
            New-Item -Path $newFolderPath -ItemType Directory
            Write-Host "The folder 'Sorted_Photos' has been created."
        }
        foreach ($file in $files) {
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
        Show-SuccessDialog
        $form.Close()
    } else {
        Show-ErrorDialog
        Write-Host "Error."
        $form.Close()
    }
    }
})

$form.Controls.Add($label)
$form.Controls.Add($folderBrowserButton)

$form.ShowDialog()
