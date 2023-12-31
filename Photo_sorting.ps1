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

$sourceLabel = New-Object System.Windows.Forms.Label
$sourceLabel.Text = "Select the source directory:"
$sourceLabel.Location = New-Object System.Drawing.Point(10, 20)
$sourceLabel.Width = $form.Width - 20
$sourceLabel.Font = New-Object System.Drawing.Font("Arial", 14, [System.Drawing.FontStyle]::Bold)

$folderBrowserButton = New-Object System.Windows.Forms.Button
$folderBrowserButton.Text = "Choose Source Folder"
$folderBrowserButton.Location = New-Object System.Drawing.Point(100, 80)
$folderBrowserButton.Width = 200
$folderBrowserButton.Font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Regular)

$destinationFolder = $null
$loadingForm = $null

$folderBrowserButton.Add_Click({
    $openFolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $openFolderDialog.Description = "Select the source directory"
    $result = $openFolderDialog.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $selectedFolder = $openFolderDialog.SelectedPath
        Write-Host "Selected Source Folder: $selectedFolder"
        $sourceFolderPath = $openFolderDialog.SelectedPath

        # Close the first dialog before opening the second one
        $form.Close()

        # Create a separate modal window for selecting the destination folder
        $destinationForm = New-Object System.Windows.Forms.Form
        $destinationForm.Text = "Select Destination Folder"
        $destinationForm.Width = 400
        $destinationForm.Height = 200

        $destinationLabel = New-Object System.Windows.Forms.Label
        $destinationLabel.Text = "Select the destination directory:"
        $destinationLabel.Location = New-Object System.Drawing.Point(10, 20)
        $destinationLabel.Width = $destinationForm.Width - 20
        $destinationLabel.Font = New-Object System.Drawing.Font("Arial", 14, [System.Drawing.FontStyle]::Bold)

        $destinationFolderButton = New-Object System.Windows.Forms.Button
        $destinationFolderButton.Text = "Choose Destination Folder"
        $destinationFolderButton.Location = New-Object System.Drawing.Point(100, 80)
        $destinationFolderButton.Width = 250
        $destinationFolderButton.Font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Regular)
        $destinationFolderButton.Add_Click({
            $openFolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
            $openFolderDialog.Description = "Select the destination directory"
            $result = $openFolderDialog.ShowDialog()

            if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
                $destinationFolder = $openFolderDialog.SelectedPath
                Write-Host "Selected Destination Folder: $destinationFolder"
                $destinationForm.Close()
                
                # Create a loading form with a progress bar
                $loadingForm = New-Object System.Windows.Forms.Form
                $loadingForm.Text = "Loading..."
                $loadingForm.Width = 300
                $loadingForm.Height = 150
                $loadingForm.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
                $loadingForm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
                $loadingForm.ControlBox = $false

                $loadingLabel = New-Object System.Windows.Forms.Label
                $loadingLabel.Text = "Copying files and sorting..."
                $loadingLabel.Location = New-Object System.Drawing.Point(10, 20)
                $loadingLabel.Width = $loadingForm.Width - 20
                $loadingLabel.Font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold)

                $progressBar = New-Object System.Windows.Forms.ProgressBar
                $progressBar.Style = [System.Windows.Forms.ProgressBarStyle]::Marquee
                $progressBar.Location = New-Object System.Drawing.Point(10, 50)
                $progressBar.Width = $loadingForm.Width - 40

                $loadingForm.Controls.Add($loadingLabel)
                $loadingForm.Controls.Add($progressBar)

                # Show the loading form asynchronously
                $loadingForm.Show()

                Start-Sleep -Seconds 1 # Simulate some processing time (remove this line in production)
                
                # Actual processing logic (copy files, sort, etc.) here
                $files = Get-ChildItem -Path $sourceFolderPath -File

                if ($files.Count -gt 0) {
                    $newFolderPath = Join-Path -Path $destinationFolder -ChildPath "Sorted Photos"

                    if (Test-Path -Path $newFolderPath -PathType Container) {
                        Write-Host "The folder 'Sorted Photos' already exists."
                    } else {
                        New-Item -Path $newFolderPath -ItemType Directory
                        Write-Host "The folder 'Sorted Photos' has been created."
                    }

                    $totalFiles = $files.Count
                    $progress = 0

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

                        # Update progress bar
                        $progress++
                        $percentComplete = ($progress / $totalFiles) * 100
                        $progressBar.Value = $percentComplete
                    }

                    Show-SuccessDialog
                } else {
                    Show-ErrorDialog
                }

                # Close the loading form when processing is complete
                $loadingForm.Close()
            }
        })

        $destinationForm.Controls.Add($destinationLabel)
        $destinationForm.Controls.Add($destinationFolderButton)
        $destinationForm.ShowDialog()
    }
})

$form.Controls.Add($sourceLabel)
$form.Controls.Add($folderBrowserButton)

$form.ShowDialog()