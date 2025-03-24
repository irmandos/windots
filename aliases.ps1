# Custom Aliases and Functions

# File and Directory Management
function touch($file) { "" | Out-File $file -Encoding ASCII }
function nf { param($name) New-Item -ItemType "file" -Path . -Name $name } # Quick File Creation
function mkcd { param($dir) mkdir $dir -Force; Set-Location $dir } # Directory Management
function docs { Set-Location -Path $HOME\Documents } # Navigation Shortcuts
function dtop { Set-Location -Path $HOME\Desktop } # Navigation Shortcuts
function la { Get-ChildItem -Path . -Force | Format-Table -AutoSize } # Enhanced Listing
function ll { Get-ChildItem -Path . -Force -Hidden | Format-Table -AutoSize } # Enhanced Listing

# Git Shortcuts
function gs { git status }
function ga { git add . }
function gc { param($m) git commit -m "$m" }
function gp { git push }
function g { z Github }
function gcl { git clone "$args" }
function gcom {
    git add .
    git commit -m "$args"
}
function lazyg {
    git add .
    git commit -m "$args"
    git push
}

# Clipboard Functions
function cpy { Set-Clipboard $args[0] }
function pst { Get-Clipboard }

# System Administration
function admin {
    if ($args.Count -gt 0) {
        $argList = "& '$args'"
        Start-Process wt -Verb runAs -ArgumentList "pwsh.exe -NoExit -Command $argList"
    } else {
        Start-Process wt -Verb runAs
    }
}
Set-Alias -Name su -Value admin

function uptime {
    if ($PSVersionTable.PSVersion.Major -eq 5) {
        Get-WmiObject win32_operatingsystem | Select-Object @{Name='LastBootUpTime'; Expression={$_.ConverttoDateTime($_.lastbootuptime)}} | Format-Table -HideTableHeaders
    } else {
        net statistics workstation | Select-String "since" | ForEach-Object { $_.ToString().Replace('Statistics since ', '') }
    }
}

# File Operations
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

# Process Management
function pkill($name) {
    Get-Process $name -ErrorAction SilentlyContinue | Stop-Process
}

function pgrep($name) {
    Get-Process $name
}

# Text File Operations
function head {
    param($Path, $n = 10)
    Get-Content $Path -Head $n
}

function tail {
    param($Path, $n = 10, [switch]$f = $false)
    Get-Content $Path -Tail $n -Wait:$f
}

# DNS Management
function flushdns {
    Clear-DnsClientCache
    Write-Host "DNS has been flushed"
}

# Environment Variables
function export($name, $value) {
    set-item -force -path "env:$name" -value $value;
}

# Profile Management
function Edit-Profile {
    notepad $PROFILE
}

function reload-profile {
    & $PROFILE
}

# Network Tools
function Get-PubIP { (Invoke-WebRequest http://ifconfig.me/ip).Content }

# System Information
function Get-SystemInfo {
    if (-not (Get-Command -Name fastfetch -ErrorAction SilentlyContinue)) {
        Get-ComputerInfo
    }
    fastfetch -c all
}

# Windows Utility
function winutil {
    Invoke-WebRequest -useb https://christitus.com/win | Invoke-Expression
}

# Export functions for use in other scripts
Export-ModuleMember -Function * -Alias *

