#Requires -Version 5.1
<#
.SYNOPSIS
    Custom PowerShell aliases and utility functions
.DESCRIPTION
    This file contains optimized aliases and functions to enhance PowerShell productivity.
    Organized in functional categories with proper error handling and parameter validation.
.NOTES
    Author: irman
    Last Edit: $(Get-Date -Format "yyyy-MM-dd")
    Version: 1.2.0
.LINK
    https://github.com/irman/windots
#>

# Module metadata for import handling
$script:ModuleVersion = '1.2.2'
$script:ModuleName = 'PowerShell-Aliases'
$script:ModuleDescription = 'Optimized PowerShell aliases and utility functions'
#>

#region Initialization

# Define common parameter attributes for reuse
$PathParamAttribute = [System.Management.Automation.ParameterAttribute]@{
    Mandatory   = $true
    Position    = 0
    HelpMessage = "Specify the file or directory path"
}

# Initialize performance optimizations
$script:CommandCache = @{}

#endregion Initialization

#region File and Directory Management Functions

<#
.SYNOPSIS
    Creates an empty file (similar to Linux touch)
.DESCRIPTION
    Creates a new empty file or updates the timestamp of an existing file
.PARAMETER Path
    The path of the file to create or update
.EXAMPLE
    touch newfile.txt
#>
function touch {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, HelpMessage = "Specify the file or directory path")]
        [string]$Path
    )
    
    try {
        if (Test-Path -Path $Path) {
            # Update timestamp if file exists
            (Get-Item -Path $Path).LastWriteTime = Get-Date
            Write-Verbose "Updated timestamp for $Path"
        } 
        else {
            # Create empty file
            "" | Out-File -FilePath $Path -Encoding UTF8 -ErrorAction Stop
            Write-Verbose "Created new file: $Path"
        }
    }
    catch {
        Write-Error "Failed to touch $Path':' $_"
    }
}

<#
.SYNOPSIS
    Creates a new file in the current directory
.PARAMETER Name
    The name of the file to create
#>
function nf {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Name
    )
    
    try {
        $file = New-Item -ItemType "file" -Path . -Name $Name -ErrorAction Stop
        Write-Verbose "Created new file: $($file.FullName)"
        return $file
    }
    catch {
        Write-Error "Failed to create file '$Name': ${_}"
    }
}

<#
.SYNOPSIS
    Creates a directory and changes to it
.PARAMETER Directory
    The directory to create and navigate to
#>
function mkcd {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Directory
    )
    
    try {
        $newDir = New-Item -ItemType Directory -Path $Directory -Force -ErrorAction Stop
        Set-Location -Path $newDir.FullName -ErrorAction Stop
        Write-Verbose "Created and navigated to: $($newDir.FullName)"
    }
    catch {
        Write-Error "Failed to create or navigate to directory: ${_}"
    }
}

<#
.SYNOPSIS
    Quick navigation shortcuts
#>
function docs {
    Set-Location -Path $HOME\Documents
}

function dtop {
    Set-Location -Path $HOME\Desktop
}

<#
.SYNOPSIS
    Enhanced directory listing with different options
.DESCRIPTION
    Provides better formatted directory listings with various options
#>
function la {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string]$Path = ".",
        
        [Parameter()]
        [switch]$Detail
    )
    
    if ($Detail) {
        Get-ChildItem -Path $Path -Force | Format-List
    } 
    else {
        Get-ChildItem -Path $Path -Force | Format-Table -AutoSize
    }
}

function ll {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string]$Path = "."
    )
    
    Get-ChildItem -Path $Path -Force -Hidden | Format-Table -AutoSize
}

#endregion File and Directory Management Functions

#region Git Functions

<#
.SYNOPSIS
    Smart Git command execution with fallback
.DESCRIPTION
    Checks if git is installed and provides meaningful error if not
#>
function Invoke-GitCommand {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Command,
        
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Arguments
    )
    
    # Check if git command exists - use cache for performance
    if (-not $script:CommandCache.ContainsKey('git')) {
        $script:CommandCache['git'] = Get-Command -Name git -ErrorAction SilentlyContinue
    }
    
    if ($script:CommandCache['git']) {
        $argString = $Arguments -join ' '
        $expression = "git $Command $argString"
        Write-Verbose "Executing: $expression"
        Invoke-Expression $expression
    }
    else {
        Write-Error "Git is not installed or not in your PATH. Please install Git to use this function."
    }
}

<#
.SYNOPSIS
    Git status shortcut
#>
function gs {
    [CmdletBinding()]
    param()
    
    Invoke-GitCommand -Command "status"
}

<#
.SYNOPSIS
    Git add shortcut
#>
function ga {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$Path = "."
    )
    
    Invoke-GitCommand -Command "add" -Arguments $Path
}

<#
.SYNOPSIS
    Git commit shortcut
.PARAMETER Message
    The commit message
#>
function gc {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message
    )
    
    Invoke-GitCommand -Command "commit" -Arguments "-m", "`"$Message`""
}

<#
.SYNOPSIS
    Git push shortcut
#>
function gp {
    [CmdletBinding()]
    param()
    
    Invoke-GitCommand -Command "push"
}

<#
.SYNOPSIS
    Navigate to Github folder
#>
function g {
    # Check if z module is available
    if (Get-Command -Name z -ErrorAction SilentlyContinue) {
        z Github
    }
    else {
        # Fallback if z module is not available
        $githubPath = Join-Path -Path $HOME -ChildPath "Github"
        if (Test-Path -Path $githubPath) {
            Set-Location -Path $githubPath
        }
        else {
            Write-Warning "Github directory not found. Creating it..."
            New-Item -ItemType Directory -Path $githubPath -Force
            Set-Location -Path $githubPath
        }
    }
}

<#
.SYNOPSIS
    Git clone shortcut
.PARAMETER Url
    The repository URL to clone
#>
function gcl {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Url
    )
    
    Invoke-GitCommand -Command "clone" -Arguments $Url
}

<#
.SYNOPSIS
    Git commit shortcut - adds and commits in one step
.PARAMETER Message
    The commit message
#>
function gcom {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Message
    )
    
    try {
        ga
        gc -Message $Message
    }
    catch {
        Write-Error "Git commit failed: ${_}"
    }
}

<#
.SYNOPSIS
    Git add, commit, and push in one command
.PARAMETER Message
    The commit message
#>
function lazyg {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Message
    )
    
    try {
        ga
        gc -Message $Message
        gp
    }
    catch {
        Write-Error "LazyGit operation failed: ${_}"
    }
}

#endregion Git Functions

#region Clipboard Functions

<#
.SYNOPSIS
    Copy text to clipboard
.PARAMETER Text
    Text to copy to clipboard
#>
function cpy {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string]$Text
    )
    
    process {
        try {
            $Text | Set-Clipboard
            Write-Verbose "Copied to clipboard: $Text"
        }
        catch {
            Write-Error "Failed to copy to clipboard: ${_}"
        }
    }
}

<#
.SYNOPSIS
    Paste text from clipboard
#>
function pst {
    [CmdletBinding()]
    param()
    
    try {
        $clipboardContent = Get-Clipboard -TextFormatType Text -ErrorAction Stop
        return $clipboardContent
    }
    catch {
        Write-Error "Failed to get clipboard content: ${_}"
        return $null
    }
}

#endregion Clipboard Functions

#region System Administration

<#
.SYNOPSIS
    Elevate to admin privileges
.DESCRIPTION
    Opens a new terminal window with admin privileges
.PARAMETER Command
    Optional command to run in the admin window
#>
function admin {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
        [string[]]$Command
    )
    
    try {
        if ($Command.Count -gt 0) {
            $cmdString = $Command -join ' '
            $argList = "pwsh.exe -NoExit -Command `"& { $cmdString }`""
            Start-Process wt -Verb runAs -ArgumentList $argList -ErrorAction Stop
        }
        else {
            Start-Process wt -Verb runAs -ErrorAction Stop
        }
        Write-Verbose "Started admin terminal session"
    }
    catch {
        Write-Error "Failed to start admin terminal: ${_}"
    }
}

<#
.SYNOPSIS
    Restarts the current PowerShell session
.DESCRIPTION
    Cleanly restarts the current PowerShell session
#>
function restart-powershell {
    [CmdletBinding()]
    param()
    
    try {
        if ($host.Name -eq 'ConsoleHost') {
            Write-Verbose "Restarting PowerShell console..."
            Start-Process pwsh.exe -NoNewWindow
            exit
        }
        elseif ($host.Name -eq 'Windows PowerShell ISE Host') {
            Write-Verbose "Restarting PowerShell ISE..."
            $psISE.CurrentPowerShellTab.Files.Save($true)
            Start-Process powershell_ise.exe -NoNewWindow
            exit
        }
        elseif ($host.Name -eq 'Visual Studio Code Host') {
            Write-Warning "Please use VSCode's terminal restart functionality instead."
        }
        else {
            Write-Warning "Unknown PowerShell host: $($host.Name). Please restart manually."
        }
    }
    catch {
        Write-Error "Failed to restart PowerShell: ${_}"
    }
}

<#
.SYNOPSIS
    Updates system components
.DESCRIPTION
    Updates PowerShell modules, Windows packages and system components
.PARAMETER Component
    Component to update (All, PSModules, Winget, Windows)
#>
function update-system {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [ValidateSet('All', 'PSModules', 'Winget', 'Windows')]
        [string]$Component = 'All'
    )
    
    Write-Host "Starting system update..." -ForegroundColor Cyan
    
    # Update PowerShell modules
    if ($Component -in @('All', 'PSModules')) {
        try {
            # Use module-manager's smart update (out-of-process)
            if (Get-Command 'Update-AllPSModules' -ErrorAction SilentlyContinue) {
                Update-AllPSModules -Force
            }
            else {
                # Fallback if module-manager isn't loaded
                Write-Host "Updating PowerShell modules..." -ForegroundColor Yellow
                Update-Module -Force -ErrorAction Continue
                Write-Host "PowerShell modules updated." -ForegroundColor Green
            }
        }
        catch {
            Write-Error "Failed to update PowerShell modules: ${_}"
        }
    }
    
    # Update Winget packages
    if ($Component -in @('All', 'Winget')) {
        try {
            Write-Host "Updating installed applications..." -ForegroundColor Yellow
            if (Get-Command winget -ErrorAction SilentlyContinue) {
                winget upgrade --all
                Write-Host "Winget packages updated." -ForegroundColor Green
            }
            else {
                Write-Warning "Winget not installed. Skipping application updates."
            }
        }
        catch {
            if ($_.ToString().Contains("No installed package found matching input criteria")) {
                 Write-Host "No installed package found matching input criteria." -ForegroundColor DarkGray
            } else {
                Write-Error "Failed to update Winget packages: ${_}"
            }
        }
    }
    
    # Windows Update
    if ($Component -in @('All', 'Windows')) {
        try {
            Write-Host "Checking for Windows Updates..." -ForegroundColor Yellow
            
            $isElevated = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
            
            if ($isElevated) {
                if (Get-Command -Name Get-WindowsUpdate -ErrorAction SilentlyContinue) {
                    Get-WindowsUpdate -MicrosoftUpdate -AcceptAll -Install -IgnoreReboot
                    Write-Host "Windows updates installed." -ForegroundColor Green
                }
                else {
                    Write-Warning "PSWindowsUpdate module not found. Install with 'Install-Module PSWindowsUpdate'"
                }
            }
            else {
                Write-Host "Elevation required for Windows Updates. Launching admin prompt..." -ForegroundColor Yellow
                
                # Check if PSWindowsUpdate is available even if not elevated, just to give a better error if it's missing entirely
                # Note: Get-Command might fail for some admin-only modules but usually visible
                if (Get-Command -Name Get-WindowsUpdate -ErrorAction SilentlyContinue) {
                    $cmd = "Get-WindowsUpdate -MicrosoftUpdate -AcceptAll -Install -IgnoreReboot; Write-Host 'Press any key to close...'; [void][System.Console]::ReadKey()"
                    Start-Process pwsh -ArgumentList "-Command", "& { $cmd }" -Verb RunAs -Wait
                }
                else {
                    # If we can't see the command, we try to run it anyway in the elevated session, 
                    # but if we are sure it's missing we could warn. 
                    # Safer to just try running it in the elevated session as the module might be installed in a scope visible to admin.
                     $cmd = "if (Get-Command -Name Get-WindowsUpdate -ErrorAction SilentlyContinue) { Get-WindowsUpdate -MicrosoftUpdate -AcceptAll -Install -IgnoreReboot } else { Write-Warning 'PSWindowsUpdate module not found.' }; Write-Host 'Press any key to close...'; [void][System.Console]::ReadKey()"
                     Start-Process pwsh -ArgumentList "-Command", "& { $cmd }" -Verb RunAs -Wait
                }
                Write-Host "Windows update process completed." -ForegroundColor Green
            }
        }
        catch {
            Write-Error "Failed to update Windows: ${_}"
        }
    }
    
    Write-Host "System update completed." -ForegroundColor Cyan
}

# Create alias for update-system
Set-Alias -Name ups -Value update-system

<#
.SYNOPSIS
    Get system information
.DESCRIPTION
    Displays detailed system information including hardware, OS, and network
#>
function sysinfo {
    [CmdletBinding()]
    param()
    
    try {
        $os = Get-CimInstance Win32_OperatingSystem
        $cs = Get-CimInstance Win32_ComputerSystem
        $proc = Get-CimInstance Win32_Processor
        $memory = [math]::Round($cs.TotalPhysicalMemory / 1GB, 2)
        
        Write-Host "`n=== System Information ===" -ForegroundColor Cyan
        Write-Host "Computer: $($cs.Name)" -ForegroundColor Green
        Write-Host "OS: $($os.Caption) $($os.Version)" -ForegroundColor Green
        Write-Host "CPU: $($proc.Name)" -ForegroundColor Green
        Write-Host "Memory: ${memory}GB" -ForegroundColor Green
        Write-Host "Uptime: $([math]::Round(($os.LocalDateTime - $os.LastBootUpTime).TotalHours, 2)) hours" -ForegroundColor Green
        
        # Only attempt to get IP address if there's network connectivity
        if (Test-Connection -ComputerName 8.8.8.8 -Count 1 -Quiet -ErrorAction SilentlyContinue) {
            $ipInfo = Get-NetIPAddress -AddressFamily IPv4 -PrefixOrigin Dhcp -ErrorAction SilentlyContinue
            if ($ipInfo) {
                Write-Host "IP Address: $($ipInfo.IPAddress)" -ForegroundColor Green
            }
        }
        
        Write-Host "==========================`n" -ForegroundColor Cyan
    }
    catch {
        Write-Error "Failed to retrieve system information: ${_}"
    }
}

#endregion System Administration

#region Text Operations

<#
.SYNOPSIS
    Find in files
.DESCRIPTION
    Searches for text in files with configurable options
.PARAMETER Pattern
    Search pattern to find in files
.PARAMETER Path
    Path to search in (default: current directory)
.PARAMETER Extension
    File extension filter (e.g., "*.ps1")
.PARAMETER Context
    Number of context lines to display
#>
function find-in-files {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Pattern,
        
        [Parameter(Position = 1)]
        [string]$Path = ".",
        
        [Parameter(Position = 2)]
        [string]$Extension = "*.*",
        
        [Parameter()]
        [int]$Context = 0
    )
    
    try {
        $files = Get-ChildItem -Path $Path -Filter $Extension -Recurse -File
        
        if ($files.Count -eq 0) {
            Write-Warning "No files found matching pattern '$Extension' in path '$Path'"
            return
        }
        
        $count = 0
        foreach ($file in $files) {
            $matches = Select-String -Path $file.FullName -Pattern $Pattern -Context $Context, $Context
            if ($matches) {
                $count += $matches.Count
                foreach ($match in $matches) {
                    Write-Host "$($file.FullName):$($match.LineNumber)" -ForegroundColor Cyan
                    
                    if ($match.Context.PreContext) {
                        $match.Context.PreContext | ForEach-Object {
                            Write-Host "  $_" -ForegroundColor DarkGray
                        }
                    }
                    
                    Write-Host "  $($match.Line)" -ForegroundColor Yellow
                    
                    if ($match.Context.PostContext) {
                        $match.Context.PostContext | ForEach-Object {
                            Write-Host "  $_" -ForegroundColor DarkGray
                        }
                    }
                    
                    Write-Host ""
                }
            }
        }
        
        Write-Host "Found $count matches in $($files.Count) files" -ForegroundColor Green
    }
    catch {
        Write-Error "Search failed: ${_}"
    }
}

# Create alias for find-in-files
Set-Alias -Name fif -Value find-in-files

<#
.SYNOPSIS
    Replace in files
.DESCRIPTION
    Find and replace text in files
.PARAMETER Find
    Text to find
.PARAMETER Replace
    Text to replace with
.PARAMETER Path
    Path to search in (default: current directory)
.PARAMETER Extension
    File extension filter (e.g., "*.ps1")
.PARAMETER Backup
    Create backup files before making changes
#>
function replace-in-files {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Find,
        
        [Parameter(Mandatory = $true, Position = 1)]
        [string]$Replace,
        
        [Parameter(Position = 2)]
        [string]$Path = ".",
        
        [Parameter(Position = 3)]
        [string]$Extension = "*.*",
        
        [Parameter()]
        [switch]$Backup
    )
    
    try {
        $files = Get-ChildItem -Path $Path -Filter $Extension -Recurse -File
        
        if ($files.Count -eq 0) {
            Write-Warning "No files found matching pattern '$Extension' in path '$Path'"
            return
        }
        
        $fileCount = 0
        $replaceCount = 0
        
        foreach ($file in $files) {
            $content = Get-Content -Path $file.FullName -Raw
            $newContent = $content -replace $Find, $Replace
            
            if ($content -ne $newContent) {
                $fileCount++
                $replaceCount += ([regex]::Matches($content, [regex]::Escape($Find))).Count
                
                if ($PSCmdlet.ShouldProcess($file.FullName, "Replace '$Find' with '$Replace'")) {
                    if ($Backup) {
                        Copy-Item -Path $file.FullName -Destination "$($file.FullName).bak" -Force
                        Write-Verbose "Created backup: $($file.FullName).bak"
                    }
                    
                    Set-Content -Path $file.FullName -Value $newContent -NoNewline
                    Write-Verbose "Updated file: $($file.FullName)"
                }
            }
        }
        
        Write-Host "Replaced $replaceCount occurrences in $fileCount files" -ForegroundColor Green
    }
    catch {
        Write-Error "Replace operation failed: ${_}"
    }
}

# Create alias for replace-in-files
Set-Alias -Name rif -Value replace-in-files

<#
.SYNOPSIS
    Format JSON content
.DESCRIPTION
    Formats JSON data from file or pipeline with indentation
.PARAMETER Path
    Path to JSON file to format
.PARAMETER Input
    JSON string to format (via pipeline)
.PARAMETER Depth
    Maximum depth (default: 20)
.PARAMETER Compress
    Compress JSON instead of formatting it
#>
function format-json {
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    param (
        [Parameter(ParameterSetName = 'Path', Position = 0)]
        [string]$Path,
        
        [Parameter(ParameterSetName = 'Input', ValueFromPipeline = $true)]
        [string]$Input,
        
        [Parameter()]
        [int]$Depth = 20,
        
        [Parameter()]
        [switch]$Compress
    )
    
    begin {
        $jsonContent = ""
    }
    
    process {
        try {
            if ($PSCmdlet.ParameterSetName -eq 'Path') {
                if (-not (Test-Path -Path $Path)) {
                    Write-Error "File not found: $Path"
                    return
                }
                $jsonContent = Get-Content -Path $Path -Raw
            }
            else {
                $jsonContent = $Input
            }
            
            # Try to convert to object and back to JSON for formatting
            $jsonObject = ConvertFrom-Json -InputObject $jsonContent -Depth $Depth -ErrorAction Stop
            
            if ($Compress) {
                $output = ConvertTo-Json -InputObject $jsonObject -Depth $Depth -Compress -ErrorAction Stop
            }
            else {
                $output = ConvertTo-Json -InputObject $jsonObject -Depth $Depth -ErrorAction Stop
            }
            
            return $output
        }
        catch {
            Write-Error "JSON formatting failed: ${_}"
        }
    }
}

# Create alias for format-json
Set-Alias -Name fmtj -Value format-json

#endregion Text Operations

#region Network Tools

<#
.SYNOPSIS
    Get public IP address
.DESCRIPTION
    Returns the current public IP address using a web service
#>
function get-public-ip {
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]$Raw
    )
    
    try {
        $ipServices = @(
            'https://api.ipify.org',
            'https://ipinfo.io/ip',
            'https://icanhazip.com'
        )
        
        foreach ($service in $ipServices) {
            try {
                $ip = Invoke-RestMethod -Uri $service -TimeoutSec 5 -ErrorAction Stop
                if ($Raw) {
                    return $ip.Trim()
                }
                else {
                    Write-Host "Public IP: $($ip.Trim())" -ForegroundColor Green
                    return $ip.Trim()
                }
            }
            catch {
                Write-Verbose "Service $service failed, trying next..."
                continue
            }
        }
        
        Write-Error "Could not retrieve public IP from any service."
    }
    catch {
        Write-Error "Failed to get public IP: ${_}"
    }
}

# Create alias for get-public-ip
Set-Alias -Name pubip -Value get-public-ip

<#
.SYNOPSIS
    Enhanced ping command
.DESCRIPTION
    Pings a host with enhanced output and options
.PARAMETER Target
    The target to ping
.PARAMETER Count
    Number of pings to send
.PARAMETER Continuous
    Ping continuously until stopped
#>
function ping-host {
    [CmdletBinding(DefaultParameterSetName = 'Count')]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Target,
        
        [Parameter(ParameterSetName = 'Count', Position = 1)]
        [int]$Count = 4,
        
        [Parameter(ParameterSetName = 'Continuous')]
        [switch]$Continuous
    )
    
    try {
        $totalTime = 0
        $successful = 0
        $failed = 0
        $minTime = [int]::MaxValue
        $maxTime = 0
        $pingCount = 0
        
        # Table header
        Write-Host "`nPinging $Target..." -ForegroundColor Cyan
        Write-Host ("Seq".PadRight(5) + "Status".PadRight(10) + "Address".PadRight(20) + "Time".PadRight(10))
        Write-Host ("-" * 45)
        
        do {
            $pingCount++
            $ping = Test-Connection -ComputerName $Target -Count 1 -ErrorAction SilentlyContinue
            
            if ($ping) {
                $time = $ping.ResponseTime
                $successful++
                $totalTime += $time
                $minTime = [Math]::Min($minTime, $time)
                $maxTime = [Math]::Max($maxTime, $time)
                
                # Green for fast, Yellow for medium, Red for slow
                $color = if ($time -lt 50) { 'Green' } elseif ($time -lt 200) { 'Yellow' } else { 'Red' }
                Write-Host ($pingCount.ToString().PadRight(5) + "Success".PadRight(10) + $ping.Address.ToString().PadRight(20) + "$time ms".PadRight(10)) -ForegroundColor $color
            }
            else {
                $failed++
                Write-Host ($pingCount.ToString().PadRight(5) + "Failed".PadRight(10) + $Target.PadRight(20) + "Timeout".PadRight(10)) -ForegroundColor Red
            }
            
            if ($Continuous -or $pingCount -lt $Count) {
                Start-Sleep -Milliseconds 1000
            }
        } while ($Continuous -or $pingCount -lt $Count)
        
        # Calculate statistics
        $avgTime = if ($successful -gt 0) { $totalTime / $successful } else { 0 }
        $packetLoss = if ($pingCount -gt 0) { ($failed / $pingCount) * 100 } else { 0 }
        
        # Display summary
        Write-Host "`nPing statistics for $Target':'" -ForegroundColor Cyan
        Write-Host "    Packets: Sent = $pingCount, Received = $successful, Lost = $failed ($([math]::Round($packetLoss, 2))% loss)"
        
        if ($successful -gt 0) {
            Write-Host "Approximate round trip times in milliseconds:"
            Write-Host "    Minimum = $minTime ms, Maximum = $maxTime ms, Average = $([math]::Round($avgTime, 2)) ms"
        }
    }
    catch {
        Write-Error "Ping failed: ${_}"
    }
}

# Create alias for ping-host
Set-Alias -Name pping -Value ping-host

<#
.SYNOPSIS
    Check if ports are open on a host
.DESCRIPTION
    Tests if specified TCP ports are open on a remote host
.PARAMETER ComputerName
    Target host to check
.PARAMETER Ports
    Array of ports to test
.PARAMETER Timeout
    Connection timeout in milliseconds
#>
function test-port {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$ComputerName,
        
        [Parameter(Mandatory = $true, Position = 1)]
        [int[]]$Ports,
        
        [Parameter()]
        [int]$Timeout = 1000
    )
    
    try {
        # Verify host is reachable first
        if (-not (Test-Connection -ComputerName $ComputerName -Count 1 -Quiet -ErrorAction SilentlyContinue)) {
            Write-Warning "Host $ComputerName appears to be offline"
        }
        
        Write-Host "`nTesting ports on $ComputerName (timeout: ${Timeout}ms)..." -ForegroundColor Cyan
        Write-Host ("Port".PadRight(10) + "Status".PadRight(10) + "Service")
        Write-Host ("-" * 45)
        
        foreach ($port in $Ports) {
            $result = $null
            $tcpClient = New-Object System.Net.Sockets.TcpClient
            
            # Get common service name for well-known ports
            $serviceName = switch ($port) {
                20 { "FTP Data" }
                21 { "FTP Control" }
                22 { "SSH" }
                23 { "Telnet" }
                25 { "SMTP" }
                53 { "DNS" }
                80 { "HTTP" }
                110 { "POP3" }
                143 { "IMAP" }
                443 { "HTTPS" }
                3389 { "RDP" }
                5985 { "WinRM HTTP" }
                5986 { "WinRM HTTPS" }
                default { "" }
            }
            
            try {
                # Async connection attempt with timeout
                $connect = $tcpClient.BeginConnect($ComputerName, $port, $null, $null)
                $wait = $connect.AsyncWaitHandle.WaitOne($Timeout, $false)
                
                if ($wait -and $tcpClient.Connected) {
                    $status = "Open"
                    $color = "Green"
                }
                else {
                    $status = "Closed"
                    $color = "Red"
                }
            }
            catch {
                $status = "Error"
                $color = "Red"
            }
            finally {
                $tcpClient.Close()
            }
            
            Write-Host ($port.ToString().PadRight(10) + $status.PadRight(10) + $serviceName) -ForegroundColor $color
        }
    }
    catch {
        Write-Error "Port test failed: ${_}"
    }
}

# Create alias for test-port
Set-Alias -Name tport -Value test-port

#endregion Network Tools

#region Process Management

<#
.SYNOPSIS
    Enhanced process monitoring and management
.DESCRIPTION
    Shows top processes by CPU or memory usage with filtering options
.PARAMETER SortBy
    Sort criterion (CPU, Memory, IO, PID)
.PARAMETER Count
    Number of processes to display
.PARAMETER Name
    Filter by process name
#>
function show-processes {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [ValidateSet('CPU', 'Memory', 'IO', 'PID')]
        [string]$SortBy = 'CPU',
        
        [Parameter(Position = 1)]
        [int]$Count = 10,
        
        [Parameter(Position = 2)]
        [string]$Name = "*"
    )
    
    try {
        # Define sort property based on parameter
        $sortProperty = switch ($SortBy) {
            'CPU' { 'CPU' }
            'Memory' { 'WS' }
            'IO' { 'Handles' }
            'PID' { 'Id' }
        }
        
        # Get process information with calculated properties
        $processes = Get-Process -Name $Name |
        Select-Object -Property Name, Id, 
        @{Name = "CPU"; Expression = { [math]::Round($_.CPU, 2) } },
        @{Name = "Memory(MB)"; Expression = { [math]::Round($_.WorkingSet / 1MB, 2) } },
        @{Name = "WS"; Expression = { $_.WorkingSet } },
        Handles, 
        @{Name = "ThreadCount"; Expression = { $_.Threads.Count } }, 
        @{Name = "IO(KB)"; Expression = { [math]::Round(($_.ReadOperationCount + $_.WriteOperationCount) / 1KB, 2) } },
        Path |
        Sort-Object -Property $sortProperty -Descending |
        Select-Object -First $Count
        
        if (-not $processes) {
            Write-Warning "No processes found matching '$Name'"
            return
        }
        
        # Display results
        Write-Host "`nTop $Count processes by $SortBy usage:" -ForegroundColor Cyan
        $processes | Format-Table -Property Name, Id, "CPU", "Memory(MB)", "ThreadCount", "IO(KB)" -AutoSize
    }
    catch {
        Write-Error "Failed to get process information: ${_}"
    }
}

# Create alias for show-processes
Set-Alias -Name top -Value show-processes

<#
.SYNOPSIS
    Kills process by name with confirmation
.DESCRIPTION
    Terminates one or more processes by name with verification
.PARAMETER Name
    Name of the process to terminate
.PARAMETER Force
    Skip confirmation
#>
function kill-process {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Name,
        
        [Parameter()]
        [switch]$Force
    )
    
    try {
        $processes = Get-Process -Name $Name -ErrorAction SilentlyContinue
        
        if (-not $processes) {
            Write-Warning "No processes found with name '$Name'"
            return
        }
        
        # Show processes that will be terminated
        Write-Host "`nProcesses matching '$Name':" -ForegroundColor Cyan
        $processes | Format-Table -Property Id, Name, Description -AutoSize
        
        if ($Force -or $PSCmdlet.ShouldProcess("$($processes.Count) process(es) with name '$Name'", "Stop")) {
            $processes | Stop-Process -Force
            Write-Host "Successfully terminated $($processes.Count) process(es)" -ForegroundColor Green
        }
    }
    catch {
        Write-Error "Failed to terminate processes: ${_}"
    }
}

# Create alias for kill-process
Set-Alias -Name kill -Value kill-process

<#
.SYNOPSIS
    Shows process tree
.DESCRIPTION
    Displays hierarchical process tree with parent-child relationships
.PARAMETER RootProcess
    Optional root process to start tree from
#>
function show-process-tree {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string]$RootProcess
    )
    
    try {
        # Get all processes with parent process info
        $allProcesses = Get-CimInstance -ClassName Win32_Process | 
        Select-Object ProcessId, ParentProcessId, Name, CommandLine

        # Create a hashtable for quick lookups
        $processTable = @{}
        foreach ($process in $allProcesses) {
            $processTable[$process.ProcessId] = $process
        }
        
        # Find root processes or filter by specified root
        if ($RootProcess) {
            $rootProcesses = $allProcesses | Where-Object { $_.Name -like "*$RootProcess*" }
            if (-not $rootProcesses) {
                Write-Warning "No processes found matching '$RootProcess'"
                return
            }
        }
        else {
            $rootProcesses = $allProcesses | Where-Object { 
                $_.ParentProcessId -eq 0 -or -not $processTable.ContainsKey($_.ParentProcessId)
            }
        }
        
        # Display tree function
        function Show-ProcessBranch {
            param (
                [Parameter(Mandatory = $true)]
                $Process,
                
                [string]$Indent = "",
                
                [System.Collections.Generic.HashSet[int]]$VisitedIds
            )
            
            # Prevent circular references
            if ($VisitedIds.Contains($Process.ProcessId)) { return }
            $null = $VisitedIds.Add($Process.ProcessId)
            
            # Display current process
            $color = if ($Process.ProcessId -eq $PID) { "Yellow" } else { "White" }
            Write-Host ("{0}{1} [{2}]" -f $Indent, $Process.Name, $Process.ProcessId) -ForegroundColor $color
            
            # Find and display children
            $childProcesses = $allProcesses | Where-Object { $_.ParentProcessId -eq $Process.ProcessId }
            foreach ($child in $childProcesses) {
                Show-ProcessBranch -Process $child -Indent "$Indent    " -VisitedIds $VisitedIds
            }
        }
        
        # Display process tree
        Write-Host "`nProcess Tree:" -ForegroundColor Cyan
        
        $visitedIds = New-Object System.Collections.Generic.HashSet[int]
        foreach ($rootProcess in $rootProcesses) {
            Show-ProcessBranch -Process $rootProcess -VisitedIds $visitedIds
        }
    }
    catch {
        Write-Error "Failed to generate process tree: ${_}"
    }
}

# Create alias for show-process-tree
Set-Alias -Name pstree -Value show-process-tree

<#
.SYNOPSIS
    Monitor process resource usage
.DESCRIPTION
    Real-time monitoring of CPU and memory usage for specified processes
.PARAMETER Name
    Process name to monitor (supports wildcards)
.PARAMETER RefreshInterval
    Refresh interval in seconds
.PARAMETER Count
    Number of refresh cycles (0 for continuous)
#>
function monitor-process {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string]$Name = "*",
        
        [Parameter()]
        [int]$RefreshInterval = 2,
        
        [Parameter()]
        [int]$Count = 0
    )
    
    try {
        $cycles = 0
        
        # Initialize previous measurements for CPU calculation
        $prevCPU = @{}
        $prevTime = Get-Date
        
        do {
            $currentTime = Get-Date
            
            # Clear screen and show header
            Clear-Host
            Write-Host "Process Monitor - Press Ctrl+C to exit`n" -ForegroundColor Cyan
            Write-Host "Process".PadRight(30) + "PID".PadRight(10) + "CPU%".PadRight(10) + "Memory(MB)".PadRight(15) + "Threads"
            Write-Host ("-" * 75)
            
            # Get current processes
            $currentProcesses = Get-Process -Name $Name -ErrorAction SilentlyContinue |
            Select-Object Name, Id, CPU, WorkingSet, Threads
                
            if (-not $currentProcesses) {
                Write-Warning "No processes found matching '$Name'"
                return
            }
            
            # Calculate and display metrics
            foreach ($process in $currentProcesses) {
                # Calculate CPU percentage (approximation)
                $cpuPercent = 0
                if ($prevCPU.ContainsKey($process.Id)) {
                    $cpuDiff = $process.CPU - $prevCPU[$process.Id]
                    $timeDiff = ($currentTime - $prevTime).TotalSeconds
                    if ($timeDiff -gt 0) {
                        $cpuPercent = [math]::Round(($cpuDiff / $timeDiff) * 100 / [Environment]::ProcessorCount, 1)
                        # Cap at 100% per core
                        $cpuPercent = [math]::Min($cpuPercent, 100 * [Environment]::ProcessorCount)
                    }
                }
                
                # Store current values for next cycle
                $prevCPU[$process.Id] = $process.CPU
                
                # Determine color based on resource usage
                $cpuColor = if ($cpuPercent -gt 80) { "Red" } elseif ($cpuPercent -gt 50) { "Yellow" } else { "Green" }
                $memoryMB = [math]::Round($process.WorkingSet / 1MB, 1)
                $memoryColor = if ($memoryMB -gt 1000) { "Red" } elseif ($memoryMB -gt 500) { "Yellow" } else { "Green" }
                
                # Display process info with color-coded metrics
                Write-Host $process.Name.PadRight(30) -NoNewline
                Write-Host $process.Id.ToString().PadRight(10) -NoNewline
                Write-Host ("{0}%" -f $cpuPercent.ToString().PadRight(8)) -ForegroundColor $cpuColor -NoNewline
                Write-Host ("{0}" -f $memoryMB.ToString().PadRight(14)) -ForegroundColor $memoryColor -NoNewline
                Write-Host $process.Threads.Count
            }
            
            # Display system-wide metrics
            $systemCPU = Get-CimInstance -ClassName Win32_Processor | Measure-Object -Property LoadPercentage -Average
            $systemMemory = Get-CimInstance -ClassName Win32_OperatingSystem
            $usedMemoryGB = [math]::Round(($systemMemory.TotalVisibleMemorySize - $systemMemory.FreePhysicalMemory) / 1MB, 1)
            $totalMemoryGB = [math]::Round($systemMemory.TotalVisibleMemorySize / 1MB, 1)
            $memoryPercentage = [math]::Round(($usedMemoryGB / $totalMemoryGB) * 100, 1)
            
            Write-Host "`nSystem:`t" -NoNewline
            Write-Host ("CPU: {0}%" -f [math]::Round($systemCPU.Average, 1)) -NoNewline
            Write-Host " | " -NoNewline
            Write-Host ("Memory: {0}GB / {1}GB ({2}%)" -f $usedMemoryGB, $totalMemoryGB, $memoryPercentage)
            
            Write-Host ("Last refresh: {0}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"))
            
            # Increment cycle count if tracking
            if ($Count -gt 0) {
                $cycles++
                if ($cycles -lt $Count) {
                    Write-Host ("`nRefreshing in {0} seconds... (Cycle {1}/{2})" -f $RefreshInterval, $cycles, $Count) -ForegroundColor DarkGray
                }
            }
            else {
                Write-Host "`nRefreshing in $RefreshInterval seconds... (Press Ctrl+C to exit)" -ForegroundColor DarkGray
            }
            
            # Store current time for next cycle
            $prevTime = $currentTime
            
            # Wait for next refresh
            if ($Count -eq 0 -or $cycles -lt $Count) {
                Start-Sleep -Seconds $RefreshInterval
            }
        } while ($Count -eq 0 -or $cycles -lt $Count)
    }
    catch {
        Write-Error "Process monitoring failed: ${_}"
    }
    finally {
        Write-Host "`nProcess monitoring stopped." -ForegroundColor Cyan
    }
}

# Create alias for monitor-process
Set-Alias -Name pmon -Value monitor-process

#endregion Process Management

#region Environment Management

<#
.SYNOPSIS
    Gets or sets environment variables
.DESCRIPTION
    View, set, or remove environment variables with scope control
.PARAMETER Name
    The name of the environment variable
.PARAMETER Value
    The value to set (omit to display current value)
.PARAMETER Scope
    The scope of the environment variable (Process, User, Machine)
.PARAMETER Remove
    Switch to remove the specified environment variable
.PARAMETER List
    Switch to list all environment variables
#>
function env-var {
    [CmdletBinding(DefaultParameterSetName = 'Get')]
    param (
        [Parameter(Position = 0, Mandatory = $true, ParameterSetName = 'Get')]
        [Parameter(Position = 0, Mandatory = $true, ParameterSetName = 'Set')]
        [Parameter(Position = 0, Mandatory = $true, ParameterSetName = 'Remove')]
        [string]$Name,
        
        [Parameter(Position = 1, Mandatory = $true, ParameterSetName = 'Set')]
        [string]$Value,
        
        [Parameter(ParameterSetName = 'Set')]
        [Parameter(ParameterSetName = 'Remove')]
        [ValidateSet('Process', 'User', 'Machine')]
        [string]$Scope = 'Process',
        
        [Parameter(ParameterSetName = 'Remove')]
        [switch]$Remove,
        
        [Parameter(ParameterSetName = 'List')]
        [switch]$List
    )
    
    try {
        # List all environment variables
        if ($List) {
            Get-ChildItem env: | Sort-Object Name | Format-Table -AutoSize
            return
        }
        
        # Handle different parameter sets
        switch ($PSCmdlet.ParameterSetName) {
            'Get' {
                if (Test-Path "env:$Name") {
                    $value = [Environment]::GetEnvironmentVariable($Name)
                    Write-Host "$Name = $value"
                    return $value
                }
                else {
                    Write-Warning "Environment variable '$Name' not found."
                    return $null
                }
            }
            
            'Set' {
                # Set environment variable in specified scope
                $scopeValue = [System.EnvironmentVariableTarget]::$Scope
                [Environment]::SetEnvironmentVariable($Name, $Value, $scopeValue)
                
                # Also set in current process for immediate effect
                if ($Scope -ne 'Process') {
                    [Environment]::SetEnvironmentVariable($Name, $Value, [System.EnvironmentVariableTarget]::Process)
                }
                
                Write-Host "Set environment variable: $Name = $Value ($Scope scope)" -ForegroundColor Green
            }
            
            'Remove' {
                # Remove environment variable from specified scope
                $scopeValue = [System.EnvironmentVariableTarget]::$Scope
                
                if (![string]::IsNullOrEmpty([Environment]::GetEnvironmentVariable($Name, $scopeValue))) {
                    [Environment]::SetEnvironmentVariable($Name, $null, $scopeValue)
                    
                    # Also remove from current process for immediate effect
                    if ($Scope -ne 'Process') {
                        [Environment]::SetEnvironmentVariable($Name, $null, [System.EnvironmentVariableTarget]::Process)
                    }
                    
                    Write-Host "Removed environment variable: $Name ($Scope scope)" -ForegroundColor Yellow
                }
                else {
                    Write-Warning "Environment variable '$Name' not found in $Scope scope."
                }
            }
        }
    }
    catch {
        Write-Error "Environment variable operation failed: ${_}"
    }
}

# Create alias for env-var
Set-Alias -Name env -Value env-var

<#
.SYNOPSIS
    Adds a directory to the PATH environment variable
.DESCRIPTION
    Adds the specified directory to the PATH environment variable with scope control
.PARAMETER Directory
    The directory to add to PATH
.PARAMETER Scope
    The scope of the environment variable (Process, User, Machine)
.PARAMETER Force
    Add the directory even if it already exists in PATH
#>
function add-to-path {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateScript({ Test-Path -Path $_ -PathType Container })]
        [string]$Directory,
        
        [Parameter()]
        [ValidateSet('Process', 'User', 'Machine')]
        [string]$Scope = 'User',
        
        [Parameter()]
        [switch]$Force
    )
    
    try {
        # Get the current PATH value from the specified scope
        $scopeValue = [System.EnvironmentVariableTarget]::$Scope
        $currentPath = [Environment]::GetEnvironmentVariable("PATH", $scopeValue)
        
        # Normalize directory path (remove trailing backslash)
        $Directory = [IO.Path]::GetFullPath($Directory).TrimEnd('\')
        
        # Check if directory already exists in PATH
        $pathItems = $currentPath -split ';' | Where-Object { $_ }
        $normalizedPathItems = $pathItems | ForEach-Object { [IO.Path]::GetFullPath($_).TrimEnd('\') }
        
        if ($normalizedPathItems -contains $Directory -and -not $Force) {
            Write-Warning "Directory already exists in PATH: $Directory"
            return
        }
        
        # Add directory to PATH
        $newPath = $currentPath
        if (-not $newPath.EndsWith(';')) {
            $newPath += ';'
        }
        $newPath += "$Directory;"
        
        # Set the new PATH value
        [Environment]::SetEnvironmentVariable("PATH", $newPath, $scopeValue)
        
        # Also update current session PATH for immediate effect
        if ($Scope -ne 'Process') {
            $currentProcessPath = [Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::Process)
            if (-not $currentProcessPath.EndsWith(';')) {
                $currentProcessPath += ';'
            }
            $currentProcessPath += "$Directory;"
            [Environment]::SetEnvironmentVariable("PATH", $currentProcessPath, [System.EnvironmentVariableTarget]::Process)
        }
        
        Write-Host "Added to PATH ($Scope scope): $Directory" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to add directory to PATH: ${_}"
    }
}

# Create alias for add-to-path
Set-Alias -Name apath -Value add-to-path

<#
.SYNOPSIS
    Removes a directory from the PATH environment variable
.DESCRIPTION
    Removes the specified directory from the PATH environment variable with scope control
.PARAMETER Directory
    The directory to remove from PATH
.PARAMETER Scope
    The scope of the environment variable (Process, User, Machine)
#>
function remove-from-path {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Directory,
        
        [Parameter()]
        [ValidateSet('Process', 'User', 'Machine')]
        [string]$Scope = 'User'
    )
    
    try {
        # Get the current PATH value from the specified scope
        $scopeValue = [System.EnvironmentVariableTarget]::$Scope
        $currentPath = [Environment]::GetEnvironmentVariable("PATH", $scopeValue)
        
        # Normalize directory path (remove trailing backslash)
        $Directory = [IO.Path]::GetFullPath($Directory).TrimEnd('\')
        
        # Split PATH into components and filter out the specified directory
        $pathItems = $currentPath -split ';' | Where-Object { $_ }
        $updatedItems = $pathItems | Where-Object { 
            $normalized = [IO.Path]::GetFullPath($_).TrimEnd('\')
            $normalized -ne $Directory 
        }
        
        # Check if directory was found in PATH
        if ($pathItems.Count -eq $updatedItems.Count) {
            Write-Warning "Directory not found in PATH: $Directory"
            return
        }
        
        # Rebuild PATH string
        $newPath = ($updatedItems -join ';') + ';'
        
        # Set the new PATH value
        [Environment]::SetEnvironmentVariable("PATH", $newPath, $scopeValue)
        
        # Also update current session PATH for immediate effect
        if ($Scope -ne 'Process') {
            $currentProcessPath = [Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::Process)
            $processPathItems = $currentProcessPath -split ';' | Where-Object { $_ }
            $updatedProcessItems = $processPathItems | Where-Object { 
                $normalized = [IO.Path]::GetFullPath($_).TrimEnd('\')
                $normalized -ne $Directory 
            }
            $newProcessPath = ($updatedProcessItems -join ';') + ';'
            [Environment]::SetEnvironmentVariable("PATH", $newProcessPath, [System.EnvironmentVariableTarget]::Process)
        }
        
        Write-Host "Removed from PATH ($Scope scope): $Directory" -ForegroundColor Yellow
    }
    catch {
        Write-Error "Failed to remove directory from PATH: ${_}"
    }
}

# Create alias for remove-from-path
Set-Alias -Name rpath -Value remove-from-path

<#
.SYNOPSIS
    Shows the current PATH environment variable
.DESCRIPTION
    Displays PATH entries in a readable format with validation
.PARAMETER Scope
    The scope of the environment variable (Process, User, Machine, All)
.PARAMETER Validate
    Validate if the PATH entries exist
#>
function show-path {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateSet('Process', 'User', 'Machine', 'All')]
        [string]$Scope = 'Process',
        
        [Parameter()]
        [switch]$Validate
    )
    
    try {
        $scopes = @()
        if ($Scope -eq 'All') {
            $scopes = @('Machine', 'User', 'Process')
        }
        else {
            $scopes = @($Scope)
        }
        
        foreach ($currentScope in $scopes) {
            $scopeValue = [System.EnvironmentVariableTarget]::$currentScope
            $pathValue = [Environment]::GetEnvironmentVariable("PATH", $scopeValue)
            
            Write-Host "`n=== $currentScope PATH ===" -ForegroundColor Cyan
            
            if ([string]::IsNullOrWhiteSpace($pathValue)) {
                Write-Host "   <empty>" -ForegroundColor Gray
                continue
            }
            
            $pathItems = $pathValue -split ';' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Sort-Object
            $index = 1
            
            foreach ($item in $pathItems) {
                $exists = Test-Path -Path $item -PathType Container
                $color = if ($Validate) { 
                    if ($exists) { 'Green' } else { 'Red' }
                }
                else { 
                    'White'
                }
                
                Write-Host ("{0,3}. " -f $index) -NoNewline
                Write-Host $item -ForegroundColor $color
                
                if ($Validate -and -not $exists) {
                    Write-Host "      [INVALID PATH]" -ForegroundColor Red
                }
                
                $index++
            }
        }
    }
    catch {
        Write-Error "Failed to show PATH: ${_}"
    }
}

# Create alias for show-path
Set-Alias -Name path -Value show-path

#endregion Environment Management

#region Profile Management

<#
.SYNOPSIS
    Edits PowerShell profile with preferred editor
.DESCRIPTION
    Opens the PowerShell profile in the configured editor
.PARAMETER Scope
    Which profile to edit (AllUsersAllHosts, AllUsersCurrentHost, CurrentUserAllHosts, CurrentUserCurrentHost)
.PARAMETER Editor
    Which editor to use (VSCode, ISE, Default, or specify a path)
.EXAMPLE
    edit-profile
    # Opens current user profile in default editor
.EXAMPLE
    edit-profile -Scope AllUsersAllHosts -Editor VSCode
    # Opens all users profile in VS Code
#>
function edit-profile {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [ValidateSet('AllUsersAllHosts', 'AllUsersCurrentHost', 'CurrentUserAllHosts', 'CurrentUserCurrentHost')]
        [string]$Scope = 'CurrentUserCurrentHost',
        
        [Parameter(Position = 1)]
        [ValidateSet('VSCode', 'ISE', 'Default', 'Vim', 'Notepad')]
        [string]$Editor = 'Default'
    )
    
    try {
        # Determine which profile to edit
        $profilePath = switch ($Scope) {
            'AllUsersAllHosts' { $PROFILE.AllUsersAllHosts }
            'AllUsersCurrentHost' { $PROFILE.AllUsersCurrentHost }
            'CurrentUserAllHosts' { $PROFILE.CurrentUserAllHosts }
            'CurrentUserCurrentHost' { $PROFILE.CurrentUserCurrentHost }
        }
        
        # Create the profile if it doesn't exist
        if (-not (Test-Path -Path $profilePath)) {
            Write-Warning "Profile doesn't exist. Creating it now."
            New-Item -Path $profilePath -ItemType File -Force | Out-Null
        }
        
        # Open the profile in the specified editor
        switch ($Editor) {
            'VSCode' {
                if (Get-Command code -ErrorAction SilentlyContinue) {
                    code $profilePath
                }
                else {
                    Write-Error "VS Code is not available in PATH. Install VS Code or add it to your PATH."
                    return
                }
            }
            'ISE' {
                powershell_ise.exe $profilePath
            }
            'Vim' {
                if (Get-Command vim -ErrorAction SilentlyContinue) {
                    vim $profilePath
                }
                else {
                    Write-Error "Vim is not available in PATH. Install Vim or add it to your PATH."
                    return
                }
            }
            'Notepad' {
                notepad.exe $profilePath
            }
            'Default' {
                # Try VSCode first, then fallback to standard editor
                if (Get-Command code -ErrorAction SilentlyContinue) {
                    code $profilePath
                }
                else {
                    # Fallback to the system's default editor for .ps1 files
                    Invoke-Item $profilePath
                }
            }
        }
        
        Write-Host "Opened $Scope profile: $profilePath" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to edit profile: ${_}"
    }
}

<#
.SYNOPSIS
    Backup PowerShell profiles
.DESCRIPTION
    Creates a backup of PowerShell profiles in a specified location
.PARAMETER BackupDirectory
    Directory to store backups (defaults to $HOME\Documents\PowerShell\Backups)
.PARAMETER IncludeScripts
    Also backup PowerShell scripts referenced in the profile
.PARAMETER Name
    Custom name for the backup (defaults to timestamp)
.EXAMPLE
    backup-profile
    # Creates timestamped backup of profiles in default location
.EXAMPLE
    backup-profile -IncludeScripts -Name "before-update"
    # Creates a named backup including referenced scripts
#>
function backup-profile {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$BackupDirectory = (Join-Path -Path $HOME -ChildPath "Documents\PowerShell\Backups"),
        
        [Parameter()]
        [switch]$IncludeScripts,
        
        [Parameter()]
        [string]$Name = "backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    )
    
    try {
        # Create backup directory if it doesn't exist
        if (-not (Test-Path -Path $BackupDirectory)) {
            New-Item -Path $BackupDirectory -ItemType Directory -Force | Out-Null
            Write-Verbose "Created backup directory: $BackupDirectory"
        }
        
        # Create a subdirectory for this backup
        $backupPath = Join-Path -Path $BackupDirectory -ChildPath $Name
        New-Item -Path $backupPath -ItemType Directory -Force | Out-Null
        
        # Create a profiles subdirectory
        $profilesPath = Join-Path -Path $backupPath -ChildPath "Profiles"
        New-Item -Path $profilesPath -ItemType Directory -Force | Out-Null
        
        # Backup all profile types
        $count = 0
        foreach ($profileType in @('AllUsersAllHosts', 'AllUsersCurrentHost', 'CurrentUserAllHosts', 'CurrentUserCurrentHost')) {
            $sourcePath = $PROFILE.$profileType
            if (Test-Path -Path $sourcePath) {
                $profileName = Split-Path -Path $sourcePath -Leaf
                $destPath = Join-Path -Path $profilesPath -ChildPath $profileName
                Copy-Item -Path $sourcePath -Destination $destPath -Force
                Write-Verbose "Backed up $profileType profile: $sourcePath"
                $count++
            }
        }
        
        # Backup referenced scripts if requested
        if ($IncludeScripts) {
            $scriptsPath = Join-Path -Path $backupPath -ChildPath "Scripts"
            New-Item -Path $scriptsPath -ItemType Directory -Force | Out-Null
            
            # Determine scripts directory (assumed to be in the same folder as profile)
            $profileDir = Split-Path -Path $PROFILE.CurrentUserCurrentHost -Parent
            if (Test-Path -Path $profileDir) {
                $scriptFiles = Get-ChildItem -Path $profileDir -Filter "*.ps1" -Exclude "Microsoft.PowerShell_profile.ps1"
                
                foreach ($script in $scriptFiles) {
                    $destPath = Join-Path -Path $scriptsPath -ChildPath $script.Name
                    Copy-Item -Path $script.FullName -Destination $destPath -Force
                    Write-Verbose "Backed up script: $($script.Name)"
                    $count++
                }
            }
        }
        
        # Create a metadata file with information about the backup
        $metadataPath = Join-Path -Path $backupPath -ChildPath "metadata.json"
        $metadata = @{
            CreatedAt         = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Name              = $Name
            IncludedScripts   = $IncludeScripts
            ProfilesPath      = $profileDir
            PowerShellVersion = $PSVersionTable.PSVersion.ToString()
            FileCount         = $count
        }
        
        $metadata | ConvertTo-Json | Set-Content -Path $metadataPath
        
        Write-Host "Profile backup created at $backupPath ($count files)" -ForegroundColor Green
        return $backupPath
    }
    catch {
        Write-Error "Failed to backup profile: ${_}"
        return $null
    }
}

<#
.SYNOPSIS
    Restore PowerShell profiles from backup
.DESCRIPTION
    Restores PowerShell profiles from a specified backup
.PARAMETER BackupPath
    Path to the backup to restore
.PARAMETER Force
    Overwrite existing files without confirmation
.EXAMPLE
    restore-profile -BackupPath "C:\Users\user\Documents\PowerShell\Backups\before-update"
    # Restores profiles from the specified backup
#>
function restore-profile {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$BackupPath,
        
        [Parameter()]
        [switch]$Force
    )
    
    try {
        # Verify backup path exists
        if (-not (Test-Path -Path $BackupPath)) {
            Write-Error "Backup path not found: $BackupPath"
            return
        }
        
        # Check for profiles directory in the backup
        $profilesPath = Join-Path -Path $BackupPath -ChildPath "Profiles"
        if (-not (Test-Path -Path $profilesPath)) {
            Write-Error "Invalid backup: Profiles directory not found in $BackupPath"
            return
        }
        
        # Get profile files from backup
        $profileFiles = Get-ChildItem -Path $profilesPath -Filter "*.ps1"
        if ($profileFiles.Count -eq 0) {
            Write-Warning "No profile files found in the backup."
            return
        }
        
        # Restore profile files
        $count = 0
        foreach ($file in $profileFiles) {
            $destPath = Join-Path -Path (Split-Path -Path $PROFILE.CurrentUserCurrentHost -Parent) -ChildPath $file.Name
            
            if ((Test-Path -Path $destPath) -and -not $Force) {
                if (-not $PSCmdlet.ShouldProcess($destPath, "Overwrite with backup: $($file.FullName)")) {
                    Write-Verbose "Skipped $($file.Name)"
                    continue
                }
            }
            
            Copy-Item -Path $file.FullName -Destination $destPath -Force
            Write-Verbose "Restored $($file.Name) to $destPath"
            $count++
        }
        
        # Check for scripts directory in the backup
        $scriptsPath = Join-Path -Path $BackupPath -ChildPath "Scripts"
        if (Test-Path -Path $scriptsPath) {
            $scriptFiles = Get-ChildItem -Path $scriptsPath -Filter "*.ps1"
            
            # Restore script files
            foreach ($file in $scriptFiles) {
                $destPath = Join-Path -Path (Split-Path -Path $PROFILE.CurrentUserCurrentHost -Parent) -ChildPath $file.Name
                
                if ((Test-Path -Path $destPath) -and -not $Force) {
                    if (-not $PSCmdlet.ShouldProcess($destPath, "Overwrite with backup: $($file.FullName)")) {
                        Write-Verbose "Skipped $($file.Name)"
                        continue
                    }
                }
                
                Copy-Item -Path $file.FullName -Destination $destPath -Force
                Write-Verbose "Restored $($file.Name) to $destPath"
                $count++
            }
        }
        
        Write-Host "Profile restore completed. Restored $count files from $BackupPath" -ForegroundColor Green
        Write-Host "Restart your PowerShell session or run reload-profile to apply changes." -ForegroundColor Yellow
    }
    catch {
        Write-Error "Failed to restore profile: ${_}"
    }
}

<#
.SYNOPSIS
    Reloads PowerShell profile
.DESCRIPTION
    Reloads the PowerShell profile with proper cleanup of existing sessions
.PARAMETER Force
    Force reload even if there are potential issues
.PARAMETER BackupFirst
    Create a backup before reloading
.EXAMPLE
    reload-profile
    # Reloads the current PowerShell profile
.EXAMPLE
    reload-profile -BackupFirst
    # Creates a backup and then reloads the profile
#>
function reload-profile {
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]$Force,
        
        [Parameter()]
        [switch]$BackupFirst
    )
    
    try {
        # Backup profile if requested
        if ($BackupFirst) {
            Write-Host "Creating profile backup before reload..." -ForegroundColor Cyan
            backup-profile -Name "before-reload-$(Get-Date -Format 'yyyyMMddHHmmss')"
        }
        
        # List of resources to clean up before reloading
        $modulesToRemove = @()
        $functionsToRemove = @()
        $aliasesToRemove = @()
        $variablesToRemove = @()
        
        # Don't attempt cleanup if Force is specified
        if (-not $Force) {
            Write-Host "Preparing to reload profile..." -ForegroundColor Cyan
            
            # Check if profile exists
            if (-not (Test-Path -Path $PROFILE.CurrentUserCurrentHost)) {
                Write-Warning "Profile doesn't exist at: $($PROFILE.CurrentUserCurrentHost)"
                if (-not $Force) { 
                    $response = Read-Host "Do you want to create it? (Y/N)"
                    if ($response -ne 'Y' -and $response -ne 'y') {
                        Write-Warning "Profile reload canceled."
                        return
                    }
                    New-Item -Path $PROFILE.CurrentUserCurrentHost -ItemType File -Force | Out-Null
                }
            }
            
            # Clean up resources that will be redefined by the profile
            # This helps prevent duplicate aliases, functions, etc.
            
            # Clean up common aliases 
            $aliasesToRemove = @('ll', 'la', 'touch', 'gs', 'ga', 'gc', 'gp', 'fif', 'rif', 'fmtj', 'pubip')
            foreach ($alias in $aliasesToRemove) {
                if (Test-Path "Alias:$alias") {
                    Write-Verbose "Removing alias: $alias"
                    Remove-Item -Path "Alias:$alias" -Force -ErrorAction SilentlyContinue
                }
            }
            
            # Clear module import caches
            [System.Collections.Generic.HashSet[string]]$script:CommandCache = @{}
        }
        
        # Record session state before reload
        $beforeModules = Get-Module | Select-Object -ExpandProperty Name
        $beforeFunctions = Get-ChildItem function: | Select-Object -ExpandProperty Name
        $beforeAliases = Get-Alias | Select-Object -ExpandProperty Name
        
        # Dot-source the profile
        Write-Host "Reloading profile from: $($PROFILE.CurrentUserCurrentHost)" -ForegroundColor Cyan
        . $PROFILE.CurrentUserCurrentHost
        
        # Report on changes
        $afterModules = Get-Module | Select-Object -ExpandProperty Name
        $afterFunctions = Get-ChildItem function: | Select-Object -ExpandProperty Name
        $afterAliases = Get-Alias | Select-Object -ExpandProperty Name
        
        $newModules = $afterModules | Where-Object { $beforeModules -notcontains $_ }
        $newFunctions = $afterFunctions | Where-Object { $beforeModules -notcontains $_ }
        $newAliases = $afterAliases | Where-Object { $beforeAliases -notcontains $_ }

        # Report on session state changes after reload
        Write-Host "`nProfile reload completed!" -ForegroundColor Green
        
        if ($newModules.Count -gt 0) {
            Write-Host "`nModules loaded:" -ForegroundColor Cyan
            foreach ($module in $newModules) {
                Write-Host "  - $module" -ForegroundColor White
            }
        }
        
        if ($newFunctions.Count -gt 0) {
            Write-Host "`nNew functions available:" -ForegroundColor Cyan
            foreach ($function in $newFunctions | Sort-Object) {
                Write-Host "  - $function" -ForegroundColor White
            }
        }
        
        if ($newAliases.Count -gt 0) {
            Write-Host "`nNew aliases available:" -ForegroundColor Cyan
            foreach ($alias in $newAliases | Sort-Object) {
                $aliasObj = Get-Alias -Name $alias -ErrorAction SilentlyContinue
                if ($aliasObj) {
                    Write-Host "  - $($alias) -> $($aliasObj.Definition)" -ForegroundColor White
                }
            }
        }
        
        Write-Host "`nSession refreshed successfully. Profile is ready to use." -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to reload profile: ${_}"
    }
}

# Create aliases for profile management functions
Set-Alias -Name ep -Value edit-profile
Set-Alias -Name bp -Value backup-profile
#Set-Alias -Name rp -Value restore-profile
Set-Alias -Name reload -Value reload-profile

#endregion Profile Management

##region Module Exports
#
## Export all functions to make them available upon import
#Export-ModuleMember -Function @(
#    # File and Directory Management
#    'touch', 'nf', 'mkcd', 'docs', 'dtop', 'la', 'll',
#    
#    # Git Functions
#    'Invoke-GitCommand', 'gs', 'ga', 'gc', 'gp', 'g', 'gcl', 'gcom', 'lazyg',
#    
#    # Clipboard Functions
#    'cpy', 'pst',
#    
#    # System Administration
#    'admin', 'restart-powershell', 'update-system', 'sysinfo',
#    
#    # Text Operations
#    'find-in-files', 'replace-in-files', 'format-json',
#    
#    # Network Tools
#    'get-public-ip', 'ping-host', 'test-port',
#    
#    # Process Management
#    'show-processes', 'kill-process', 'show-process-tree', 'monitor-process',
#    
#    # Environment Management
#    'env-var', 'add-to-path', 'remove-from-path', 'show-path',
#    
#    # Profile Management
#    'edit-profile', 'backup-profile', 'restore-profile', 'reload-profile'
#)
#
## Export all aliases
#Export-ModuleMember -Alias @(
#    # File and Directory Management
#    'll', 'la',
#    
#    # Git Functions
#    'gs', 'ga', 'gc', 'gp', 'g', 'gcl',
#    
#    # System Administration
#    'ups',
#    
#    # Text Operations
#    'fif', 'rif', 'fmtj',
#    
#    # Network Tools
#    'pubip', 'pping', 'tport',
#    
#    # Process Management
#    'top', 'kill', 'pstree', 'pmon',
#    
#    # Environment Management
#    'env', 'apath', 'rpath', 'path',
#    
#    # Profile Management
#    'ep', 'bp', 'reload'
#)
#
## Module cleanup function to support proper unloading
#$ExecutionContext.SessionState.Module.OnRemove = {
#    # Clean up aliases when the module is removed
#    $aliasesToRemove = @(
#        'll', 'la', 'gs', 'ga', 'gc', 'gp', 'g', 'gcl', 'ups', 'fif', 'rif', 'fmtj',
#        'pubip', 'pping', 'tport', 'top', 'kill', 'pstree', 'pmon', 'env', 'apath',
#        'rpath', 'path', 'ep', 'bp', 'rp', 'reload'
#    )
#    
#    foreach ($alias in $aliasesToRemove) {
#        if (Test-Path "Alias:$alias") {
#            Remove-Item -Path "Alias:$alias" -Force -ErrorAction SilentlyContinue
#        }
#    }
#    
#    # Clean up command cache and any other module-specific variables
#    Remove-Variable -Name CommandCache -Scope Script -Force -ErrorAction SilentlyContinue
#    
#    Write-Verbose "Aliases module unloaded successfully."
#}
#
## Module initialization confirmation
#Write-Verbose "Aliases module version $script:ModuleVersion loaded successfully."
#
##endregion Module Exports
