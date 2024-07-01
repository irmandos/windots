###############################
###   MY CUSTOM FUNCTIONS   ###
###############################

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
                Write-Verbose "Installing $using:app.WingetName..."
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

# Update Powershell
function Update-PowerShell {
    if (-not (Test-InternetConnection)) {
        Write-Host "Skipping PowerShell update check due to GitHub.com not responding within 1 second." -ForegroundColor Yellow
        return
    }

    try {
        Write-Host "Checking for PowerShell updates..." -ForegroundColor Cyan
        $updateNeeded = $false
        $currentVersion = $PSVersionTable.PSVersion.ToString()
        $gitHubApiUrl = "https://api.github.com/repos/PowerShell/PowerShell/releases/latest"
        $latestReleaseInfo = Invoke-RestMethod -Uri $gitHubApiUrl
        $latestVersion = $latestReleaseInfo.tag_name.Trim('v')
        if ($currentVersion -lt $latestVersion) {
            $updateNeeded = $true
        }

        if ($updateNeeded) {
            Write-Host "Updating PowerShell..." -ForegroundColor Yellow
            winget upgrade "Microsoft.PowerShell" --accept-source-agreements --accept-package-agreements
            Write-Host "PowerShell has been updated. Please restart your shell to reflect changes" -ForegroundColor Magenta
        } else {
            Write-Host "Your PowerShell is up to date." -ForegroundColor Green
        }
    } catch {
        Write-Error "Failed to update PowerShell. Error: $_"
    }
}

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

# Check for Profile Updates
function Update-Profile {
    if (-not (Test-InternetConnection)) {
        Write-Host "Skipping profile update check due to GitHub.com not responding within 1 second." -ForegroundColor Yellow
        return
    }

    try {
        $url = "https://raw.githubusercontent.com/irmandos/windots/main/Microsoft.PowerShell_profile.ps1"
        $oldhash = Get-FileHash $PROFILE
        Invoke-RestMethod $url -OutFile "$env:temp/Microsoft.PowerShell_profile.ps1"
        $newhash = Get-FileHash "$env:temp/Microsoft.PowerShell_profile.ps1"
        if ($newhash.Hash -ne $oldhash.Hash) {
            Copy-Item -Path "$env:temp/Microsoft.PowerShell_profile.ps1" -Destination $PROFILE -Force
            Write-Host "Profile has been updated. Please restart your shell to reflect changes" -ForegroundColor Magenta
        }
    } catch {
        Write-Error "Unable to check for `$PROFILE updates"
    } finally {
        Remove-Item "$env:temp/Microsoft.PowerShell_profile.ps1" -ErrorAction SilentlyContinue
    }
}

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

# Function to upgrade WinGet packages
function Update-WinGet {if (Get-Command "winget" -ErrorAction SilentlyContinue) {
        winget upgrade --accept-source-agreements --accept-package-agreements --include-pinned --all
    } else {
        Write-Host "Oh no, what have you done, WinGet is missing!"
    }
}

# Function to update PowerShell modules
function Update-Modules {if (Get-Command "Install-M365Module" -ErrorAction SilentlyContinue) {
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
    Update-PowerShell
    Update-Modules
    Update-WinGet
    Update-Profile
    #windowsUpdateCheck
}

# Show fastfetch in terminal or if not installed get powerfetch from online script
function Show-fastfetch {
    if (Get-Command "fastfetch" -ErrorAction SilentlyContinue) {
        fastfetch -c paleofetch
    } else {
        Invoke-Expression (new-object net.webclient).DownloadString('https://raw.githubusercontent.com/jantari/powerfetch/master/powerfetch.ps1')
    }
}

function touch($file) { "" | Out-File $file -Encoding ASCII }

function Edit-Profile {
    notepad $PROFILE.CurrentUserAllHosts
}

function Get-PubIP { (Invoke-WebRequest http://ifconfig.me/ip).Content }

# Open WinUtil
function winutil {
    Invoke-WebRequest -useb https://christitus.com/win | Invoke-Expression
}

### Quality of Life Aliases
function nf { param($name) New-Item -ItemType "file" -Path . -Name $name } # Quick File Creation
function mkcd { param($dir) mkdir $dir -Force; Set-Location $dir } # Directory Management
function docs { Set-Location -Path $HOME\Documents } # Navigation Shortcuts
function dtop { Set-Location -Path $HOME\Desktop } # Navigation Shortcuts
function la { Get-ChildItem -Path . -Force | Format-Table -AutoSize } # Enhanced Listing
function ll { Get-ChildItem -Path . -Force -Hidden | Format-Table -AutoSize } # Enhanced Listing
function gs { git status } # Git Shortcuts
function ga { git add . } # Git Shortcuts
function gc { param($m) git commit -m "$m" } # Git Shortcuts
function gp { git push } # Git Shortcuts
function g { z Github } # Git Shortcuts
function gcl { git clone "$args" } # Git Shortcuts
function cpy { Set-Clipboard $args[0] } # Clipboard Utilities
function pst { Get-Clipboard } # Clipboard Utilities
function sysinfo { Get-ComputerInfo }

function admin {
    if ($args.Count -gt 0) {
        $argList = "& '$args'"
        Start-Process wt -Verb runAs -ArgumentList "pwsh.exe -NoExit -Command $argList"
    } else {
        Start-Process wt -Verb runAs
    }
}
# Set UNIX-like aliases for the admin command, so sudo <command> will run the command with elevated rights.
Set-Alias -Name su -Value admin

function uptime {
    if ($PSVersionTable.PSVersion.Major -eq 5) {
        Get-WmiObject win32_operatingsystem | Select-Object @{Name='LastBootUpTime'; Expression={$_.ConverttoDateTime($_.lastbootuptime)}} | Format-Table -HideTableHeaders
    } else {
        net statistics workstation | Select-String "since" | ForEach-Object { $_.ToString().Replace('Statistics since ', '') }
    }
}

function reload-profile {
    & $PROFILE
}

function grep($regex, $dir) {
    if ( $dir ) {
        Get-ChildItem $dir | select-string $regex
        return
    }
    $input | select-string $regex
}

function df {
    get-volume
}

function sed($file, $find, $replace) {
    (Get-Content $file).replace("$find", $replace) | Set-Content $file
}

function which($name) {
    Get-Command $name | Select-Object -ExpandProperty Definition
}

function export($name, $value) {
    set-item -force -path "env:$name" -value $value;
}

function pkill($name) {
    Get-Process $name -ErrorAction SilentlyContinue | Stop-Process
}

function pgrep($name) {
    Get-Process $name
}

function head {
  param($Path, $n = 10)
  Get-Content $Path -Head $n
}

function tail {
  param($Path, $n = 10, [switch]$f = $false)
  Get-Content $Path -Tail $n -Wait:$f
}

function gcom {
    git add .
    git commit -m "$args"
}

function lazyg {
    git add .
    git commit -m "$args"
    git push
}

function flushdns {
	Clear-DnsClientCache
	Write-Host "DNS has been flushed"
}


#########################################
###   SHELL CUSTOMISATION FUNCTIONS   ###
#########################################
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











# Help Function
function Show-Help {
    @"
PowerShell Profile Help
=======================

Update-Profile - Checks for profile updates from a remote repository and updates if necessary.

Update-PowerShell - Checks for the latest PowerShell release and updates if a new version is available.

Edit-Profile - Opens the current user's profile for editing using the configured editor.

touch <file> - Creates a new empty file.

Get-PubIP - Retrieves the public IP address of the machine.

winutil - Runs the WinUtil script from Chris Titus Tech.

uptime - Displays the system uptime.

reload-profile - Reloads the current user's PowerShell profile.

grep <regex> [dir] - Searches for a regex pattern in files within the specified directory or from the pipeline input.

df - Displays information about volumes.

sed <file> <find> <replace> - Replaces text in a file.

which <name> - Shows the path of the command.

export <name> <value> - Sets an environment variable.

pkill <name> - Kills processes by name.

pgrep <name> - Lists processes by name.

head <path> [n] - Displays the first n lines of a file (default 10).

tail <path> [n] - Displays the last n lines of a file (default 10).

nf <name> - Creates a new file with the specified name.

mkcd <dir> - Creates and changes to a new directory.

docs - Changes the current directory to the user's Documents folder.

dtop - Changes the current directory to the user's Desktop folder.

la - Lists all files in the current directory with detailed formatting.

ll - Lists all files, including hidden, in the current directory with detailed formatting.

gs - Shortcut for 'git status'.

ga - Shortcut for 'git add .'.

gc <message> - Shortcut for 'git commit -m'.

gp - Shortcut for 'git push'.

g - Changes to the GitHub directory.

gcom <message> - Adds all changes and commits with the specified message.

lazyg <message> - Adds all changes, commits with the specified message, and pushes to the remote repository.

sysinfo - Displays detailed system information.

flushdns - Clears the DNS cache.

cpy <text> - Copies the specified text to the clipboard.

pst - Retrieves text from the clipboard.

Use 'Show-Help' to display this help message.
"@
}
