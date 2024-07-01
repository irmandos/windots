# My personal Windows-friendly dotfiles. Supports automatic installation of dependencies and configuration.

## 🎉 Features

- **Centralized Configuration:** Brings together scattered Windows configuration files into one organized location for easy access and management.

## ✅ Pre-requisites

- [PowerShell 7](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.3#install-powershell-using-winget-recommended)
- [Git](https://winget.run/pkg/Git/Git)

## 🚀 Installation
>
> [!WARNING]\
> Under _**active development**_, expect changes. Existing configuration files will be overwritten. Please make a backup of any files you wish to keep before proceeding.
Execute the following command in an elevated PowerShell window to install the PowerShell profile:

```
irm "https://github.com/irmandos/windots/raw/main/setup.ps1" | iex
```

## Customize this profile

**Do not make any changes to the `Microsoft.PowerShell_profile.ps1` file**, since it's hashed and automatically overwritten by any commits to this repository.

Now, enjoy your enhanced and stylish PowerShell experience! 🚀
