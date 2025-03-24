# Profile Management Functions

# Function to test internet connectivity
function Test-InternetConnection {
    try {
        $testConnection = Test-Connection -ComputerName github.com -Count 1 -ErrorAction Stop
        return $true
    }
    catch {
        Write-Warning "Internet connection is required but not available. Please check your connection."
        return $false
    }
}

# Function to backup local profile files before update
function Backup-ProfileFiles {
    $backupDir = Join-Path $env:USERPROFILE "Documents\PowerShell\backup"
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupPath = Join-Path $backupDir $timestamp

    if (-not (Test-Path $backupDir)) {
        New-Item -ItemType Directory -Path $backupDir | Out-Null
    }

    New-Item -ItemType Directory -Path $backupPath | Out-Null

    $filesToBackup = @(
        $PROFILE,
        "$PSScriptRoot\module-manager.ps1",
        "$PSScriptRoot\aliases.ps1",
        "$PSScriptRoot\help-content.ps1",
        "$PSScriptRoot\profile-manager.ps1"
    )

    foreach ($file in $filesToBackup) {
        if (Test-Path $file) {
            Copy-Item $file -Destination $backupPath
        }
    }

    Write-Host "Profile files backed up to: $backupPath" -ForegroundColor Green
}

# Function to compare local and remote files
function Compare-ProfileFiles {
    param (
        [string]$LocalPath,
        [string]$RemoteUrl
    )

    try {
        $tempFile = Join-Path $env:TEMP "temp_profile_file.ps1"
        Invoke-RestMethod -Uri $RemoteUrl -OutFile $tempFile

        if (Test-Path $LocalPath) {
            $localHash = Get-FileHash $LocalPath
            $remoteHash = Get-FileHash $tempFile
            
            Remove-Item $tempFile -Force
            return $localHash.Hash -ne $remoteHash.Hash
        }
        
        Remove-Item $tempFile -Force
        return $true
    }
    catch {
        Write-Error "Failed to compare files: $_"
        return $false
    }
}

# Function to update profile from GitHub
function Update-ProfileFromGithub {
    if (-not (Test-InternetConnection)) {
        Write-Host "Skipping profile update check due to no internet connection." -ForegroundColor Yellow
        return
    }

    $repoBaseUrl = "https://raw.githubusercontent.com/irmandos/windots/main"
    $profileFiles = @{
        "$PROFILE" = "$repoBaseUrl/Microsoft.PowerShell_profile.ps1"
        "$PSScriptRoot\module-manager.ps1" = "$repoBaseUrl/module-manager.ps1"
        "$PSScriptRoot\aliases.ps1" = "$repoBaseUrl/aliases.ps1"
        "$PSScriptRoot\help-content.ps1" = "$repoBaseUrl/help-content.ps1"
        "$PSScriptRoot\profile-manager.ps1" = "$repoBaseUrl/profile-manager.ps1"
    }

    $updatesAvailable = $false

    foreach ($file in $profileFiles.GetEnumerator()) {
        if (Compare-ProfileFiles -LocalPath $file.Key -RemoteUrl $file.Value) {
            $updatesAvailable = $true
            break
        }
    }

    if ($updatesAvailable) {
        Write-Host "Updates available for PowerShell profile files." -ForegroundColor Yellow
        $confirmation = Read-Host "Do you want to update? (Y/N)"
        
        if ($confirmation -eq 'Y') {
            Backup-ProfileFiles
            
            foreach ($file in $profileFiles.GetEnumerator()) {
                try {
                    Invoke-RestMethod -Uri $file.Value -OutFile $file.Key
                    Write-Host "Updated: $($file.Key)" -ForegroundColor Green
                }
                catch {
                    Write-Error "Failed to update $($file.Key): $_"
                }
            }
            
            Write-Host "Profile has been updated. Please restart your shell to apply changes" -ForegroundColor Magenta
        }
    }
    else {
        Write-Host "Your PowerShell profile is up to date." -ForegroundColor Green
    }
}

# Function to push profile changes to GitHub
function Push-ProfileToGithub {
    param(
        [Parameter(Mandatory=$false)]
        [string]$CommitMessage = "Update PowerShell profile files"
    )

    $repoPath = "$env:USERPROFILE\Github\windots"
    
    if (-not (Test-Path $repoPath)) {
        Write-Error "GitHub repository not found at: $repoPath"
        return
    }

    # Copy current profile files to repo
    $filesToCopy = @(
        @{Source = $PROFILE; Destination = "Microsoft.PowerShell_profile.ps1"}
        @{Source = "$PSScriptRoot\module-manager.ps1"; Destination = "module-manager.ps1"}
        @{Source = "$PSScriptRoot\aliases.ps1"; Destination = "aliases.ps1"}
        @{Source = "$PSScriptRoot\help-content.ps1"; Destination = "help-content.ps1"}
        @{Source = "$PSScriptRoot\profile-manager.ps1"; Destination = "profile-manager.ps1"}
    )

    foreach ($file in $filesToCopy) {
        if (Test-Path $file.Source) {
            Copy-Item -Path $file.Source -Destination (Join-Path $repoPath $file.Destination) -Force
        }
    }

    # Change to repo directory and push changes
    Push-Location $repoPath
    try {
        git add .
        git commit -m $CommitMessage
        git push
        Write-Host "Successfully pushed profile updates to GitHub" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to push changes to GitHub: $_"
    }
    finally {
        Pop-Location
    }
}

# Function to sync profile (both ways)
function Sync-Profile {
    param(
        [Parameter(Mandatory=$false)]
        [string]$CommitMessage = "Update PowerShell profile files"
    )

    if (-not (Test-InternetConnection)) {
        Write-Host "Cannot sync profile without internet connection." -ForegroundColor Red
        return
    }

    # First push local changes
    Push-ProfileToGithub -CommitMessage $CommitMessage

    # Then check for any other updates
    Update-ProfileFromGithub
}
