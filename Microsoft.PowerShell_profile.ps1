#region PROFILE HEADER
#############################################################################
###                        POWERSHELL PROFILE                            ###
#############################################################################
# Author: irman
# Last Updated: $(Get-Date -Format "yyyy-MM-dd")
# Description: Primary PowerShell profile with optimized session handling
#############################################################################
#endregion PROFILE HEADER

#region SESSION DETECTION
#############################################################################
# Detect session type early for optimized loading
#############################################################################

# Define session type flags
$script:IsNonInteractive = [Environment]::GetCommandLineArgs() | Where-Object { 
    $_ -match "-NonInteractive|-Command|-EncodedCommand|-CustomPipeName" 
} | Select-Object -First 1 -ErrorAction SilentlyContinue

$script:IsVSCodeTerminal = $Host.Name -eq 'Visual Studio Code Host'
$script:IsAzureFunction = $env:AZUREPS_HOST_ENVIRONMENT -or $env:AZURE_FUNCTIONS_ENVIRONMENT
$script:IsRemoteSession = $env:TERM_PROGRAM -eq 'vscode' -and $env:SSH_CONNECTION
$script:IsFullInteractive = -not ($IsNonInteractive -or $IsVSCodeTerminal -or $IsAzureFunction)

# Session type-specific trace for debugging
if ($VerbosePreference -eq 'Continue') {
    Write-Verbose "PowerShell Session Type:"
    Write-Verbose "  NonInteractive: $IsNonInteractive"
    Write-Verbose "  VS Code: $IsVSCodeTerminal"
    Write-Verbose "  Azure Function: $IsAzureFunction"
    Write-Verbose "  Remote Session: $IsRemoteSession"
    Write-Verbose "  Full Interactive: $IsFullInteractive"
}
#endregion SESSION DETECTION

#region MINIMAL PROFILE
#############################################################################
# Core functionality for ALL session types
# These scripts and functions are necessary regardless of session type
#############################################################################

# Import essential module management 
. "$env:OneDriveConsumer\Documents\PowerShell\module-manager.ps1"

# Load essential modules with optimized parallel loading
# This uses the optimized Import-RequiredModules function from module-manager.ps1
Import-RequiredModules

# Import core aliases and functions for any session type
. "$env:OneDriveConsumer\Documents\PowerShell\aliases.ps1"

# Exit early for non-interactive sessions (jobs, commands, etc.)
if ($IsNonInteractive) {
    # Non-interactive sessions only need modules and aliases
    return
}
#endregion MINIMAL PROFILE

#region VSCODE SPECIFIC CONFIGURATION
#############################################################################
# VS Code specific configuration
# Limited terminal customization for integrated terminal
#############################################################################
if ($IsVSCodeTerminal) {
    # Import additional VS Code specific modules and functions
    . "$env:OneDriveConsumer\Documents\PowerShell\profile-manager.ps1"
    
    # Function for Oh-My-Posh with VS Code optimized settings
    function Set-OhMyPoshVSCode {
        if (Get-Command "oh-my-posh" -ErrorAction SilentlyContinue) {
            # Simplified theme for VS Code (faster loading)
            oh-my-posh init pwsh --config "$env:OneDriveConsumer\Documents\PowerShell\oh-my-posh-vscode.json" | Invoke-Expression
        }
    }
    
    # Apply minimal VS Code customizations
    Set-OhMyPoshVSCode
    
    # Configure PSReadLine for VS Code
    if (Get-Command "Set-PSReadLineOption" -ErrorAction SilentlyContinue) {
        Set-PSReadLineOption -PredictionViewStyle ListView
        Set-PSReadLineOption -HistoryNoDuplicates
    }
    
    # Start background module check without blocking (VS Code specific)
    Start-BackgroundInstallationCheck
    
    return
}
#endregion VSCODE SPECIFIC CONFIGURATION

#region FULL INTERACTIVE PROFILE
#############################################################################
# Full interactive terminal profile
# Complete customization for standard terminal sessions
#############################################################################

# Import all profile modules for interactive sessions
. "$env:OneDriveConsumer\Documents\PowerShell\profile-manager.ps1"
. "$env:OneDriveConsumer\Documents\PowerShell\help-content.ps1"

#region SHELL CUSTOMIZATION FUNCTIONS
#############################################################################
# Terminal customization functions
#############################################################################

# Function for Oh-My-Posh customizations
function Set-OhMyPosh {
    if (Get-Command "oh-my-posh" -ErrorAction SilentlyContinue) {
        # Install font if needed (only once)
        if (!(Test-Path "$env:LOCALAPPDATA\Microsoft\Windows\Fonts\CaskaydiaCove*")) {
            oh-my-posh font install CascadiaCode --user
        }
        
        # Load standard theme for interactive sessions
        oh-my-posh init pwsh --config "$env:OneDriveConsumer\Documents\PowerShell\oh-my-posh-theme.json" | Invoke-Expression
    } else {
        Write-Host "Oh-My-Posh was not found on this system" -ForegroundColor Yellow
    }
}

# Function for PSReadLine customizations
function Set-PSReadLine {
    if (Get-Command "Set-PSReadLineOption" -ErrorAction SilentlyContinue) {
        # Configure prediction and history
        Set-PSReadLineOption -PredictionViewStyle ListView
        Set-PSReadLineOption -PredictionSource HistoryAndPlugin
        Set-PSReadLineOption -HistoryNoDuplicates
        Set-PSReadLineOption -MaximumHistoryCount 10000
        
        # Key handlers
        Set-PSReadLineKeyHandler -Key Tab -Function Complete
        Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
        Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    }
}

# Function for system information display
function Show-SystemInfo {
    if (Get-Command "fastfetch" -ErrorAction SilentlyContinue) {
        fastfetch
    } elseif (Get-Command "neofetch" -ErrorAction SilentlyContinue) {
        neofetch
    } else {
        Write-Host "┌─────────────────────────────────────────┐" -ForegroundColor Cyan
        Write-Host "│ System: $env:COMPUTERNAME                " -ForegroundColor Cyan
        Write-Host "│ PowerShell: $($PSVersionTable.PSVersion)" -ForegroundColor Cyan
        Write-Host "│ User: $env:USERNAME                     " -ForegroundColor Cyan  
        Write-Host "└─────────────────────────────────────────┘" -ForegroundColor Cyan
    }
}
#endregion SHELL CUSTOMIZATION FUNCTIONS

#region INITIALIZATION SECTION
#############################################################################
# Profile initialization for interactive sessions
#############################################################################

# Start Update-Help to run in the background once per day
# This runs silently and won't block the profile loading
$helpUpdateScript = {
    $updateFile = Join-Path $env:TEMP "PSHelpUpdate.txt"
    $lastUpdate = if (Test-Path $updateFile) { Get-Item $updateFile | Select-Object -ExpandProperty LastWriteTime }
    
    if (!$lastUpdate -or ((Get-Date) - $lastUpdate).Days -ge 1) {
        Update-Help -Scope CurrentUser -ErrorAction SilentlyContinue
        Get-Date | Out-File $updateFile -Force
    }
}
Start-ThreadJob -ScriptBlock $helpUpdateScript -StreamingHost $null | Out-Null

# Check and install required modules and applications in the background
Start-BackgroundInstallationCheck

# Display system information for interactive sessions
Show-SystemInfo

# Apply shell customizations for interactive sessions
Set-OhMyPosh
Set-PSReadLine
#endregion INITIALIZATION SECTION
#endregion FULL INTERACTIVE PROFILE
