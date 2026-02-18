
. "$env:OneDriveConsumer\Documents\PowerShell\module-manager.ps1"

Write-Host "--- Testing Update-AllPSModules (expect no JSON errors) ---"
try {
    Update-AllPSModules
    Write-Host "Update-AllPSModules finished without crashing."
}
catch {
    Write-Error "Test Failed: $_"
}
