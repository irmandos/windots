# ⚡ Windots — Portable PowerShell Environment

<div align="center">

[![PowerShell](https://img.shields.io/badge/PowerShell-%235391FE.svg?style=for-the-badge&logo=powershell&logoColor=white)](https://github.com/PowerShell/PowerShell)
[![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)](https://www.microsoft.com/windows)
[![Oh My Posh](https://img.shields.io/badge/Oh%20My%20Posh-182835?style=for-the-badge&logo=ohmyposh&logoColor=white)](https://ohmyposh.dev)
[![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/irmandos/windots)

*One PowerShell profile, every machine. Synchronised through [GitHub](https://github.com/irmandos/windots) · synced via OneDrive.*

`46 built-in commands` · `22 aliases` · `self-documenting help`

</div>

---

## 🚀 About

**Windots** is a portable, feature-rich [PowerShell](https://github.com/PowerShell/PowerShell) 7 profile designed to *look and work identically on every machine* you use. It lives in `OneDrive\Documents\PowerShell` (the current-user profile path when OneDrive Known Folder Move is active), so on a new install you simply:

1. Sign into **OneDrive** and let Documents sync.
2. Open PowerShell — the profile auto-loads and **auto-installs** any missing modules, fonts and tools in the background.
3. Run `psync` whenever you want to push your profile changes back.

It's session-aware: a full rich prompt in interactive terminals, a *lightly-loaded* path in IDEs, and a *minimal* toolkit for scripts/jobs.

---

## 🧭 Quick Start

### Option A — Your machines via OneDrive (recommended)
- Already lives at `OneDrive\Documents\PowerShell`. Just open PowerShell after OneDrive syncs; everything loads automatically.

### Option B — New machine / fresh clone (portable)
```powershell
git clone https://github.com/irmandos/windots.git "$HOME\Documents\PowerShell"
& "$HOME\Documents\PowerShell\setup.ps1"   # run as Administrator
```
`setup.ps1` installs the winget apps (Git, VS Code, Oh My Posh, fastfetch, …), the Nerd font, modules, and the secrets file template.

> 🔒 On first run, copy `.example` → `Microsoft.PowerShell_secrets.ps1` (your keys never leave this machine and are git-ignored).

---

## ⚙️ Structure

| File | Role |
| :--- | :--- |
| `Microsoft.PowerShell_profile.ps1` | **Entry point** — session detection + loads everything |
| `aliases.ps1` | **46 commands** — the heart of the profile |
| `module-manager.ps1` | Auto-installs/updates modules, Oh My Posh & fonts |
| `profile-manager.ps1` | Pull profile updates from GitHub |
| `setup.ps1` | One-command provisioner for new machines |
| `help-content.ps1` | **Self-generating** command reference (`help`, `whatis`) |
| `oh-my-posh-theme.json` | The prompt theme |
| `Microsoft.PowerShell_secrets.ps1` | Local secrets (git-ignored) |

---

## 📦 Command Reference

> **Synced from the source.** This table is generated from each function's `.SYNOPSIS` comment in `aliases.ps1` — it can never drift out of date. Auto-refreshed on every `push-profile` / `ppush`.

<!-- CMDINDEX:START -->
| Command | Aliases | Description |
|---------|---------|-------------|
| `touch` | `—` | Creates an empty file (similar to Linux touch) |
| `nf` | `—` | Creates a new file in the current directory |
| `mkcd` | `—` | Creates a directory and changes to it |
| `docs` | `—` | Quick navigation shortcuts |
| `dtop` | `—` | Navigate to the Desktop folder. |
| `la` | `—` | Enhanced directory listing with different options |
| `ll` | `—` | List all files including hidden ones in the current or specified directory. |
| `pgemini` | `—` | Smart Gemini CLI wrapper with automatic workspace management |
| `Invoke-GitCommand` | `—` | Smart Git command execution with fallback |
| `gs` | `—` | Git status shortcut |
| `ga` | `—` | Git add shortcut |
| `gc` | `—` | Git commit shortcut |
| `gp` | `—` | Git push shortcut |
| `g` | `—` | Navigate to Github folder |
| `gcl` | `—` | Git clone shortcut |
| `gcom` | `—` | Git commit shortcut - adds and commits in one step |
| `lazyg` | `—` | Git add, commit, and push in one command |
| `cpy` | `—` | Copy text to clipboard |
| `pst` | `—` | Paste text from clipboard |
| `admin` | `—` | Elevate to admin privileges |
| `restart-powershell` | `—` | Restarts the current PowerShell session |
| `update-system` | `ups` | Updates system components |
| `sysinfo` | `—` | Get system information |
| `find-in-files` | `fif` | Find in files |
| `replace-in-files` | `rif` | Replace in files |
| `format-json` | `fmtj` | Format JSON content |
| `get-public-ip` | `pubip` | Get public IP address |
| `ping-host` | `pping` | Enhanced ping command |
| `test-port` | `tport` | Check if ports are open on a host |
| `show-processes` | `top` | Enhanced process monitoring and management |
| `kill-process` | `kill` | Kills process by name with confirmation |
| `show-process-tree` | `pstree` | Shows process tree |
| `Show-ProcessBranch` | `—` | Internal helper: recursively renders one branch of the process tree. |
| `monitor-process` | `pmon` | Monitor process resource usage |
| `env-var` | `env` | Gets or sets environment variables |
| `add-to-path` | `apath` | Adds a directory to the PATH environment variable |
| `remove-from-path` | `rpath` | Removes a directory from the PATH environment variable |
| `show-path` | `path` | Shows the current PATH environment variable |
| `edit-profile` | `ep` | Edits PowerShell profile with preferred editor |
| `backup-profile` | `bp` | Backup PowerShell profiles |
| `restore-profile` | `—` | Restore PowerShell profiles from backup |
| `reload-profile` | `reload` | Reloads PowerShell profile |
| `push-profile` | `ppush, pw` | Synchronise the windots profile repo with GitHub: backup, pull, stage, commit (signed), push. |
| `pull-profile` | `ppull` | Pull the windots profile repo from GitHub so local matches cloud. |
| `sync-profile` | `psync` | Sync the windots profile repo: pull then push (backup + signed commit + push). |
| `Show-ProfileSyncReminder` | `—` | Show a one-line banner below system info if the windots repo has uncommitted or unpushed changes. |
<!-- CMDINDEX:END -->

---

## 🖥️ On-demand help

PowerShell ships with native comment-based help, and Windots adds two friendly helpers:

```powershell
help              # full living index of every command + alias
whatis <name>     # one-liner for a single command/alias, e.g. whatis ups
Get-Help <name>   # full PowerShell help (synopsis, params, examples)
```

Every function has a `.SYNOPSIS` (and where relevant `.DESCRIPTION`, `.PARAMETER`, `.EXAMPLE`) so **the help you read is always the actual behaviour**, never a stale list.

---

## 🤝 Contribute

Fork, improve the aliases, add a new command with a proper `.SYNOPSIS`, and open a PR. The command reference regenerates itself.

---

<div align="center">
  <sub>Maintained by <a href="https://github.com/irmandos">irmandos</a> · Windots — your PowerShell, everywhere.</sub>
</div>
