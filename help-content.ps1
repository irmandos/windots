<#
.SYNOPSIS
    Self-generating help for the Windots PowerShell profile.
.DESCRIPTION
    This help system is GENERATED, not hand-written. It parses aliases.ps1 using
    the PowerShell AST (for functions + their .SYNOPSIS) and a regex for the
    Set-Alias lines, then renders a live command index. It can never drift out of
    sync with the profile and has no hand-maintained command list.
    Run  help  for the full index, or  whatis <name>  for one command.
.NOTES
    Author: irman
#>

$script:HelpAliasesPath = Join-Path $PSScriptRoot 'aliases.ps1'

<#
.SYNOPSIS
    Parse aliases.ps1 and return all functions + aliases with their synopses.
.DESCRIPTION
    Uses the PowerShell AST parser for function extraction and a regex for aliases.
    Returns a PSCustomObject with:
      .Functions : array of {Name, Synopsis, Line, Aliases[]}
      .Aliases   : ordered map of alias name -> target function
#>
function Get-ProfileCommandIndex {
    [CmdletBinding()]
    param()

    if (-not (Test-Path $script:HelpAliasesPath)) {
        Write-Warning "aliases.ps1 not found at $script:HelpAliasesPath"
        return $null
    }

    $source = Get-Content -Path $script:HelpAliasesPath -Raw
    $tokens = $null; $errs = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:HelpAliasesPath, [ref]$tokens, [ref]$errs)

    # --- functions + their preceding .SYNOPSIS (AST) ---
    $rawFuncs = [System.Collections.Generic.List[object]]::new()
    foreach ($f in $ast.FindAll({ param($x) $x -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true)) {
        $synopsis = '[no synopsis]'
        $startLine = $f.Extent.StartLineNumber
        foreach ($t in $tokens) {
            if ($t.Kind -eq 'Comment' -and $t.Extent.EndLineNumber -eq ($startLine - 1)) {
                if ($t.Extent.Text -match '\.SYNOPSIS\s+([^\r\n]*)') { $synopsis = $matches[1].Trim() }
                break
            }
        }
        $rawFuncs.Add([PSCustomObject]@{ Name = $f.Name.ToString(); Synopsis = $synopsis; Line = $startLine })
    }
    # Sort by file order (line numbers are unique) -- NOTE: do NOT pipe through
    # Select-Object -Unique here; on PSCustomObject it collapses to a single item.
    $funcs = $rawFuncs | Sort-Object Line

    # --- aliases via regex (uniform Set-Alias -Name X -Value Y lines) ---
    # Anchor at line start so commented-out aliases (e.g. '#Set-Alias rp ...') are ignored.
    $aliasMap = [ordered]@{}
    foreach ($m in [regex]::Matches($source, '(?m)^\s*Set-Alias\s+-Name\s+([\w-]+)\s+-Value\s+([\w-]+)')) {
        $nm = $m.Groups[1].Value
        $vl = $m.Groups[2].Value
        if (-not $aliasMap.Contains($nm)) { $aliasMap[$nm] = $vl }
    }

    # --- attach aliases to each function ---
    $aliasesByTarget = @{}
    foreach ($nm in $aliasMap.Keys) {
        $tgt = $aliasMap[$nm]
        if (-not $aliasesByTarget.ContainsKey($tgt)) { $aliasesByTarget[$tgt] = [System.Collections.Generic.List[string]]::new() }
        $aliasesByTarget[$tgt].Add($nm)
    }
    foreach ($f in $funcs) {
        $fA = if ($aliasesByTarget.ContainsKey($f.Name)) { ($aliasesByTarget[$f.Name] | Sort-Object) -join ', ' } else { '' }
        $f | Add-Member -NotePropertyName Aliases -NotePropertyValue $fA -Force
    }

    return [PSCustomObject]@{ Functions = $funcs; Aliases = $aliasMap }
}

<#
.SYNOPSIS
    Show the full live command index (all functions + aliases + synopsis).
.DESCRIPTION
    Renders the complete index derived from aliases.ps1. No hand-written list.
.EXAMPLE
    help
#>
function Show-ProfileHelp {
    [CmdletBinding()]
    param()

    $idx = Get-ProfileCommandIndex
    if (-not $idx) { return }

    Write-Host ''
    Write-Host '  ╔══════════════════════════════════════════════════════════╗' -ForegroundColor Cyan
    Write-Host '  ║      Windots · PowerShell Profile · Command Reference    ║' -ForegroundColor Cyan
    Write-Host '  ╚══════════════════════════════════════════════════════════╝' -ForegroundColor Cyan
    Write-Host ('  {0} functions · {1} aliases · generated live from aliases.ps1' -f $idx.Functions.Count, $idx.Aliases.Count) -ForegroundColor DarkGray
    Write-Host ''

    foreach ($f in $idx.Functions) {
        $aliasNote = if ($f.Aliases) { '  ·  aliases: ' + $f.Aliases } else { '' }
        Write-Host ('  {0}' -f $f.Name) -ForegroundColor Green
        Write-Host ('      {0}' -f $f.Synopsis) -ForegroundColor White
        if ($aliasNote) {
            Write-Host ('      {0}' -f $aliasNote.Trim()) -ForegroundColor DarkGray
        }
    }

    Write-Host ''
    Write-Host '  Tip: whatis <name> shows one command; Get-Help <name> shows full help.' -ForegroundColor Yellow
    Write-Host ''
}

<#
.SYNOPSIS
    Show a one-liner for a single function or alias.
.DESCRIPTION
    Resolves a name (function or alias) and prints its synopsis + aliases, so you
    can quickly recall what a command does.
.EXAMPLE
    whatis push-profile
    whatis ups
#>
function whatis {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Name
    )

    $idx = Get-ProfileCommandIndex
    if (-not $idx) { return }

    $target = $Name
    if ($idx.Aliases.Contains($Name)) { $target = $idx.Aliases[$Name] }

    $f = $idx.Functions | Where-Object { $_.Name -eq $target } | Select-Object -First 1
    if (-not $f) {
        Write-Warning "'$Name' is not a known Windots function or alias."
        return
    }

    Write-Host ''
    Write-Host ('  {0}' -f $f.Name) -ForegroundColor Green -NoNewline
    if ($f.Aliases) { Write-Host ('  ·  aliases: {0}' -f $f.Aliases) -ForegroundColor DarkGray }
    Write-Host ''
    Write-Host ('    {0}' -f $f.Synopsis) -ForegroundColor White
    Write-Host ('    defined at aliases.ps1 line {0}' -f $f.Line) -ForegroundColor DarkGray
    Write-Host ''
}

# Convenience aliases for the help system
Set-Alias -Name help -Value Show-ProfileHelp
Set-Alias -Name he -Value Show-ProfileHelp
Set-Alias -Name ws -Value whatis

<#
.SYNOPSIS
    Regenerate the README command-reference table from the live profile index.
.DESCRIPTION
    Replaces everything between the CMDINDEX:START/END markers in README.md with a
    freshly generated table (commands + aliases + synopsis) derived from aliases.ps1.
    Called automatically by push-profile before committing, so 'ppush' always ships
    an up-to-date command reference. Can also be run manually:  update-profile-docs
.EXAMPLE
    update-profile-docs
#>
function Update-ProfileReadme {
    [CmdletBinding()]
    param()

    $readmePath = Join-Path $PSScriptRoot 'README.md'
    if (-not (Test-Path $readmePath)) {
        Write-Warning "README.md not found at $readmePath"
        return $false
    }

    $idx = Get-ProfileCommandIndex
    if (-not $idx) {
        Write-Warning "Could not generate command index -- README not updated."
        return $false
    }

    # Build the markdown table rows
    $rows = @()
    foreach ($f in $idx.Functions) {
        $name = $f.Name.Replace('|', '\|')
        $als  = if ($f.Aliases) { $f.Aliases } else { '—' }
        $syn  = if ($f.Synopsis -eq '[no synopsis]') { '*internal helper*' } else { $f.Synopsis.Replace('|', '\|') }
        $rows += "| ``$name`` | ``$als`` | $syn |"
    }
    $table = "| Command | Aliases | Description |`n|---------|---------|-------------|`n" + ($rows -join "`n")

    $content = Get-Content -Path $readmePath -Raw
    $pattern = '(?s)<!-- CMDINDEX:START -->.*?<!-- CMDINDEX:END -->'
    if ($content -match $pattern) {
        $newContent = [regex]::Replace($content, $pattern, "<!-- CMDINDEX:START -->`n$table`n<!-- CMDINDEX:END -->")
        Set-Content -Path $readmePath -Value $newContent -Encoding UTF8NoBOM -NoNewline
        Write-Host "README command reference updated ($(@($idx.Functions).Count) commands)." -ForegroundColor Green
        return $true
    }
    else {
        Write-Warning "CMDINDEX markers not found in README.md -- nothing replaced."
        return $false
    }
}

# Alias for the docs generator
Set-Alias -Name update-profile-docs -Value Update-ProfileReadme
