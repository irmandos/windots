# Setup script for new windows machine
#Requires -RunAsAdministrator

$OneApps = "$Env:OneDriveConsumer\Apps\"


# Linked Files (Destination => Source)
$symlinks = @{
    $PROFILE.CurrentUserAllHosts                                                                         = ".\profile.ps1"
    "$Env:UserProfile\.gitconfig"                                                                        = "$OneApps\Git\.gitconfig"
    "$Env:UserProfile\.ssh"                                                                              = "$OneApps\SSH"
    "$Env:LocalAppData\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"        = "$OneApps\WindowsTerminal\settings.json"
    "$Env:LocalAppData\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json" = "$OneApps\WindowsTerminalBeta\settings.json"
    
}