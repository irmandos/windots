
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
    [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Runtime.PreviewMessageAttribute("This cmdlet is based on a preview API version and may experience breaking changes in future releases.")]
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

        [Parameter(Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the source appliance name for the AzLocal scenario.
        ${SourceApplianceName},

        [Parameter(Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the target appliance name for the AzLocal scenario.
        ${TargetApplianceName},
    
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
        Import-Module $PSScriptRoot\Helper\AZLocalCommonHelper.ps1

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
        
        $MachineIdArray = $MachineId.Split("/")
        if ($MachineIdArray.Length -lt 11) {
            throw "Invalid machine ARM ID '$MachineId'"
        }
        $SiteType = $MachineIdArray[7]
        $SiteName = $MachineIdArray[8]
        $ResourceGroupName = $MachineIdArray[4]
        $MachineName = $MachineIdArray[10]

        # Get the source site and the discovered machine
        if (($SiteType -ne $SiteTypes.HyperVSites) -and ($SiteType -ne $SiteTypes.VMwareSites)) {
            throw "Site type is not supported. Site type '$SiteType'. Check MachineId provided."
        }
        
        if ($SiteType -eq $SiteTypes.HyperVSites) {
            $instanceType = $AzLocalInstanceTypes.HyperVToAzLocal

            # Get Hyper-V machine
            $machine = InvokeAzMigrateGetCommandWithRetries `
                -CommandName 'Az.Migrate.Internal\Get-AzMigrateHyperVMachine' `
                -Parameters @{
                    'ResourceGroupName' = $ResourceGroupName;
                    'SiteName' = $SiteName;
                    'MachineName' = $MachineName;
                } `
                -ErrorMessage "Machine '$MachineName' not found in resource group '$ResourceGroupName' and site '$SiteName'."

            # Get Hyper-V site
            $siteObject = InvokeAzMigrateGetCommandWithRetries `
                -CommandName 'Az.Migrate.Internal\Get-AzMigrateHyperVSite' `
                -Parameters @{
                    'ResourceGroupName' = $ResourceGroupName;
                    'SiteName' = $SiteName;
                } `
                -ErrorMessage "Machine site '$SiteName' with Type '$SiteType' not found."

            # Get RunAsAccount
            if (![string]::IsNullOrEmpty($machine.HostId))
            {
                # machine is on a single Hyper-V host
                $hostIdArray = $machine.HostId.Split("/")
                if ($hostIdArray.Length -lt 11) {
                    throw "Invalid Hyper-V Host ARM ID '$($machine.HostId)'"
                }

                $hostResourceGroupName = $hostIdArray[4]
                $hostSiteName = $hostIdArray[8]
                $hostName = $hostIdArray[10]

                $hyperVHost = InvokeAzMigrateGetCommandWithRetries `
                    -CommandName 'Az.Migrate.Internal\Get-AzMigrateHyperVHost' `
                    -Parameters @{
                        'ResourceGroupName' = $hostResourceGroupName;
                        'SiteName' = $hostSiteName;
                        'HostName' = $hostName;
                    } `
                    -ErrorMessage "Hyper-V host '$hostName' not found in resource group '$hostResourceGroupName' and site '$hostSiteName'."
                
                $runAsAccountId = $hyperVHost.RunAsAccountId
            }
            elseif(![string]::IsNullOrEmpty($machine.ClusterId))
            {
                # machine is on a Hyper-V cluster
                $clusterIdArray = $machine.ClusterId.Split("/")
                if ($clusterIdArray.Length -lt 11) {
                    throw "Invalid Hyper-V Cluster ARM ID '$($machine.ClusterId)'"
                }

                $clusterResourceGroupName = $clusterIdArray[4]
                $clusterSiteName = $clusterIdArray[8]
                $clusterName = $clusterIdArray[10]

                $hyperVCluster = InvokeAzMigrateGetCommandWithRetries `
                    -CommandName 'Az.Migrate.Internal\Get-AzMigrateHyperVCluster' `
                    -Parameters @{
                        'ResourceGroupName' = $clusterResourceGroupName;
                        'SiteName' = $clusterSiteName;
                        'ClusterName' = $clusterName;
                    } `
                    -ErrorMessage "Hyper-V cluster '$clusterName' not found in resource group '$clusterResourceGroupName' and site '$clusterSiteName'."

                $runAsAccountId = $hyperVCluster.RunAsAccountId
            }
        }
        elseif ($SiteType -eq $SiteTypes.VMwareSites)
        {
            $instanceType = $AzLocalInstanceTypes.VMwareToAzLocal

            # Get VMware machine
            $machine = InvokeAzMigrateGetCommandWithRetries `
                -CommandName 'Az.Migrate.Internal\Get-AzMigrateMachine' `
                -Parameters @{
                    'ResourceGroupName' = $ResourceGroupName;
                    'SiteName' = $SiteName;
                    'MachineName' = $MachineName;
                } `
                -ErrorMessage "Machine '$MachineName' not found in resource group '$ResourceGroupName' and site '$SiteName'."

            # Get VMware site
            $siteObject = InvokeAzMigrateGetCommandWithRetries `
                -CommandName 'Az.Migrate\Get-AzMigrateSite' `
                -Parameters @{
                    'ResourceGroupName' = $ResourceGroupName;
                    'SiteName' = $SiteName;
                } `
                -ErrorMessage "Machine site '$SiteName' with Type '$SiteType' not found."

            # Get RunAsAccount
            if (![string]::IsNullOrEmpty($machine.VCenterId))
            {
                # machine is on a single vCenter
                $vCenterIdArray = $machine.VCenterId.Split("/")
                if ($vCenterIdArray.Length -lt 11) {
                    throw "Invalid VMware vCenter ARM ID '$($machine.VCenterId)'"
                }

                $vCenterResourceGroupName = $vCenterIdArray[4]
                $vCenterSiteName = $vCenterIdArray[8]
                $vCenterName = $vCenterIdArray[10]

                $vmwareVCenter = InvokeAzMigrateGetCommandWithRetries `
                    -CommandName 'Az.Migrate.Internal\Get-AzMigrateVCenter' `
                    -Parameters @{
                        'ResourceGroupName' = $vCenterResourceGroupName;
                        'SiteName' = $vCenterSiteName;
                        'Name' = $vCenterName;
                    } `
                    -ErrorMessage "VMware vCenter '$vCenterName' not found in resource group '$vCenterResourceGroupName' and site '$vCenterSiteName'."

                $runAsAccountId = $vmwareVCenter.RunAsAccountId
            }
        }
        else
        {
            throw "Unsupported site type '$SiteType'. Only Hyper-V and VMware sites are supported."
        }

        if ([string]::IsNullOrEmpty($runAsAccountId)) {
            throw "Unable to determine RunAsAccount for site '$SiteName' from machine '$MachineName'. Please verify your appliance setup."
        }

        # Validate the VM
        ValidateReplication -Machine $machine -MigrationType $instanceType
        
        # $siteObject is not null or exception would have been thrown
        $ProjectName = $siteObject.DiscoverySolutionId.Split("/")[8]

        # Get Data Replication Service, or the AMH solution
        $amhSolutionName = "Servers-Migration-ServerMigration_DataReplication"
        $amhSolution = InvokeAzMigrateGetCommandWithRetries `
            -CommandName 'Az.Migrate\Get-AzMigrateSolution' `
            -Parameters @{
                "ResourceGroupName" = $ResourceGroupName;
                "Name" = $amhSolutionName;
                "MigrateProjectName" = $ProjectName;
            } `
            -ErrorMessage "No Data Replication Service Solution '$amhSolutionName' found in resource group '$ResourceGroupName' and project '$ProjectName'. Please verify your appliance setup."
        
        # Validate replication vault
        $replicationVaultName = $amhSolution.DetailExtendedDetail["vaultId"].Split("/")[8]
        if ([string]::IsNullOrEmpty($replicationVaultName)) {
            throw "No Replication Vault found. Please verify your Azure Migrate project setup."
        }
        $replicationVault = InvokeAzMigrateGetCommandWithRetries `
            -CommandName "Az.Migrate.Internal\Get-AzMigrateVault" `
            -Parameters @{
                "ResourceGroupName" = $ResourceGroupName;
                "Name" = $replicationVaultName
            } `
            -ErrorMessage "No Replication Vault '$replicationVaultName' found in Resource Group '$ResourceGroupName'. Please verify your Azure Migrate project setup."
        if ($replicationVault.Property.ProvisioningState -ne [ProvisioningState]::Succeeded) {
            throw "The Replication Vault '$replicationVaultName' is not in a valid state. The provisioning state is '$($replicationVault.Property.ProvisioningState)'. Please verify your Azure Migrate project setup."
        }

        # Access Discovery Service
        $discoverySolutionName = "Servers-Discovery-ServerDiscovery"
        $discoverySolution = InvokeAzMigrateGetCommandWithRetries `
            -CommandName "Az.Migrate\Get-AzMigrateSolution" `
            -Parameters @{
                "SubscriptionId" = $SubscriptionId;
                "ResourceGroupName" = $ResourceGroupName;
                "MigrateProjectName" = $ProjectName;
                "Name" = $discoverySolutionName;
            } `
            -ErrorMessage "Server Discovery Solution '$discoverySolutionName' not found."

        # Get Appliances Mapping
        $appMap = @{}
        if ($null -ne $discoverySolution.DetailExtendedDetail["applianceNameToSiteIdMapV2"]) {
            $appMapV2 = $discoverySolution.DetailExtendedDetail["applianceNameToSiteIdMapV2"] | ConvertFrom-Json
            # Fetch all appliance from V2 map first. Then these can be updated if found again in V3 map.
            foreach ($item in $appMapV2) {
                $appMap[$item.ApplianceName.ToLower()] = $item.SiteId
            }
        }
    
        if ($null -ne $discoverySolution.DetailExtendedDetail["applianceNameToSiteIdMapV3"]) {
            $appMapV3 = $discoverySolution.DetailExtendedDetail["applianceNameToSiteIdMapV3"] | ConvertFrom-Json
            foreach ($item in $appMapV3) {
                $t = $item.psobject.properties
                $appMap[$t.Name.ToLower()] = $t.Value.SiteId
            }
        }

        if ($null -eq $discoverySolution.DetailExtendedDetail["applianceNameToSiteIdMapV2"] -And
            $null -eq $discoverySolution.DetailExtendedDetail["applianceNameToSiteIdMapV3"] ) {
            throw "Server Discovery Solution missing Appliance Details. Invalid Solution."           
        }

        $hyperVSiteTypeRegex = "(?<=/Microsoft.OffAzure/HyperVSites/).*$"
        $vmwareSiteTypeRegex = "(?<=/Microsoft.OffAzure/VMwareSites/).*$"

        # Validate SourceApplianceName & TargetApplianceName
        $sourceSiteId = $appMap[$SourceApplianceName.ToLower()]
        $targetSiteId = $appMap[$TargetApplianceName.ToLower()]
        if (-not ($sourceSiteId -match $hyperVSiteTypeRegex -and $targetSiteId -match $hyperVSiteTypeRegex) -and
            -not ($sourceSiteId -match $vmwareSiteTypeRegex -and $targetSiteId -match $hyperVSiteTypeRegex)) {
            throw "Error encountered in matching the given source appliance name '$SourceApplianceName' and target appliance name '$TargetApplianceName'. Please verify the VM site type to be either for HyperV or VMware for both source and target appliances, and the appliance names are correct."
        }
        
        # Get healthy asrv2 fabrics in the resource group
        $allFabrics = Az.Migrate\Get-AzMigrateLocalReplicationFabric -ResourceGroupName $ResourceGroupName | Where-Object {
            $_.Property.ProvisioningState -eq [ProvisioningState]::Succeeded -and
            $_.Property.CustomProperty.MigrationSolutionId -eq $amhSolution.Id
        }

        # Filter for source fabric
        if ($instanceType -eq $AzLocalInstanceTypes.HyperVToAzLocal)
        {
            $fabricInstanceType = $FabricInstanceTypes.HyperVInstance
        }
        else { # $instanceType -eq $AzLocalInstanceTypes.VMwareToAzLocal
            $fabricInstanceType = $FabricInstanceTypes.VmwareInstance
        }

        $sourceFabric = $allFabrics | Where-Object {
            $_.Property.CustomProperty.InstanceType -ceq $fabricInstanceType -and
            $_.Name.StartsWith($SourceApplianceName, [System.StringComparison]::InvariantCultureIgnoreCase)
        }

        if ($null -eq $sourceFabric)
        {
            throw "Couldn't find connected source appliance with the name '$SourceApplianceName'. Deploy a source appliance by completing the Discover step of migration for your on-premises environment."
        }

        # Get source fabric agent (dra)
        $sourceDraErrorMessage = "The source appliance '$SourceApplianceName' is in a disconnected state. Ensure that the source appliance is running and has connectivity before proceeding."
        $sourceDras = InvokeAzMigrateGetCommandWithRetries `
            -CommandName 'Az.Migrate.Internal\Get-AzMigrateFabricAgent' `
            -Parameters @{
                FabricName = $sourceFabric.Name;
                ResourceGroupName = $ResourceGroupName
            } `
            -ErrorMessage $sourceDraErrorMessage
        $sourceDra = $sourceDras | Where-Object {
            $_.Property.MachineName -eq $SourceApplianceName -and
            $_.Property.CustomProperty.InstanceType -eq $fabricInstanceType -and
            $_.Property.IsResponsive -eq $true
        }

        if ($null -eq $sourceDra)
        {
            throw $sourceDraErrorMessage
        }
        $sourceDra = $sourceDra[0]

        # Filter for target fabric
        $fabricInstanceType = $FabricInstanceTypes.AzLocalInstance
        $targetFabric = $allFabrics | Where-Object {
            $_.Property.CustomProperty.InstanceType -ceq $fabricInstanceType -and
            $_.Name.StartsWith($TargetApplianceName, [System.StringComparison]::InvariantCultureIgnoreCase)
        }

        if ($null -eq $targetFabric)
        {
            throw "Couldn't find connected target appliance with the name '$TargetApplianceName'. Deploy a target appliance by completing the Configuration step of migration for your Azure Local environment."
        }

        # Get target fabric agent (dra)
        $targetDraErrorMessage = "The target appliance '$TargetApplianceName' is in a disconnected state. Ensure that the target appliance is running and has connectivity before proceeding."
        $targetDras = InvokeAzMigrateGetCommandWithRetries `
            -CommandName 'Az.Migrate.Internal\Get-AzMigrateFabricAgent' `
            -Parameters @{
                FabricName = $targetFabric.Name;
                ResourceGroupName = $ResourceGroupName
            } `
            -ErrorMessage $targetDraErrorMessage
        $targetDra = $targetDras | Where-Object {
            $_.Property.MachineName -eq $TargetApplianceName -and
            $_.Property.CustomProperty.InstanceType -eq $fabricInstanceType -and
            $_.Property.IsResponsive -eq $true
        }

        if ($null -eq $targetDra)
        {
            throw $targetDraErrorMessage
        }
        $targetDra = $targetDras[0]

        # Validate Policy
        $policyName = $replicationVaultName + $instanceType + "policy"
        $policy = InvokeAzMigrateGetCommandWithRetries `
            -CommandName 'Az.Migrate.Internal\Get-AzMigratePolicy' `
            -Parameters @{
                ResourceGroupName = $ResourceGroupName;
                Name = $policyName;
                VaultName = $replicationVaultName;
            } `
            -ErrorMessage "The replication policy '$policyName' not found. The replication infrastructure is not initialized. Run the Initialize-AzMigrateLocalReplicationInfrastructure command."
        if ($policy.Property.ProvisioningState -ne [ProvisioningState]::Succeeded) {
            throw "The replication policy '$policyName' is not in a valid state. The provisioning state is '$($policy.Property.ProvisioningState)'. Re-run the Initialize-AzMigrateLocalReplicationInfrastructure command."
        }

        # Validate Replication Extension
        $replicationExtensionName = ($sourceFabric.Id -split '/')[-1] + "-" + ($targetFabric.Id -split '/')[-1] + "-MigReplicationExtn"
        $replicationExtension = InvokeAzMigrateGetCommandWithRetries `
            -CommandName 'Az.Migrate.Internal\Get-AzMigrateReplicationExtension' `
            -Parameters @{
                ResourceGroupName = $ResourceGroupName;
                Name = $replicationExtensionName;
                VaultName = $replicationVaultName;
            } `
            -ErrorMessage "The replication extension '$replicationExtensionName' not found. The replication infrastructure is not initialized. Run the Initialize-AzMigrateLocalReplicationInfrastructure command."
        if ($replicationExtension.Property.ProvisioningState -ne [ProvisioningState]::Succeeded) {
            throw "The replication extension '$replicationExtensionName' is not in a valid state. The provisioning state is '$($replicationExtension.Property.ProvisioningState)'. Re-run the Initialize-AzMigrateLocalReplicationInfrastructure command."
        }
        
        # Get ARC Resource Bridge info
        $targetClusterId = $targetFabric.Property.CustomProperty.Cluster.ResourceName
        $targetClusterIdArray = $targetClusterId.Split("/")
        $targetSubscription = $targetClusterIdArray[2]
        $arbArgQuery = GetARGQueryForArcResourceBridge -HCIClusterID $targetClusterId
        $arbArgResult = Az.ResourceGraph\Search-AzGraph -Query $arbArgQuery -Subscription $targetSubscription
        if ($null -eq $arbArgResult) {
            throw "$($ArcResourceBridgeValidationMessages.NoClusters). Validate target cluster with id '$targetClusterId' exists."
        }
        elseif ($arbArgResult.statusOfTheBridge -ne "Running") {
            throw "$($ArcResourceBridgeValidationMessages.NotRunning). Make sure the Arc Resource Bridge is online before retrying."
        }

        # Validate TargetVMName
        if ($TargetVMName.length -gt 64 -or $TargetVMName.length -eq 0) {
            throw "The target virtual machine name must be between 1 and 64 characters long."
        }
        elseif ($TargetVMName -notmatch "^[^_\W][a-zA-Z0-9\-]{0,63}(?<![-._])$") {
            throw "The target virtual machine name must begin with a letter or number, and can contain only letters, numbers, or hyphens(-). The names cannot contain special characters \/""[]:|<>+=;,?*@&, whitespace, or begin with '_' or end with '.' or '-'."
        }
        elseif (IsReservedOrTrademarked($TargetVMName)) {
            throw "The target virtual machine name '$TargetVMName' or part of the name is a trademarked or reserved word."
        }

        # Construct create protected item request object
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
        $customProperties.CustomLocationRegion = $arbArgResult.CustomLocationRegion
        $customProperties.FabricDiscoveryMachineId = $machine.Id
        $customProperties.RunAsAccountId = $runAsAccountId
        $customProperties.SourceFabricAgentName = $sourceDra.Name
        $customProperties.StorageContainerId = $TargetStoragePathId
        $customProperties.TargetArcClusterCustomLocationId = $arbArgResult.CustomLocation
        $customProperties.TargetFabricAgentName = $targetDra.Name
        $customProperties.TargetHciClusterId = $targetClusterId
        $customProperties.TargetResourceGroupId = $TargetResourceGroupId
        $customProperties.TargetVMName = $TargetVMName
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
                throw "Specify a target RAM that is greater than 0"    
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
                    throw "No Disk found with InstanceId $OSDiskID from discovered machine disks."
                }

                $diskName = Split-Path $osDisk.Path -leaf
                if (IsReservedOrTrademarked($diskName)) {
                    throw "The disk name $diskName or part of the name is a trademarked or reserved word."
                }
            }
            elseif ($SiteType -eq $SiteTypes.VMwareSites) {  
                $osDisk = $machine.Disk | Where-Object { $_.Uuid -eq $OSDiskID }
                if ($null -eq $osDisk) {
                    throw "No Disk found with Uuid $OSDiskID from discovered machine disks."
                }

                $diskName = Split-Path $osDisk.Path -leaf
                if (IsReservedOrTrademarked($diskName)) {
                    throw "The disk name $diskName or part of the name is a trademarked or reserved word."
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
                # VHD is not supported in Gen2 VMs
                if ($customProperties.HyperVGeneration -eq "2" -and $disk.DiskFileFormat -eq "VHD") {
                    throw "VHD disks are not supported in Hyper-V Generation 2 VMs. Please replace disk with id '$($disk.DiskId)' in -DiskToInclude by re-running New-AzMigrateLocalDiskMappingObject with 'VHDX' as Format."
                }

                # PhysicalSectorSize must be 512 for VHD format
                if ($disk.DiskFileFormat -eq "VHD" -and $disk.DiskPhysicalSectorSize -ne 512) {
                    throw "PhysicalSectorSize must be 512 for VHD format. Please replace disk with id '$($disk.DiskId)' in -DiskToInclude by re-running New-AzMigrateLocalDiskMappingObject with 512 as PhysicalSectorSize."
                }

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
                    throw "The disk name $diskName or part of the name is a trademarked or reserved word."
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
            $operation = Az.Migrate.Internal\New-AzMigrateProtectedItem `
                -Name $MachineName `
                -ResourceGroupName $ResourceGroupName `
                -VaultName $replicationVaultName `
                -Property $protectedItemProperties `
                -NoWait:$true

            $jobName = $operation.Target.Split("/")[-1].Split("?")[0].Split("_")[0]
            return Az.Migrate.Internal\Get-AzMigrateLocalReplicationJob `
                -Name $jobName `
                -ResourceGroupName $ResourceGroupName `
                -VaultName $replicationVaultName
        }
    }
}
# SIG # Begin signature block
# MIIoPAYJKoZIhvcNAQcCoIIoLTCCKCkCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCArXROfrNXw3vBN
# LnYH/UhPeaYGMpX87aOQe4hJXKfYfKCCDYUwggYDMIID66ADAgECAhMzAAAEhJji
# EuB4ozFdAAAAAASEMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjUwNjE5MTgyMTM1WhcNMjYwNjE3MTgyMTM1WjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQDtekqMKDnzfsyc1T1QpHfFtr+rkir8ldzLPKmMXbRDouVXAsvBfd6E82tPj4Yz
# aSluGDQoX3NpMKooKeVFjjNRq37yyT/h1QTLMB8dpmsZ/70UM+U/sYxvt1PWWxLj
# MNIXqzB8PjG6i7H2YFgk4YOhfGSekvnzW13dLAtfjD0wiwREPvCNlilRz7XoFde5
# KO01eFiWeteh48qUOqUaAkIznC4XB3sFd1LWUmupXHK05QfJSmnei9qZJBYTt8Zh
# ArGDh7nQn+Y1jOA3oBiCUJ4n1CMaWdDhrgdMuu026oWAbfC3prqkUn8LWp28H+2S
# LetNG5KQZZwvy3Zcn7+PQGl5AgMBAAGjggGCMIIBfjAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQUBN/0b6Fh6nMdE4FAxYG9kWCpbYUw
# VAYDVR0RBE0wS6RJMEcxLTArBgNVBAsTJE1pY3Jvc29mdCBJcmVsYW5kIE9wZXJh
# dGlvbnMgTGltaXRlZDEWMBQGA1UEBRMNMjMwMDEyKzUwNTM2MjAfBgNVHSMEGDAW
# gBRIbmTlUAXTgqoXNzcitW2oynUClTBUBgNVHR8ETTBLMEmgR6BFhkNodHRwOi8v
# d3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NybC9NaWNDb2RTaWdQQ0EyMDExXzIw
# MTEtMDctMDguY3JsMGEGCCsGAQUFBwEBBFUwUzBRBggrBgEFBQcwAoZFaHR0cDov
# L3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jZXJ0cy9NaWNDb2RTaWdQQ0EyMDEx
# XzIwMTEtMDctMDguY3J0MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQADggIB
# AGLQps1XU4RTcoDIDLP6QG3NnRE3p/WSMp61Cs8Z+JUv3xJWGtBzYmCINmHVFv6i
# 8pYF/e79FNK6P1oKjduxqHSicBdg8Mj0k8kDFA/0eU26bPBRQUIaiWrhsDOrXWdL
# m7Zmu516oQoUWcINs4jBfjDEVV4bmgQYfe+4/MUJwQJ9h6mfE+kcCP4HlP4ChIQB
# UHoSymakcTBvZw+Qst7sbdt5KnQKkSEN01CzPG1awClCI6zLKf/vKIwnqHw/+Wvc
# Ar7gwKlWNmLwTNi807r9rWsXQep1Q8YMkIuGmZ0a1qCd3GuOkSRznz2/0ojeZVYh
# ZyohCQi1Bs+xfRkv/fy0HfV3mNyO22dFUvHzBZgqE5FbGjmUnrSr1x8lCrK+s4A+
# bOGp2IejOphWoZEPGOco/HEznZ5Lk6w6W+E2Jy3PHoFE0Y8TtkSE4/80Y2lBJhLj
# 27d8ueJ8IdQhSpL/WzTjjnuYH7Dx5o9pWdIGSaFNYuSqOYxrVW7N4AEQVRDZeqDc
# fqPG3O6r5SNsxXbd71DCIQURtUKss53ON+vrlV0rjiKBIdwvMNLQ9zK0jy77owDy
# XXoYkQxakN2uFIBO1UNAvCYXjs4rw3SRmBX9qiZ5ENxcn/pLMkiyb68QdwHUXz+1
# fI6ea3/jjpNPz6Dlc/RMcXIWeMMkhup/XEbwu73U+uz/MIIHejCCBWKgAwIBAgIK
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
# cVZOSEXAQsmbdlsKgEhr/Xmfwb1tbWrJUnMTDXpQzTGCGg0wghoJAgEBMIGVMH4x
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01p
# Y3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTECEzMAAASEmOIS4HijMV0AAAAA
# BIQwDQYJYIZIAWUDBAIBBQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIMR7
# 2p9Rlwyv1n/dOwSvGqg0TlUafsCR0k2qFD7Q9KomMEIGCisGAQQBgjcCAQwxNDAy
# oBSAEgBNAGkAYwByAG8AcwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20wDQYJKoZIhvcNAQEBBQAEggEAoZ0sfskoe3tPpTgWB++dQO1lI5wbjyTeVY+a
# +B/ZcPWX9KufDXq2GbIFq4Kjv8tIPhGv6YMlm9tU3GnhjGUqx/AmD67153UwTZZl
# fc2gSASowrS0B5G+fDVnQ1b+TFudlEJZtTIg6C1r/DmiPjq13G5FtmHl+/yEBDDZ
# 5JrpjMF77MKKHKWim/qvnlZUqaS2G9imBt0C6hdEk35f19c6gAtFA6zmGLaYFNOp
# po1W50E4impMtrQFydyt2PH2XYwBlsCZOMgbAEkQik/6waCJyqSmx7mLOlPhX6Ox
# UZTmhgEYD3Gv51pEtChwYjiORe7kvVOw6FCSIsi5dXoGs2xWXKGCF5cwgheTBgor
# BgEEAYI3AwMBMYIXgzCCF38GCSqGSIb3DQEHAqCCF3AwghdsAgEDMQ8wDQYJYIZI
# AWUDBAIBBQAwggFSBgsqhkiG9w0BCRABBKCCAUEEggE9MIIBOQIBAQYKKwYBBAGE
# WQoDATAxMA0GCWCGSAFlAwQCAQUABCC/OIs0IrARwFhkALcENjrAvnxYROpwlXml
# luovH7QhJwIGaEtOPBGAGBMyMDI1MDczMDAzNTEzMC4wMjdaMASAAgH0oIHRpIHO
# MIHLMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQL
# ExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxk
# IFRTUyBFU046RTAwMi0wNUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1l
# LVN0YW1wIFNlcnZpY2WgghHtMIIHIDCCBQigAwIBAgITMwAAAgsRnVYpkvm/hQAB
# AAACCzANBgkqhkiG9w0BAQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAx
# MDAeFw0yNTAxMzAxOTQyNThaFw0yNjA0MjIxOTQyNThaMIHLMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1l
# cmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046RTAwMi0w
# NUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2Uw
# ggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCqrPitRjAXqFh2IHzQYD3u
# ykDPyJF+79e5CkY4aYsb93QVun4fZ3Ju/0WHrtAF3JswSiAVl7p1H2zFKrvyhaVu
# RYcSc7YuyP0GHEVq7YVS5uF3YLlLeoyGOPKSXGs6agW60CqVBhPQ+2n49e6YD9wG
# v6Y0HmBKmnQqY/AKJijgUiRulb1ovNEcTZmTNRu1mY+0JjiEus+eF66VNoBv1a2M
# W0JPYbFBhPzFHlddFXcjf2qIkb5BYWsFL7QlBjXApf2HmNrPzG36g1ybo/KnRjSg
# IRpHeYXxBIaCEGtR1EmpJ90OSFHxUu7eIjVfenqnVtag0yAQY7zEWSXMN6+CHjv3
# SBNtm5ZIRyyCsUZG8454K+865bw7FwuH8vk5Q+07K5lFY02eBDw3UKzWjWvqTp2p
# K8MTa4kozvlKgrSGp5sh57GnkjlvNvt78NXbZTVIrwS7xcIGjbvS/2r5lRDT+Q3P
# 2tT+g6KDPdLntlcbFdHuuzyJyx0WfCr8zHv8wGCB3qPObRXK4opAInSQ4j5iS28K
# ATJGwQabRueZvhvd9Od0wcFYOb4orUv1dD5XwFyKlGDPMcTPOQr0gxmEQVrLiJEo
# LyyW8EV/aDFUXToxyhfzWZ6Dc0l9eeth1Et2NQ3A/qBR5x33pjKdHJVJ5xpp2AI3
# ZzNYLDCqO1lthz1GaSz+PQIDAQABo4IBSTCCAUUwHQYDVR0OBBYEFGZcLIjfr+l6
# WeMuhE9gsxe98j/+MB8GA1UdIwQYMBaAFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMF8G
# A1UdHwRYMFYwVKBSoFCGTmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMv
# Y3JsL01pY3Jvc29mdCUyMFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNybDBs
# BggrBgEFBQcBAQRgMF4wXAYIKwYBBQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0
# LmNvbS9wa2lvcHMvY2VydHMvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUy
# MDIwMTAoMSkuY3J0MAwGA1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUH
# AwgwDgYDVR0PAQH/BAQDAgeAMA0GCSqGSIb3DQEBCwUAA4ICAQCaKPVn6GLcnkbP
# EdM0R9q4Zm0+7JfG05+pmqP6nA4SwT26k9HlJQjqw/+WkiQLD4owJxooIr9MDZbi
# ZX6ypPhF+g1P5u8BOEXPYYkOWpzFGLRLtlZHvfxpqAIa7mjLGHDzKr/102AXaD4m
# GydEwaLGhUn9DBGdMm5dhiisWAqb/LN4lm4OuX4YLqKcW/0yScHKgprGgLY+6pqv
# 0zPU74j7eCr+PDTNYM8tFJ/btUnBNLyOE4WZwBIq4tnvXjd2cCOtgUnoQjFU1ZY7
# ZWdny3BJbf3hBrb3NB2IU4nu622tVrb1fNkwdvT501WRUBMd9oFf4xifj2j2Clbv
# 1XGljXmd6yJjvt+bBuvJLUuc9m+vMKOWyRwUdvOl/E5a8zV3MrjCnY6fIrLQNzBO
# Z6klICPCi+2GqbViM0CI6CbZypei5Rr9hJbH8rZEzjaYWLnr/XPsU0wr2Tn6L9dJ
# x2q/LAoK+oviAInj0aP4iRrMyUSO6KL2KwY6zJc6SDxbHkwYHdQRrPNP3SutMg6L
# gBSvtmfqwgaXIHkCoiUFEAz9cGIqvgjGpGppKTcTuoo3EEgp/zRd0wxW0QqmV3yg
# YGicen30KAWHrKFC8Sbwc6qC4podVZYJZmirHBP/uo7sQne5H0xtdvDmXDUfy5gN
# jLljQIUsJhQSyyXbSjSb2a5jhOUfxzCCB3EwggVZoAMCAQICEzMAAAAVxedrngKb
# SZkAAAAAABUwDQYJKoZIhvcNAQELBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQI
# EwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3Nv
# ZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBSb290IENlcnRpZmlj
# YXRlIEF1dGhvcml0eSAyMDEwMB4XDTIxMDkzMDE4MjIyNVoXDTMwMDkzMDE4MzIy
# NVowfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcT
# B1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UE
# AxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQDk4aZM57RyIQt5osvXJHm9DtWC0/3unAcH0qlsTnXI
# yjVX9gF/bErg4r25PhdgM/9cT8dm95VTcVrifkpa/rg2Z4VGIwy1jRPPdzLAEBjo
# YH1qUoNEt6aORmsHFPPFdvWGUNzBRMhxXFExN6AKOG6N7dcP2CZTfDlhAnrEqv1y
# aa8dq6z2Nr41JmTamDu6GnszrYBbfowQHJ1S/rboYiXcag/PXfT+jlPP1uyFVk3v
# 3byNpOORj7I5LFGc6XBpDco2LXCOMcg1KL3jtIckw+DJj361VI/c+gVVmG1oO5pG
# ve2krnopN6zL64NF50ZuyjLVwIYwXE8s4mKyzbnijYjklqwBSru+cakXW2dg3viS
# kR4dPf0gz3N9QZpGdc3EXzTdEonW/aUgfX782Z5F37ZyL9t9X4C626p+Nuw2TPYr
# bqgSUei/BQOj0XOmTTd0lBw0gg/wEPK3Rxjtp+iZfD9M269ewvPV2HM9Q07BMzlM
# jgK8QmguEOqEUUbi0b1qGFphAXPKZ6Je1yh2AuIzGHLXpyDwwvoSCtdjbwzJNmSL
# W6CmgyFdXzB0kZSU2LlQ+QuJYfM2BjUYhEfb3BvR/bLUHMVr9lxSUV0S2yW6r1AF
# emzFER1y7435UsSFF5PAPBXbGjfHCBUYP3irRbb1Hode2o+eFnJpxq57t7c+auIu
# rQIDAQABo4IB3TCCAdkwEgYJKwYBBAGCNxUBBAUCAwEAATAjBgkrBgEEAYI3FQIE
# FgQUKqdS/mTEmr6CkTxGNSnPEP8vBO4wHQYDVR0OBBYEFJ+nFV0AXmJdg/Tl0mWn
# G1M1GelyMFwGA1UdIARVMFMwUQYMKwYBBAGCN0yDfQEBMEEwPwYIKwYBBQUHAgEW
# M2h0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvRG9jcy9SZXBvc2l0b3J5
# Lmh0bTATBgNVHSUEDDAKBggrBgEFBQcDCDAZBgkrBgEEAYI3FAIEDB4KAFMAdQBi
# AEMAQTALBgNVHQ8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBTV
# 9lbLj+iiXGJo0T2UkFvXzpoYxDBWBgNVHR8ETzBNMEugSaBHhkVodHRwOi8vY3Js
# Lm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNSb29DZXJBdXRfMjAx
# MC0wNi0yMy5jcmwwWgYIKwYBBQUHAQEETjBMMEoGCCsGAQUFBzAChj5odHRwOi8v
# d3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1Jvb0NlckF1dF8yMDEwLTA2
# LTIzLmNydDANBgkqhkiG9w0BAQsFAAOCAgEAnVV9/Cqt4SwfZwExJFvhnnJL/Klv
# 6lwUtj5OR2R4sQaTlz0xM7U518JxNj/aZGx80HU5bbsPMeTCj/ts0aGUGCLu6WZn
# OlNN3Zi6th542DYunKmCVgADsAW+iehp4LoJ7nvfam++Kctu2D9IdQHZGN5tggz1
# bSNU5HhTdSRXud2f8449xvNo32X2pFaq95W2KFUn0CS9QKC/GbYSEhFdPSfgQJY4
# rPf5KYnDvBewVIVCs/wMnosZiefwC2qBwoEZQhlSdYo2wh3DYXMuLGt7bj8sCXgU
# 6ZGyqVvfSaN0DLzskYDSPeZKPmY7T7uG+jIa2Zb0j/aRAfbOxnT99kxybxCrdTDF
# NLB62FD+CljdQDzHVG2dY3RILLFORy3BFARxv2T5JL5zbcqOCb2zAVdJVGTZc9d/
# HltEAY5aGZFrDZ+kKNxnGSgkujhLmm77IVRrakURR6nxt67I6IleT53S0Ex2tVdU
# CbFpAUR+fKFhbHP+CrvsQWY9af3LwUFJfn6Tvsv4O+S3Fb+0zj6lMVGEvL8CwYKi
# excdFYmNcP7ntdAoGokLjzbaukz5m/8K6TT4JDVnK+ANuOaMmdbhIurwJ0I9JZTm
# dHRbatGePu1+oDEzfbzL6Xu/OHBE0ZDxyKs6ijoIYn/ZcGNTTY3ugm2lBRDBcQZq
# ELQdVTNYs6FwZvKhggNQMIICOAIBATCB+aGB0aSBzjCByzELMAkGA1UEBhMCVVMx
# EzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoT
# FU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjElMCMGA1UECxMcTWljcm9zb2Z0IEFtZXJp
# Y2EgT3BlcmF0aW9uczEnMCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOkUwMDItMDVF
# MC1EOTQ3MSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloiMK
# AQEwBwYFKw4DAhoDFQCoQndUJN3Ppq2xh8RhtsR35NCZwaCBgzCBgKR+MHwxCzAJ
# BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jv
# c29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwMA0GCSqGSIb3DQEBCwUAAgUA7DO/DTAi
# GA8yMDI1MDcyOTIxNDM0MVoYDzIwMjUwNzMwMjE0MzQxWjB3MD0GCisGAQQBhFkK
# BAExLzAtMAoCBQDsM78NAgEAMAoCAQACAgy0AgH/MAcCAQACAhNPMAoCBQDsNRCN
# AgEAMDYGCisGAQQBhFkKBAIxKDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMHoSCh
# CjAIAgEAAgMBhqAwDQYJKoZIhvcNAQELBQADggEBAEMBdmS3s3lW61vZ7RgS1Yr9
# jhZHmNKvPjHAy+2+MaI5QP3sTpZPmHRHy2TfDME5WB6zquFHZFx4FKes1zcldYrw
# wuk0hTj2vOZbquzed0kVS6Rgv2B0VfC7A9//ZPR0orC+RC9eVCCepKRaWvG5/1E5
# g+Lff/b9hoSYzq6DrmfMIkWHRE9jvsjfKYgyOt9+BfxCNDgnWsOVsbrJTaPJNEYg
# yH2X3DqyN2szXNb7Ph1crf5IaN1skcdTSQUSIX7op1UMx/+mCRuly/EdyGFrpqhi
# LlW/PRW+vuj0b05BA0mjgsoOjMrSvVfnhlS0MNpfUuUwNsBaIiXRMy9QfXk55CAx
# ggQNMIIECQIBATCBkzB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3Rv
# bjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0
# aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAA
# AgsRnVYpkvm/hQABAAACCzANBglghkgBZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkD
# MQ0GCyqGSIb3DQEJEAEEMC8GCSqGSIb3DQEJBDEiBCD2VGqT53R6ygzKAPPMpUU0
# 3cAmXz1z7CQOnWB9J4hDfDCB+gYLKoZIhvcNAQkQAi8xgeowgecwgeQwgb0EIDTV
# dKu6N77bh0wdOyF+ogRN8vKJcw5jnf2/EussYkozMIGYMIGApH4wfDELMAkGA1UE
# BhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc
# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0
# IFRpbWUtU3RhbXAgUENBIDIwMTACEzMAAAILEZ1WKZL5v4UAAQAAAgswIgQg4tqU
# GsV21uox/+tmN2xz4kvh9Sgr0VIlGLPunSvbFYAwDQYJKoZIhvcNAQELBQAEggIA
# AAbQq2fpUKl43t09QxHMFONl2x1Wz/Ef1gaorSiZzuV0qczEj5UTLO70NYDYUPY2
# YTeQFUFrsHwpgo+VsWqLjZVNq7GO0FQqAbEJ44uAOg4P6XPRH5beLWPwWDVDxAyo
# ydvNRNjSWKAtGu7fguJC/nUGbtoStkebHJ7YhVfkJfktFLr3L2IBTxgPbZrHsmTB
# DA9nfv0b4TQ+v+yCwTq3vTlWs7Q7Q6tC8n+N2n4kFUEm4912cpcxOXteE6QqkbOY
# wntNIDauWjNypJBt3tWbN2mmgrAsb3D6NDjaS5qgXsC7LqLcKmE7caVdIlsJ5OC0
# dh3t1XajFhssuTPURDCyW1IEbJmEfn6/GnFk4W4Rtc1x5vK/aF/mg9a4vELmxuii
# GzhT/rv5NeBYrTvAt7cBivJbwxsPIJO7SyvwkOv8DJZAIvzRQAzAECg23UwQhjMM
# hnZSk0bcSzRUfg1DvS1RJOl1v7EbVfqi9S5MwCg7lZm3V1gGHLvI8DOKEA/D/BYB
# iDFghfto85j75rq8ALl2/NZnuJF58v6ARyZ9pLKr8S9k/uhhxr6VKci8uueLuua9
# j94Pr7sDeTLyASz+SoIchvjGSP+wAY6sMvKDEYotFfeCG1w27Ku/pJQ1Vq8OHTl9
# wmYhrDbJwZrnTbf66LbQxuJWCpyOAiU2+yzjKcrgnMg=
# SIG # End signature block
