# Module and Package Management Functions

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

    $totalModules = $Modules.Count
    $completedModules = 0

    $jobs = @()
    foreach ($module in $Modules) {
        $moduleName = $module.moduleName
        $installOptions = $module.installOptions

        $jobs += Start-Job -Name "Install-$moduleName" -ScriptBlock {
            if (-not (Get-Module -ListAvailable -Name $using:moduleName)) {
                Install-Module -Name $using:moduleName -Scope CurrentUser $using:installOptions
                Import-Module $using:moduleName
            }
            Import-Module $using:moduleName
        }
    }

    # Display progress bar
    do {
        $completedModules = ($jobs | Where-Object { $_.State -eq 'Completed' }).Count
        Write-Progress -Activity "Installing Modules" -Status "Progress" -PercentComplete ($completedModules / $totalModules * 100)
        Start-Sleep -Seconds 1
    } while ($completedModules -lt $totalModules)

    # Wait for all jobs to complete and check for any issues
    $jobs | Wait-Job | Out-Null
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

    $totalApps = $AppList.Count
    $completedApps = 0

    $jobs = @()
    foreach ($app in $AppList) {
        $jobs += Start-Job -Name "Install-$($app.Command)" -ScriptBlock {
            if (-not (Get-Command -Name $using:app.Command -ErrorAction SilentlyContinue)) {
                Install-WinGetPackage $using:app.WingetName
            }
        }
    }

    # Display progress bar
    do {
        $completedApps = ($jobs | Where-Object { $_.State -eq 'Completed' }).Count
        Write-Progress -Activity "Installing Applications" -Status "Progress" -PercentComplete ($completedApps / $totalApps * 100)
        Start-Sleep -Seconds 1
    } while ($completedApps -lt $totalApps)

    # Wait for all jobs to complete and check for any issues
    $jobs | Wait-Job | Out-Null
    $failedJobs = $jobs | Where-Object { $_.State -ne 'Completed' }
    if ($failedJobs) {
        Write-Host "Some application installations failed:"
        $failedJobs | ForEach-Object { Receive-Job -Job $_ }
    }
}

# Function to upgrade WinGet packages
function Update-WinGet {
    if (Get-Command "winget" -ErrorAction SilentlyContinue) {
        winget upgrade --accept-source-agreements --accept-package-agreements --include-pinned --all
    } else {
        Write-Host "Oh no, what have you done, WinGet is missing!"
    }
}

# Function to update PowerShell modules
function Update-Modules {
    if (Get-Command "Install-M365Module" -ErrorAction SilentlyContinue) {
        Write-Host "Checking WinGet..."
        Install-M365Module -Modules $myModules.moduleName
    } else {
        Write-Host "Oh no, you do not have M365 module installed!"
    }
}

# Export functions
Export-ModuleMember -Function @(
    'Install-Modules',
    'Install-Applications',
    'Update-WinGet',
    'Update-Modules'
)

