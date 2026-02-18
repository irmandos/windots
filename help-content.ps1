function Show-Help {
    @"
PowerShell Profile Help
=======================

MODULE MANAGEMENT (module-manager.ps1)
------------------------------------
Install-Modules [-Modules <array>]
    Installs PowerShell modules asynchronously with progress tracking
    Example: Install-Modules -Modules $myModules

Install-Applications [-AppList <array>]
    Installs applications via WinGet with progress tracking
    Example: Install-Applications -AppList $AppList

Update-WinGet
    Updates all installed WinGet packages
    Example: Update-WinGet

Update-Modules
    Updates all PowerShell modules using M365 module
    Example: Update-Modules

PROFILE MANAGEMENT (profile-manager.ps1)
------------------------------------
Update-ProfileFromGithub
    Updates PowerShell profile files from GitHub repository
    Example: Update-ProfileFromGithub

Push-ProfileToGithub [-CommitMessage <string>]
    Pushes local profile changes to GitHub repository
    Example: Push-ProfileToGithub -CommitMessage "Updated aliases"

Sync-Profile [-CommitMessage <string>]
    Syncs profile by pushing local changes and pulling remote updates
    Example: Sync-Profile

Backup-ProfileFiles
    Creates a backup of all profile files with timestamp
    Example: Backup-ProfileFiles

ALIASES AND FUNCTIONS (aliases.ps1)
---------------------------------
File Management:
    touch <file>          - Create empty file
    nf <name>             - Create new file
    mkcd <dir>            - Create directory and navigate to it
    docs                  - Go to Documents folder
    dtop                  - Go to Desktop folder
    la                    - List all files (detailed)
    ll                    - List all files including hidden (detailed)

Git Commands:
    gs                    - git status
    ga                    - git add .
    gc <message>          - git commit -m
    gp                    - git push
    g                     - Navigate to Github folder
    gcl <url>             - git clone
    gcom <message>        - Add and commit changes
    lazyg <message>       - Add, commit, and push changes

System Administration:
    admin (alias: su)     - Run commands as administrator
    uptime                - Show system uptime
    Get-SystemInfo        - Display detailed system information
    flushdns             - Clear DNS cache
    reload-profile        - Reload PowerShell profile
    Edit-Profile          - Open profile in notepad

Clipboard Operations:
    cpy <text>            - Copy text to clipboard
    pst                   - Paste from clipboard

File Operations:
    grep <regex> [dir]    - Search for pattern in files
    df                    - Show volume information
    sed <file> <find> <replace> - Replace text in file
    which <command>       - Show command location
    head <file> [n]       - Show first n lines (default: 10)
    tail <file> [n] [-f]  - Show last n lines (default: 10)

Process Management:
    pkill <name>          - Kill process by name
    pgrep <name>          - Find process by name

Network Tools:
    Get-PubIP            - Show public IP address
    winutil              - Launch Windows utility tool

Environment Management:
    export <name> <value> - Set environment variable

CONFIGURATION
-------------
To enable all features, uncomment these lines in your profile:
    . "$PSScriptRoot\module-manager.ps1"
    . "$PSScriptRoot\aliases.ps1"
    . "$PSScriptRoot\help-content.ps1"
    . "$PSScriptRoot\profile-manager.ps1"

MODULES INSTALLED
----------------
- Microsoft.WinGet.Client
- PSWriteColor
- PSReadLine
- posh-git
- Terminal-Icons
- M365PSProfile
- Az.Accounts
- Az.Tools.Predictor
- PSWindowsUpdate

APPLICATIONS MANAGED
-------------------
- Oh-My-Posh
- Git
- Fastfetch
- Onefetch
"@
}


