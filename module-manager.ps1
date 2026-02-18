<#
.SYNOPSIS
    Optimized PowerShell module manager with reliable caching and updates
.DESCRIPTION
    This script provides reliable module management with proper caching,
    background updates, and conflict resolution.
.NOTES
    Author: irman
    Version: 2.0
#>

# Cache configuration
$script:CacheFolder = Join-Path $env:USERPROFILE '.pwsh-cache'
$script:ModuleCacheFile = Join-Path $script:CacheFolder 'module-cache.json'
$script:CacheValidHours = 6 # Cache validity in hours

# Required modules definition
$script:RequiredModules = @(
    @{Name = 'PSReadLine'; AllowPrerelease = $true }
    @{Name = 'posh-git' }
    @{Name = 'Terminal-Icons' }
    @{Name = 'Get-ChildItemColor' }
)

$script:RequiredWingetApps = @(
    'JanDeDobbeleer.OhMyPosh'
)

#region CACHE MANAGEMENT
function Initialize-Cache {
    [CmdletBinding()]
    param()

    if (-not (Test-Path -Path $script:CacheFolder)) {
        New-Item -Path $script:CacheFolder -ItemType Directory -Force | Out-Null
    }

    if (-not (Test-Path -Path $script:ModuleCacheFile)) {
        $initialCache = @{
            LastChecked     = (Get-Date).AddHours(-$script:CacheValidHours - 1).ToString('o')
            Modules         = @{}
            WingetApps      = @{}
            FontsInstalled  = @()
            LastUpdateCheck = (Get-Date).AddDays(-8).ToString('o')
        }
        $initialCache | ConvertTo-Json -Depth 5 | Set-Content -Path $script:ModuleCacheFile
    }
}

function Get-CacheData {
    [CmdletBinding()]
    param()

    try {
        if (Test-Path -Path $script:ModuleCacheFile) {
            $cacheData = Get-Content -Path $script:ModuleCacheFile -Raw | ConvertFrom-Json
            
            # Ensure required properties exist (migration for existing cache)
            if (-not $cacheData.PSObject.Properties['FontsInstalled']) {
                $cacheData | Add-Member -MemberType NoteProperty -Name 'FontsInstalled' -Value @()
            }
            if (-not $cacheData.PSObject.Properties['WingetApps']) {
                $cacheData | Add-Member -MemberType NoteProperty -Name 'WingetApps' -Value @{}
            }
            if (-not $cacheData.PSObject.Properties['Modules']) {
                $cacheData | Add-Member -MemberType NoteProperty -Name 'Modules' -Value @{}
            }
            if (-not $cacheData.PSObject.Properties['LastUpdateCheck']) {
                $cacheData | Add-Member -MemberType NoteProperty -Name 'LastUpdateCheck' -Value (Get-Date).AddDays(-8).ToString('o')
            }
            
            return $cacheData
        }
    }
    catch {
        Write-Warning "Cache corrupted, recreating..."
    }
    
    Initialize-Cache
    return Get-Content -Path $script:ModuleCacheFile -Raw | ConvertFrom-Json
}

function Update-CacheData {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [PSCustomObject]$CacheData
    )

    try {
        $CacheData | ConvertTo-Json -Depth 5 | Set-Content -Path $script:ModuleCacheFile
    }
    catch {
        Write-Warning "Failed to update cache: $_"
    }
}

function Test-CacheValid {
    [CmdletBinding()]
    param(
        [int]$ValidHours = $script:CacheValidHours
    )

    $cacheData = Get-CacheData
    $lastChecked = [DateTime]::Parse($cacheData.LastChecked)
    $cacheAge = (Get-Date) - $lastChecked
    
    return $cacheAge.TotalHours -lt $ValidHours
}
#endregion CACHE MANAGEMENT

#region MODULE MANAGEMENT
function Test-ModuleInstalled {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ModuleName
    )

    return [bool](Get-Module -Name $ModuleName -ListAvailable -ErrorAction SilentlyContinue)
}

function Test-ModuleLoaded {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ModuleName
    )

    return [bool](Get-Module -Name $ModuleName -ErrorAction SilentlyContinue)
}

function Install-PowerShellModule {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ModuleName,
        
        [switch]$AllowPrerelease
    )

    try {
        Write-Host "Installing module: $ModuleName" -ForegroundColor Yellow
        
        $installParams = @{
            Name         = $ModuleName
            Scope        = 'CurrentUser'
            Force        = $true
            AllowClobber = $true
            ErrorAction  = 'Stop'
        }
        
        if ($AllowPrerelease) {
            $installParams.AllowPrerelease = $true
        }
        
        # Remove -Force to avoid overhead if already present in a way we missed
        $installParams.Remove('Force')
        
        Install-Module @installParams
        
        # Verify installation
        if (Test-ModuleInstalled -ModuleName $ModuleName) {
            Write-Host "Module $ModuleName installed successfully" -ForegroundColor Green
            return $true
        }
        else {
            Write-Warning "Module $ModuleName installation may have failed"
            return $false
        }
    }
    catch {
        Write-Warning "Failed to install module $ModuleName : $_"
        return $false
    }
}

function Update-PowerShellModule {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ModuleName
    )

    # Check if module is currently loaded
    $loadedModule = Get-Module -Name $ModuleName -ErrorAction SilentlyContinue
    
    if ($loadedModule) {
        Write-Host "Module $ModuleName is currently loaded. It will be updated on next session." -ForegroundColor Yellow
        return $false
    }
    
    try {
        Write-Host "Updating module: $ModuleName" -ForegroundColor Yellow
        Update-Module -Name $ModuleName -Force -ErrorAction Stop
        Write-Host "Module $ModuleName updated successfully" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Warning "Failed to update module $ModuleName : $_"
        return $false
    }
}

function Install-RequiredPSModules {
    [CmdletBinding()]
    param(
        [switch]$Force
    )

    # Skip if cache is valid and Force is not specified
    if ((-not $Force) -and (Test-CacheValid)) {
        Write-Verbose "Module cache is valid. Skipping module installation check."
        return
    }

    Write-Host "Checking required PowerShell modules..." -ForegroundColor Cyan

    $cacheData = Get-CacheData
    $cacheData.LastChecked = (Get-Date).ToString('o')
    $anyChanges = $false

    foreach ($moduleDef in $script:RequiredModules) {
        $moduleName = $moduleDef.Name
        $allowPrerelease = $moduleDef.AllowPrerelease
        
        if (Test-ModuleInstalled -ModuleName $moduleName) {
            $cacheData.Modules[$moduleName] = @{
                Installed   = $true
                LastChecked = (Get-Date).ToString('o')
                Version     = (Get-Module -Name $moduleName -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).Version.ToString()
            }
            Write-Verbose "Module $moduleName is already installed"
        }
        else {
            Write-Host "Installing module: $moduleName" -ForegroundColor Yellow
            if (Install-PowerShellModule -ModuleName $moduleName -AllowPrerelease:$allowPrerelease) {
                $cacheData.Modules[$moduleName] = @{
                    Installed   = $true
                    LastChecked = (Get-Date).ToString('o')
                    Version     = (Get-Module -Name $moduleName -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).Version.ToString()
                }
                $anyChanges = $true
            }
            else {
                $cacheData.Modules[$moduleName] = @{
                    Installed   = $false
                    LastChecked = (Get-Date).ToString('o')
                    Error       = "Installation failed"
                }
            }
        }
    }

    if ($anyChanges) {
        Update-CacheData -CacheData $cacheData
    }
}

function Import-RequiredModules {
    [CmdletBinding()]
    param()

    foreach ($moduleDef in $script:RequiredModules) {
        $moduleName = $moduleDef.Name
        
        if (Test-ModuleInstalled -ModuleName $moduleName) {
            if (-not (Test-ModuleLoaded -ModuleName $moduleName)) {
                try {
                    Import-Module -Name $moduleName -ErrorAction Stop
                    Write-Verbose "Imported module: $moduleName"
                }
                catch {
                    Write-Warning "Failed to import module $moduleName : $_"
                }
            }
            else {
                Write-Verbose "Module $moduleName is already loaded"
            }
        }
    }
}

function Update-AllPSModules {
    [CmdletBinding()]
    param(
        [switch]$Force
    )

    Write-Host "Checking for module updates..." -ForegroundColor Cyan
    
    # Define the update script to run in a separate process
    $updateScript = {
        param($RequiredModules, $Confirm)
        
        $ProgressPreference = 'SilentlyContinue'
        $ErrorActionPreference = 'Stop'
        
        foreach ($moduleDef in $RequiredModules) {
            $moduleName = $moduleDef.Name
            
            try {
                # Check for updates
                $current = Get-Module -Name $moduleName -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1
                if (-not $current) { continue }
                
                $latest = Find-Module -Name $moduleName -ErrorAction SilentlyContinue
                
                if ($latest -and $latest.Version -gt $current.Version) {
                    Write-Host "Updating $moduleName ($($current.Version) -> $($latest.Version))..." -ForegroundColor Yellow
                    
                    Update-Module -Name $moduleName -Force -ErrorAction Stop
                    
                    # Pruning: Remove older versions
                    $versions = Get-Module -Name $moduleName -ListAvailable | Sort-Object Version -Descending
                    if ($versions.Count -gt 1) {
                        $oldVersions = $versions | Select-Object -Skip 1
                        foreach ($ver in $oldVersions) {
                            try {
                                Write-Host "  Pruning old version: $($ver.Version)" -ForegroundColor DarkGray
                                Uninstall-Module -Name $moduleName -RequiredVersion $ver.Version -Force -ErrorAction Stop
                            }
                            catch {
                                Write-Warning "  Failed to prune $($ver.Version): $_"
                            }
                        }
                    }
                    
                    Write-Host "Updated $moduleName" -ForegroundColor Green
                }
            }
            catch {
                Write-Warning "Failed to update $moduleName : $_"
            }
        }
    }

    # Run the update in a separate process to avoid file locks
    try {
        $encodedCommand = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($updateScript.ToString()))
        
        # Serialize arguments and Base64 encode them to prevent quoting issues
        $jsonArgs = $script:RequiredModules | ConvertTo-Json -Compress
        $encodedArgs = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($jsonArgs))
        
        $processArgs = @(
            '-NoProfile',
            '-NonInteractive',
            '-Command',
            "& { 
                `$jsonArgs = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$encodedArgs'));
                `$requiredModules = `$jsonArgs | ConvertFrom-Json;
                `$scriptBlock = [ScriptBlock]::Create([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('$encodedCommand')));
                & `$scriptBlock -RequiredModules `$requiredModules
            }"
        )
        
        Start-Process -FilePath "pwsh" -ArgumentList $processArgs -Wait -NoNewWindow
    }
    catch {
        Write-Error "Failed to launch update process: $_"
    }

    # Force cache update after process finishes
    $cacheData = Get-CacheData
    $cacheData.LastChecked = (Get-Date).AddHours(-$script:CacheValidHours - 1).ToString('o')
    $cacheData.LastUpdateCheck = (Get-Date).ToString('o') # Reset the 7-day timer
    Update-CacheData -CacheData $cacheData
}
            

#endregion MODULE MANAGEMENT

#region OH-MY-POSH & FONT MANAGEMENT
function Test-OhMyPoshFontInstalled {
    [CmdletBinding()]
    param()

    $cacheData = Get-CacheData
    if ($cacheData.FontsInstalled -contains 'CascadiaCode') {
        return $true
    }

    # Check if Cascadia Code is installed (System or User)
    $systemFonts = @(Get-ChildItem -Path "$env:WINDIR\Fonts" -Filter "*Cas*dia*" -ErrorAction SilentlyContinue)
    $userFonts = @(Get-ChildItem -Path "$env:LOCALAPPDATA\Microsoft\Windows\Fonts" -Filter "*Cas*dia*" -ErrorAction SilentlyContinue)
    
    if ($systemFonts.Count -gt 0 -or $userFonts.Count -gt 0) {
        # Update cache
        $cacheData.FontsInstalled += 'CascadiaCode'
        Update-CacheData -CacheData $cacheData
        return $true
    }
    
    return $false
}

function Install-OhMyPoshFont {
    [CmdletBinding()]
    param()

    if (Test-OhMyPoshFontInstalled) {
        Write-Verbose "Cascadia Code font is already installed"
        return $true
    }

    try {
        Write-Host "Installing Cascadia Code font..." -ForegroundColor Yellow
        oh-my-posh font install CascadiaCode
        Write-Host "Font installed successfully" -ForegroundColor Green
        
        # Update cache
        $cacheData = Get-CacheData
        $cacheData.FontsInstalled += 'CascadiaCode'
        Update-CacheData -CacheData $cacheData
        
        return $true
    }
    catch {
        Write-Warning "Failed to install font: $_"
        Write-Host "You may need to manually install a Nerd Font for proper Oh-My-Posh display" -ForegroundColor Yellow
        return $false
    }
}

function Initialize-OhMyPosh {
    [CmdletBinding()]
    param(
        [switch]$ForVSCode
    )

    if (-not (Get-Command "oh-my-posh" -ErrorAction SilentlyContinue)) {
        Write-Warning "Oh-My-Posh is not installed. Run 'winget install JanDeDobbeleer.OhMyPosh' to install it."
        return
    }

    # Install font if needed (only once per system)
    if (-not $ForVSCode) {
        Install-OhMyPoshFont
    }

    try {
        if ($ForVSCode) {
            oh-my-posh init pwsh --config "$env:OneDriveConsumer\Documents\PowerShell\oh-my-posh-vscode.json" | Invoke-Expression
        }
        else {
            oh-my-posh init pwsh --config "$env:OneDriveConsumer\Documents\PowerShell\oh-my-posh-theme.json" | Invoke-Expression
        }
        Write-Verbose "Oh-My-Posh initialized successfully"
    }
    catch {
        Write-Warning "Failed to initialize Oh-My-Posh: $_"
    }
}
#endregion OH-MY-POSH & FONT MANAGEMENT

#region PSREADLINE CONFIGURATION
function Initialize-PSReadLine {
    [CmdletBinding()]
    param(
        [switch]$ForVSCode
    )

    if (-not (Get-Module -Name PSReadLine -ErrorAction SilentlyContinue)) {
        Write-Verbose "PSReadLine module not available"
        return
    }

    try {
        if ($ForVSCode) {
            Set-PSReadLineOption -PredictionViewStyle ListView
            Set-PSReadLineOption -HistoryNoDuplicates
        }
        else {
            Set-PSReadLineOption -PredictionViewStyle ListView
            Set-PSReadLineOption -PredictionSource HistoryAndPlugin
            Set-PSReadLineOption -HistoryNoDuplicates
            Set-PSReadLineOption -MaximumHistoryCount 10000
            
            Set-PSReadLineKeyHandler -Key Tab -Function Complete
            Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
            Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
        }
        Write-Verbose "PSReadLine configured successfully"
    }
    catch {
        Write-Warning "Failed to configure PSReadLine: $_"
    }
}
#endregion PSREADLINE CONFIGURATION

#region SESSION INITIALIZATION
function Initialize-ShellCustomizations {
    [CmdletBinding()]
    param(
        [switch]$ForVSCode
    )

    # Initialize Oh-My-Posh
    Initialize-OhMyPosh -ForVSCode:$ForVSCode
    
    # Initialize PSReadLine
    Initialize-PSReadLine -ForVSCode:$ForVSCode
}

function Initialize-InteractiveSession {
    [CmdletBinding()]
    param()

    # Import required modules
    Import-RequiredModules

    # Apply shell customizations
    Initialize-ShellCustomizations

    # Display system information
    Show-SystemInfo

    # Start background module check (non-blocking)
    Start-BackgroundModuleCheck
}

function Show-SystemInfo {
    [CmdletBinding()]
    param()

    if (Get-Command "fastfetch" -ErrorAction SilentlyContinue) {
        fastfetch
    }
    elseif (Get-Command "neofetch" -ErrorAction SilentlyContinue) {
        neofetch
    }
    else {
        Write-Host "┌─────────────────────────────────────────┐" -ForegroundColor Cyan
        Write-Host "│ System: $env:COMPUTERNAME                " -ForegroundColor Cyan
        Write-Host "│ PowerShell: $($PSVersionTable.PSVersion)" -ForegroundColor Cyan
        Write-Host "│ User: $env:USERNAME                     " -ForegroundColor Cyan  
        Write-Host "└─────────────────────────────────────────┘" -ForegroundColor Cyan
    }
}

function Start-BackgroundModuleCheck {
    [CmdletBinding()]
    param()

    $cacheData = Get-CacheData
    
    # Check if we need to run updates (every 7 days)
    $lastUpdate = [DateTime]::Parse($cacheData.LastUpdateCheck)
    $shouldUpdate = (Get-Date) -gt $lastUpdate.AddDays(7)

    # Only run in the background if we're in an interactive session and (cache is stale OR updates needed)
    if ((-not (Test-CacheValid)) -or $shouldUpdate) {
        $jobScript = {
            param($ModuleManagerPath, $ShouldUpdate)
            
            # Import the module manager functions
            . $ModuleManagerPath
            
            # Run installation checks
            Install-RequiredPSModules -ErrorAction SilentlyContinue
            
            # Run updates if needed
            if ($ShouldUpdate) {
                Update-AllPSModules
                
                # Update LastUpdateCheck
                $cacheData = Get-CacheData
                $cacheData.LastUpdateCheck = (Get-Date).ToString('o')
                Update-CacheData -CacheData $cacheData
            }
        }
        
        try {
            # Prefer ThreadJob for performance
            if (Get-Module -Name ThreadJob -ListAvailable) {
                Start-ThreadJob -Name "BackgroundModuleCheck" -ScriptBlock $jobScript -ArgumentList $PSCommandPath, $shouldUpdate -ThrottleLimit 1 | Out-Null
                Write-Verbose "Started background module check (ThreadJob)"
            }
            else {
                Start-Job -Name "BackgroundModuleCheck" -ScriptBlock $jobScript -ArgumentList $PSCommandPath, $shouldUpdate | Out-Null
                Write-Verbose "Started background module check (Job)"
            }
        }
        catch {
            Write-Verbose "Failed to start background module check: $_"
        }
    }
}
#endregion SESSION INITIALIZATION

# Initialize cache when module is imported
Initialize-Cache

# Export functions
$exportFunctions = @(
    'Install-RequiredPSModules',
    'Import-RequiredModules',
    'Update-AllPSModules',
    'Initialize-ShellCustomizations',
    'Initialize-InteractiveSession',
    'Start-BackgroundModuleCheck'
)

foreach ($function in $exportFunctions) {
    Set-Item -Path "function:global:$function" -Value (Get-Item "function:$function").Definition
}

Write-Verbose "Module manager initialized successfully"