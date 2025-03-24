<#
.SYNOPSIS
    PowerShell module and package manager for Windows.

.DESCRIPTION
    This script provides functions for managing PowerShell modules and Windows package installations.
    It implements a caching system to minimize performance impact during profile loading.

.NOTES
    Author: Irman
    Version: 1.0
#>

# Cache configuration
$script:CacheFolder = Join-Path $env:USERPROFILE '.pwsh-cache'
$script:ModuleCacheFile = Join-Path $script:CacheFolder 'module-cache.json'
$script:WingetCacheFile = Join-Path $script:CacheFolder 'winget-cache.json'
$script:CacheValidDays = 1 # Number of days before cache expires

# Module and package definitions
$script:RequiredModules = @(
    'posh-git',
    'Terminal-Icons', 
    'PSReadLine',
    'CompletionPredictor',
    'Get-ChildItemColor'
)

$script:RequiredWingetApps = @(
    'JanDeDobbeleer.OhMyPosh',
    'Microsoft.Powershell',
    'Starship.Starship'
)

<#
.SYNOPSIS
    Ensures the cache directory and files exist
#>
function Initialize-Cache {
    [CmdletBinding()]
    param()

    # Create cache directory if it doesn't exist
    if (-not (Test-Path -Path $script:CacheFolder)) {
        New-Item -Path $script:CacheFolder -ItemType Directory -Force | Out-Null
        Write-Verbose "Created cache directory: $script:CacheFolder"
    }

    # Create module cache file if it doesn't exist
    if (-not (Test-Path -Path $script:ModuleCacheFile)) {
        $initialCache = @{
            LastChecked = (Get-Date).AddDays(-2).ToString('o') # Force check on first run
            Modules = @{}
        }
        $initialCache | ConvertTo-Json | Set-Content -Path $script:ModuleCacheFile
        Write-Verbose "Created module cache file: $script:ModuleCacheFile"
    }

    # Create winget cache file if it doesn't exist
    if (-not (Test-Path -Path $script:WingetCacheFile)) {
        $initialCache = @{
            LastChecked = (Get-Date).AddDays(-2).ToString('o') # Force check on first run
            Apps = @{}
        }
        $initialCache | ConvertTo-Json | Set-Content -Path $script:WingetCacheFile
        Write-Verbose "Created winget cache file: $script:WingetCacheFile"
    }
}

<#
.SYNOPSIS
    Gets the cache data from the specified cache file
#>
function Get-CacheData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$CacheFile
    )

    try {
        $cacheData = Get-Content -Path $CacheFile -Raw | ConvertFrom-Json
        return $cacheData
    }
    catch {
        Write-Warning "Error reading cache file $CacheFile. Creating new cache file."
        Initialize-Cache
        return Get-Content -Path $CacheFile -Raw | ConvertFrom-Json
    }
}

<#
.SYNOPSIS
    Updates the cache data in the specified cache file
#>
function Update-CacheData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$CacheFile,
        
        [Parameter(Mandatory)]
        [PSCustomObject]$CacheData
    )

    try {
        $CacheData | ConvertTo-Json | Set-Content -Path $CacheFile
        Write-Verbose "Updated cache file: $CacheFile"
    }
    catch {
        Write-Warning "Failed to update cache file $CacheFile: $_"
    }
}

<#
.SYNOPSIS
    Checks if a cache is valid (not expired)
#>
function Test-CacheValid {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$CacheFile
    )

    if (-not (Test-Path -Path $CacheFile)) {
        return $false
    }

    try {
        $cacheData = Get-Content -Path $CacheFile -Raw | ConvertFrom-Json
        $lastChecked = [DateTime]::Parse($cacheData.LastChecked)
        $cacheAge = (Get-Date) - $lastChecked
        
        return $cacheAge.TotalDays -lt $script:CacheValidDays
    }
    catch {
        Write-Warning "Error checking cache validity: $_"
        return $false
    }
}

<#
.SYNOPSIS
    Imports all required PowerShell modules
.DESCRIPTION
    Imports all required PowerShell modules without checking if they're installed
    This is optimized for fast profile loading
#>
function Import-RequiredModules {
    [CmdletBinding()]
    param()

    # Import modules in parallel for faster loading
    $script:RequiredModules | ForEach-Object -Parallel {
        try {
            Import-Module $_ -ErrorAction SilentlyContinue
        }
        catch {
            # Silently continue - we don't want to block profile loading
        }
    } -ThrottleLimit 10
}

<#
.SYNOPSIS
    Checks and installs required PowerShell modules
.DESCRIPTION
    Checks if required PowerShell modules are installed and installs them if needed
    Uses a cache to minimize impact on profile loading times
.PARAMETER Force
    Forces checking and installation regardless of cache status
#>
function Install-RequiredPSModules {
    [CmdletBinding()]
    param(
        [switch]$Force
    )

    # Skip if cache is valid and Force is not specified
    if (-not $Force -and (Test-CacheValid -CacheFile $script:ModuleCacheFile)) {
        Write-Verbose "Module cache is valid. Skipping module installation check."
        return
    }

    Write-Host "Checking required PowerShell modules..." -ForegroundColor Cyan

    # Get current cache data
    $cacheData = Get-CacheData -CacheFile $script:ModuleCacheFile

    # Update last checked timestamp
    $cacheData.LastChecked = (Get-Date).ToString('o')

    # Check each module
    foreach ($moduleName in $script:RequiredModules) {
        $module = Get-Module -Name $moduleName -ListAvailable
        
        if (-not $module) {
            Write-Host "Installing module: $moduleName" -ForegroundColor Yellow
            try {
                Install-Module -Name $moduleName -Scope CurrentUser -Force -AllowClobber
                $cacheData.Modules[$moduleName] = @{
                    Installed = $true
                    InstalledOn = (Get-Date).ToString('o')
                }
                Write-Host "Module $moduleName installed successfully" -ForegroundColor Green
            }
            catch {
                $cacheData.Modules[$moduleName] = @{
                    Installed = $false
                    Error = $_.Exception.Message
                }
                Write-Warning "Failed to install module $moduleName : $_"
            }
        }
        else {
            $cacheData.Modules[$moduleName] = @{
                Installed = $true
                InstalledOn = (Get-Date).ToString('o')
            }
            Write-Verbose "Module $moduleName is already installed"
        }
    }

    # Update cache file
    Update-CacheData -CacheFile $script:ModuleCacheFile -CacheData $cacheData
}

<#
.SYNOPSIS
    Checks and installs required Winget applications
.DESCRIPTION
    Checks if required Winget applications are installed and installs them if needed
    Uses a cache to minimize impact on profile loading times
.PARAMETER Force
    Forces checking and installation regardless of cache status
#>
function Install-RequiredWingetApps {
    [CmdletBinding()]
    param(
        [switch]$Force
    )

    # Skip if cache is valid and Force is not specified
    if (-not $Force -and (Test-CacheValid -CacheFile $script:WingetCacheFile)) {
        Write-Verbose "Winget cache is valid. Skipping winget app installation check."
        return
    }

    # Check if winget is available
    $wingetPath = Get-Command winget -ErrorAction SilentlyContinue
    if (-not $wingetPath) {
        Write-Warning "Winget is not available. Please install Microsoft App Installer from the Microsoft Store."
        return
    }

    Write-Host "Checking required Winget applications..." -ForegroundColor Cyan

    # Get current cache data
    $cacheData = Get-CacheData -CacheFile $script:WingetCacheFile

    # Update last checked timestamp
    $cacheData.LastChecked = (Get-Date).ToString('o')

    # Check each application
    foreach ($appId in $script:RequiredWingetApps) {
        try {
            $installed = winget list --id $appId --accept-source-agreements | Select-String -Pattern $appId -Quiet
            
            if (-not $installed) {
                Write-Host "Installing application: $appId" -ForegroundColor Yellow
                try {
                    winget install --id $appId --accept-source-agreements --accept-package-agreements --silent
                    
                    # Verify installation
                    $verifyInstalled = winget list --id $appId --accept-source-agreements | Select-String -Pattern $appId -Quiet
                    if ($verifyInstalled) {
                        $cacheData.Apps[$appId] = @{
                            Installed = $true
                            InstalledOn = (Get-Date).ToString('o')
                        }
                        Write-Host "Application $appId installed successfully" -ForegroundColor Green
                    }
                    else {
                        $cacheData.Apps[$appId] = @{
                            Installed = $false
                            Error = "Installation completed but application not found in winget list"
                        }
                        Write-Warning "Installation of $appId may have failed: Application not found in winget list"
                    }
                }
                catch {
                    $cacheData.Apps[$appId] = @{
                        Installed = $false
                        Error = $_.Exception.Message
                    }
                    Write-Warning "Failed to install application $appId : $_"
                }
            }
            else {
                $cacheData.Apps[$appId] = @{
                    Installed = $true
                    InstalledOn = (Get-Date).ToString('o')
                }
                Write-Verbose "Application $appId is already installed"
            }
        }
        catch {
            $cacheData.Apps[$appId] = @{
                Installed = $false
                Error = $_.Exception.Message
            }
            Write-Warning "Error checking status for application $appId : $_"
        }
    }

    # Update cache file
    Update-CacheData -CacheFile $script:WingetCacheFile -CacheData $cacheData
}

<#
.SYNOPSIS
    Updates all installed PowerShell modules
.DESCRIPTION
    Updates all installed PowerShell modules to their latest versions
#>
function Update-AllPSModules {
    [CmdletBinding()]
    param()

    Write-Host "Updating PowerShell modules..." -ForegroundColor Cyan
    
    try {
        # Get all installed modules that can be updated
        $outdatedModules = Get-Module -ListAvailable | 
            Where-Object { $_.RepositorySourceLocation -ne $null } | 
            Get-Unique -PipelineVariable Module | 
            ForEach-Object {
                $latestVersion = Find-Module -Name $_.Name -ErrorAction SilentlyContinue
                if ($latestVersion -and $latestVersion.Version -gt $_.Version) {
                    [PSCustomObject]@{
                        Name = $_.Name
                        CurrentVersion = $_.Version
                        LatestVersion = $latestVersion.Version
                    }
                }
            }

        if ($outdatedModules) {
            $outdatedModules | ForEach-Object {
                Write-Host "Updating module $($_.Name) from version $($_.CurrentVersion) to $($_.LatestVersion)" -ForegroundColor Yellow
                Update-Module -Name $_.Name -Force
                Write-Host "Module $($_.Name) updated successfully" -ForegroundColor Green
            }
        }
        else {
            Write-Host "All modules are up to date" -ForegroundColor Green
        }
    }
    catch {
        Write-Warning "Error updating modules: $_"
    }
}

<#
.SYNOPSIS
    Performs a background check for module and application installations
.DESCRIPTION
    Starts a background job to check and install required modules and applications
    This allows profile loading to continue without waiting for installation checks
.PARAMETER Force
    Forces checking and installation regardless of cache status
#>
function Start-BackgroundInstallationCheck {
    [CmdletBinding()]
    param(
        [switch]$Force
    )
    
    $jobScript = {
        param($ModulePath, $Force)
        
        # Import the module
        Import-Module $ModulePath -Force
        
        # Run installation checks
        if ($Force) {
            Install-RequiredPSModules -Force -Verbose
            Install-RequiredWingetApps -Force -Verbose
        }
        else {
            Install-RequiredPSModules -Verbose
            Install-RequiredWingetApps -Verbose
        }
    }
    
    Start-Job -Name "ModuleInstallationCheck" -ScriptBlock $jobScript -ArgumentList $PSCommandPath, $Force | Out-Null
    Write-Verbose "Started background installation check job"
}

# Initialize cache when module is imported
Initialize-Cache

# Export public functions
Export-ModuleMember -Function Import-RequiredModules
Export-ModuleMember -Function Install-RequiredPSModules
Export-ModuleMember -Function Install-RequiredWingetApps
Export-ModuleMember -Function Update-AllPSModules
Export-ModuleMember -Function Start-BackgroundInstallationCheck

#region Module Manager
# Improved module manager with caching, background processing, and parallel importing
# Author: User
# Version: 2.0

# Constants
$ModuleCachePath = Join-Path $env:USERPROFILE '.module-cache.json'
$DefaultModules = @(
    @{moduleName = "Microsoft.WinGet.Client"; installOptions = "-AcceptLicense -Force"},
    @{moduleName = "PSWriteColor"; installOptions = "-AcceptLicense -Force"},
    @{moduleName = "PSReadLine"; installOptions = "-AcceptLicense -AllowPrerelease -Force -SkipPublisherCheck"},
    @{moduleName = "posh-git"; installOptions = "-AcceptLicense -Force"},
    @{moduleName = "Terminal-Icons"; installOptions = "-AcceptLicense -Force"},
    @{moduleName = "oh-my-posh"; installOptions = "-AcceptLicense -Force"},
    @{moduleName = "z"; installOptions = "-AcceptLicense -Force"},
    @{moduleName = "M365PSProfile"; installOptions = "-AcceptLicense -Force"},
    @{moduleName = "Az.Accounts"; installOptions = "-AcceptLicense -Force"},
    @{moduleName = "Az.Tools.Predictor"; installOptions = "-AcceptLicense -Force"},
    @{moduleName = "PSWindowsUpdate"; installOptions = "-AcceptLicense -Force"}
)

$DefaultWingetApps = @(
    @{ Command = 'oh-my-posh'; WingetName = 'JanDeDobbeleer.OhMyPosh'; OptionalStrings = '' },
    @{ Command = 'git'; WingetName = 'git.git'; OptionalStrings = '' },
    @{ Command = 'fastfetch'; WingetName = 'Fastfetch-cli.Fastfetch'; OptionalStrings = '' },
    @{ Command = 'onefetch'; WingetName = 'o2sh.onefetch'; OptionalStrings = '' }
)

# Initialize logging
function Write-ModuleLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('Info', 'Warning', 'Error', 'Success')]
        [string]$Level = 'Info'
    )
    
    $colors = @{
        'Info' = 'Cyan'
        'Warning' = 'Yellow'
        'Error' = 'Red'
        'Success' = 'Green'
    }
    
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logMessage = "[$timestamp] [$Level] $Message"
    
    # Only show output if not in a background job
    if (-not $env:POWERSHELL_BACKGROUND_JOB) {
        Write-Host $logMessage -ForegroundColor $colors[$Level]
    }
    
    # Could add file logging here if needed
}

# Cache Management
function Initialize-ModuleCache {
    [CmdletBinding()]
    param()
    
    try {
        if (-not (Test-Path $ModuleCachePath)) {
            $defaultCache = @{
                'LastCheckDate' = (Get-Date).AddDays(-2).ToString('yyyy-MM-dd')
                'ModuleStatus' = @{}
                'WingetStatus' = @{}
            }
            
            $defaultCache | ConvertTo-Json -Depth 4 | Set-Content -Path $ModuleCachePath -Force
            Write-ModuleLog "Module cache initialized at $ModuleCachePath" -Level Info
        }
        
        return Get-Content -Path $ModuleCachePath -Raw | ConvertFrom-Json
    }
    catch {
        Write-ModuleLog "Failed to initialize module cache: $_" -Level Error
        # Create a default cache in memory if file operations fail
        return @{
            'LastCheckDate' = (Get-Date).AddDays(-2).ToString('yyyy-MM-dd')
            'ModuleStatus' = @{}
            'WingetStatus' = @{}
        }
    }
}

function Update-ModuleCache {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Cache
    )
    
    try {
        $Cache | ConvertTo-Json -Depth 4 | Set-Content -Path $ModuleCachePath -Force
        Write-ModuleLog "Module cache updated successfully" -Level Info
    }
    catch {
        Write-ModuleLog "Failed to update module cache: $_" -Level Error
    }
}

function Test-ShouldCheckModules {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch]$Force
    )
    
    if ($Force) {
        return $true
    }
    
    try {
        $cache = Initialize-ModuleCache
        $lastCheck = [DateTime]::ParseExact($cache.LastCheckDate, 'yyyy-MM-dd', $null)
        $today = (Get-Date).Date
        
        return $lastCheck -lt $today
    }
    catch {
        Write-ModuleLog "Error determining if modules should be checked: $_" -Level Error
        # Default to checking if there's an error
        return $true
    }
}

# Module Importing
function Import-RequiredModules {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [array]$Modules = $DefaultModules
    )
    
    Write-ModuleLog "Importing PowerShell modules..." -Level Info
    
    # Create a runspace pool for parallel importing
    $runspacePool = [runspacefactory]::CreateRunspacePool(1, [Environment]::ProcessorCount)
    $runspacePool.Open()
    
    $runspaces = @()
    $results = [System.Collections.ArrayList]::new()
    
    foreach ($module in $Modules) {
        $powershell = [powershell]::Create()
        $powershell.RunspacePool = $runspacePool
        
        [void]$powershell.AddScript({
            param($module)
            try {
                $moduleName = if ($module -is [string]) { $module } else { $module.moduleName }
                
                if (Get-Module -ListAvailable -Name $moduleName) {
                    Import-Module $moduleName -DisableNameChecking
                    return @{
                        'ModuleName' = $moduleName
                        'Status' = 'Imported'
                        'Success' = $true
                        'Error' = $null
                    }
                }
                else {
                    return @{
                        'ModuleName' = $moduleName
                        'Status' = 'NotAvailable'
                        'Success' = $false
                        'Error' = "Module not available"
                    }
                }
            }
            catch {
                return @{
                    'ModuleName' = if ($module -is [string]) { $module } else { $module.moduleName }
                    'Status' = 'Error'
                    'Success' = $false
                    'Error' = $_.Exception.Message
                }
            }
        })
        
        [void]$powershell.AddArgument($module)
        
        $runspaces += [PSCustomObject]@{
            Runspace = $powershell.BeginInvoke()
            PowerShell = $powershell
            ModuleName = if ($module -is [string]) { $module } else { $module.moduleName }
        }
    }
    
    # Wait for all runspaces to complete and collect results
    foreach ($runspace in $runspaces) {
        $results.Add($runspace.PowerShell.EndInvoke($runspace.Runspace))
        $runspace.PowerShell.Dispose()
    }
    
    $runspacePool.Close()
    $runspacePool.Dispose()
    
    # Log results
    foreach ($result in $results) {
        if ($result.Success) {
            Write-ModuleLog "Imported module: $($result.ModuleName)" -Level Success
        }
        else {
            Write-ModuleLog "Failed to import module: $($result.ModuleName) - $($result.Error)" -Level Warning
        }
    }
    
    Write-ModuleLog "Module importing completed" -Level Info
    
    return $results
}

# Module and Application Installation
function Start-ModuleVerification {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch]$Force,
        
        [Parameter(Mandatory = $false)]
        [switch]$NoBackground
    )
    
    # Check if we should run the verification
    if (-not (Test-ShouldCheckModules -Force:$Force)) {
        Write-ModuleLog "Skipping module verification - last check was today" -Level Info
        return
    }
    
    # If NoBackground is specified or we're forcing, run synchronously
    if ($NoBackground -or $Force) {
        Sync-ModulesAndPackages -Force:$Force
        return
    }
    
    # Otherwise, run in background
    Write-ModuleLog "Starting background module verification..." -Level Info
    
    $scriptBlock = {
        param($ModuleCachePath, $DefaultModules, $DefaultWingetApps, $Force)
        
        # Set flag to control output in the background job
        $env:POWERSHELL_BACKGROUND_JOB = $true
        
        # Import required modules for winget if available
        try {
            Import-Module Microsoft.WinGet.Client -ErrorAction SilentlyContinue
        }
        catch {
            # Continue without Microsoft.WinGet.Client module
        }
        
        function Write-ModuleLog {
            param($Message, $Level = 'Info')
            # Silent in background job
        }
        
        function Initialize-ModuleCache {
            try {
                if (-not (Test-Path $ModuleCachePath)) {
                    $defaultCache = @{
                        'LastCheckDate' = (Get-Date).AddDays(-2).ToString('yyyy-MM-dd')
                        'ModuleStatus' = @{}
                        'WingetStatus' = @{}
                    }
                    
                    $defaultCache | ConvertTo-Json -Depth 4 | Set-Content -Path $ModuleCachePath -Force
                }
                
                return Get-Content -Path $ModuleCachePath -Raw | ConvertFrom-Json
            }
            catch {
                # Create a default cache in memory if file operations fail
                return @{
                    'LastCheckDate' = (Get-Date).AddDays(-2).ToString('yyyy-MM-dd')
                    'ModuleStatus' = @{}
                    'WingetStatus' = @{}
                }
            }
        }
        
        function Update-ModuleCache {
            param($Cache)
            
            try {
                $Cache | ConvertTo-Json -Depth 4 | Set-Content -Path $ModuleCachePath -Force
            }
            catch {
                # Silently fail in background job
            }
        }
        
        function Install-RequiredPSModules {
            param([array]$Modules)
            
            $cache = Initialize-ModuleCache
            $installedModules = Get-Module -ListAvailable | Select-Object -ExpandProperty Name -Unique
            
            foreach ($module in $Modules) {
                $moduleName = if ($module -is [string]) { $module } else { $module.moduleName }
                $installOptions = if ($module -is [string]) { "-Force -AllowClobber" } else { $module.installOptions }
                
                if ($installedModules -notcontains $moduleName) {
                    try {
                        # Convert install options string to script block for execution
                        $scriptBlock = [ScriptBlock]::Create("Install-Module -Name $moduleName -Scope CurrentUser $installOptions")
                        Invoke-Command -ScriptBlock $scriptBlock
                        
                        $cache.ModuleStatus[$moduleName] = @{
                            'Installed' = $true
                            'LastChecked' = (Get-Date).ToString('yyyy-MM-dd')
                        }
                    }
                    catch {
                        $cache.ModuleStatus[$moduleName] = @{
                            'Installed' = $false
                            'LastChecked' = (Get-Date).ToString('yyyy-MM-dd')
                            'Error' = $_.Exception.Message
                        }
                    }
                }
                else {
                    $cache.ModuleStatus[$moduleName] = @{
                        'Installed' = $true
                        'LastChecked' = (Get-Date).ToString('yyyy-MM-dd')
                    }
                }
            }
            
            Update-ModuleCache -Cache $cache
        }
        
        function Install-RequiredWingetApps {
            param([array]$Apps)
            
            $cache = Initialize-ModuleCache
            
            # Check if winget is available - try using module first, then command line
            try {
                # First try using Microsoft.WinGet.Client module if available
                if (Get-Module Microsoft.WinGet.Client -ListAvailable) {
                    foreach ($app in $Apps) {
                        try {
                            $appName = if ($app -is [string]) { $app } else { $app.WingetName }
                            $appCommand = if ($app -is [string]) { $app } else { $app.Command }
                            
                            # Check if app is installed - using command availability as a proxy
                            if (-not (Get-Command -Name $appCommand -ErrorAction SilentlyContinue)) {
                                # Install the app
                                Install-WinGetPackage -Id $appName -Silent
                                
                                $cache.WingetStatus[$appName] = @{
                                    'Installed' = $true
                                    'LastChecked' = (Get-Date).ToString('yyyy-MM-dd')
                                }
                            }
                            else {
                                $cache.WingetStatus[$appName] = @{
                                    'Installed' = $true
                                    'LastChecked' = (Get-Date).ToString('yyyy-MM-dd')
                                }
                            }
        
        # Run the installations
        Install-RequiredPSModules -Modules $DefaultModules
        Install-RequiredWingetApps -Apps $DefaultWingetApps
        
        # Update the last check date
        $cache = Initialize-ModuleCache
        $cache.LastCheckDate = (Get-Date).ToString('yyyy-MM-dd')
        Update-ModuleCache -Cache $cache
    }
    
    Start-Job -ScriptBlock $scriptBlock -ArgumentList $ModuleCachePath, $DefaultModules, $DefaultWingetApps, $Force | Out-Null
}

function Sync-ModulesAndPackages {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch]$Force
    )
    
    Write-ModuleLog "Verifying modules and packages..." -Level Info
    
    # Update cache with today's date
    $cache = Initialize-ModuleCache
    $cache.LastCheckDate = (Get-Date).ToString('yyyy-MM-dd')
    Update-ModuleCache -Cache $cache
    
    # Install PowerShell modules
    Install-RequiredPSModules -Modules $DefaultModules
    
    # Install Winget applications
    Install-RequiredWingetApps -Apps $DefaultWingetApps
    
    Write-ModuleLog "Module and package verification completed" -Level Success
}

function Install-RequiredPSModules {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string[]]$Modules = $DefaultModules
    )
    
    Write-ModuleLog "Checking PowerShell modules..." -Level Info
    $installedModules = Get-Module -ListAvailable | Select-Object -ExpandProperty Name -Unique
    $cache = Initialize-ModuleCache
    
    $progress = 0
    $total = $Modules.Count
    
    foreach ($module in $Modules) {
        $progress++
        Write-Progress -Activity "Checking PowerShell modules" -Status "Module: $module" -PercentComplete (($progress / $total) * 100)
        
        if ($installedModules -notcontains $module) {
            Write-ModuleLog "Installing module: $module" -Level Info
            try {
                Install-Module -Name $module -Scope CurrentUser -Force -AllowClobber
                Write-ModuleLog "Module installed successfully: $module" -Level Success
                
                $cache.ModuleStatus[$module] = @{
                    'Installed' = $true
                    'LastChecked' = (Get-Date).ToString('yyyy-MM-dd')
                }
            }
            catch {
                Write-ModuleLog "Failed to install module $module`: $_" -Level Error
                
                $cache.ModuleStatus[$module] = @{

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

