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

    $jobs = @()
    foreach ($module in $Modules) {
        $moduleName = $module.moduleName
        $installOptions = $module.installOptions

        $jobs += Start-Job -Name "Install-$moduleName" -ScriptBlock {
            if (-not (Get-Module -ListAvailable -Name $using:moduleName)) {
                Install-Module -Name $using:moduleName -Scope CurrentUser $using:installOptions
            }
            Import-Module $using:moduleName
        }
    }

    # Wait for all jobs to complete and check for any issues
    $jobs | Wait-Job
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

    $jobs = @()
    foreach ($app in $AppList) {
        $jobs += Start-Job -Name "Install-$($app.Command)" -ScriptBlock {
            if (-not (Get-Command -Name $using:app.Command -ErrorAction SilentlyContinue)) {
                Write-Verbose "Installing $using:app.WingetName..."
                Install-WinGetPackage $using:app.WingetName
            }
        }
    }

    # Wait for all jobs to complete and check for any issues
    $jobs | Wait-Job
    $failedJobs = $jobs | Where-Object { $_.State -ne 'Completed' }
    if ($failedJobs) {
        Write-Host "Some application installations failed:"
        $failedJobs | ForEach-Object { Receive-Job -Job $_ }
    }
}

# Install modules and applications
Install-Modules -Modules $myModules
Install-Applications -AppList $AppList


########################################################################################################

###############################
###   MY CUSTOM FUNCTIONS   ###
###############################

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


#########################################
###   SHELL CUSTOMISATION FUNCTIONS   ###
#########################################
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
 