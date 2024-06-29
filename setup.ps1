# Setup script for new windows machine
Requires -RunAsAdministrator

# Set working directory
Set-Location $PSScriptRoot
[Environment]::CurrentDirectory = $PSScriptRoot

# Set Paths
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
$OneApps = "$Env:OneDriveConsumer\Apps\"

=======
#Requires -RunAsAdministrator

$OneApps = "$Env:OneDriveConsumer\Apps\"

# Linked Files (Destination => Source)
$symlinks = @{
    $PROFILE.CurrentUserAllHosts                                                                         = ".\profile.ps1"
    "$Env:UserProfile\.gitconfig"                                                                        = "$OneApps\Git\.gitconfig"
    "$Env:UserProfile\.ssh"                                                                              = "$OneApps\SSH"
    "$Env:LocalAppData\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"        = "$OneApps\WindowsTerminal\settings.json"
    "$Env:LocalAppData\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json" = "$OneApps\WindowsTerminalBeta\settings.json"
    
}

# Define the list of modules to  with additional options
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

# Define the list of winget applications to install with additional options
$AppList = @(
    @{ Command = ''; WingetName = 'Microsoft.WindowsTerminal.Preview'; OptionalStrings = '' },
    @{ Command = ''; WingetName = 'Microsoft.DotNet.Runtime.6 '; OptionalStrings = '' },
    @{ Command = ''; WingetName = 'Microsoft.VCRedist.2013.x86'; OptionalStrings = '' },
    @{ Command = ''; WingetName = 'Microsoft.VCRedist.2013.x64'; OptionalStrings = '' },
    @{ Command = ''; WingetName = 'Microsoft.VCRedist.2015+.x86'; OptionalStrings = '' },
    @{ Command = ''; WingetName = 'Microsoft.VCRedist.2015+.x64'; OptionalStrings = '' },
    @{ Command = ''; WingetName = 'Cloudflare.Warp'; OptionalStrings = '' },
    @{ Command = ''; WingetName = 'Cloudflare.cloudflared'; OptionalStrings = '' },
    @{ Command = ''; WingetName = 'Windscribe.Windscribe'; OptionalStrings = '' },
    @{ Command = ''; WingetName = 'Bitwarden.Bitwarden'; OptionalStrings = '' },
    @{ Command = ''; WingetName = 'Resilio.ResilioSync'; OptionalStrings = '' },
    @{ Command = ''; WingetName = 'GnuPG.GnuPG'; OptionalStrings = '' },
    @{ Command = ''; WingetName = 'GnuPG.Gpg4win'; OptionalStrings = '' },
    @{ Command = 'git'; WingetName = 'git.git'; OptionalStrings = '' },
    @{ Command = 'oh-my-posh'; WingetName = 'JanDeDobbeleer.OhMyPosh'; OptionalStrings = '' },
    @{ Command = 'fastfetch'; WingetName = 'Fastfetch-cli.Fastfetch'; OptionalStrings = '' },
    @{ Command = 'onefetch'; WingetName = 'o2sh.onefetch'; OptionalStrings = '' },
    @{ Command = ''; WingetName = 'Notepad++.Notepad++'; OptionalStrings = '' },
    @{ Command = ''; WingetName = '7zip.7zip'; OptionalStrings = '' },
    @{ Command = ''; WingetName = 'CodecGuide.K-LiteCodecPack.Full'; OptionalStrings = '' },
    @{ Command = ''; WingetName = 'Valve.Steam'; OptionalStrings = '' },
    @{ Command = ''; WingetName = 'EpicGames.EpicGamesLauncher'; OptionalStrings = '' },
    @{ Command = ''; WingetName = 'Ubisoft.Connect'; OptionalStrings = '' },
    @{ Command = ''; WingetName = 'Microsoft.VisualStudioCode'; OptionalStrings = '' },
    @{ Command = ''; WingetName = 'namazso.OpenHashTab'; OptionalStrings = '' },
    @{ Command = ''; WingetName = 'Discord.Discord'; OptionalStrings = '' }
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
        $jobs += Start-Job -Name "Install-$($app.WingetName)" -ScriptBlock {
            if (-not (Get-WinGetPackage $using:app.WingetName -ErrorAction SilentlyContinue)) {
                Write-Verbose "Installing $using:app.WingetName..."
                Install-WinGetPackage $using:app.WingetName $using:app.OptionalStrings
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

# Function to create symbolic links
function New-SymbolicLinks {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Hashtable]$Symlinks
    )

    Write-Host "Creating Symbolic Links..."

    foreach ($symlink in $Symlinks.GetEnumerator()) {
        $existingItem = Get-Item -Path $symlink.Key -ErrorAction SilentlyContinue
        if ($existingItem) {
            Remove-Item -Path $symlink.Key -Force -Recurse -ErrorAction SilentlyContinue
        }

        $targetPath = Resolve-Path $symlink.Value
        New-Item -ItemType SymbolicLink -Path $symlink.Key -Target $targetPath -Force | Out-Null
    }
}

# Setup Actions
Install-Modules -Modules $myModules
Install-Applications -AppList $AppList
New-SymbolicLinks -Symlinks $symlinks
