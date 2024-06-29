<<<<<<< HEAD
###############################
###   MY CUSTOM FUNCTIONS   ###
###############################

=======
>>>>>>> 411475fb899f2447e85be5cf9e40d7cf18149f75
# Define the list of modules to install
$myModules = @(
    @{moduleName = "Microsoft.WinGet.Client"; installOptions = "-AcceptLicense -Force"},
    @{moduleName = "PSWriteColor"; installOptions = "-AcceptLicense -Force"},
    @{moduleName = "PSReadLine"; installOptions = "-AcceptLicense -AllowPrerelease -Force -SkipPublisherCheck"},
    @{moduleName = "posh-git"; installOptions = "-AcceptLicense -Force"},
    @{moduleName = "Terminal-Icons"; installOptions = "-AcceptLicense -Force"},
    @{moduleName = "M365PSProfile"; installOptions = "-AcceptLicense -Force && Install-PSResource -Name M365PSProfile"},
    @{moduleName = "Az.Accounts"; installOptions = "-AcceptLicense -Force"},
    @{moduleName = "Az.Tools.Predictor"; installOptions = "-AcceptLicense -Force"},
    @{moduleName = "PSWindowsUpdate"; installOptions = "-AcceptLicense -Force"}
)

# Define the list of applications to install
$AppList = @(
    @{ Command = 'oh-my-posh'; WingetName = 'JanDeDobbeleer.OhMyPosh'; OptionalStrings = '' },
    @{ Command = 'git'; WingetName = 'git.git'; OptionalStrings = '' },
    @{ Command = 'fastfetch'; WingetName = 'Fastfetch-cli.Fastfetch'; OptionalStrings = '' },
    @{ Command = 'onefetch'; WingetName = 'o2sh.onefetch'; OptionalStrings = '' }
)

# Function to install modules asynchronously
function Install-Modules {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [array]$Modules
    )

<<<<<<< HEAD
    $totalModules = $Modules.Count
    $completedModules = 0

=======
>>>>>>> 411475fb899f2447e85be5cf9e40d7cf18149f75
    $jobs = @()
    foreach ($module in $Modules) {
        $moduleName = $module.moduleName
        $installOptions = $module.installOptions

        $jobs += Start-Job -Name "Install-$moduleName" -ScriptBlock {
            if (-not (Get-Module -ListAvailable -Name $using:moduleName)) {
                Install-Module -Name $using:moduleName -Scope CurrentUser $using:installOptions
<<<<<<< HEAD
                Import-Module $using:moduleName
=======
>>>>>>> 411475fb899f2447e85be5cf9e40d7cf18149f75
            }
            Import-Module $using:moduleName
        }
    }

<<<<<<< HEAD
    # Display progress bar
    do {
        $completedModules = ($jobs | Where-Object { $_.State -eq 'Completed' }).Count
        Write-Progress -Activity "Installing Modules" -Status "Progress" -PercentComplete ($completedModules / $totalModules * 100)
        Start-Sleep -Seconds 1
    } while ($completedModules -lt $totalModules)

    # Wait for all jobs to complete and check for any issues
    $jobs | Wait-Job | Out-Null
=======
    # Wait for all jobs to complete and check for any issues
    $jobs | Wait-Job
>>>>>>> 411475fb899f2447e85be5cf9e40d7cf18149f75
    $failedJobs = $jobs | Where-Object { $_.State -ne 'Completed' }
    if ($failedJobs) {
        Write-Host "Some module installations failed:"
        $failedJobs | ForEach-Object { Receive-Job -Job $_ }
    }
}

# Function to install applications asynchronously
function Install-Applications {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [array]$AppList
    )

<<<<<<< HEAD
    $totalApps = $AppList.Count
    $completedApps = 0

=======
>>>>>>> 411475fb899f2447e85be5cf9e40d7cf18149f75
    $jobs = @()
    foreach ($app in $AppList) {
        $jobs += Start-Job -Name "Install-$($app.Command)" -ScriptBlock {
            if (-not (Get-Command -Name $using:app.Command -ErrorAction SilentlyContinue)) {
                Write-Verbose "Installing $using:app.WingetName..."
                Install-WinGetPackage $using:app.WingetName
            }
        }
    }

<<<<<<< HEAD
    # Display progress bar
    do {
        $completedApps = ($jobs | Where-Object { $_.State -eq 'Completed' }).Count
        Write-Progress -Activity "Installing Applications" -Status "Progress" -PercentComplete ($completedApps / $totalApps * 100)
        Start-Sleep -Seconds 1
    } while ($completedApps -lt $totalApps)

    # Wait for all jobs to complete and check for any issues
    $jobs | Wait-Job | Out-Null
=======
    # Wait for all jobs to complete and check for any issues
    $jobs | Wait-Job
>>>>>>> 411475fb899f2447e85be5cf9e40d7cf18149f75
    $failedJobs = $jobs | Where-Object { $_.State -ne 'Completed' }
    if ($failedJobs) {
        Write-Host "Some application installations failed:"
        $failedJobs | ForEach-Object { Receive-Job -Job $_ }
    }
}

<<<<<<< HEAD
# Function for Oh-My-Posh customisations
function Set-OhMyPosh {
    if (Get-Command "oh-my-posh" -ErrorAction SilentlyContinue) {
        if (!(Test-Path "$env:LOCALAPPDATA\Microsoft\Windows\Fonts\CaskaydiaCove*")) {
            oh-my-posh font install CascadiaCode --user
        }
        oh-my-posh init pwsh --config "$env:OneDriveConsumer\Documents\PowerShell\oh-my-posh-theme.json" | Invoke-Expression
    } else {
        Write-Host "Oh-My-Posh was not found on this system"
    }
}

# Function for PSReadLine customisations
function Set-PSReadLine {
    if (Get-Command "Set-PSReadLineOption" -ErrorAction SilentlyContinue) {
        Set-PSReadLineOption -PredictionViewStyle ListView
        Set-PSReadLineOption -PredictionSource HistoryAndPlugin
        Set-PSReadLineOption -HistoryNoDuplicates
        Set-PSReadLineKeyHandler -Key Tab -Function Complete
    }
}
=======
# Install modules and applications
Install-Modules -Modules $myModules
Install-Applications -AppList $AppList


########################################################################################################

###############################
###   MY CUSTOM FUNCTIONS   ###
###############################
>>>>>>> 411475fb899f2447e85be5cf9e40d7cf18149f75

# Function to upgrade WinGet packages
function wingetUpgrade {if (Get-Command "winget" -ErrorAction SilentlyContinue) {
        winget upgrade --accept-source-agreements --accept-package-agreements --include-pinned --all
    } else {
        Write-Host "Oh no, what have you done, WinGet is missing!"
    }
}

# Function to update PowerShell modules
function updateModules {if (Get-Command "Install-M365Module" -ErrorAction SilentlyContinue) {
        Write-Host "Checking WinGet..."
        Install-M365Module -Modules $myModules.moduleName
    } else {
        Write-Host "Oh no, you do not have M365 module installed!"
    }
}

# Function to check Windows Update status
function windowsUpdateCheck {
    Get-WULastResults | Select-Object LastSearchSuccessDate, LastInstallationSuccessDate
}

# Function to perform all updates
function update {
    updateModules
    wingetUpgrade
    #windowsUpdateCheck
}

<<<<<<< HEAD
# Show fastfetch in terminal or if not installed get powerfetch from online script
function Show-fastfetch {
    if (Get-Command "fastfetch" -ErrorAction SilentlyContinue) {
        fastfetch -c paleofetch
    } else {
        Invoke-Expression (new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jantari/powerfetch/master/powerfetch.ps1')
    }
}
=======
>>>>>>> 411475fb899f2447e85be5cf9e40d7cf18149f75

#########################################
###   SHELL CUSTOMISATION FUNCTIONS   ###
#########################################
<<<<<<< HEAD
if ([Environment]::GetCommandLineArgs().Contains("-NonInteractive") -or [Environment]::GetCommandLineArgs().Contains("-CustomPipeName")) {
    Install-Modules -Modules $myModules
    return
}

if ($Host.Name -eq 'Visual Studio Code Host') {
    Install-Modules -Modules $myModules
	Customise-OhMyPosh 
	Customise-PSReadLine
    return
}

# Start Update-Help to run in the background to ensure helpfiles are always up to date
# Update-Help will only run once per day and will require -Force to override this behaviour
# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/update-help?view=powershell-7.4
Start-Process pwsh -WindowStyle Hidden -ArgumentList "-NoProfile -Command Update-Help -Scope CurrentUser"

Show-fastfetch
Install-Modules -Modules $myModules
Install-Applications -AppList $AppList
Set-OhMyPosh
Set-PSReadLine
=======
# Check and install the CaskaydiaCove NerdFont if not already installed
$fontPath = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts\CaskaydiaCove*"
if (Test-Path $fontPath) {
} else {
    if (Get-Command "oh-my-posh" -ErrorAction SilentlyContinue) {
        oh-my-posh font install CascadiaCode --user
    } else {
        Write-Host "Oh-My-Posh was not found on this system"
    }
}

if (Get-Command "oh-my-posh" -ErrorAction SilentlyContinue) {
    oh-my-posh init pwsh --config "$env:OneDriveConsumer\Documents\PowerShell\oh-my-posh-theme.json" | Invoke-Expression
} else {
    Write-Host "Oh-My-Posh was not found on this system"
}

if (Get-Command "Set-PSReadLineOption" -ErrorAction SilentlyContinue) {
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -PredictionSource HistoryAndPlugin
    Set-PSReadLineOption -HistoryNoDuplicates
    Set-PSReadLineKeyHandler -Key Tab -Function Complete
}

if (Get-Command "fastfetch" -ErrorAction SilentlyContinue) {
    Write-Host " "
    Write-Host " "
    fastfetch -c paleofetch
    } else {
        iex (new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jantari/powerfetch/master/powerfetch.ps1')
    }
 
>>>>>>> 411475fb899f2447e85be5cf9e40d7cf18149f75
