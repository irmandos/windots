# Profile Management Functions

function Test-InternetConnection {
    try {
        $testConnection = Test-NetConnection -ComputerName 8.8.8.8 -Port 53 -InformationLevel Quiet -ErrorAction Stop
        return $testConnection
    }
    catch {
        Write-Verbose "Internet connection test failed: $_"
        return $false
    }
}

function Update-ProfileFromGithub {
    [CmdletBinding()]
    param(
        [switch]$Force
    )

    if (-not (Test-InternetConnection)) {
        Write-Host "No internet connection. Skipping profile update check." -ForegroundColor Yellow
        return
    }

    Write-Host "Checking for profile updates..." -ForegroundColor Cyan

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
        if (-not (Test-Path $file.Key)) {
            $updatesAvailable = $true
            break
        }
        
        try {
            $tempFile = Join-Path $env:TEMP "temp_profile_file.ps1"
            Invoke-RestMethod -Uri $file.Value -OutFile $tempFile -ErrorAction Stop

            $localHash = Get-FileHash $file.Key -ErrorAction Stop
            $remoteHash = Get-FileHash $tempFile -ErrorAction Stop
            
            Remove-Item $tempFile -Force
            
            if ($localHash.Hash -ne $remoteHash.Hash) {
                $updatesAvailable = $true
                break
            }
        }
        catch {
            Write-Verbose "Failed to compare $($file.Key): $_"
        }
    }

    if ($updatesAvailable -or $Force) {
        Write-Host "Updates available for PowerShell profile files." -ForegroundColor Yellow
        
        if ($Force -or (Read-Host "Do you want to update? (Y/N)") -eq 'Y') {
            foreach ($file in $profileFiles.GetEnumerator()) {
                try {
                    Invoke-RestMethod -Uri $file.Value -OutFile $file.Key -ErrorAction Stop
                    Write-Host "Updated: $($file.Key)" -ForegroundColor Green
                }
                catch {
                    Write-Warning "Failed to update $($file.Key): $_"
                }
            }
            
            Write-Host "Profile updated. Please restart your shell to apply changes." -ForegroundColor Magenta
        }
    }
    else {
        Write-Host "Your PowerShell profile is up to date." -ForegroundColor Green
    }
}

# Export functions
Set-Item -Path "function:global:Update-ProfileFromGithub" -Value (Get-Item "function:Update-ProfileFromGithub").Definition