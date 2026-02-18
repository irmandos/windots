
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
The New-AzMigrateServerReplication cmdlet starts the replication for a particular discovered server in the Azure Migrate project.
.Link
https://learn.microsoft.com/powershell/module/az.migrate/new-azmigrateserverreplication
#>
function New-AzMigrateServerReplication {
    [OutputType([Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api202401.IJob])]
    [CmdletBinding(DefaultParameterSetName = 'ByIdDefaultUser', PositionalBinding = $false)]
    param(
        [Parameter(ParameterSetName = 'ByIdDefaultUser', Mandatory)]
        [Parameter(ParameterSetName = 'ByIdPowerUser', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the machine ID of the discovered server to be migrated.
        ${MachineId},

        [Parameter(ParameterSetName = 'ByInputObjectDefaultUser', Mandatory)]
        [Parameter(ParameterSetName = 'ByInputObjectPowerUser', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api202001.IVMwareMachine]
        # Specifies the discovered server to be migrated. The server object can be retrieved using the Get-AzMigrateServer cmdlet.
        ${InputObject},

        [Parameter(ParameterSetName = 'ByIdPowerUser', Mandatory)]
        [Parameter(ParameterSetName = 'ByInputObjectPowerUser', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api202401.IVMwareCbtDiskInput[]]
        # Specifies the disks on the source server to be included for replication.
        ${DiskToInclude},

        [Parameter(Mandatory)]
        [ValidateSet("NoLicenseType" , "WindowsServer")]
        [ArgumentCompleter( { "NoLicenseType" , "WindowsServer" })]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies if Azure Hybrid benefit is applicable for the source server to be migrated.
        ${LicenseType},

        [Parameter()]
        [ValidateSet("NoLicenseType" , "PAYG" , "AHUB")]
        [ArgumentCompleter( { "NoLicenseType" , "PAYG" , "AHUB" })]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies if Azure Hybrid benefit for SQL Server is applicable for the server to be migrated.
        ${SqlServerLicenseType},

        [Parameter()]
        [ValidateSet( "NotSpecified", "NoLicenseType", "LinuxServer")]
        [ArgumentCompleter( { "NotSpecified", "NoLicenseType", "LinuxServer" })]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies if Azure Hybrid benefit is applicable for the source linux server to be migrated.
        ${LinuxLicenseType},

        [Parameter(Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the Resource Group id within the destination Azure subscription to which the server needs to be migrated.
        ${TargetResourceGroupId},

        [Parameter(Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the Virtual Network id within the destination Azure subscription to which the server needs to be migrated.
        ${TargetNetworkId},

        [Parameter(Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the Subnet name within the destination Virtual Network to which the server needs to be migrated.
        ${TargetSubnetName},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the Virtual Network id within the destination Azure subscription to which the server needs to be test migrated.
        ${TestNetworkId},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the Subnet name within the destination Virtual Network to which the server needs to be test migrated.
        ${TestSubnetName},

        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Mapping.
        ${ReplicationContainerMapping},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Account id.
        ${VMWarerunasaccountID},

        [Parameter(Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the name of the Azure VM to be created.
        ${TargetVMName},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the SKU of the Azure VM to be created.
        ${TargetVMSize},

        [Parameter(ParameterSetName = 'ByIdDefaultUser')]
        [Parameter(ParameterSetName = 'ByInputObjectDefaultUser')]
        [Parameter(ParameterSetName = 'ByIdPowerUser')]
        [Parameter(ParameterSetName = 'ByInputObjectPowerUser')]
        [ValidateSet("true" , "false")]
        [ArgumentCompleter( { "true" , "false" })]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies if replication be auto-repaired in case change tracking is lost for the source server under replication.
        ${PerformAutoResync},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the Availability Set to be used for VM creationSpecifies the Availability Set to be used for VM creation.
        ${TargetAvailabilitySet},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the Availability Zone to be used for VM creation.
        ${TargetAvailabilityZone},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api202401.IVMwareCbtEnableMigrationInputTargetVmtags]
        # Specifies the tag to be used for VM creation.
        ${VMTag},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api202401.IVMwareCbtEnableMigrationInputTargetNicTags]
        # Specifies the tag to be used for NIC creation.
        ${NicTag},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api202401.IVMwareCbtEnableMigrationInputTargetDiskTags]
        # Specifies the tag to be used for disk creation.
        ${DiskTag},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.Collections.Hashtable]
        # Specifies the tag to be used for Resource creation.
        ${Tag},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the storage account to be used for boot diagnostics.
        ${TargetBootDiagnosticsStorageAccount},

        [Parameter(ParameterSetName = 'ByIdDefaultUser', Mandatory)]
        [Parameter(ParameterSetName = 'ByInputObjectDefaultUser', Mandatory)]
        [ValidateSet("Standard_LRS" , "Premium_LRS", "StandardSSD_LRS")]
        [ArgumentCompleter( { "Standard_LRS" , "Premium_LRS", "StandardSSD_LRS" })]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the type of disks to be used for the Azure VM.
        ${DiskType},
        
        [Parameter(ParameterSetName = 'ByIdDefaultUser', Mandatory)]
        [Parameter(ParameterSetName = 'ByInputObjectDefaultUser', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the Operating System disk for the source server to be migrated.
        ${OSDiskID},

        [Parameter(ParameterSetName = 'ByIdDefaultUser')]
        [Parameter(ParameterSetName = 'ByInputObjectDefaultUser')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the disk encyption set to be used.
        ${DiskEncryptionSetID},
    
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
        $parameterSet = $PSCmdlet.ParameterSetName
        $HasRunAsAccountId = $PSBoundParameters.ContainsKey('VMWarerunasaccountID')
        $HasTargetAVSet = $PSBoundParameters.ContainsKey('TargetAvailabilitySet')
        $HasTargetAVZone = $PSBoundParameters.ContainsKey('TargetAvailabilityZone')
        $HasVMTag = $PSBoundParameters.ContainsKey('VMTag')
        $HasNicTag = $PSBoundParameters.ContainsKey('NicTag')
        $HasDiskTag = $PSBoundParameters.ContainsKey('DiskTag')
        $HasTag = $PSBoundParameters.ContainsKey('Tag')
        $HasSqlServerLicenseType = $PSBoundParameters.ContainsKey('SqlServerLicenseType')
        $HasLinuxLicenseType = $PSBoundParameters.ContainsKey('LinuxLicenseType')
        $HasTargetBDStorage = $PSBoundParameters.ContainsKey('TargetBootDiagnosticsStorageAccount')
        $HasResync = $PSBoundParameters.ContainsKey('PerformAutoResync')
        $HasDiskEncryptionSetID = $PSBoundParameters.ContainsKey('DiskEncryptionSetID')
        $HasTargetVMSize = $PSBoundParameters.ContainsKey('TargetVMSize')

        $null = $PSBoundParameters.Remove('ReplicationContainerMapping')
        $null = $PSBoundParameters.Remove('VMWarerunasaccountID')
        $null = $PSBoundParameters.Remove('TargetAvailabilitySet')
        $null = $PSBoundParameters.Remove('TargetAvailabilityZone')
        $null = $PSBoundParameters.Remove('VMTag')
        $null = $PSBoundParameters.Remove('NicTag')
        $null = $PSBoundParameters.Remove('DiskTag')
        $null = $PSBoundParameters.Remove('Tag')
        $null = $PSBoundParameters.Remove('TargetBootDiagnosticsStorageAccount')
        $null = $PSBoundParameters.Remove('MachineId')
        $null = $PSBoundParameters.Remove('DiskToInclude')
        $null = $PSBoundParameters.Remove('TargetResourceGroupId')
        $null = $PSBoundParameters.Remove('TargetNetworkId')
        $null = $PSBoundParameters.Remove('TargetSubnetName')
        $null = $PSBoundParameters.Remove('TestNetworkId')
        $null = $PSBoundParameters.Remove('TestSubnetName')
        $null = $PSBoundParameters.Remove('TargetVMName')
        $null = $PSBoundParameters.Remove('TargetVMSize')
        $null = $PSBoundParameters.Remove('PerformAutoResync')
        $null = $PSBoundParameters.Remove('DiskType')
        $null = $PSBoundParameters.Remove('OSDiskID')
        $null = $PSBoundParameters.Remove('SqlServerLicenseType')
        $null = $PSBoundParameters.Remove('LinuxLicenseType')
        $null = $PSBoundParameters.Remove('LicenseType')
        $null = $PSBoundParameters.Remove('DiskEncryptionSetID')

        $null = $PSBoundParameters.Remove('MachineId')
        $null = $PSBoundParameters.Remove('InputObject')

        $validLicenseSpellings = @{ 
            NoLicenseType = "NoLicenseType";
            WindowsServer = "WindowsServer"
        }
        $LicenseType = $validLicenseSpellings[$LicenseType]

        if ($parameterSet -match "DefaultUser") {
            $validDiskTypeSpellings = @{ 
                Standard_LRS    = "Standard_LRS";
                Premium_LRS     = "Premium_LRS";
                StandardSSD_LRS = "StandardSSD_LRS"
            }
            $DiskType = $validDiskTypeSpellings[$DiskType]
            
            if ($parameterSet -eq "ByInputObjectDefaultUser") {
                foreach ($onPremDisk in $InputObject.Disk) {
                    if ($onPremDisk.Uuid -eq $OSDiskID) {
                        $OSDiskID = $onPremDisk.Uuid
                        break
                    }
                }
            }
        }

        # Get the discovered machine Id.
        if (($parameterSet -match 'InputObject')) {
            $MachineId = $InputObject.Id
        }

        # Get the discovered machine object.
        $MachineIdArray = $MachineId.Split("/")
        $SiteType = $MachineIdArray[7]
        $SiteName = $MachineIdArray[8]
        $ResourceGroupName = $MachineIdArray[4]
        $MachineName = $MachineIdArray[10]

        $null = $PSBoundParameters.Add("Name", $MachineName)
        $null = $PSBoundParameters.Add("ResourceGroupName", $ResourceGroupName)
        $null = $PSBoundParameters.Add("SiteName", $SiteName)
        $InputObject = Get-AzMigrateMachine @PSBoundParameters

        $null = $PSBoundParameters.Remove('Name')
        $null = $PSBoundParameters.Remove('ResourceGroupName')
        $null = $PSBoundParameters.Remove('SiteName')
        
        # Get the site to get project name.
        $null = $PSBoundParameters.Add('ResourceGroupName', $ResourceGroupName)
        $null = $PSBoundParameters.Add('SiteName', $SiteName)
        $siteObject = Az.Migrate\Get-AzMigrateSite @PSBoundParameters
        if ($siteObject -and ($siteObject.Count -ge 1)) {
            $ProjectName = $siteObject.DiscoverySolutionId.Split("/")[8]
        }
        else {
            throw "Site not found"
        }
            
        $null = $PSBoundParameters.Remove('ResourceGroupName')
        $null = $PSBoundParameters.Remove('SiteName')

        # Get the solution to get vault name.
        $null = $PSBoundParameters.Add("ResourceGroupName", $ResourceGroupName)
        $null = $PSBoundParameters.Add("Name", "Servers-Migration-ServerMigration")
        $null = $PSBoundParameters.Add("MigrateProjectName", $ProjectName)
            
        $solution = Az.Migrate\Get-AzMigrateSolution @PSBoundParameters
        $VaultName = $solution.DetailExtendedDetail.AdditionalProperties.vaultId.Split("/")[8]
            
        $null = $PSBoundParameters.Remove('ResourceGroupName')
        $null = $PSBoundParameters.Remove("Name")
        $null = $PSBoundParameters.Remove("MigrateProjectName")

        if ($SiteType -ne "VMwareSites") {
            throw "Provider not supported"
        }
           
        # This supports Multi-Vcenter feature.
        if (!$HasRunAsAccountId) {

            # Get the VCenter object.
            $vcenterId = $InputObject.VCenterId
            if ($null -eq $vcenterId){
                throw "Cannot find Vcenter ID in discovered machine."
            }

            $vCenterIdArray = $vcenterId.Split("/")
            $vCenterName = $vCenterIdArray[10] 
            $vCenterSite = $vCenterIdArray[8]
            $vCenterResourceGroupName = $vCenterIdArray[4]

            $null = $PSBoundParameters.Add("Name", $vCenterName)
            $null = $PSBoundParameters.Add("ResourceGroupName", $vCenterResourceGroupName)
            $null = $PSBoundParameters.Add("SiteName", $vCenterSite)

            $vCenter = Get-AzMigrateVCenter @PSBoundParameters

            $null = $PSBoundParameters.Remove('Name')
            $null = $PSBoundParameters.Remove('ResourceGroupName')
            $null = $PSBoundParameters.Remove('SiteName')

            # Get the run as account Id.
            $VMWarerunasaccountID = $vCenter.RunAsAccountId
            if ($VMWarerunasaccountID -eq "") {
                throw "Run As Account missing."
            } 
        }

        $policyName = "migrate" + $SiteName + "policy"
        $null = $PSBoundParameters.Add('ResourceGroupName', $ResourceGroupName)
        $null = $PSBoundParameters.Add('ResourceName', $VaultName)
        $null = $PSBoundParameters.Add('PolicyName', $policyName)
        $policyObj = Az.Migrate\Get-AzMigrateReplicationPolicy @PSBoundParameters -ErrorVariable notPresent -ErrorAction SilentlyContinue
        if ($policyObj -and ($policyObj.Count -ge 1)) {
            $PolicyId = $policyObj.Id
        }
        else {
            throw "The replication infrastructure is not initialized. Run the initialize-azmigratereplicationinfrastructure script again."
        }
        $null = $PSBoundParameters.Remove('ResourceGroupName')
        $null = $PSBoundParameters.Remove('ResourceName')
        $null = $PSBoundParameters.Remove('PolicyName')

        $null = $PSBoundParameters.Add('ResourceGroupName', $ResourceGroupName)
        $null = $PSBoundParameters.Add('ResourceName', $VaultName)
        $allFabrics = Az.Migrate\Get-AzMigrateReplicationFabric @PSBoundParameters
        $FabricName = ""
        if ($allFabrics -and ($allFabrics.length -gt 0)) {
            foreach ($fabric in $allFabrics) {
                if (($fabric.Property.CustomDetail.InstanceType -ceq "VMwareV2") -and ($fabric.Property.CustomDetail.VmwareSiteId.Split("/")[8] -ceq $SiteName)) {
                    $FabricName = $fabric.Name
                    break
                }
            }
        }
        if ($FabricName -eq "") {
            throw "Fabric not found for given resource group."
        }
                
        $null = $PSBoundParameters.Add('FabricName', $FabricName)
        $peContainers = Az.Migrate\Get-AzMigrateReplicationProtectionContainer @PSBoundParameters
        $ProtectionContainerName = ""
        if ($peContainers -and ($peContainers.length -gt 0)) {
            $ProtectionContainerName = $peContainers[0].Name
        }

        if ($ProtectionContainerName -eq "") {
            throw "Container not found for given resource group."
        }

        $mappingName = "containermapping"
        $null = $PSBoundParameters.Add('MappingName', $mappingName)
        $null = $PSBoundParameters.Add("ProtectionContainerName", $ProtectionContainerName)

        $mappingObject = Az.Migrate\Get-AzMigrateReplicationProtectionContainerMapping @PSBoundParameters -ErrorVariable notPresent -ErrorAction SilentlyContinue
        if ($mappingObject -and ($mappingObject.Count -ge 1)) {
            $TargetRegion = $mappingObject.ProviderSpecificDetail.TargetLocation
        }
        else {
            throw "The replication infrastructure is not initialized. Run the initialize-azmigratereplicationinfrastructure script again."
        }
        $null = $PSBoundParameters.Remove('MappingName')

        # Validate sku size
        $hasAzComputeModule = $true
        try { Import-Module Az.Compute }catch { $hasAzComputeModule = $false }
        if ($hasAzComputeModule -and $HasTargetVMSize) {
            $null = $PSBoundParameters.Remove("ProtectionContainerName")
            $null = $PSBoundParameters.Remove("FabricName")
            $null = $PSBoundParameters.Remove('ResourceGroupName')
            $null = $PSBoundParameters.Remove('ResourceName')
            $null = $PSBoundParameters.Remove('SubscriptionId')
            $null = $PSBoundParameters.Add('Location', $TargetRegion)
            $allAvailableSkus = Get-AzVMSize @PSBoundParameters -ErrorVariable notPresent -ErrorAction SilentlyContinue
            if ($null -ne $allAvailableSkus) {
                $matchingComputeSku = $allAvailableSkus | Where-Object { $_.Name -eq $TargetVMSize }
                if ($null -ne $matchingComputeSku) {
                    $TargetVMSize = $matchingComputeSku.Name
                }
            }

            $null = $PSBoundParameters.Remove('Location')
            $null = $PSBoundParameters.Add("ProtectionContainerName", $ProtectionContainerName)
            $null = $PSBoundParameters.Add('FabricName', $FabricName)
            $null = $PSBoundParameters.Add("ResourceGroupName", $ResourceGroupName)
            $null = $PSBoundParameters.Add('ResourceName', $VaultName)
            $null = $PSBoundParameters.Add('SubscriptionId', $SubscriptionId)
        }

        $HashCodeInput = $SiteName + $TargetRegion
        $Source = @"
using System;
public class HashFunctions
{
public static int hashForArtifact(String artifact)
{
        int hash = 0;
        int al = artifact.Length;
        int tl = 0;
        char[] ac = artifact.ToCharArray();
        while (tl < al)
        {
            hash = ((hash << 5) - hash) + ac[tl++] | 0;
        }
        return Math.Abs(hash);
}
}
"@
        Add-Type -TypeDefinition $Source -Language CSharp
        if ([string]::IsNullOrEmpty($mappingObject.ProviderSpecificDetail.KeyVaultUri)) {
             $LogStorageAccountID = $mappingObject.ProviderSpecificDetail.StorageAccountId
             $LogStorageAccountSas = $LogStorageAccountID.Split('/')[-1] + '-cacheSas'
        }
        else {
            $hash = [HashFunctions]::hashForArtifact($HashCodeInput)
            $LogStorageAccountID = "/subscriptions/" + $SubscriptionId + "/resourceGroups/" +
            $ResourceGroupName + "/providers/Microsoft.Storage/storageAccounts/migratelsa" + $hash
            $LogStorageAccountSas = "migratelsa" + $hash + '-cacheSas'
        }

        if (!$HasTargetBDStorage) {
            $TargetBootDiagnosticsStorageAccount = $LogStorageAccountID
        }

        # Storage accounts need to be in the same subscription as that of the VM.
        if (($null -ne $TargetBootDiagnosticsStorageAccount) -and ($TargetBootDiagnosticsStorageAccount.length -gt 1)) {
            $TargetBDSASubscriptionId = $TargetBootDiagnosticsStorageAccount.Split('/')[2]
            $TargetSubscriptionId = $TargetResourceGroupId.Split('/')[2]
            if ($TargetBDSASubscriptionId -ne $TargetSubscriptionId) {
                $TargetBootDiagnosticsStorageAccount = $null
            }
        }
            
        if (!$HasResync) {
            $PerformAutoResync = "true"
        }
        $validBooleanSpellings = @{ 
            true  = "true";
            false = "false"
        }
        $PerformAutoResync = $validBooleanSpellings[$PerformAutoResync]

        $null = $PSBoundParameters.Add("MigrationItemName", $MachineName)
        $null = $PSBoundParameters.Add("PolicyId", $PolicyId)

        $ProviderSpecificDetails = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api202401.VMwareCbtEnableMigrationInput]::new()
        $ProviderSpecificDetails.DataMoverRunAsAccountId = $VMWarerunasaccountID
        $ProviderSpecificDetails.SnapshotRunAsAccountId = $VMWarerunasaccountID
        $ProviderSpecificDetails.InstanceType = 'VMwareCbt'
        $ProviderSpecificDetails.LicenseType = $LicenseType
        $ProviderSpecificDetails.PerformAutoResync = $PerformAutoResync
        if ($HasTargetAVSet) {
            $ProviderSpecificDetails.TargetAvailabilitySetId = $TargetAvailabilitySet
        }
        if ($HasTargetAVZone) {
            $ProviderSpecificDetails.TargetAvailabilityZone = $TargetAvailabilityZone
        }

        if ($HasSqlServerLicenseType) {
            $validSqlLicenseSpellings = @{ 
                NoLicenseType = "NoLicenseType";
                PAYG          = "PAYG";
                AHUB          = "AHUB"
            }
            $SqlServerLicenseType = $validSqlLicenseSpellings[$SqlServerLicenseType]
            $ProviderSpecificDetails.SqlServerLicenseType = $SqlServerLicenseType
        }

        if ($HasLinuxLicenseType) {
            $validLinuxLicenseSpellings = @{ 
                NotSpecified  = "NotSpecified";
                NoLicenseType = "NoLicenseType";
                LinuxServer   = "LinuxServer";
            }
            $LinuxLicenseType = $validLinuxLicenseSpellings[$LinuxLicenseType]
            $ProviderSpecificDetails.LinuxLicenseType = $LinuxLicenseType
        }

        $UserProvidedTags = $null
        if ($HasTag -And $Tag) {
            $UserProvidedTags += @{"Tag" = $Tag }
        }

        if ($HasVMTag -And $VMTag) {
            $UserProvidedTags += @{"VMTag" = $VMTag }
        }

        if ($HasNicTag -And $NicTag) {
            $UserProvidedTags += @{"NicTag" = $NicTag }
        }

        if ($HasDiskTag -And $DiskTag) {
            $UserProvidedTags += @{"DiskTag" = $DiskTag }
        }

        foreach ($tagtype in $UserProvidedTags.Keys) {
            $IllegalCharKey = New-Object Collections.Generic.List[String]
            $ExceededLengthKey = New-Object Collections.Generic.List[String]
            $ExceededLengthValue = New-Object Collections.Generic.List[String]
            $ResourceTag = $($UserProvidedTags.Item($tagtype))

            if ($ResourceTag.Count -gt 50) {
                throw "InvalidTags : Too many tags specified. Requested tag count - '$($ResourceTag.Count)'. Maximum number of tags allowed - '50'."
            }

            foreach ($key in $ResourceTag.Keys) {
                if ($key.length -eq 0) {
                    throw "InvalidTagName : The tag name must be non-null, non-empty and non-whitespace only. Please provide an actual value."
                }

                if ($key.length -gt 512) {
                    $ExceededLengthKey.add($key)
                }

                if ($key -match "[<>%&\?/.]") {
                    $IllegalCharKey.add($key)
                }

                if ($($ResourceTag.Item($key)).length -gt 256) {
                    $ExceededLengthValue.add($($ResourceTag.Item($key)))
                }
            }

            if ($IllegalCharKey.Count -gt 0) {
                throw "InvalidTagNameCharacters : The tag names '$($IllegalCharKey -join ', ')' have reserved characters '<,>,%,&,\,?,/' or control characters."
            }

            if ($ExceededLengthKey.Count -gt 0) {
                throw "InvalidTagName : Tag key too large. Following tag name '$($ExceededLengthKey -join ', ')' exceeded the maximum length. Maximum allowed length for tag name - '512' characters."
            }

            if ($ExceededLengthValue.Count -gt 0) {
                throw "InvalidTagValueLength : Tag value too large. Following tag value '$($ExceededLengthValue -join ', ')' exceeded the maximum length. Maximum allowed length for tag value - '256' characters."
            }

            if ($tagtype -eq "Tag" -or $tagtype -eq "DiskTag") {
                $ProviderSpecificDetails.SeedDiskTag = $ResourceTag
                $ProviderSpecificDetails.TargetDiskTag = $ResourceTag
            }

            if ($tagtype -eq "Tag" -or $tagtype -eq "NicTag") {
                $ProviderSpecificDetails.TargetNicTag = $ResourceTag
            }

            if ($tagtype -eq "Tag" -or $tagtype -eq "VMTag") {
                $ProviderSpecificDetails.TargetVmTag = $ResourceTag
            }
        }

        $ProviderSpecificDetails.TargetBootDiagnosticsStorageAccountId = $TargetBootDiagnosticsStorageAccount
        $ProviderSpecificDetails.TargetNetworkId = $TargetNetworkId
        $ProviderSpecificDetails.TargetResourceGroupId = $TargetResourceGroupId
        $ProviderSpecificDetails.TargetSubnetName = $TargetSubnetName
        $ProviderSpecificDetails.TestNetworkId = $TestNetworkId
        $ProviderSpecificDetails.TestSubnetName = $TestSubnetName

        if ($TargetVMName.length -gt 64 -or $TargetVMName.length -eq 0) {
            throw "The target virtual machine name must be between 1 and 64 characters long."
        }

        Import-Module Az.Resources
        $vmId = $ProviderSpecificDetails.TargetResourceGroupId + "/providers/Microsoft.Compute/virtualMachines/" + $TargetVMName
        $VMNamePresentinRg = Get-AzResource -ResourceId $vmId -ErrorVariable notPresent -ErrorAction SilentlyContinue
        if ($VMNamePresentinRg) {
            throw "The target virtual machine name must be unique in the target resource group."
        }

        if ($TargetVMName -notmatch "^[^_\W][a-zA-Z0-9\-]{0,63}(?<![-._])$") {
            throw "The target virtual machine name must begin with a letter or number, and can contain only letters, numbers, or hyphens(-). The names cannot contain special characters \/""[]:|<>+=;,?*@&, whitespace, or begin with '_' or end with '.' or '-'."
        }

        $ProviderSpecificDetails.TargetVMName = $TargetVMName
        if ($HasTargetVMSize) { $ProviderSpecificDetails.TargetVMSize = $TargetVMSize }
        $ProviderSpecificDetails.VmwareMachineId = $MachineId
        $uniqueDiskUuids = [System.Collections.Generic.HashSet[String]]::new([StringComparer]::InvariantCultureIgnoreCase)

        if ($parameterSet -match 'DefaultUser') {
            [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api202401.IVMwareCbtDiskInput[]]$DiskToInclude = @()
            foreach ($onPremDisk in $InputObject.Disk) {
                if ($onPremDisk.Uuid -ne $OSDiskID) {
                    $DiskObject = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api202401.VMwareCbtDiskInput]::new()
                    $DiskObject.DiskId = $onPremDisk.Uuid
                    $DiskObject.DiskType = "Standard_LRS"
                    $DiskObject.IsOSDisk = "false"
                    $DiskObject.LogStorageAccountSasSecretName = $LogStorageAccountSas
                    $DiskObject.LogStorageAccountId = $LogStorageAccountID
                    if ($HasDiskEncryptionSetID) {
                        $DiskObject.DiskEncryptionSetId = $DiskEncryptionSetID
                    }
                    $DiskToInclude += $DiskObject
                }
            }
            $DiskObject = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api202401.VMwareCbtDiskInput]::new()
            $DiskObject.DiskId = $OSDiskID
            $DiskObject.DiskType = $DiskType
            $DiskObject.IsOSDisk = "true"
            $DiskObject.LogStorageAccountSasSecretName = $LogStorageAccountSas
            $DiskObject.LogStorageAccountId = $LogStorageAccountID
            if ($HasDiskEncryptionSetID) {
                $DiskObject.DiskEncryptionSetId = $DiskEncryptionSetID
            }

            $DiskToInclude += $DiskObject
            $ProviderSpecificDetails.DisksToInclude = $DiskToInclude
        }
        else {
            foreach ($DiskObject in $DiskToInclude) {
                $DiskObject.LogStorageAccountSasSecretName = $LogStorageAccountSas
                $DiskObject.LogStorageAccountId = $LogStorageAccountID
            }
            $ProviderSpecificDetails.DisksToInclude = $DiskToInclude
        }


        # Check for duplicate disk UUID in user input/discovered VM and Premium V2 disk validations.
        foreach ($disk in $ProviderSpecificDetails.DisksToInclude)
        {
            if ($uniqueDiskUuids.Contains($disk.DiskId)) {
                throw "The disk uuid '$($disk.DiskId)' is already taken."
            }

            if (-not $HasTargetAVZone -and $disk.DiskType -eq "PremiumV2_LRS") {
                throw "Premium SSD V2 disk can only be attached to zonal VMs."
            }

            $res = $uniqueDiskUuids.Add($disk.DiskId)
        }

        $null = $PSBoundParameters.add('ProviderSpecificDetail', $ProviderSpecificDetails)
        $null = $PSBoundParameters.Add('NoWait', $true)
        $output = Az.Migrate.internal\New-AzMigrateReplicationMigrationItem @PSBoundParameters
        $JobName = $output.Target.Split("/")[12].Split("?")[0]
        $null = $PSBoundParameters.Remove('NoWait')
        $null = $PSBoundParameters.Remove('ProviderSpecificDetail')
        $null = $PSBoundParameters.Remove("ResourceGroupName")
        $null = $PSBoundParameters.Remove("ResourceName")
        $null = $PSBoundParameters.Remove("FabricName")
        $null = $PSBoundParameters.Remove("MigrationItemName")
        $null = $PSBoundParameters.Remove("ProtectionContainerName")
        $null = $PSBoundParameters.Remove("PolicyId")

        $null = $PSBoundParameters.Add('JobName', $JobName)
        $null = $PSBoundParameters.Add('ResourceName', $VaultName)
        $null = $PSBoundParameters.Add('ResourceGroupName', $ResourceGroupName)
        
        return Az.Migrate.internal\Get-AzMigrateReplicationJob @PSBoundParameters
        
    }

}   
# SIG # Begin signature block
# MIIoUgYJKoZIhvcNAQcCoIIoQzCCKD8CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCASfKnyWLqJ9r/z
# eScDorI16lQwpmKL/rD0CpIwQJUK1KCCDYUwggYDMIID66ADAgECAhMzAAAEA73V
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
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIAZL
# n0aW4h49WhD6bJj282gZ7aVOuHFlb5wpm9hk6WjuMEIGCisGAQQBgjcCAQwxNDAy
# oBSAEgBNAGkAYwByAG8AcwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20wDQYJKoZIhvcNAQEBBQAEggEAbnKlmBaWMQlU1hHuI4drYpYa+WZWtRhOkPxP
# tSG9rNUCNh3wN+qny+OhV13loDEYDpVP7MlVmntm4veVjuwooThbY6ZbKUmksslI
# ZBpfalgM8G+G0bne8yAuUUpnHoJTff7e7PeWVLHKygr/Hq5Q+jzzyLIEl9K9ET7m
# 6YIJHV2O6DZXMtnoWS5qLDtaMAEYHyecxPtIXjfPxpYI37wvPzF2tu3TRJTOiDQU
# ppDlW0P9gljfi1oMQ21XwvoaVG6NSJfgwchT5SnU930Hzm0/3SDswj6vZRsinTuO
# qAmu1auUdHuITxQTFxN++sd9ModqMjlEMAIuZDqCUra6aBnRpKGCF60wghepBgor
# BgEEAYI3AwMBMYIXmTCCF5UGCSqGSIb3DQEHAqCCF4YwgheCAgEDMQ8wDQYJYIZI
# AWUDBAIBBQAwggFaBgsqhkiG9w0BCRABBKCCAUkEggFFMIIBQQIBAQYKKwYBBAGE
# WQoDATAxMA0GCWCGSAFlAwQCAQUABCDrNC8CzJfVVNhlZAv0UzLZGF6xYbf8Su+l
# y8okQ+HpegIGZ7YsQOexGBMyMDI1MDIyNTA3MDMzMy4xNjlaMASAAgH0oIHZpIHW
# MIHTMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQL
# EyRNaWNyb3NvZnQgSXJlbGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJzAlBgNVBAsT
# Hm5TaGllbGQgVFNTIEVTTjozMjFBLTA1RTAtRDk0NzElMCMGA1UEAxMcTWljcm9z
# b2Z0IFRpbWUtU3RhbXAgU2VydmljZaCCEfswggcoMIIFEKADAgECAhMzAAAB+KOh
# JgwMQEj+AAEAAAH4MA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFBDQSAyMDEwMB4XDTI0MDcyNTE4MzEwOFoXDTI1MTAyMjE4MzEwOFowgdMxCzAJ
# BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xLTArBgNVBAsTJE1pY3Jv
# c29mdCBJcmVsYW5kIE9wZXJhdGlvbnMgTGltaXRlZDEnMCUGA1UECxMeblNoaWVs
# ZCBUU1MgRVNOOjMyMUEtMDVFMC1EOTQ3MSUwIwYDVQQDExxNaWNyb3NvZnQgVGlt
# ZS1TdGFtcCBTZXJ2aWNlMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA
# xR23pXYnD2BuODdeXs2Cu/T5kKI+bAw8cbtN50Cm/FArjXyL4RTqMe6laQ/CqeMT
# xgckvZr1JrW0Mi4F15rx/VveGhKBmob45DmOcV5xyx7h9Tk59NAl5PNMAWKAIWf2
# 70SWAAWxQbpVIhhPWCnVV3otVvahEad8pMmoSXrT5Z7Nk1RnB70A2bq9Hk8wIeC3
# vBuxEX2E8X50IgAHsyaR9roFq3ErzUEHlS8YnSq33ui5uBcrFOcFOCZILuVFVTgE
# qSrX4UiX0etqi7jUtKypgIflaZcV5cI5XI/eCxY8wDNmBprhYMNlYxdmQ9aLRDcT
# KWtddWpnJtyl5e3gHuYoj8xuDQ0XZNy7ESRwJIK03+rTZqfaYyM4XSK1s0aa+mO6
# 9vo/NmJ4R/f1+KucBPJ4yUdbqJWM3xMvBwLYycvigI/WK4kgPog0UBNczaQwDVXp
# cU+TMcOvWP8HBWmWJQImTZInAFivXqUaBbo3wAfPNbsQpvNNGu/12pg0F8O/CdRf
# gPHfOhIWQ0D8ALCY+LsiwbzcejbrVl4N9fn2wOg2sDa8RfNoD614I0pFjy/lq1Ns
# Bo9V4GZBikzX7ZjWCRgd1FCBXGpfpDikHjQ05YOkAakdWDT2bGSaUZJGVYtepIpP
# TAs1gd/vUogcdiL51o7shuHIlB6QSUiQ24XYhRbbQCECAwEAAaOCAUkwggFFMB0G
# A1UdDgQWBBS9zsZzz57QlT5nrt/oitLv1OQ7tjAfBgNVHSMEGDAWgBSfpxVdAF5i
# XYP05dJlpxtTNRnpcjBfBgNVHR8EWDBWMFSgUqBQhk5odHRwOi8vd3d3Lm1pY3Jv
# c29mdC5jb20vcGtpb3BzL2NybC9NaWNyb3NvZnQlMjBUaW1lLVN0YW1wJTIwUENB
# JTIwMjAxMCgxKS5jcmwwbAYIKwYBBQUHAQEEYDBeMFwGCCsGAQUFBzAChlBodHRw
# Oi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMFRp
# bWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNydDAMBgNVHRMBAf8EAjAAMBYGA1Ud
# JQEB/wQMMAoGCCsGAQUFBwMIMA4GA1UdDwEB/wQEAwIHgDANBgkqhkiG9w0BAQsF
# AAOCAgEAYfk8GzzpEVnGl7y6oXoytCb42Hx6TOA0+dkaBI36ftDE9tLubUa/xMbH
# B5rcNiRhFHZ93RefdPpc4+FF0DAl5lP8xKAO+293RWPKDFOFIxgtZY08t8D9cSQp
# gGUzyw3lETZebNLEA17A/CTpA2F9uh8j84KygeEbj+bidWDiEfayoH2A5/5ywJJx
# IuLzFVHacvWxSCKoF9hlSrZSG5fXWS3namf4tt690UT6AGyWLFWe895coFPxm/m0
# UIMjjp9VRFH7nb3Ng2Q4gPS9E5ZTMZ6nAlmUicDj0NXAs2wQuQrnYnbRAJ/DQW35
# qLo7Daw9AsItqjFhbMcG68gDc4j74L2KYe/2goBHLwzSn5UDftS1HZI0ZRsqmNHI
# 0TZvvUWX9ajm6SfLBTEtoTo6gLOX0UD/9rrhGjdkiCw4SwU5osClgqgiNMK5ndk2
# gxFlDXHCyLp5qB6BoPpc82RhO0yCzoP9gv7zv2EocAWEsqE5+0Wmu5uarmfvcziL
# fU1SY240OZW8ld4sS8fnybn/jDMmFAhazV1zH0QERWEsfLSpwkOXaImWNFJ5lmcn
# f1VTm6cmfasScYtElpjqZ9GooCmk1XFApORPs/PO43IcFmPRwagt00iQSw+rBeIH
# 00KQq+FJT/62SB70g9g/R8TS6k6b/wt2UWhqrW+Q8lw6Xzgex/YwggdxMIIFWaAD
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
# Hm5TaGllbGQgVFNTIEVTTjozMjFBLTA1RTAtRDk0NzElMCMGA1UEAxMcTWljcm9z
# b2Z0IFRpbWUtU3RhbXAgU2VydmljZaIjCgEBMAcGBSsOAwIaAxUAtkQt/ebWSQ5D
# nG+aKRzPELCFE9GggYMwgYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAx
# MDANBgkqhkiG9w0BAQsFAAIFAOtnQdcwIhgPMjAyNTAyMjQxOTA3MDNaGA8yMDI1
# MDIyNTE5MDcwM1owdDA6BgorBgEEAYRZCgQBMSwwKjAKAgUA62dB1wIBADAHAgEA
# AgId6TAHAgEAAgITcTAKAgUA62iTVwIBADA2BgorBgEEAYRZCgQCMSgwJjAMBgor
# BgEEAYRZCgMCoAowCAIBAAIDB6EgoQowCAIBAAIDAYagMA0GCSqGSIb3DQEBCwUA
# A4IBAQA0tciEMQ0TV4co8NSnnsxUjOEkw4K74agPl5DClvBTXNw9RfED4VhgLuzm
# t6JeCDHeF3FGonQdAlYCqi0fZBS6zMzP1+xEKqDcCx7XQj1QrqnKb7ZAPu+hXf7S
# I+GAwwibVrYtLOGAbPJXctLUThg5QnoobfBJD4c7YecHmPmO5WMJF40ZUb8ZB1Do
# 1q+uN1PqTAv27ff0ucx0ITYRlT2U+w5dyihvyuy4CIsEYf/quXs4sh/yy9uvWRoK
# zOrREjFzIulV5ExkZG0pJqYtaQhNXgyrk5GiEuwvSCiztReU+aI2zDuhq8A3nDxd
# ymlZRcSZ7zIsM/1VyK2i8knTqXf4MYIEDTCCBAkCAQEwgZMwfDELMAkGA1UEBhMC
# VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNV
# BAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRp
# bWUtU3RhbXAgUENBIDIwMTACEzMAAAH4o6EmDAxASP4AAQAAAfgwDQYJYIZIAWUD
# BAIBBQCgggFKMBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAvBgkqhkiG9w0B
# CQQxIgQgLqWioCR/g842j9/p7sentFWeSU48vucRYTCSQlzq1vkwgfoGCyqGSIb3
# DQEJEAIvMYHqMIHnMIHkMIG9BCDvzDPyXw1UkAUFYt8bR4UdjM90Qv5xnVaiKD3I
# 0Zz3WjCBmDCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9u
# MRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRp
# b24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAAB
# +KOhJgwMQEj+AAEAAAH4MCIEIJVggWP1VL9W6Bl4hJL958t+C0gnFrXP+DclWHt4
# V4OKMA0GCSqGSIb3DQEBCwUABIICAIboXJIwnRf14Itw2qtgmIaQWXXUCANQLtVT
# TjQL18secjT88Jyne8t+Nq5CnWOsOBRkTGXaFqV/WDMB1yJkOoXxgc4eBP6QpNUv
# 2hTF0L8Z81hgGbqsJWDck28g2cWYTwao8tNDX58rlGjpxsUgW53vCpsGHYCPJ6xz
# K3f1+B5JexlivPwJufAUDzOlM1VgB14U1S60N80xIXYaAwMySbAtnAvBCmx+M0RL
# hn3bH9vUr7IwpFnnYwmkDO6F2TlQsJUnXLBqwMQtrAm7lwTctBCYW56oVYOZIlaT
# V0fU5HmIh+CsKOqsn4+XQv3trVEO95FREmmhNWvZxLG4leMCeORtmylzBd2KSs5a
# TOk2OCwkrJ3SaB0upXBoGkjcmdP2ycaNwb2LZnN6/yXo0Mf62o6C5pzg88Wa8UIT
# dFA4HJf9anYZExVx2gPuRsMcYE1W+QnP87AeNBwyLxPgvy55e5hYU5kf2nRUp+ZQ
# Ca5CddpDAZdRjpb59mLB6ZeM+5ekg5zWckkT4eVlMS3MTCbhQt17FWMttfwkedwm
# a/FG/3ijmvZSRKfIRanR14nJbX5X1d5QtL0wMON7qOJJuurzFy+Fc/9pSsjQQ4Ot
# wDOjhGPzgbHrxVnOOR08aiIJzK3ArJ5OpeZylkmvF3+3whNNXpa5g/axiVCvwvLF
# PRpEgxMU
# SIG # End signature block
