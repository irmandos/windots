
# ----------------------------------------------------------------------------------
#
# Copyright Microsoft Corporation
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ----------------------------------------------------------------------------------

<#
.Synopsis
Updates the target properties for the replicating server.
.Description
The Set-AzMigrateLocalServerReplication cmdlet updates the target properties for the replicating server.
.Link
https://learn.microsoft.com/powershell/module/az.migrate/set-azmigratelocalserverreplication
#>
function Set-AzMigrateLocalServerReplication {
    [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Runtime.PreviewMessageAttribute("This cmdlet is based on a preview API version and may experience breaking changes in future releases.")]
    [OutputType([Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.IJobModel])]
    [CmdletBinding(DefaultParameterSetName = 'ById', PositionalBinding = $false, SupportsShouldProcess, ConfirmImpact='Medium')]
    param(
        [Parameter(Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the replicating server for which the properties need to be updated. The ID should be retrieved using the Get-AzMigrateLocalServerReplication cmdlet.
        ${TargetObjectID},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.Int32]
        # Specifies the number of CPU cores.
        ${TargetVMCPUCore},

        [Parameter()]
        [ValidateSet("true" , "false")]
        [ArgumentCompleter( { "true" , "false" })]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies if RAM is dynamic or not. 
        ${IsDynamicMemoryEnabled},
        
        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.ProtectedItemDynamicMemoryConfig]
        # Specifies the dynamic memory configuration of RAM.
        ${DynamicMemoryConfig},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.Int64]
        # Specifies the target RAM size in MB. 
        ${TargetVMRam},
		
        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.AzLocalNicInput[]]
        # Specifies the nics on the source server to be included for replication.
        ${NicToInclude},

        [Parameter()]
        [ValidateSet("WindowsGuest" , "LinuxGuest")]
        [ArgumentCompleter( { "WindowsGuest" , "LinuxGuest" })]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the OS type of the VM, either WindowsGuest or LinuxGuest.
        ${OsType},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Runtime.DefaultInfo(Script = '(Get-AzContext).Subscription.Id')]
        [System.String]
        # The subscription Id.
        ${SubscriptionId},

        [Parameter()]
        [Alias('AzureRMContext', 'AzureCredential')]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Azure')]
        [System.Management.Automation.PSObject]
        # The credentials, account, tenant, and subscription used for communication with Azure.
        ${DefaultProfile},

        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Wait for .NET debugger to attach
        ${Break},

        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Runtime')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Runtime.SendAsyncStep[]]
        # SendAsync Pipeline Steps to be appended to the front of the pipeline
        ${HttpPipelineAppend},

        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Runtime')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Runtime.SendAsyncStep[]]
        # SendAsync Pipeline Steps to be prepended to the front of the pipeline
        ${HttpPipelinePrepend},

        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Runtime')]
        [System.Uri]
        # The URI for the proxy server to use
        ${Proxy},

        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Runtime')]
        [System.Management.Automation.PSCredential]
        # Credentials for a proxy server to use for the remote call
        ${ProxyCredential},

        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Use the default credentials for the proxy
        ${ProxyUseDefaultCredentials}
    )
    
    process {
        Import-Module $PSScriptRoot\Helper\AzLocalCommonSettings.ps1
        Import-Module $PSScriptRoot\Helper\AZLocalCommonHelper.ps1

        CheckResourcesModuleDependency
        
        $HasTargetVMCPUCore = $PSBoundParameters.ContainsKey('TargetVMCPUCore')
        $HasTargetVMRam = $PSBoundParameters.ContainsKey('TargetVMRam')
        $HasDynamicMemoryConfig = $PSBoundParameters.ContainsKey('DynamicMemoryConfig')
        $HasNicToInclude = $PSBoundParameters.ContainsKey('NicToInclude')
        $HasIsDynamicMemoryEnabled = $PSBoundParameters.ContainsKey('IsDynamicMemoryEnabled')
        if ($HasIsDynamicMemoryEnabled) {
            $isDynamicRamEnabled = [System.Convert]::ToBoolean($IsDynamicMemoryEnabled)
        }
        $HasOsType = $PSBoundParameters.ContainsKey('OsType')

        $null = $PSBoundParameters.Remove('TargetVMCPUCore')
        $null = $PSBoundParameters.Remove('IsDynamicMemoryEnabled')
        $null = $PSBoundParameters.Remove('DynamicMemoryConfig')
        $null = $PSBoundParameters.Remove('TargetVMRam')
        $null = $PSBoundParameters.Remove('NicToInclude')
        $null = $PSBoundParameters.Remove('TargetObjectID')
        $null = $PSBoundParameters.Remove('OsType')
        $null = $PSBoundParameters.Remove('WhatIf')
        $null = $PSBoundParameters.Remove('Confirm')
        
        $ProtectedItemIdArray = $TargetObjectID.Split("/")
        $ResourceGroupName = $ProtectedItemIdArray[4]
        $VaultName = $ProtectedItemIdArray[8]
        $MachineName = $ProtectedItemIdArray[10]
      
        # Get existing Protected Item
        $null = $PSBoundParameters.Add("ResourceGroupName", $ResourceGroupName)
        $null = $PSBoundParameters.Add("VaultName", $VaultName)
        $null = $PSBoundParameters.Add("Name", $MachineName)
      
        $ProtectedItem = InvokeAzMigrateGetCommandWithRetries `
            -CommandName 'Az.Migrate.Internal\Get-AzMigrateProtectedItem' `
            -Parameters $PSBoundParameters `
            -ErrorMessage "Replication item is not found with Id '$TargetObjectID'."
      
        $null = $PSBoundParameters.Remove("ResourceGroupName")
        $null = $PSBoundParameters.Remove("VaultName")
        $null = $PSBoundParameters.Remove("Name")
        
        $protectedItemProperties = $ProtectedItem.Property
        $customProperties = $protectedItemProperties.CustomProperty
        $MachineIdArray = $customProperties.FabricDiscoveryMachineId.Split("/")
        $SiteType = $MachineIdArray[7]
        $SiteName = $MachineIdArray[8]
       
        # No "DisableProtection" means IR has not been initiated
        # "CommitFailover" means migration has been completed
        if (!$protectedItemProperties.AllowedJob.Contains('DisableProtection') -or
            $protectedItemProperties.AllowedJob.Contains('CommitFailover')) {
            throw "Set server replication is not allowed for this item '$TargetObjectID' at the moment. Please check its status and try again later."
        }

        if ($SiteType -eq $SiteTypes.HyperVSites) {     
            $customPropertiesUpdate = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.HyperVToAzStackHCIProtectedItemModelCustomPropertiesUpdate]::new()
            $customPropertiesUpdate.InstanceType = $AzLocalInstanceTypes.HyperVToAzLocal
        }
        elseif ($SiteType -eq $SiteTypes.VMwareSites) {  
            $customPropertiesUpdate = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.VMwareToAzStackHCIProtectedItemModelCustomPropertiesUpdate]::new()
            $customPropertiesUpdate.InstanceType = $AzLocalInstanceTypes.VMwareToAzLocal
        }

        # Update target CPU core
        if ($HasTargetVMCPUCore) {
            if ($TargetVMCPUCore -le 0) {
                throw "Specify target CPU core greater than 0"    
            }

            $customPropertiesUpdate.TargetCpuCore = $TargetVMCPUCore
        }

        # Update VM Ram
        if ($HasTargetVMRam) {
            if ($TargetVMRam -le 0) {
                throw "Specify target RAM greater than 0"    
            }

            $customPropertiesUpdate.TargetMemoryInMegaByte = $TargetVMRam
        }
        $targetMemory = $customPropertiesUpdate.TargetMemoryInMegaByte -or $customProperties.TargetMemoryInMegaByte

        # Update IsDynamicRam 
        if ($HasIsDynamicMemoryEnabled) {
            $customPropertiesUpdate.IsDynamicRam = $isDynamicRamEnabled
        }
        elseif ($HasDynamicMemoryConfig) {
            $customPropertiesUpdate.IsDynamicRam = $customProperties.IsDynamicRam
        }

        # Dynamic memory is enabled - set provided configuration
        if ($customPropertiesUpdate.IsDynamicRam -and $HasDynamicMemoryConfig) {
            if ($targetMemory -lt $DynamicMemoryConfig.MinimumMemoryInMegaByte) {
                throw "DynamicMemoryConfig - Specify minimum memory less than $($targetMemory)"
            }
          
            if ($targetMemory -gt $DynamicMemoryConfig.MaximumMemoryInMegaByte) {
                throw "DynamicMemoryConfig - Specify maximum memory greater than $($targetMemory)"
            }

            if ($DynamicMemoryConfig.TargetMemoryBufferPercentage -NotIn $RAMConfig.MinTargetMemoryBufferPercentage..$RAMConfig.MaxTargetMemoryBufferPercentage)
            {
                throw "DynamicMemoryConfig - Specify target memory buffer percentage between $($RAMConfig.MinTargetMemoryBufferPercentage) % and $($RAMConfig.MaxTargetMemoryBufferPercentage) %."
            }

            $customPropertiesUpdate.DynamicMemoryConfig = $DynamicMemoryConfig
        }

        # Dynamic memory is enabled - set default configuration
        if ($customPropertiesUpdate.IsDynamicRam -and !$HasDynamicMemoryConfig) {
            if ($null -eq $customProperties.DynamicMemoryConfig) {
                $memoryConfig = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.ProtectedItemDynamicMemoryConfig]::new()
                $memoryConfig.MinimumMemoryInMegaByte = [System.Math]::Min($targetMemory, $RAMConfig.DefaultMinDynamicMemoryInMB)
                $memoryConfig.MaximumMemoryInMegaByte = [System.Math]::Max($targetMemory, $RAMConfig.DefaultMaxDynamicMemoryInMB)
                $memoryConfig.TargetMemoryBufferPercentage = $RAMConfig.DefaultTargetMemoryBufferPercentage
                $customPropertiesUpdate.DynamicMemoryConfig = $memoryConfig
            }
            else {
                $customPropertiesUpdate.DynamicMemoryConfig = $customProperties.DynamicMemoryConfig
            }
        }
        
        # Update Nics
        if ($HasNicToInclude -and $NicToInclude.length -gt 0) {
            # Get discovered machine
            $null = $PSBoundParameters.Add("ResourceGroupName", $ResourceGroupName)
            $null = $PSBoundParameters.Add("SiteName", $SiteName)
            $null = $PSBoundParameters.Add("MachineName", $MachineName)
            
            if ($SiteType -eq $SiteTypes.HyperVSites) {
                $machine = InvokeAzMigrateGetCommandWithRetries `
                    -CommandName 'Az.Migrate.Internal\Get-AzMigrateHyperVMachine' `
                    -Parameters $PSBoundParameters `
                    -ErrorMessage "Machine '$MachineName' not found in resource group '$ResourceGroupName' and site '$SiteName'."
            }
            elseif ($SiteType -eq $SiteTypes.VMwareSites) {
                $machine = InvokeAzMigrateGetCommandWithRetries `
                    -CommandName 'Az.Migrate.Internal\Get-AzMigrateMachine' `
                    -Parameters $PSBoundParameters `
                    -ErrorMessage "Machine '$MachineName' not found in resource group '$ResourceGroupName' and site '$SiteName'."
            }

            $null = $PSBoundParameters.Remove("ResourceGroupName")
            $null = $PSBoundParameters.Remove("SiteName")
            $null = $PSBoundParameters.Remove("MachineName")
            
            # Nics
            [PSCustomObject[]]$nics = @()
            [PSCustomObject[]]$uniqueNics = @()
            foreach ($nic in $NicToInclude) {
                $discoveredNic = $machine.NetworkAdapter | Where-Object { $_.NicId -eq $nic.NicId }
                if ($null -eq $discoveredNic) {
                    throw "The Nic id '$($nic.NicId)' is not found."
                }

                if ($uniqueNics.Contains($nic.NicId)) {
                    throw "The Nic id '$($nic.NicId)' is already included. Please remove the duplicate entry and try again."
                }

                $uniqueNics += $nic.NicId
                
                $htNic = @{}
                $nic.PSObject.Properties | ForEach-Object { $htNic[$_.Name] = $_.Value }

                if ($htNic.SelectionTypeForFailover -eq $VMNicSelection.SelectedByUser -and
                    [string]::IsNullOrEmpty($htNic.TargetNetworkId)) {
                    throw "The TargetVirtualSwitchId parameter is required when the CreateAtTarget flag is set to 'true'. NIC '$($htNic.NicId)'. Please utilize the New-AzMigrateLocalNicMappingObject command to properly create a Nic mapping object."
                }

                $nics += [PSCustomObject]$htNic
            }

            if ($SiteType -eq $SiteTypes.HyperVSites) {     
                $customPropertiesUpdate.NicsToInclude = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.HyperVToAzStackHCINicInput[]]$nics
            }
            elseif ($SiteType -eq $SiteTypes.VMwareSites) {     
                $customPropertiesUpdate.NicsToInclude = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.VMwareToAzStackHCINicInput[]]$nics
            }
        }

        # Update OS type
        if ($HasOsType) {
            $customPropertiesUpdate.OsType = $OsType
        }

        $protectedItemPropertiesUpdate = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.ProtectedItemModelPropertiesUpdate]::new()
        $protectedItemPropertiesUpdate.CustomProperty = $customPropertiesUpdate

        $null = $PSBoundParameters.Add('ResourceGroupName', $ResourceGroupName)
        $null = $PSBoundParameters.Add('VaultName', $vaultName)
        $null = $PSBoundParameters.Add('Name', $MachineName)
        $null = $PSBoundParameters.Add('Property', $protectedItemPropertiesUpdate)
        $null = $PSBoundParameters.Add('NoWait', $true)
        
        if ($PSCmdlet.ShouldProcess($TargetObjectID, "Updates VM replication.")) {
            $operation = Az.Migrate.Internal\Update-AzMigrateProtectedItem @PSBoundParameters
            $jobName = $operation.Target.Split("/")[-1].Split("?")[0].Split("_")[0]
            
            $null = $PSBoundParameters.Remove('Name')  
            $null = $PSBoundParameters.Remove('Property')
            $null = $PSBoundParameters.Remove('NoWait')

            $null = $PSBoundParameters.Add('JobName', $jobName)
            return Az.Migrate.Internal\Get-AzMigrateLocalReplicationJob @PSBoundParameters
        }
    }
}   
# SIG # Begin signature block
# MIIoKgYJKoZIhvcNAQcCoIIoGzCCKBcCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCy5GKZ9WSNQTUi
# 2VNc+hbCQanCncTj6xfLKbmamvHyfaCCDXYwggX0MIID3KADAgECAhMzAAAEhV6Z
# 7A5ZL83XAAAAAASFMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjUwNjE5MTgyMTM3WhcNMjYwNjE3MTgyMTM3WjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQDASkh1cpvuUqfbqxele7LCSHEamVNBfFE4uY1FkGsAdUF/vnjpE1dnAD9vMOqy
# 5ZO49ILhP4jiP/P2Pn9ao+5TDtKmcQ+pZdzbG7t43yRXJC3nXvTGQroodPi9USQi
# 9rI+0gwuXRKBII7L+k3kMkKLmFrsWUjzgXVCLYa6ZH7BCALAcJWZTwWPoiT4HpqQ
# hJcYLB7pfetAVCeBEVZD8itKQ6QA5/LQR+9X6dlSj4Vxta4JnpxvgSrkjXCz+tlJ
# 67ABZ551lw23RWU1uyfgCfEFhBfiyPR2WSjskPl9ap6qrf8fNQ1sGYun2p4JdXxe
# UAKf1hVa/3TQXjvPTiRXCnJPAgMBAAGjggFzMIIBbzAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQUuCZyGiCuLYE0aU7j5TFqY05kko0w
# RQYDVR0RBD4wPKQ6MDgxHjAcBgNVBAsTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEW
# MBQGA1UEBRMNMjMwMDEyKzUwNTM1OTAfBgNVHSMEGDAWgBRIbmTlUAXTgqoXNzci
# tW2oynUClTBUBgNVHR8ETTBLMEmgR6BFhkNodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpb3BzL2NybC9NaWNDb2RTaWdQQ0EyMDExXzIwMTEtMDctMDguY3JsMGEG
# CCsGAQUFBwEBBFUwUzBRBggrBgEFBQcwAoZFaHR0cDovL3d3dy5taWNyb3NvZnQu
# Y29tL3BraW9wcy9jZXJ0cy9NaWNDb2RTaWdQQ0EyMDExXzIwMTEtMDctMDguY3J0
# MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQADggIBACjmqAp2Ci4sTHZci+qk
# tEAKsFk5HNVGKyWR2rFGXsd7cggZ04H5U4SV0fAL6fOE9dLvt4I7HBHLhpGdE5Uj
# Ly4NxLTG2bDAkeAVmxmd2uKWVGKym1aarDxXfv3GCN4mRX+Pn4c+py3S/6Kkt5eS
# DAIIsrzKw3Kh2SW1hCwXX/k1v4b+NH1Fjl+i/xPJspXCFuZB4aC5FLT5fgbRKqns
# WeAdn8DsrYQhT3QXLt6Nv3/dMzv7G/Cdpbdcoul8FYl+t3dmXM+SIClC3l2ae0wO
# lNrQ42yQEycuPU5OoqLT85jsZ7+4CaScfFINlO7l7Y7r/xauqHbSPQ1r3oIC+e71
# 5s2G3ClZa3y99aYx2lnXYe1srcrIx8NAXTViiypXVn9ZGmEkfNcfDiqGQwkml5z9
# nm3pWiBZ69adaBBbAFEjyJG4y0a76bel/4sDCVvaZzLM3TFbxVO9BQrjZRtbJZbk
# C3XArpLqZSfx53SuYdddxPX8pvcqFuEu8wcUeD05t9xNbJ4TtdAECJlEi0vvBxlm
# M5tzFXy2qZeqPMXHSQYqPgZ9jvScZ6NwznFD0+33kbzyhOSz/WuGbAu4cHZG8gKn
# lQVT4uA2Diex9DMs2WHiokNknYlLoUeWXW1QrJLpqO82TLyKTbBM/oZHAdIc0kzo
# STro9b3+vjn2809D0+SOOCVZMIIHejCCBWKgAwIBAgIKYQ6Q0gAAAAAAAzANBgkq
# hkiG9w0BAQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
# EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
# bjEyMDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5
# IDIwMTEwHhcNMTEwNzA4MjA1OTA5WhcNMjYwNzA4MjEwOTA5WjB+MQswCQYDVQQG
# EwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
# A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSgwJgYDVQQDEx9NaWNyb3NvZnQg
# Q29kZSBTaWduaW5nIFBDQSAyMDExMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIIC
# CgKCAgEAq/D6chAcLq3YbqqCEE00uvK2WCGfQhsqa+laUKq4BjgaBEm6f8MMHt03
# a8YS2AvwOMKZBrDIOdUBFDFC04kNeWSHfpRgJGyvnkmc6Whe0t+bU7IKLMOv2akr
# rnoJr9eWWcpgGgXpZnboMlImEi/nqwhQz7NEt13YxC4Ddato88tt8zpcoRb0Rrrg
# OGSsbmQ1eKagYw8t00CT+OPeBw3VXHmlSSnnDb6gE3e+lD3v++MrWhAfTVYoonpy
# 4BI6t0le2O3tQ5GD2Xuye4Yb2T6xjF3oiU+EGvKhL1nkkDstrjNYxbc+/jLTswM9
# sbKvkjh+0p2ALPVOVpEhNSXDOW5kf1O6nA+tGSOEy/S6A4aN91/w0FK/jJSHvMAh
# dCVfGCi2zCcoOCWYOUo2z3yxkq4cI6epZuxhH2rhKEmdX4jiJV3TIUs+UsS1Vz8k
# A/DRelsv1SPjcF0PUUZ3s/gA4bysAoJf28AVs70b1FVL5zmhD+kjSbwYuER8ReTB
# w3J64HLnJN+/RpnF78IcV9uDjexNSTCnq47f7Fufr/zdsGbiwZeBe+3W7UvnSSmn
# Eyimp31ngOaKYnhfsi+E11ecXL93KCjx7W3DKI8sj0A3T8HhhUSJxAlMxdSlQy90
# lfdu+HggWCwTXWCVmj5PM4TasIgX3p5O9JawvEagbJjS4NaIjAsCAwEAAaOCAe0w
# ggHpMBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBRIbmTlUAXTgqoXNzcitW2o
# ynUClTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMCAYYwDwYD
# VR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBRyLToCMZBDuRQFTuHqp8cx0SOJNDBa
# BgNVHR8EUzBRME+gTaBLhklodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2Ny
# bC9wcm9kdWN0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFfMDNfMjIuY3JsMF4GCCsG
# AQUFBwEBBFIwUDBOBggrBgEFBQcwAoZCaHR0cDovL3d3dy5taWNyb3NvZnQuY29t
# L3BraS9jZXJ0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFfMDNfMjIuY3J0MIGfBgNV
# HSAEgZcwgZQwgZEGCSsGAQQBgjcuAzCBgzA/BggrBgEFBQcCARYzaHR0cDovL3d3
# dy5taWNyb3NvZnQuY29tL3BraW9wcy9kb2NzL3ByaW1hcnljcHMuaHRtMEAGCCsG
# AQUFBwICMDQeMiAdAEwAZQBnAGEAbABfAHAAbwBsAGkAYwB5AF8AcwB0AGEAdABl
# AG0AZQBuAHQALiAdMA0GCSqGSIb3DQEBCwUAA4ICAQBn8oalmOBUeRou09h0ZyKb
# C5YR4WOSmUKWfdJ5DJDBZV8uLD74w3LRbYP+vj/oCso7v0epo/Np22O/IjWll11l
# hJB9i0ZQVdgMknzSGksc8zxCi1LQsP1r4z4HLimb5j0bpdS1HXeUOeLpZMlEPXh6
# I/MTfaaQdION9MsmAkYqwooQu6SpBQyb7Wj6aC6VoCo/KmtYSWMfCWluWpiW5IP0
# wI/zRive/DvQvTXvbiWu5a8n7dDd8w6vmSiXmE0OPQvyCInWH8MyGOLwxS3OW560
# STkKxgrCxq2u5bLZ2xWIUUVYODJxJxp/sfQn+N4sOiBpmLJZiWhub6e3dMNABQam
# ASooPoI/E01mC8CzTfXhj38cbxV9Rad25UAqZaPDXVJihsMdYzaXht/a8/jyFqGa
# J+HNpZfQ7l1jQeNbB5yHPgZ3BtEGsXUfFL5hYbXw3MYbBL7fQccOKO7eZS/sl/ah
# XJbYANahRr1Z85elCUtIEJmAH9AAKcWxm6U/RXceNcbSoqKfenoi+kiVH6v7RyOA
# 9Z74v2u3S5fi63V4GuzqN5l5GEv/1rMjaHXmr/r8i+sLgOppO6/8MO0ETI7f33Vt
# Y5E90Z1WTk+/gFcioXgRMiF670EKsT/7qMykXcGhiJtXcVZOSEXAQsmbdlsKgEhr
# /Xmfwb1tbWrJUnMTDXpQzTGCGgowghoGAgEBMIGVMH4xCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNp
# Z25pbmcgUENBIDIwMTECEzMAAASFXpnsDlkvzdcAAAAABIUwDQYJYIZIAWUDBAIB
# BQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIBoKdw4oAAYTtRMv8hKbKBFw
# 8hH1ooX//hkzpYRj1EcBMEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEB
# BQAEggEAuTay7WLLGbQ3d7mJ08XLDH70nLeK3WsUh6lGU+98W+Qu1iGANdaMN8dt
# MZ8DgvQJPI3PVqMRTEkYruS5yZBlr45J1QKLx2o65CCTHRHi7BKbOe8JO5SxEneY
# ln7D8sZbrwoesdxMnS+PJXh4XgfTaYcNaNRhPP88GTXtIoe4tPo0Z8FQskHrN8qF
# DdZN8gAQIQPc39Z2HQsop/NxzfwvWNJ/wzEI4pYgVVB7L1Rb2X7/tzv+nv1BU4iF
# h3X9mTLdxYIKGsL0iof/mR+UHqKK2U0mQ8D9JmvLpoWF4cebDZ38OEzy7StQoEIE
# docfRjA25JSsthiK2oc0C9bB/1NHJKGCF5QwgheQBgorBgEEAYI3AwMBMYIXgDCC
# F3wGCSqGSIb3DQEHAqCCF20wghdpAgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFSBgsq
# hkiG9w0BCRABBKCCAUEEggE9MIIBOQIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCAtzpX9MW5RS5A418hflWM05rRgrIyy421HsKqQHoLddgIGaEr7fLxw
# GBMyMDI1MDczMDAzNTEzMC43MTdaMASAAgH0oIHRpIHOMIHLMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1l
# cmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046ODYwMy0w
# NUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2Wg
# ghHqMIIHIDCCBQigAwIBAgITMwAAAgcsETmJzYX7xQABAAACBzANBgkqhkiG9w0B
# AQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYD
# VQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAeFw0yNTAxMzAxOTQy
# NTJaFw0yNjA0MjIxOTQyNTJaMIHLMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25z
# MScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046ODYwMy0wNUUwLUQ5NDcxJTAjBgNV
# BAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2UwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQDFP/96dPmcfgODe3/nuFveuBst/JmSxSkOn89ZFytH
# Qm344iLoPqkVws+CiUejQabKf+/c7KU1nqwAmmtiPnG8zm4Sl9+RJZaQ4Dx3qtA9
# mdQdS7Chf6YUbP4Z++8laNbTQigJoXCmzlV34vmC4zpFrET4KAATjXSPK0sQuFhK
# r7ltNaMFGclXSnIhcnScj9QUDVLQpAsJtsKHyHN7cN74aEXLpFGc1I+WYFRxaTgq
# SPqGRfEfuQ2yGrAbWjJYOXueeTA1MVKhW8zzSEpfjKeK/t2XuKykpCUaKn5s8sqN
# bI3bHt/rE/pNzwWnAKz+POBRbJxIkmL+n/EMVir5u8uyWPl1t88MK551AGVh+2H4
# ziR14YDxzyCG924gaonKjicYnWUBOtXrnPK6AS/LN6Y+8Kxh26a6vKbFbzaqWXAj
# zEiQ8EY9K9pYI/KCygixjDwHfUgVSWCyT8Kw7mGByUZmRPPxXONluMe/P8CtBJMp
# uh8CBWyjvFfFmOSNRK8ETkUmlTUAR1CIOaeBqLGwscShFfyvDQrbChmhXib4nRMX
# 5U9Yr9d7VcYHn6eZJsgyzh5QKlIbCQC/YvhFK42ceCBDMbc+Ot5R6T/Mwce5jVyV
# CmqXVxWOaQc4rA2nV7onMOZC6UvCG8LGFSZBnj1loDDLWo/I+RuRok2j/Q4zcMnw
# kQIDAQABo4IBSTCCAUUwHQYDVR0OBBYEFHK1UmLCvXrQCvR98JBq18/4zo0eMB8G
# A1UdIwQYMBaAFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMF8GA1UdHwRYMFYwVKBSoFCG
# Tmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUy
# MFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNybDBsBggrBgEFBQcBAQRgMF4w
# XAYIKwYBBQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2Vy
# dHMvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUyMDIwMTAoMSkuY3J0MAwG
# A1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQD
# AgeAMA0GCSqGSIb3DQEBCwUAA4ICAQDju0quPbnix0slEjD7j2224pYOPGTmdDvO
# 0+bNRCNkZqUv07P04nf1If3Y/iJEmUaU7w12Fm582ImpD/Kw2ClXrNKLPTBO6nfx
# vOPGtalpAl4wqoGgZxvpxb2yEunG4yZQ6EQOpg1dE9uOXoze3gD4Hjtcc75kca8y
# ivowEI+rhXuVUWB7vog4TGUxKdnDvpk5GSGXnOhPDhdId+g6hRyXdZiwgEa+q9M9
# Xctz4TGhDgOKFsYxFhXNJZo9KRuGq6evhtyNduYrkzjDtWS6gW8akR59UhuLGsVq
# +4AgqEY8WlXjQGM2OTkyBnlQLpB8qD7x9jRpY2Cq0OWWlK0wfH/1zefrWN5+be87
# Sw2TPcIudIJn39bbDG7awKMVYDHfsPJ8ZvxgWkZuf6ZZAkph0eYGh3IV845taLkd
# LOCvw49Wxqha5Dmi2Ojh8Gja5v9kyY3KTFyX3T4C2scxfgp/6xRd+DGOhNVPvVPa
# /3yRUqY5s5UYpy8DnbppV7nQO2se3HvCSbrb+yPyeob1kUfMYa9fE2bEsoMbOaHR
# gGji8ZPt/Jd2bPfdQoBHcUOqPwjHBUIcSc7xdJZYjRb4m81qxjma3DLjuOFljMZT
# YovRiGvEML9xZj2pHRUyv+s5v7VGwcM6rjNYM4qzZQM6A2RGYJGU780GQG0QO98w
# +sucuTVrfTCCB3EwggVZoAMCAQICEzMAAAAVxedrngKbSZkAAAAAABUwDQYJKoZI
# hvcNAQELBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAw
# DgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24x
# MjAwBgNVBAMTKU1pY3Jvc29mdCBSb290IENlcnRpZmljYXRlIEF1dGhvcml0eSAy
# MDEwMB4XDTIxMDkzMDE4MjIyNVoXDTMwMDkzMDE4MzIyNVowfDELMAkGA1UEBhMC
# VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNV
# BAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRp
# bWUtU3RhbXAgUENBIDIwMTAwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoIC
# AQDk4aZM57RyIQt5osvXJHm9DtWC0/3unAcH0qlsTnXIyjVX9gF/bErg4r25Phdg
# M/9cT8dm95VTcVrifkpa/rg2Z4VGIwy1jRPPdzLAEBjoYH1qUoNEt6aORmsHFPPF
# dvWGUNzBRMhxXFExN6AKOG6N7dcP2CZTfDlhAnrEqv1yaa8dq6z2Nr41JmTamDu6
# GnszrYBbfowQHJ1S/rboYiXcag/PXfT+jlPP1uyFVk3v3byNpOORj7I5LFGc6XBp
# Dco2LXCOMcg1KL3jtIckw+DJj361VI/c+gVVmG1oO5pGve2krnopN6zL64NF50Zu
# yjLVwIYwXE8s4mKyzbnijYjklqwBSru+cakXW2dg3viSkR4dPf0gz3N9QZpGdc3E
# XzTdEonW/aUgfX782Z5F37ZyL9t9X4C626p+Nuw2TPYrbqgSUei/BQOj0XOmTTd0
# lBw0gg/wEPK3Rxjtp+iZfD9M269ewvPV2HM9Q07BMzlMjgK8QmguEOqEUUbi0b1q
# GFphAXPKZ6Je1yh2AuIzGHLXpyDwwvoSCtdjbwzJNmSLW6CmgyFdXzB0kZSU2LlQ
# +QuJYfM2BjUYhEfb3BvR/bLUHMVr9lxSUV0S2yW6r1AFemzFER1y7435UsSFF5PA
# PBXbGjfHCBUYP3irRbb1Hode2o+eFnJpxq57t7c+auIurQIDAQABo4IB3TCCAdkw
# EgYJKwYBBAGCNxUBBAUCAwEAATAjBgkrBgEEAYI3FQIEFgQUKqdS/mTEmr6CkTxG
# NSnPEP8vBO4wHQYDVR0OBBYEFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMFwGA1UdIARV
# MFMwUQYMKwYBBAGCN0yDfQEBMEEwPwYIKwYBBQUHAgEWM2h0dHA6Ly93d3cubWlj
# cm9zb2Z0LmNvbS9wa2lvcHMvRG9jcy9SZXBvc2l0b3J5Lmh0bTATBgNVHSUEDDAK
# BggrBgEFBQcDCDAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMC
# AYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBTV9lbLj+iiXGJo0T2UkFvX
# zpoYxDBWBgNVHR8ETzBNMEugSaBHhkVodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20v
# cGtpL2NybC9wcm9kdWN0cy9NaWNSb29DZXJBdXRfMjAxMC0wNi0yMy5jcmwwWgYI
# KwYBBQUHAQEETjBMMEoGCCsGAQUFBzAChj5odHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpL2NlcnRzL01pY1Jvb0NlckF1dF8yMDEwLTA2LTIzLmNydDANBgkqhkiG
# 9w0BAQsFAAOCAgEAnVV9/Cqt4SwfZwExJFvhnnJL/Klv6lwUtj5OR2R4sQaTlz0x
# M7U518JxNj/aZGx80HU5bbsPMeTCj/ts0aGUGCLu6WZnOlNN3Zi6th542DYunKmC
# VgADsAW+iehp4LoJ7nvfam++Kctu2D9IdQHZGN5tggz1bSNU5HhTdSRXud2f8449
# xvNo32X2pFaq95W2KFUn0CS9QKC/GbYSEhFdPSfgQJY4rPf5KYnDvBewVIVCs/wM
# nosZiefwC2qBwoEZQhlSdYo2wh3DYXMuLGt7bj8sCXgU6ZGyqVvfSaN0DLzskYDS
# PeZKPmY7T7uG+jIa2Zb0j/aRAfbOxnT99kxybxCrdTDFNLB62FD+CljdQDzHVG2d
# Y3RILLFORy3BFARxv2T5JL5zbcqOCb2zAVdJVGTZc9d/HltEAY5aGZFrDZ+kKNxn
# GSgkujhLmm77IVRrakURR6nxt67I6IleT53S0Ex2tVdUCbFpAUR+fKFhbHP+Crvs
# QWY9af3LwUFJfn6Tvsv4O+S3Fb+0zj6lMVGEvL8CwYKiexcdFYmNcP7ntdAoGokL
# jzbaukz5m/8K6TT4JDVnK+ANuOaMmdbhIurwJ0I9JZTmdHRbatGePu1+oDEzfbzL
# 6Xu/OHBE0ZDxyKs6ijoIYn/ZcGNTTY3ugm2lBRDBcQZqELQdVTNYs6FwZvKhggNN
# MIICNQIBATCB+aGB0aSBzjCByzELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
# bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
# b3JhdGlvbjElMCMGA1UECxMcTWljcm9zb2Z0IEFtZXJpY2EgT3BlcmF0aW9uczEn
# MCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOjg2MDMtMDVFMC1EOTQ3MSUwIwYDVQQD
# ExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloiMKAQEwBwYFKw4DAhoDFQDT
# vVU/Yj9lUSyeDCaiJ2Da5hUiS6CBgzCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFBDQSAyMDEwMA0GCSqGSIb3DQEBCwUAAgUA7DQU/zAiGA8yMDI1MDczMDAzNTAy
# M1oYDzIwMjUwNzMxMDM1MDIzWjB0MDoGCisGAQQBhFkKBAExLDAqMAoCBQDsNBT/
# AgEAMAcCAQACAhBkMAcCAQACAhI/MAoCBQDsNWZ/AgEAMDYGCisGAQQBhFkKBAIx
# KDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMHoSChCjAIAgEAAgMBhqAwDQYJKoZI
# hvcNAQELBQADggEBAJDIFyMZB7IMcvhwWGIshi7v2H5fQI5oOXNE/CDP90ropUl2
# W2sm159jtmWpxzH+cTiLSwujK3MjWmSTRjiq5DL6ZGye2h1psW3KqQFynI0s5a6n
# 1prF3kXxEqjqwBPdQzPj3C9MuYdJq+V0bVEA/QVJcWCkZVOk9NUTILfeQ6FScTts
# j9rCdQlu2NPjXvMJi97sCRKMi1OiTrt/gTaPujNsqmdJjf5jbrUrmQi3e0i5u0pB
# ziwugqiQ4Wk92Gh2LGGrgFIMNPZZIGFw+TdVlcn7aAPGOSdr/ADHNa0IAWK1OJTw
# izPdlHxMrI6r/uYZi3NZw2bjmKoHgilN5fFm194xggQNMIIECQIBATCBkzB8MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNy
# b3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAgcsETmJzYX7xQABAAACBzAN
# BglghkgBZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMC8G
# CSqGSIb3DQEJBDEiBCDL0sNO48NjpERVZ05aDUshrwFPSh0vIAv2oVqrYjk8wzCB
# +gYLKoZIhvcNAQkQAi8xgeowgecwgeQwgb0EIC/31NHQds1IZ5sPnv59p+v6BjBD
# goDPIwiAmn0PHqezMIGYMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldh
# c2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBD
# b3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIw
# MTACEzMAAAIHLBE5ic2F+8UAAQAAAgcwIgQgpS3b9m4iXRFGcVttPTxdZAB7WZ6q
# a/Gfu/VC6OkFYhgwDQYJKoZIhvcNAQELBQAEggIAnS+hXKsXQnM8Hkf/o34v4b25
# UnD8XPZl4AmHj5wRRUuoy8AVMvVWipGsOY55GHFM1ZFVPXugOofphpMvM7ey2aua
# filNyV0hvXmYTBpYvR7KqINxi34vCW7jOyPwdTgXWpZjfzkItUCpLTUZlNM7D67f
# 4PucjZPVKJIADLgsmwn67ToPFU/9cf+vG5OPSYcN/AtNEuTbmmgcFKNDrYTX5AdV
# b9QB27jMEs5i9X8RkPVWrVahy7Tr08SrgFMKHy4n2lLXUSaodWIesWXyF6PGcYbY
# 8OCbZOtexMz7+TeadsJ2dFM5UfpFqagovbIyBFb4UxoFzYLBuXknrDXvZz1PTD/4
# 8lYs9uhv0qIbnj5go/HxDxS6rBVldL0JD2EliaMjUq7SSjjP+xOfA12sxafjPXo8
# PT+O0yM5BGOoVG3n75zdNKS6+QVUAjdz6eoXF2W1elNWcxL2ztrH3EZjMcjMS2II
# S5vzWRdfQ1WeCuQ3tHXuXAALQDgIqY3lC/TEvo6MJNtiNEpKW3ED3cYoYjRFwIgi
# DF4tvtFdPep9Q4gH23JwKOU7h6So3E6re/ESDoPmeeRrXD9sq5Nwf5JowcZgaVdq
# 9ODeMZ6Ge2so8ucqkFA05i12fyaCY+742OV3RE+bSMtyRik0KboWUJ4j2VwNxgty
# jfBBM13iZRSZ242eiw0=
# SIG # End signature block
