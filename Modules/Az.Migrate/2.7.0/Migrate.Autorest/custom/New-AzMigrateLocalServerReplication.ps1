
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
Starts replication for the specified server.
.Description
The New-AzMigrateLocalServerReplication cmdlet starts the replication for a particular discovered server in the Azure Migrate project.
.Link
https://learn.microsoft.com/powershell/module/az.migrate/new-azmigratelocalserverreplication
#>
function New-AzMigrateLocalServerReplication {
    [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Runtime.PreviewMessageAttribute("This cmdlet is using a preview API version and is subject to breaking change in a future release.")]
    [OutputType([Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.IJobModel])]
    [CmdletBinding(DefaultParameterSetName = 'ByIdDefaultUser', PositionalBinding = $false, SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [Parameter(ParameterSetName = 'ByIdDefaultUser', Mandatory)]
        [Parameter(ParameterSetName = 'ByIdPowerUser', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the machine ARM ID of the discovered server to be migrated.
        ${MachineId}, 

        [Parameter(Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the storage path ARM ID where the VMs will be stored.
        ${TargetStoragePathId},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.Int32]
        # Specifies the number of CPU cores.
        ${TargetVMCPUCore},

        [Parameter(ParameterSetName = 'ByIdDefaultUser', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the logical network ARM ID that the VMs will use. 
        ${TargetVirtualSwitchId},

        [Parameter(ParameterSetName = 'ByIdDefaultUser')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the test logical network ARM ID that the VMs will use. 
        ${TargetTestVirtualSwitchId},

        [Parameter()]
        [ValidateSet("true" , "false")]
        [ArgumentCompleter( { "true" , "false" })]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies if RAM is dynamic or not. 
        ${IsDynamicMemoryEnabled},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.Int64]
        # Specifies the target RAM size in MB. 
        ${TargetVMRam},

        [Parameter(ParameterSetName = 'ByIdPowerUser', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.AzLocalDiskInput[]]
        # Specifies the disks on the source server to be included for replication.
        ${DiskToInclude},

        [Parameter(ParameterSetName = 'ByIdPowerUser', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.AzLocalNicInput[]]
        # Specifies the NICs on the source server to be included for replication.
        ${NicToInclude},

        [Parameter(Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the target Resource Group Id where the migrated VM resources will reside.
        ${TargetResourceGroupId},

        [Parameter(Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the name of the VM to be created.
        ${TargetVMName},

        [Parameter(ParameterSetName = 'ByIdDefaultUser', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the Operating System disk for the source server to be migrated.
        ${OSDiskID},
    
        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Runtime.DefaultInfo(Script = '(Get-AzContext).Subscription.Id')]
        [System.String]
        # Azure Subscription ID.
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
        Import-Module $PSScriptRoot\Helper\CommonHelper.ps1

        CheckResourceGraphModuleDependency
        CheckResourcesModuleDependency

        $HasTargetVMCPUCore = $PSBoundParameters.ContainsKey('TargetVMCPUCore')
        $HasIsDynamicMemoryEnabled = $PSBoundParameters.ContainsKey('IsDynamicMemoryEnabled')
        if ($HasIsDynamicMemoryEnabled) {
            $isDynamicRamEnabled = [System.Convert]::ToBoolean($IsDynamicMemoryEnabled)
        }
        $HasTargetVMRam = $PSBoundParameters.ContainsKey('TargetVMRam')
        $HasTargetTestVirtualSwitchId = $PSBoundParameters.ContainsKey('TargetTestVirtualSwitchId')
        $parameterSet = $PSCmdlet.ParameterSetName

        $null = $PSBoundParameters.Remove('TargetVMCPUCore')
        $null = $PSBoundParameters.Remove('IsDynamicMemoryEnabled')
        $null = $PSBoundParameters.Remove('TargetVMRam')
        $null = $PSBoundParameters.Remove('DiskToInclude')
        $null = $PSBoundParameters.Remove('NicToInclude')
        $null = $PSBoundParameters.Remove('TargetResourceGroupId')
        $null = $PSBoundParameters.Remove('TargetVMName')
        $null = $PSBoundParameters.Remove('TargetVirtualSwitchId')
        $null = $PSBoundParameters.Remove('TargetTestVirtualSwitchId')
        $null = $PSBoundParameters.Remove('TargetStoragePathId')
        $null = $PSBoundParameters.Remove('OSDiskID')
        $null = $PSBoundParameters.Remove('MachineId')
        $null = $PSBoundParameters.Remove('WhatIf')
        $null = $PSBoundParameters.Remove('Confirm')
        
        $MachineIdArray = $MachineId.Split("/")
        $SiteType = $MachineIdArray[7]
        $SiteName = $MachineIdArray[8]
        $ResourceGroupName = $MachineIdArray[4]
        $MachineName = $MachineIdArray[10]
       
        if (($SiteType -ne $SiteTypes.HyperVSites) -and ($SiteType -ne $SiteTypes.VMwareSites)) {
            throw "Site type is not supported. Site type '$SiteType'. Check MachineId provided."
        }

        # Get the source site and the discovered machine
        $null = $PSBoundParameters.Add("ResourceGroupName", $ResourceGroupName)
        $null = $PSBoundParameters.Add("SiteName", $SiteName)
        $null = $PSBoundParameters.Add("MachineName", $MachineName)
        
        if ($SiteType -eq $SiteTypes.HyperVSites) {
            $instanceType = $AzLocalInstanceTypes.HyperVToAzLocal
            $machine = InvokeAzMigrateGetCommandWithRetries `
                -CommandName 'Az.Migrate.Internal\Get-AzMigrateHyperVMachine' `
                -Parameters $PSBoundParameters `
                -ErrorMessage "Machine '$MachineName' not found in resource group '$ResourceGroupName' and site '$SiteName'."

            $null = $PSBoundParameters.Remove('MachineName')

            $siteObject = InvokeAzMigrateGetCommandWithRetries `
                -CommandName 'Az.Migrate.Internal\Get-AzMigrateHyperVSite' `
                -Parameters $PSBoundParameters `
                -ErrorMessage "Machine site '$SiteName' with Type '$SiteType' not found."
        }
        elseif ($SiteType -eq $SiteTypes.VMwareSites) {
            $instanceType = $AzLocalInstanceTypes.VMwareToAzLocal
            $machine = InvokeAzMigrateGetCommandWithRetries `
                -CommandName 'Az.Migrate.Internal\Get-AzMigrateMachine' `
                -Parameters $PSBoundParameters `
                -ErrorMessage "Machine '$MachineName' not found in resource group '$ResourceGroupName' and site '$SiteName'."

            $null = $PSBoundParameters.Remove('MachineName')

            $siteObject = InvokeAzMigrateGetCommandWithRetries `
                -CommandName 'Az.Migrate\Get-AzMigrateSite' `
                -Parameters $PSBoundParameters `
                -ErrorMessage "Machine site '$SiteName' with Type '$SiteType' not found."
        }

        # $siteObject is not null or exception would have been thrown
        $ProjectName = $siteObject.DiscoverySolutionId.Split("/")[8]

        $null = $PSBoundParameters.Remove('SiteName')

        # Get the migrate solution.
        $amhSolutionName = "Servers-Migration-ServerMigration_DataReplication"
        $null = $PSBoundParameters.Add("Name", $amhSolutionName)
        $null = $PSBoundParameters.Add("MigrateProjectName", $ProjectName)

        $solution = InvokeAzMigrateGetCommandWithRetries `
            -CommandName 'Az.Migrate\Get-AzMigrateSolution' `
            -Parameters $PSBoundParameters `
            -ErrorMessage "No Data Replication Service Solution '$amhSolutionName' found in resource group '$ResourceGroupName' and project '$ProjectName'. Please verify your appliance setup."
        
        $null = $PSBoundParameters.Remove('ResourceGroupName')
        $null = $PSBoundParameters.Remove("Name")
        $null = $PSBoundParameters.Remove("MigrateProjectName")
        
        $VaultName = $solution.DetailExtendedDetail.AdditionalProperties.vaultId.Split("/")[8]
        if ([string]::IsNullOrEmpty($VaultName)) {
            throw "Azure Migrate Project not configured: missing replication vault. Setup Azure Migrate Project and run the Initialize-AzMigrateLocalReplicationInfrastructure script before proceeding."
        }
        
        # Get fabrics and appliances in the project
        $allFabrics = Az.Migrate\Get-AzMigrateLocalReplicationFabric -ResourceGroupName $ResourceGroupName
        foreach ($fabric in $allFabrics) {
            if ($fabric.Property.CustomProperty.MigrationSolutionId -ne $solution.Id) {
                continue
            }

            if ($fabric.Property.CustomProperty.InstanceType -ceq $FabricInstanceTypes.HyperVInstance) {
                $sourceFabric = $fabric
            }
            elseif ($fabric.Property.CustomProperty.InstanceType -ceq $FabricInstanceTypes.VmwareInstance) {
                $sourceFabric = $fabric
            }
            elseif ($fabric.Property.CustomProperty.InstanceType -ceq $FabricInstanceTypes.AzLocalInstance) {
                $targetFabric = $fabric
            }
        }

        if ($null -eq $sourceFabric) {
            throw "No connected source appliances are found. Kindly deploy an appliance by completing the Discover step of the migration jounery on the source cluster."
        }

        if ($null -eq $targetFabric) {
            throw "A target appliance is not available for the target cluster. Deploy and configure a new appliance for the cluster, or select a different cluster."
        }

        # Get Source and Target Dras
        $sourceDras = InvokeAzMigrateGetCommandWithRetries `
            -CommandName 'Az.Migrate.Internal\Get-AzMigrateFabricAgent' `
            -Parameters @{ FabricName = $sourceFabric.Name; ResourceGroupName = $ResourceGroupName } `
            -ErrorMessage "No connected source appliances are found. Kindly deploy an appliance by completing the Discover step of the migration jounery on the source cluster."

        $sourceDra = $sourceDras[0]

        $targetDras = InvokeAzMigrateGetCommandWithRetries `
            -CommandName 'Az.Migrate.Internal\Get-AzMigrateFabricAgent' `
            -Parameters @{ FabricName = $targetFabric.Name; ResourceGroupName = $ResourceGroupName } `
            -ErrorMessage "No connected target appliances are found. Deploy and configure a new appliance for the target cluster, or select a different cluster."

        $targetDra = $targetDras[0]

        # Validate Policy
        $policyName = $vaultName + $instanceType + "policy"
        $policy = InvokeAzMigrateGetCommandWithRetries `
            -CommandName 'Az.Migrate.Internal\Get-AzMigratePolicy' `
            -Parameters @{ ResourceGroupName = $ResourceGroupName; Name = $policyName; VaultName = $vaultName; SubscriptionId = $SubscriptionId } `
            -ErrorMessage "The replication policy '$policyName' not found. The replication infrastructure is not initialized. Run the Initialize-AzMigrateLocalReplicationInfrastructure script again."

        # Validate Replication Extension
        $replicationExtensionName = ($sourceFabric.Id -split '/')[-1] + "-" + ($targetFabric.Id -split '/')[-1] + "-MigReplicationExtn"
        $replicationExtension = InvokeAzMigrateGetCommandWithRetries `
            -CommandName 'Az.Migrate.Internal\Get-AzMigrateReplicationExtension' `
            -Parameters @{ ResourceGroupName = $ResourceGroupName; Name = $replicationExtensionName; VaultName = $vaultName; SubscriptionId = $SubscriptionId } `
            -ErrorMessage "The replication extension '$replicationExtensionName' not found. The replication infrastructure is not initialized. Run the Initialize-AzMigrateLocalReplicationInfrastructure script again."
        
        $targetClusterId = $targetFabric.Property.CustomProperty.Cluster.ResourceName
        $targetClusterIdArray = $targetClusterId.Split("/")
        $targetSubscription = $targetClusterIdArray[2]

        # Get Target cluster
        $hciClusterArgQuery = GetHCIClusterARGQuery -HCIClusterID $targetClusterId
        $targetCluster = Az.ResourceGraph\Search-AzGraph -Query $hciClusterArgQuery -Subscription $targetSubscription
        if ($null -eq $targetCluster) {
            throw "Validate target cluster with id '$targetClusterId' exists. Check ARC resource bridge is running on this cluster."
        }
            
        # Get source appliance RunAsAccount
        if ($SiteType -eq $SiteTypes.HyperVSites) {
            $runAsAccounts = InvokeAzMigrateGetCommandWithRetries `
                -CommandName 'Az.Migrate.Internal\Get-AzMigrateHyperVRunAsAccount' `
                -Parameters @{ ResourceGroupName = $ResourceGroupName; SiteName = $SiteName; SubscriptionId = $SubscriptionId } `
                -ErrorMessage "No run as account found for site '$SiteName'."

            $runAsAccount = $runAsAccounts | Where-Object { $_.CredentialType -eq $RunAsAccountCredentialTypes.HyperVFabric }
        }
        elseif ($SiteType -eq $SiteTypes.VMwareSites) {
            $runAsAccounts = InvokeAzMigrateGetCommandWithRetries `
                -CommandName 'Az.Migrate\Get-AzMigrateRunAsAccount' `
                -Parameters @{ ResourceGroupName = $ResourceGroupName; SiteName = $SiteName; SubscriptionId = $SubscriptionId } `
                -ErrorMessage "No run as account found for site '$SiteName'."

            $runAsAccount = $runAsAccounts | Where-Object { $_.CredentialType -eq $RunAsAccountCredentialTypes.VMwareFabric }
        }

        # Validate TargetVMName
        if ($TargetVMName.length -gt 64 -or $TargetVMName.length -eq 0) {
            throw "The target virtual machine name must be between 1 and 64 characters long."
        }

        if ($TargetVMName -notmatch "^[^_\W][a-zA-Z0-9\-]{0,63}(?<![-._])$") {
            throw "The target virtual machine name must begin with a letter or number, and can contain only letters, numbers, or hyphens(-). The names cannot contain special characters \/""[]:|<>+=;,?*@&, whitespace, or begin with '_' or end with '.' or '-'."
        }

        if (IsReservedOrTrademarked($TargetVMName)) {
            throw "The target virtual machine name '$TargetVMName' or part of the name is a trademarked or reserved word."
        }

        $protectedItemProperties = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.ProtectedItemModelProperties]::new()
        $protectedItemProperties.PolicyName = $policyName
        $protectedItemProperties.ReplicationExtensionName = $replicationExtensionName

        if ($SiteType -eq $SiteTypes.HyperVSites) {     
            $customProperties = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.HyperVToAzStackHCIProtectedItemModelCustomProperties]::new()
            $isSourceDynamicMemoryEnabled = $machine.IsDynamicMemoryEnabled
        }
        elseif ($SiteType -eq $SiteTypes.VMwareSites) {  
            $customProperties = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.VMwareToAzStackHCIProtectedItemModelCustomProperties]::new()
            $isSourceDynamicMemoryEnabled = $false
        }

        $customProperties.InstanceType = $instanceType
        $customProperties.CustomLocationRegion = $targetCluster.CustomLocationRegion
        $customProperties.FabricDiscoveryMachineId = $machine.Id
        $customProperties.RunAsAccountId = $runAsAccount.Id
        $customProperties.SourceFabricAgentName = $sourceDra.Name
        $customProperties.StorageContainerId = $TargetStoragePathId
        $customProperties.TargetArcClusterCustomLocationId = $targetCluster.CustomLocation
        $customProperties.TargetFabricAgentName = $targetDra.Name
        $customProperties.TargetHciClusterId = $targetClusterId
        $customProperties.TargetResourceGroupId = $TargetResourceGroupId
        $customProperties.TargetVMName = $TargetVMName
        $customProperties.HyperVGeneration = if ($SiteType -eq $SiteTypes.HyperVSites) { $machine.Generation } else { "1" }
        $customProperties.TargetCpuCore = if ($HasTargetVMCPUCore) { $TargetVMCPUCore } else { $machine.NumberOfProcessorCore }
        $customProperties.IsDynamicRam = if ($HasIsDynamicMemoryEnabled) { $isDynamicRamEnabled } else {  $isSourceDynamicMemoryEnabled }
    
        # Determine target VM Hyper-V Generation
        if ($SiteType -eq $SiteTypes.HyperVSites) { 
            # Hyper-V source
            $customProperties.HyperVGeneration = $machine.Generation
        }
        else { 
            #Vmware source, non-BOIS VMs will be migrated to Gen2
            $customProperties.HyperVGeneration = if ($machine.Firmware -ieq "BIOS") { "1" } else { "2" }
        }

        # Validate TargetVMRam
        if ($HasTargetVMRam) {
            # TargetVMRam needs to be greater than 0
            if ($TargetVMRam -le 0) {
                throw "Specify target RAM greater than 0"    
            }

            $customProperties.TargetMemoryInMegaByte = $TargetVMRam 
        }
        else
        {
            $customProperties.TargetMemoryInMegaByte = [System.Math]::Max($machine.AllocatedMemoryInMB, $RAMConfig.MinTargetMemoryInMB)
        }

        # Construct default dynamic memory config
        $memoryConfig = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.ProtectedItemDynamicMemoryConfig]::new()
        $memoryConfig.MinimumMemoryInMegaByte = [System.Math]::Min($customProperties.TargetMemoryInMegaByte, $RAMConfig.DefaultMinDynamicMemoryInMB)
        $memoryConfig.MaximumMemoryInMegaByte = [System.Math]::Max($customProperties.TargetMemoryInMegaByte, $RAMConfig.DefaultMaxDynamicMemoryInMB)
        $memoryConfig.TargetMemoryBufferPercentage = $RAMConfig.DefaultTargetMemoryBufferPercentage

        $customProperties.DynamicMemoryConfig = $memoryConfig
        
        # Disks and Nics
        [PSCustomObject[]]$disks = @()
        [PSCustomObject[]]$nics = @()
        if ($parameterSet -match 'DefaultUser') {
            if ($SiteType -eq $SiteTypes.HyperVSites) {
                $osDisk = $machine.Disk | Where-Object { $_.InstanceId -eq $OSDiskID }
                if ($null -eq $osDisk) {
                    throw "No Disk found with InstanceId '$OSDiskID' from discovered machine disks."
                }

                $diskName = Split-Path $osDisk.Path -leaf
                if (IsReservedOrTrademarked($diskName)) {
                    throw "The disk name '$diskName' or part of the name is a trademarked or reserved word."
                }
            }
            elseif ($SiteType -eq $SiteTypes.VMwareSites) {  
                $osDisk = $machine.Disk | Where-Object { $_.Uuid -eq $OSDiskID }
                if ($null -eq $osDisk) {
                    throw "No Disk found with Uuid '$OSDiskID' from discovered machine disks."
                }

                $diskName = Split-Path $osDisk.Path -leaf
                if (IsReservedOrTrademarked($diskName)) {
                    throw "The disk name '$diskName' or part of the name is a trademarked or reserved word."
                }
            }

            foreach ($sourceDisk in $machine.Disk) {
                $diskId = if ($SiteType -eq $SiteTypes.HyperVSites) { $sourceDisk.InstanceId } else { $sourceDisk.Uuid }
                $diskSize = if ($SiteType -eq $SiteTypes.HyperVSites) { $sourceDisk.MaxSizeInByte } else { $sourceDisk.MaxSizeInBytes }

                $DiskObject = [PSCustomObject]@{
                    DiskId         = $diskId
                    DiskSizeGb     = [long] [Math]::Ceiling($diskSize / 1GB)
                    DiskFileFormat = "VHDX"
                    IsDynamic      = $true
                    IsOSDisk       = $diskId -eq $OSDiskID
                }
                
                $disks += $DiskObject
            }
            
            foreach ($sourceNic in $machine.NetworkAdapter) {
                $NicObject = [PSCustomObject]@{
                    NicId                    = $sourceNic.NicId
                    TargetNetworkId          = $TargetVirtualSwitchId
                    TestNetworkId            = if ($HasTargetTestVirtualSwitchId) { $TargetTestVirtualSwitchId } else { $TargetVirtualSwitchId }
                    SelectionTypeForFailover = $VMNicSelection.SelectedByUser
                }
                $nics += $NicObject
            }
        }
        else
        {
            # PowerUser
            if ($null -eq $DiskToInclude -or $DiskToInclude.length -eq 0) {
                throw "Invalid DiskToInclude. At least one disk is required."
            }

            # Validate OSDisk is set.
            $osDisk = $DiskToInclude | Where-Object { $_.IsOSDisk }
            if (($null -eq $osDisk) -or ($osDisk.length -ne 1)) {
                throw "Invalid DiskToInclude. One disk must be designated as the OS disk."
            }
            
            # Validate DiskToInclude
            [PSCustomObject[]]$uniqueDisks = @()
            foreach ($disk in $DiskToInclude) {
                if ($SiteType -eq $SiteTypes.HyperVSites) {
                    $discoveredDisk = $machine.Disk | Where-Object { $_.InstanceId -eq $disk.DiskId }
                    if ($null -eq $discoveredDisk) {
                        throw "No Disk found with InstanceId '$($disk.DiskId)' from discovered machine disks."
                    }
                }
                elseif ($SiteType -eq $SiteTypes.VMwareSites) {  
                    $discoveredDisk = $machine.Disk | Where-Object { $_.Uuid -eq $disk.DiskId }
                    if ($null -eq $discoveredDisk) {
                        throw "No Disk found with Uuid '$($disk.DiskId)' from discovered machine disks."
                    }
                }

                $diskName = Split-Path -Path $discoveredDisk.Path -Leaf
                if (IsReservedOrTrademarked($diskName)) {
                    throw "The disk name '$diskName' or part of the name is a trademarked or reserved word."
                }

                if ($uniqueDisks.Contains($disk.DiskId)) {
                    throw "The disk id '$($disk.DiskId)' is already taken."
                }
                $uniqueDisks += $disk.DiskId

                $htDisk = @{}
                $disk.PSObject.Properties | ForEach-Object { $htDisk[$_.Name] = $_.Value }
                $disks += [PSCustomObject]$htDisk
            }

            # Validate NicToInclude
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
                    throw throw "The TargetVirtualSwitchId parameter is required when the CreateAtTarget flag is set to 'true'. NIC '$($htNic.NicId)'. Please utilize the New-AzMigrateLocalNicMappingObject command to properly create a Nic mapping object."
                }

                $nics += [PSCustomObject]$htNic
            }
        }

        if ($SiteType -eq $SiteTypes.HyperVSites) {     
            $customProperties.DisksToInclude = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.HyperVToAzStackHCIDiskInput[]]$disks
            $customProperties.NicsToInclude = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.HyperVToAzStackHCINicInput[]]$nics
        }
        elseif ($SiteType -eq $SiteTypes.VMwareSites) {     
            $customProperties.DisksToInclude = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.VMwareToAzStackHCIDiskInput[]]$disks
            $customProperties.NicsToInclude = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.VMwareToAzStackHCINicInput[]]$nics
        }
        
        $protectedItemProperties.CustomProperty = $customProperties

        if ($PSCmdlet.ShouldProcess($MachineId, "Replicate VM.")) {
            $null = $PSBoundParameters.Add('ResourceGroupName', $ResourceGroupName)
            $null = $PSBoundParameters.Add('VaultName', $vaultName)
            $null = $PSBoundParameters.Add('Name', $MachineName)
            $null = $PSBoundParameters.Add('Property', $protectedItemProperties)
            $null = $PSBoundParameters.Add('NoWait', $true)
            
            $operation = Az.Migrate.Internal\New-AzMigrateProtectedItem @PSBoundParameters
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
# MIIoUgYJKoZIhvcNAQcCoIIoQzCCKD8CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAwZ3aqCdG9IA/C
# HGYs83aaZrxeVJybiaH0ylK+AAm3iaCCDYUwggYDMIID66ADAgECAhMzAAAEA73V
# lV0POxitAAAAAAQDMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjQwOTEyMjAxMTEzWhcNMjUwOTExMjAxMTEzWjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQCfdGddwIOnbRYUyg03O3iz19XXZPmuhEmW/5uyEN+8mgxl+HJGeLGBR8YButGV
# LVK38RxcVcPYyFGQXcKcxgih4w4y4zJi3GvawLYHlsNExQwz+v0jgY/aejBS2EJY
# oUhLVE+UzRihV8ooxoftsmKLb2xb7BoFS6UAo3Zz4afnOdqI7FGoi7g4vx/0MIdi
# kwTn5N56TdIv3mwfkZCFmrsKpN0zR8HD8WYsvH3xKkG7u/xdqmhPPqMmnI2jOFw/
# /n2aL8W7i1Pasja8PnRXH/QaVH0M1nanL+LI9TsMb/enWfXOW65Gne5cqMN9Uofv
# ENtdwwEmJ3bZrcI9u4LZAkujAgMBAAGjggGCMIIBfjAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQU6m4qAkpz4641iK2irF8eWsSBcBkw
# VAYDVR0RBE0wS6RJMEcxLTArBgNVBAsTJE1pY3Jvc29mdCBJcmVsYW5kIE9wZXJh
# dGlvbnMgTGltaXRlZDEWMBQGA1UEBRMNMjMwMDEyKzUwMjkyNjAfBgNVHSMEGDAW
# gBRIbmTlUAXTgqoXNzcitW2oynUClTBUBgNVHR8ETTBLMEmgR6BFhkNodHRwOi8v
# d3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NybC9NaWNDb2RTaWdQQ0EyMDExXzIw
# MTEtMDctMDguY3JsMGEGCCsGAQUFBwEBBFUwUzBRBggrBgEFBQcwAoZFaHR0cDov
# L3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jZXJ0cy9NaWNDb2RTaWdQQ0EyMDEx
# XzIwMTEtMDctMDguY3J0MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQADggIB
# AFFo/6E4LX51IqFuoKvUsi80QytGI5ASQ9zsPpBa0z78hutiJd6w154JkcIx/f7r
# EBK4NhD4DIFNfRiVdI7EacEs7OAS6QHF7Nt+eFRNOTtgHb9PExRy4EI/jnMwzQJV
# NokTxu2WgHr/fBsWs6G9AcIgvHjWNN3qRSrhsgEdqHc0bRDUf8UILAdEZOMBvKLC
# rmf+kJPEvPldgK7hFO/L9kmcVe67BnKejDKO73Sa56AJOhM7CkeATrJFxO9GLXos
# oKvrwBvynxAg18W+pagTAkJefzneuWSmniTurPCUE2JnvW7DalvONDOtG01sIVAB
# +ahO2wcUPa2Zm9AiDVBWTMz9XUoKMcvngi2oqbsDLhbK+pYrRUgRpNt0y1sxZsXO
# raGRF8lM2cWvtEkV5UL+TQM1ppv5unDHkW8JS+QnfPbB8dZVRyRmMQ4aY/tx5x5+
# sX6semJ//FbiclSMxSI+zINu1jYerdUwuCi+P6p7SmQmClhDM+6Q+btE2FtpsU0W
# +r6RdYFf/P+nK6j2otl9Nvr3tWLu+WXmz8MGM+18ynJ+lYbSmFWcAj7SYziAfT0s
# IwlQRFkyC71tsIZUhBHtxPliGUu362lIO0Lpe0DOrg8lspnEWOkHnCT5JEnWCbzu
# iVt8RX1IV07uIveNZuOBWLVCzWJjEGa+HhaEtavjy6i7MIIHejCCBWKgAwIBAgIK
# YQ6Q0gAAAAAAAzANBgkqhkiG9w0BAQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlm
# aWNhdGUgQXV0aG9yaXR5IDIwMTEwHhcNMTEwNzA4MjA1OTA5WhcNMjYwNzA4MjEw
# OTA5WjB+MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSgwJgYD
# VQQDEx9NaWNyb3NvZnQgQ29kZSBTaWduaW5nIFBDQSAyMDExMIICIjANBgkqhkiG
# 9w0BAQEFAAOCAg8AMIICCgKCAgEAq/D6chAcLq3YbqqCEE00uvK2WCGfQhsqa+la
# UKq4BjgaBEm6f8MMHt03a8YS2AvwOMKZBrDIOdUBFDFC04kNeWSHfpRgJGyvnkmc
# 6Whe0t+bU7IKLMOv2akrrnoJr9eWWcpgGgXpZnboMlImEi/nqwhQz7NEt13YxC4D
# dato88tt8zpcoRb0RrrgOGSsbmQ1eKagYw8t00CT+OPeBw3VXHmlSSnnDb6gE3e+
# lD3v++MrWhAfTVYoonpy4BI6t0le2O3tQ5GD2Xuye4Yb2T6xjF3oiU+EGvKhL1nk
# kDstrjNYxbc+/jLTswM9sbKvkjh+0p2ALPVOVpEhNSXDOW5kf1O6nA+tGSOEy/S6
# A4aN91/w0FK/jJSHvMAhdCVfGCi2zCcoOCWYOUo2z3yxkq4cI6epZuxhH2rhKEmd
# X4jiJV3TIUs+UsS1Vz8kA/DRelsv1SPjcF0PUUZ3s/gA4bysAoJf28AVs70b1FVL
# 5zmhD+kjSbwYuER8ReTBw3J64HLnJN+/RpnF78IcV9uDjexNSTCnq47f7Fufr/zd
# sGbiwZeBe+3W7UvnSSmnEyimp31ngOaKYnhfsi+E11ecXL93KCjx7W3DKI8sj0A3
# T8HhhUSJxAlMxdSlQy90lfdu+HggWCwTXWCVmj5PM4TasIgX3p5O9JawvEagbJjS
# 4NaIjAsCAwEAAaOCAe0wggHpMBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBRI
# bmTlUAXTgqoXNzcitW2oynUClTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTAL
# BgNVHQ8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBRyLToCMZBD
# uRQFTuHqp8cx0SOJNDBaBgNVHR8EUzBRME+gTaBLhklodHRwOi8vY3JsLm1pY3Jv
# c29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFf
# MDNfMjIuY3JsMF4GCCsGAQUFBwEBBFIwUDBOBggrBgEFBQcwAoZCaHR0cDovL3d3
# dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFf
# MDNfMjIuY3J0MIGfBgNVHSAEgZcwgZQwgZEGCSsGAQQBgjcuAzCBgzA/BggrBgEF
# BQcCARYzaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9kb2NzL3ByaW1h
# cnljcHMuaHRtMEAGCCsGAQUFBwICMDQeMiAdAEwAZQBnAGEAbABfAHAAbwBsAGkA
# YwB5AF8AcwB0AGEAdABlAG0AZQBuAHQALiAdMA0GCSqGSIb3DQEBCwUAA4ICAQBn
# 8oalmOBUeRou09h0ZyKbC5YR4WOSmUKWfdJ5DJDBZV8uLD74w3LRbYP+vj/oCso7
# v0epo/Np22O/IjWll11lhJB9i0ZQVdgMknzSGksc8zxCi1LQsP1r4z4HLimb5j0b
# pdS1HXeUOeLpZMlEPXh6I/MTfaaQdION9MsmAkYqwooQu6SpBQyb7Wj6aC6VoCo/
# KmtYSWMfCWluWpiW5IP0wI/zRive/DvQvTXvbiWu5a8n7dDd8w6vmSiXmE0OPQvy
# CInWH8MyGOLwxS3OW560STkKxgrCxq2u5bLZ2xWIUUVYODJxJxp/sfQn+N4sOiBp
# mLJZiWhub6e3dMNABQamASooPoI/E01mC8CzTfXhj38cbxV9Rad25UAqZaPDXVJi
# hsMdYzaXht/a8/jyFqGaJ+HNpZfQ7l1jQeNbB5yHPgZ3BtEGsXUfFL5hYbXw3MYb
# BL7fQccOKO7eZS/sl/ahXJbYANahRr1Z85elCUtIEJmAH9AAKcWxm6U/RXceNcbS
# oqKfenoi+kiVH6v7RyOA9Z74v2u3S5fi63V4GuzqN5l5GEv/1rMjaHXmr/r8i+sL
# gOppO6/8MO0ETI7f33VtY5E90Z1WTk+/gFcioXgRMiF670EKsT/7qMykXcGhiJtX
# cVZOSEXAQsmbdlsKgEhr/Xmfwb1tbWrJUnMTDXpQzTGCGiMwghofAgEBMIGVMH4x
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01p
# Y3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTECEzMAAAQDvdWVXQ87GK0AAAAA
# BAMwDQYJYIZIAWUDBAIBBQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIOrF
# 7hm77S2NWrLhjS0wjRtA6FJM4BXBHO8eCyGKuW1JMEIGCisGAQQBgjcCAQwxNDAy
# oBSAEgBNAGkAYwByAG8AcwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20wDQYJKoZIhvcNAQEBBQAEggEAXBbVUuyEgOtwSWWxqlORv4kK+/iYoiAV/TXv
# 9ot5YfjBX8hUVUvyj2J5VtEp08MV080y3JFywGGXyUJeM8+3uD5JIOx8xayQFSlD
# UvACoUzXBjSBspPs5ERPd6ZkxHXToSZlAxX0ZR4luBId1mv0lQATjfCS2+szqDMG
# P64LPgwck7C/HR0qyXkyPQfVlgCvPYKUIcD6W2K3cB0CrTePXTORDCUcyuEonZ1h
# ZNqAC8QosKq6OgKSnz2yxeBtfPDeU2L9coAL/8AvHeWXXIsOgz6FWc25srNTa8yQ
# ZAIY+aYwIFkdOHztV2PZjuZpU3CoB6llWJDA+LyNbZo+eV1LgaGCF60wghepBgor
# BgEEAYI3AwMBMYIXmTCCF5UGCSqGSIb3DQEHAqCCF4YwgheCAgEDMQ8wDQYJYIZI
# AWUDBAIBBQAwggFaBgsqhkiG9w0BCRABBKCCAUkEggFFMIIBQQIBAQYKKwYBBAGE
# WQoDATAxMA0GCWCGSAFlAwQCAQUABCAppbOvDISe3pki5h0gjnJiUC/wvyTGLhDk
# V/DLw47jHAIGZ7YoK31aGBMyMDI1MDIyNTA3MDMzMC45MDdaMASAAgH0oIHZpIHW
# MIHTMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQL
# EyRNaWNyb3NvZnQgSXJlbGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJzAlBgNVBAsT
# Hm5TaGllbGQgVFNTIEVTTjo1OTFBLTA1RTAtRDk0NzElMCMGA1UEAxMcTWljcm9z
# b2Z0IFRpbWUtU3RhbXAgU2VydmljZaCCEfswggcoMIIFEKADAgECAhMzAAAB9BdG
# hcDLPznlAAEAAAH0MA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFBDQSAyMDEwMB4XDTI0MDcyNTE4MzA1OVoXDTI1MTAyMjE4MzA1OVowgdMxCzAJ
# BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xLTArBgNVBAsTJE1pY3Jv
# c29mdCBJcmVsYW5kIE9wZXJhdGlvbnMgTGltaXRlZDEnMCUGA1UECxMeblNoaWVs
# ZCBUU1MgRVNOOjU5MUEtMDVFMC1EOTQ3MSUwIwYDVQQDExxNaWNyb3NvZnQgVGlt
# ZS1TdGFtcCBTZXJ2aWNlMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA
# pwhOE6bQgC9qq4jJGX2A1yoObfk0qetQ8kkj+5m37WBxDlsZ5oJnjfzHspqPiOEV
# zZ2y2ygGgNZ3/xdZQN7f9A1Wp1Adh5qHXZZh3SBX8ABuc69Tb3cJ5KCZcXDsufwm
# XeCj81EzJEIZquVdV8STlQueB/b1MIYt5RKis3uwzdlfSl0ckHbGzoO91YTKg6IE
# xqKYojGreCopnIKxOvkr5VZsj2f95Bb1LGEvuhBIm/C7JysvJvBZWNtrspzyXVnu
# o+kDEyZwpkphsR8Zvdi+s/pQiofmdbW1UqzWlqXQVgoYXbaYkEyaSh/heBtwj1tu
# e+LcuOcHAPgbwZvQLksKaK46oktregOR4e0icsGiAWR9IL+ny4mlCUNA84F7GEEW
# OEvibig7wsrTa6ZbzuMsyTi2Az4qPV3QRkFgxSbp4R4OEKnin8Jz4XLI1wXhBhIp
# MGfA3BT850nqamzSiD5L5px+VtfCi0MJTS2LDF1PaVZwlyVZIVjVHK8oh2HYG9T2
# 6FjR9/I85i5ExxmhHpxM2Z+UhJeZA6Lz452m/+xrA4xrdYas5cm7FUhy24rPLVH+
# Fy+ZywHAp9c9oWTrtjfIKqLIvYtgJc41Q8WxbZPR7B1uft8BFsvz2dOSLkxPDLcX
# Wy16ANy73v0ipCxAwUEC9hssi0LdB8ThiNf/4A+RZ8sCAwEAAaOCAUkwggFFMB0G
# A1UdDgQWBBQrdGWhCtEsPid1LJzsTaLTKQbfmzAfBgNVHSMEGDAWgBSfpxVdAF5i
# XYP05dJlpxtTNRnpcjBfBgNVHR8EWDBWMFSgUqBQhk5odHRwOi8vd3d3Lm1pY3Jv
# c29mdC5jb20vcGtpb3BzL2NybC9NaWNyb3NvZnQlMjBUaW1lLVN0YW1wJTIwUENB
# JTIwMjAxMCgxKS5jcmwwbAYIKwYBBQUHAQEEYDBeMFwGCCsGAQUFBzAChlBodHRw
# Oi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMFRp
# bWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNydDAMBgNVHRMBAf8EAjAAMBYGA1Ud
# JQEB/wQMMAoGCCsGAQUFBwMIMA4GA1UdDwEB/wQEAwIHgDANBgkqhkiG9w0BAQsF
# AAOCAgEA3cHSDxJKUDsgacIfRX60ugODShsBqwtEURUbUXeDmYYSa5oFj34RujW3
# gOeCt/ObDO45vfpnYG5OS5YowwsFw19giCI6JV+ccG/qqM08nxASbzwWtqtorzQi
# Jh9upsE4TVZeKYXmbyx7WN9tdbVIrCelVj7P6ifMHTSLt6BmyoS2xlC2cfgKPPA1
# 3vS3euqUl6zwe7GAhjfjNXjKlE4SNWJvdqgrv0GURKjqmamNvhmSJane6TYzpdDC
# egq8adlGH85I1EWKmfERb1lzKy5OMO2e9IkAlvydpUun0C3sNEtp0ehliT0Sraq8
# jcYVDH4A2C/MbLBIwikjwiFGQ4SlFLT2Tgb4GvvpcWVzBxwDo9IRBwpzngbyzbhh
# 95UVOrQL2rbWHrHDSE3dgdL2yuaHRgY7HYYLs5Lts30wU9Ouh8N54RUta6GFZFx5
# A4uITgyJcVdWVaN0qjs0eEjwEyNUv0cRLuHWJBejkMe3qRAhvCjnhro7DGRWaIld
# yfzZqln6FsnLQ3bl+ZvVJWTYJuL+IZLI2Si3IrIRfjccn29X2BX/vz2KcYubIjK6
# XfYvrZQN4XKbnvSqBNAwIPY2xJeB4o9PDEFI2rcPaLUyz5IV7JP3JRpgg3xsUqvF
# HlSG6uMIWjwH0GQIIwrC2zRy+lNZsOKnruyyHMQTP7jy5U92qEEwggdxMIIFWaAD
# AgECAhMzAAAAFcXna54Cm0mZAAAAAAAVMA0GCSqGSIb3DQEBCwUAMIGIMQswCQYD
# VQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEe
# MBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNyb3Nv
# ZnQgUm9vdCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkgMjAxMDAeFw0yMTA5MzAxODIy
# MjVaFw0zMDA5MzAxODMyMjVaMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNo
# aW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29y
# cG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEw
# MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA5OGmTOe0ciELeaLL1yR5
# vQ7VgtP97pwHB9KpbE51yMo1V/YBf2xK4OK9uT4XYDP/XE/HZveVU3Fa4n5KWv64
# NmeFRiMMtY0Tz3cywBAY6GB9alKDRLemjkZrBxTzxXb1hlDcwUTIcVxRMTegCjhu
# je3XD9gmU3w5YQJ6xKr9cmmvHaus9ja+NSZk2pg7uhp7M62AW36MEBydUv626GIl
# 3GoPz130/o5Tz9bshVZN7928jaTjkY+yOSxRnOlwaQ3KNi1wjjHINSi947SHJMPg
# yY9+tVSP3PoFVZhtaDuaRr3tpK56KTesy+uDRedGbsoy1cCGMFxPLOJiss254o2I
# 5JasAUq7vnGpF1tnYN74kpEeHT39IM9zfUGaRnXNxF803RKJ1v2lIH1+/NmeRd+2
# ci/bfV+AutuqfjbsNkz2K26oElHovwUDo9Fzpk03dJQcNIIP8BDyt0cY7afomXw/
# TNuvXsLz1dhzPUNOwTM5TI4CvEJoLhDqhFFG4tG9ahhaYQFzymeiXtcodgLiMxhy
# 16cg8ML6EgrXY28MyTZki1ugpoMhXV8wdJGUlNi5UPkLiWHzNgY1GIRH29wb0f2y
# 1BzFa/ZcUlFdEtsluq9QBXpsxREdcu+N+VLEhReTwDwV2xo3xwgVGD94q0W29R6H
# XtqPnhZyacaue7e3PmriLq0CAwEAAaOCAd0wggHZMBIGCSsGAQQBgjcVAQQFAgMB
# AAEwIwYJKwYBBAGCNxUCBBYEFCqnUv5kxJq+gpE8RjUpzxD/LwTuMB0GA1UdDgQW
# BBSfpxVdAF5iXYP05dJlpxtTNRnpcjBcBgNVHSAEVTBTMFEGDCsGAQQBgjdMg30B
# ATBBMD8GCCsGAQUFBwIBFjNodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3Bz
# L0RvY3MvUmVwb3NpdG9yeS5odG0wEwYDVR0lBAwwCgYIKwYBBQUHAwgwGQYJKwYB
# BAGCNxQCBAweCgBTAHUAYgBDAEEwCwYDVR0PBAQDAgGGMA8GA1UdEwEB/wQFMAMB
# Af8wHwYDVR0jBBgwFoAU1fZWy4/oolxiaNE9lJBb186aGMQwVgYDVR0fBE8wTTBL
# oEmgR4ZFaHR0cDovL2NybC5taWNyb3NvZnQuY29tL3BraS9jcmwvcHJvZHVjdHMv
# TWljUm9vQ2VyQXV0XzIwMTAtMDYtMjMuY3JsMFoGCCsGAQUFBwEBBE4wTDBKBggr
# BgEFBQcwAoY+aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy9NaWNS
# b29DZXJBdXRfMjAxMC0wNi0yMy5jcnQwDQYJKoZIhvcNAQELBQADggIBAJ1Vffwq
# reEsH2cBMSRb4Z5yS/ypb+pcFLY+TkdkeLEGk5c9MTO1OdfCcTY/2mRsfNB1OW27
# DzHkwo/7bNGhlBgi7ulmZzpTTd2YurYeeNg2LpypglYAA7AFvonoaeC6Ce5732pv
# vinLbtg/SHUB2RjebYIM9W0jVOR4U3UkV7ndn/OOPcbzaN9l9qRWqveVtihVJ9Ak
# vUCgvxm2EhIRXT0n4ECWOKz3+SmJw7wXsFSFQrP8DJ6LGYnn8AtqgcKBGUIZUnWK
# NsIdw2FzLixre24/LAl4FOmRsqlb30mjdAy87JGA0j3mSj5mO0+7hvoyGtmW9I/2
# kQH2zsZ0/fZMcm8Qq3UwxTSwethQ/gpY3UA8x1RtnWN0SCyxTkctwRQEcb9k+SS+
# c23Kjgm9swFXSVRk2XPXfx5bRAGOWhmRaw2fpCjcZxkoJLo4S5pu+yFUa2pFEUep
# 8beuyOiJXk+d0tBMdrVXVAmxaQFEfnyhYWxz/gq77EFmPWn9y8FBSX5+k77L+Dvk
# txW/tM4+pTFRhLy/AsGConsXHRWJjXD+57XQKBqJC4822rpM+Zv/Cuk0+CQ1Zyvg
# DbjmjJnW4SLq8CdCPSWU5nR0W2rRnj7tfqAxM328y+l7vzhwRNGQ8cirOoo6CGJ/
# 2XBjU02N7oJtpQUQwXEGahC0HVUzWLOhcGbyoYIDVjCCAj4CAQEwggEBoYHZpIHW
# MIHTMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQL
# EyRNaWNyb3NvZnQgSXJlbGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJzAlBgNVBAsT
# Hm5TaGllbGQgVFNTIEVTTjo1OTFBLTA1RTAtRDk0NzElMCMGA1UEAxMcTWljcm9z
# b2Z0IFRpbWUtU3RhbXAgU2VydmljZaIjCgEBMAcGBSsOAwIaAxUAv+LZ/Vg0s17X
# ek4iG9R9c/7+AI6ggYMwgYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAx
# MDANBgkqhkiG9w0BAQsFAAIFAOtn5oEwIhgPMjAyNTAyMjUwNjQ5MzdaGA8yMDI1
# MDIyNjA2NDkzN1owdDA6BgorBgEEAYRZCgQBMSwwKjAKAgUA62fmgQIBADAHAgEA
# AgITgTAHAgEAAgITETAKAgUA62k4AQIBADA2BgorBgEEAYRZCgQCMSgwJjAMBgor
# BgEEAYRZCgMCoAowCAIBAAIDB6EgoQowCAIBAAIDAYagMA0GCSqGSIb3DQEBCwUA
# A4IBAQCQkEwU35DG4dpna4WpWw2ZStuo2sLNjrq8zLjiWBYtSd+HTdeGpYQsMUOM
# ox0cfiLSVhNmacARD4ojSM4BrR4QBer5h0aN/SR+iO95LG+z9PHrGstXErWoXkxL
# oF6ByPptFGnbnGKY88rPruOB9GbaiDm+996eelTfL0c4vPCBBPFZON9NjKG2aZyA
# S3Zqmw1sBX/1W2WOYOSpkwBkQO4lqekZGLX+RYOsJwV0zjgGFd+Rd4UXvU4+KPN2
# yhaCabRtup/R5WzFBaDD6bIn7WxbdBzX0bliNOoLFIa8jCxYib266oRccd/3uxyI
# gAeN9IiO7ZJihU0Sb1Y/emdHMy4GMYIEDTCCBAkCAQEwgZMwfDELMAkGA1UEBhMC
# VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNV
# BAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRp
# bWUtU3RhbXAgUENBIDIwMTACEzMAAAH0F0aFwMs/OeUAAQAAAfQwDQYJYIZIAWUD
# BAIBBQCgggFKMBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAvBgkqhkiG9w0B
# CQQxIgQgSb7l4UNnmn2AxH+Ul//+1tXwlYCUBnBVp3CXlLgmIbYwgfoGCyqGSIb3
# DQEJEAIvMYHqMIHnMIHkMIG9BCA/WMJ8biaT6njvkknB8Q7hSQIi8ys6vIBvZg60
# RBjWazCBmDCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9u
# MRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRp
# b24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAAB
# 9BdGhcDLPznlAAEAAAH0MCIEIB4EkPUdniQkbvQ8rpDYJebVtuujzCRZ6ignUXYi
# SnomMA0GCSqGSIb3DQEBCwUABIICAJxPB0y1bVI4AZellM//1bqMWlxgdM9sQmu4
# RrM4wf2aZAxtXJJo2yvOvtT1IORr9mACvVSURdbYHdg7QG9wYWobt4iRB5nkN+Lv
# +m4FFo6sZwxh77eLZW6MpjudYNuHf66NCr38GSMUHiqYhrc5fKGaoUoAQQ43CkwD
# ZZG6+PC99/LPYxZ4zdDbZcx181g2178JSP43quTGlR0m+9l3Ml4rhBdIVZToMKQi
# GLRF5ipUPKb3ElmcdDydSfDTZIfC+2EgIRHK4R4acardDuvfOdcODUktw1ipx9Nw
# g1lorC9L+KQK5XouF/ZiGBmOdmdTfGFhCv1EgIQum7NI0yG0N8b0wNTo7NcwdMnw
# +6WjvXoWSj5lG3fGcVYliWpveaj113Cu0fQbfvqkuV3smwyAuAhfeUVvLpUDLxex
# HnvPbgjlGdJ5woTr85CpzK0MI5uYJkya82i7AxWXfQjJH0AjjdX/OCHmfOHf8Prf
# K4jNogqRhSLPTSrg9GfyUXnJz3uSPQoI6byX6CBxX0JPAUPeH63uI0LG2UkcZUMI
# B9U+gypR2ypOQhtglnHK99mZvE9/b85T92ZApr8Ch1mgf4Dl86AEPQfvtn5OERre
# ElergybcKLAHzFfAjIYttlnLZC8Yx4bIe4FP3uN8IKsRlfIwRQ+W867kKkJLEEn7
# oqsm36bJ
# SIG # End signature block
