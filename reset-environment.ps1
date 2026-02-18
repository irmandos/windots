<#
.SYNOPSIS
    Resets PowerShell environment and fixes common issues
#>

function Reset-PowerShellEnvironment {
    [CmdletBinding()]
    param(
        [switch]$Force
    )

    Write-Host "Resetting PowerShell environment..." -ForegroundColor Cyan

    # Clear module cache
    $cacheFolder = Join-Path $env:USERPROFILE '.pwsh-cache'
    if (Test-Path $cacheFolder) {
        Remove-Item -Path $cacheFolder -Recurse -Force
        Write-Host "Cleared module cache" -ForegroundColor Green
    }

    # Remove loaded modules (except core ones)
    $coreModules = @('Microsoft.PowerShell.*', 'PSReadLine', 'PackageManagement', 'PowerShellGet')
    Get-Module | Where-Object {
        $_.Name -notin $coreModules -and $_.Name -notlike "Microsoft.PowerShell.*"
    } | Remove-Module -Force

    Write-Host "Cleared loaded modules" -ForegroundColor Green

    # Update PowerShellGet and PackageManagement
    Install-Module -Name PowerShellGet -Force -AllowClobber -Scope CurrentUser

    # Force update all required modules
    $requiredModules = @('PSReadLine', 'posh-git', 'Terminal-Icons', 'Get-ChildItemColor')
    
    foreach ($module in $requiredModules) {
        Write-Host "Updating module: $module" -ForegroundColor Yellow
        Update-Module -Name $module -Force -ErrorAction SilentlyContinue
    }

    Write-Host "Environment reset complete! Please restart PowerShell." -ForegroundColor Green
}

# Export function
Set-Item -Path "function:global:Reset-PowerShellEnvironment" -Value (Get-Item "function:Reset-PowerShellEnvironment").Definition