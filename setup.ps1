# Ensure the script can run with elevated privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run this script as an Administrator!"
    break
}

# Define the list of modules to install with additional options
$myModules = @(
    @{moduleName = "Microsoft.WinGet.Client"; installOptions = "-AcceptLicense -Force" },
    @{moduleName = "PSWriteColor"; installOptions = "-AcceptLicense -Force" },
    @{moduleName = "PSReadLine"; installOptions = "-AcceptLicense -AllowPrerelease -Force -SkipPublisherCheck" },
    @{moduleName = "posh-git"; installOptions = "-AcceptLicense -Force" },
    @{moduleName = "Terminal-Icons"; installOptions = "-AcceptLicense -Force" },
    @{moduleName = "M365PSProfile"; installOptions = "-AcceptLicense -Force && Install-PSResource -Name M365PSProfile" },
    @{moduleName = "Az.Accounts"; installOptions = "-AcceptLicense -Force" },
    @{moduleName = "Az.Tools.Predictor"; installOptions = "-AcceptLicense -Force" },
    @{moduleName = "PSWindowsUpdate"; installOptions = "-AcceptLicense -Force" }
)

# Define the list of winget applications to install with additional options
# Removed: Cloudflare, Windscribe, UltraVnc, Discord (per user request)
$AppList = @(
    @{ Command = ''; WingetName = 'Microsoft.WindowsTerminal'; OptionalStrings = '' },
    @{ Command = ''; WingetName = 'Microsoft.DotNet.Runtime.6'; OptionalStrings = '' },
    @{ Command = ''; WingetName = 'Microsoft.VCRedist.2013.x86'; OptionalStrings = '' },
    @{ Command = ''; WingetName = 'Microsoft.VCRedist.2013.x64'; OptionalStrings = '' },
    @{ Command = ''; WingetName = 'Microsoft.VCRedist.2015+.x86'; OptionalStrings = '' },
    @{ Command = ''; WingetName = 'Microsoft.VCRedist.2015+.x64'; OptionalStrings = '' },
    @{ Command = ''; WingetName = 'Bitwarden.Bitwarden'; OptionalStrings = '' },
    @{ Command = ''; WingetName = 'Resilio.ResilioSync'; OptionalStrings = '' },
    @{ Command = ''; WingetName = 'GnuPG.GnuPG'; OptionalStrings = '' },
    @{ Command = 'git'; WingetName = 'git.git'; OptionalStrings = '' },
    @{ Command = 'oh-my-posh'; WingetName = 'JanDeDobbeleer.OhMyPosh'; OptionalStrings = '' },
    @{ Command = 'fastfetch'; WingetName = 'Fastfetch-cli.Fastfetch'; OptionalStrings = '' },
    @{ Command = 'onefetch'; WingetName = 'o2sh.onefetch'; OptionalStrings = '' },
    @{ Command = ''; WingetName = 'Notepad++.Notepad++'; OptionalStrings = '' },
    @{ Command = ''; WingetName = '7zip.7zip'; OptionalStrings = '' },
    @{ Command = ''; WingetName = 'CodecGuide.K-LiteCodecPack.Full'; OptionalStrings = '' },
    @{ Command = ''; WingetName = 'Microsoft.VisualStudioCode'; OptionalStrings = '' },
    @{ Command = ''; WingetName = 'namazso.OpenHashTab'; OptionalStrings = '' },
    @{ Command = ''; WingetName = 'Plex.Plex'; OptionalStrings = '' },
    @{ Command = ''; WingetName = 'Spotify.Spotify'; OptionalStrings = '' }
)

# Function to test internet connectivity
function Test-InternetConnection {
    try {
        $testConnection = Test-Connection -ComputerName 8.8.8.8 -Count 1 -ErrorAction Stop
        return $true
    }
    catch {
        Write-Warning "Internet connection is required but not available."
        return $false
    }
}

# Function to install modules asynchronously
function Install-Modules {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [array]$Modules
    )

    Write-Host "Installing PowerShell Modules..." -ForegroundColor Cyan
    
    foreach ($module in $Modules) {
        $moduleName = $module.moduleName
        if (-not (Get-Module -ListAvailable -Name $moduleName)) {
            Write-Host "Installing $moduleName..." -ForegroundColor Yellow
            try {
                Install-Module -Name $moduleName -Scope CurrentUser -Force -AllowClobber -SkipPublisherCheck -ErrorAction Stop
                Write-Host "Installed $moduleName" -ForegroundColor Green
            }
            catch {
                Write-Warning "Failed to install $moduleName : $_"
            }
        }
        else {
            Write-Verbose "$moduleName already installed."
        }
    }
}

# Function to install applications asynchronously
function Install-Applications {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [array]$AppList
    )

    Write-Host "Installing Applications..." -ForegroundColor Cyan

    foreach ($app in $AppList) {
        if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
            Write-Error "Winget not found!"
            return
        }

        # Check if installed (simple check)
        $installed = winget list -e --id $app.WingetName
        if (-not $installed) {
            Write-Host "Installing $($app.WingetName)..." -ForegroundColor Yellow
            winget install --id $app.WingetName -e --accept-package-agreements --accept-source-agreements --silent
        }
        else {
            Write-Verbose "$($app.WingetName) already installed."
        }
    }
}

# Function to setup profile
function Setup-Profile {
    Write-Host "Configuring PowerShell Profile..." -ForegroundColor Cyan
    
    $repoPath = $PSScriptRoot
    $profilePath = $PROFILE.CurrentUserCurrentHost
    $profileDir = Split-Path $profilePath -Parent

    if (-not (Test-Path $profileDir)) {
        New-Item -Path $profileDir -ItemType Directory -Force | Out-Null
    }

    # Backup existing profile
    if (Test-Path $profilePath) {
        $backupPath = "$profilePath.bak.$(Get-Date -Format 'yyyyMMddHHmmss')"
        Move-Item -Path $profilePath -Destination $backupPath -Force
        Write-Host "Backed up existing profile to $backupPath" -ForegroundColor Gray
    }

    # Create Shim Profile that sources the repo profile using relative path to repo
    # We use the absolute path of the repo script for the shim
    $shimContent = ". '$repoPath\Microsoft.PowerShell_profile.ps1'"
    
    Set-Content -Path $profilePath -Value $shimContent
    Write-Host "Profile configured to source from: $repoPath" -ForegroundColor Green
}

# Function to install Nerd Font
function Install-NerdFont {
    Write-Host "Checking Fonts..." -ForegroundColor Cyan
    if (-not (Test-Path "$env:LOCALAPPDATA\Microsoft\Windows\Fonts\CaskaydiaCove*")) {
        Write-Host "Installing CascadiaCode Nerd Font..." -ForegroundColor Yellow
        oh-my-posh font install CascadiaCode
    }
}

# Main Execution
if (-not (Test-InternetConnection)) { break }

Install-Modules -Modules $myModules
Install-Applications -AppList $AppList
Install-NerdFont
Setup-Profile

Write-Host "`nSetup Completed Successfully!" -ForegroundColor Green
Write-Host "Please restart your terminal." -ForegroundColor Yellow
