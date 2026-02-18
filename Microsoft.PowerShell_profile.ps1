#region PROFILE HEADER
#############################################################################
###                        POWERSHELL PROFILE                            ###
#############################################################################
# Author: irman
# Last Updated: $(Get-Date -Format "yyyy-MM-dd")
# Description: Optimized PowerShell profile with reliable session handling
#############################################################################
#endregion PROFILE HEADER

#region SESSION DETECTION
#############################################################################
# Detect session type early for optimized loading
#############################################################################

# Robust Session Detection
$script:IsVSCodeTerminal = $env:TERM_PROGRAM -eq 'vscode' -or $Host.Name -eq 'Visual Studio Code Host'
$isUserInteractive = [Environment]::UserInteractive
$hasInteractiveArg = [Environment]::GetCommandLineArgs() -contains '-NonInteractive'

# Considered non-interactive if:
# 1. Not UserInteractive AND Not VSCode ( VS Code Integrated Console sometimes reports UserInteractive=False incorrectly)
# 2. explicitly passed -NonInteractive
$script:IsNonInteractive = ($hasInteractiveArg) -or (-not $isUserInteractive -and -not $script:IsVSCodeTerminal)

# Exit early for non-interactive sessions
if ($script:IsNonInteractive) {
    return
}

$script:IsAzureFunction = $env:AZUREPS_HOST_ENVIRONMENT -or $env:AZURE_FUNCTIONS_ENVIRONMENT
if ($script:IsAzureFunction) {
    return
}

$script:IsRemoteSession = $env:SSH_CONNECTION -or $PSSenderInfo
$script:IsFullInteractive = $true

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
#############################################################################

# Import essential module management 
. "$PSScriptRoot\module-manager.ps1"

# Load essential modules with optimized parallel loading
# This uses the optimized Import-RequiredModules function from module-manager.ps1
Import-RequiredModules

# Import local secrets (Ignored by Git)
$secretsFile = Join-Path $PSScriptRoot "Microsoft.PowerShell_secrets.ps1"
if (Test-Path $secretsFile) {
    . $secretsFile
}

# Import core aliases and functions for any session type
. "$PSScriptRoot\aliases.ps1"

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
    . "$PSScriptRoot\profile-manager.ps1"
    
    # Function for Oh-My-Posh with VS Code optimized settings
    function Set-OhMyPoshVSCode {
        if (Get-Command "oh-my-posh" -ErrorAction SilentlyContinue) {
            # Simplified theme for VS Code (faster loading)
            oh-my-posh init pwsh --config "$PSScriptRoot\oh-my-posh-vscode.json" | Invoke-Expression
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
. "$PSScriptRoot\profile-manager.ps1"
. "$PSScriptRoot\help-content.ps1"

# Initialize full interactive session
Initialize-InteractiveSession
#endregion FULL INTERACTIVE PROFILE
```