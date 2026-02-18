# Windots - Portable PowerShell Environment

<div align="center">

![PowerShell](https://img.shields.io/badge/PowerShell-%235391FE.svg?style=for-the-badge&logo=powershell&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)
![Oh My Posh](https://img.shields.io/badge/Oh_My_Posh-white?style=for-the-badge&logo=ohmyposh&logoColor=black)

*A robust, portable, and aesthetically pleasing PowerShell profile configuration designed for seamless synchronization across devices.*

</div>

---

## 🚀 Features

-   **Portable Design**: Works out-of-the-box on any machine, with or without OneDrive.
-   **Smart Session Detection**: Optimized loading for VSCode, Standard Terminal, and Remote Sessions.
-   **Automated Setup**: Single-script provisioning for new environments.
-   **Secure**: Secrets are isolated and git-ignored by default.
-   **Beautiful**: Pre-configured **Oh My Posh** themes and **Terminal-Icons**.
-   **Tooling**: Includes `git` aliases, module management, and auto-updates.

## 📦 Installation

### Option 1: New Machine (Standalone)
For a fresh environment (VM, Laptop) where you want this specific setup:

1.  **Clone the repository**:
    ```powershell
    git clone https://github.com/irmandos/windots.git "$HOME\Documents\PowerShell"
    ```

2.  **Run the Setup Script**:
    ```powershell
    & "$HOME\Documents\PowerShell\setup.ps1"
    ```
    *This will install necessary apps (VSCode, Git, etc.), Nerd Fonts, and configure your profile.*

### Option 2: Existing Environment
If you already have your own dotfiles but want to use this profile:

1.  Clone to your profile directory.
2.  Rename `Microsoft.PowerShell_secrets.ps1.example` to `Microsoft.PowerShell_secrets.ps1`.
3.  Add your API keys (Plex, OpenAI, etc.) to the secrets file.

## 📂 Structure

| File | Description |
| :--- | :--- |
| `Microsoft.PowerShell_profile.ps1` | **Main Profile**. Entry point that loads all other components. |
| `setup.ps1` | **Provisioner**. Installs apps, fonts, and links the profile. |
| `module-manager.ps1` | Handles module auto-installation and updates. |
| `aliases.ps1` | Custom functions and aliases (Git, System, Navigation). |
| `oh-my-posh-theme.json` | Visual theme configuration. |

## 🔐 Security

This repository is configured to **ignore** sensitive data.
-   **Secrets File**: `Microsoft.PowerShell_secrets.ps1` is ignored. Use the `.example` file as a template.
-   **Custom Scripts**: The `z.CustomScripts/` folder (personal automation) is ignored.
-   **Backups**: Local `backup/` folders are ignored.

## 🎨 Customization

-   **Theme**: Modify `oh-my-posh-theme.json` to change the prompt look.
-   **VSCode**: A specialized `oh-my-posh-vscode.json` (if present) or optimized settings are loaded for VSCode terminals.
-   **Modules**: Add modules to `$script:RequiredModules` in `module-manager.ps1` to have them auto-installed.

---

<div align="center">
    <sub>Maintained by <a href="https://github.com/irmandos">irmandos</a></sub>
</div>
