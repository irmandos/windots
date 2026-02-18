
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
    [OutputType([Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api202301.IJob])]
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
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api202301.IVMwareCbtDiskInput[]]
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
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api202301.IVMwareCbtEnableMigrationInputTargetVmtags]
        # Specifies the tag to be used for VM creation.
        ${VMTag},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api202301.IVMwareCbtEnableMigrationInputTargetNicTags]
        # Specifies the tag to be used for NIC creation.
        ${NicTag},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api202301.IVMwareCbtEnableMigrationInputTargetDiskTags]
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

        $ProviderSpecificDetails = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api202301.VMwareCbtEnableMigrationInput]::new()
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
            [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api202301.IVMwareCbtDiskInput[]]$DiskToInclude = @()
            foreach ($onPremDisk in $InputObject.Disk) {
                if ($onPremDisk.Uuid -ne $OSDiskID) {
                    $DiskObject = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api202301.VMwareCbtDiskInput]::new()
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
            $DiskObject = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api202301.VMwareCbtDiskInput]::new()
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


        # Check for duplicate disk UUID in user input/discovered VM.
        foreach ($disk in $ProviderSpecificDetails.DisksToInclude)
        {
            if ($uniqueDiskUuids.Contains($disk.DiskId)) {
                throw "The disk uuid '$($disk.DiskId)' is already taken."
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
# MIInzgYJKoZIhvcNAQcCoIInvzCCJ7sCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBgib0Ta4TQmnJ6
# vqJCF1TrhnepeWz+YCBh5sL9TYRNQqCCDYUwggYDMIID66ADAgECAhMzAAADri01
# UchTj1UdAAAAAAOuMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjMxMTE2MTkwODU5WhcNMjQxMTE0MTkwODU5WjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQD0IPymNjfDEKg+YyE6SjDvJwKW1+pieqTjAY0CnOHZ1Nj5irGjNZPMlQ4HfxXG
# yAVCZcEWE4x2sZgam872R1s0+TAelOtbqFmoW4suJHAYoTHhkznNVKpscm5fZ899
# QnReZv5WtWwbD8HAFXbPPStW2JKCqPcZ54Y6wbuWV9bKtKPImqbkMcTejTgEAj82
# 6GQc6/Th66Koka8cUIvz59e/IP04DGrh9wkq2jIFvQ8EDegw1B4KyJTIs76+hmpV
# M5SwBZjRs3liOQrierkNVo11WuujB3kBf2CbPoP9MlOyyezqkMIbTRj4OHeKlamd
# WaSFhwHLJRIQpfc8sLwOSIBBAgMBAAGjggGCMIIBfjAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQUhx/vdKmXhwc4WiWXbsf0I53h8T8w
# VAYDVR0RBE0wS6RJMEcxLTArBgNVBAsTJE1pY3Jvc29mdCBJcmVsYW5kIE9wZXJh
# dGlvbnMgTGltaXRlZDEWMBQGA1UEBRMNMjMwMDEyKzUwMTgzNjAfBgNVHSMEGDAW
# gBRIbmTlUAXTgqoXNzcitW2oynUClTBUBgNVHR8ETTBLMEmgR6BFhkNodHRwOi8v
# d3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NybC9NaWNDb2RTaWdQQ0EyMDExXzIw
# MTEtMDctMDguY3JsMGEGCCsGAQUFBwEBBFUwUzBRBggrBgEFBQcwAoZFaHR0cDov
# L3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jZXJ0cy9NaWNDb2RTaWdQQ0EyMDEx
# XzIwMTEtMDctMDguY3J0MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQADggIB
# AGrJYDUS7s8o0yNprGXRXuAnRcHKxSjFmW4wclcUTYsQZkhnbMwthWM6cAYb/h2W
# 5GNKtlmj/y/CThe3y/o0EH2h+jwfU/9eJ0fK1ZO/2WD0xi777qU+a7l8KjMPdwjY
# 0tk9bYEGEZfYPRHy1AGPQVuZlG4i5ymJDsMrcIcqV8pxzsw/yk/O4y/nlOjHz4oV
# APU0br5t9tgD8E08GSDi3I6H57Ftod9w26h0MlQiOr10Xqhr5iPLS7SlQwj8HW37
# ybqsmjQpKhmWul6xiXSNGGm36GarHy4Q1egYlxhlUnk3ZKSr3QtWIo1GGL03hT57
# xzjL25fKiZQX/q+II8nuG5M0Qmjvl6Egltr4hZ3e3FQRzRHfLoNPq3ELpxbWdH8t
# Nuj0j/x9Crnfwbki8n57mJKI5JVWRWTSLmbTcDDLkTZlJLg9V1BIJwXGY3i2kR9i
# 5HsADL8YlW0gMWVSlKB1eiSlK6LmFi0rVH16dde+j5T/EaQtFz6qngN7d1lvO7uk
# 6rtX+MLKG4LDRsQgBTi6sIYiKntMjoYFHMPvI/OMUip5ljtLitVbkFGfagSqmbxK
# 7rJMhC8wiTzHanBg1Rrbff1niBbnFbbV4UDmYumjs1FIpFCazk6AADXxoKCo5TsO
# zSHqr9gHgGYQC2hMyX9MGLIpowYCURx3L7kUiGbOiMwaMIIHejCCBWKgAwIBAgIK
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
# cVZOSEXAQsmbdlsKgEhr/Xmfwb1tbWrJUnMTDXpQzTGCGZ8wghmbAgEBMIGVMH4x
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01p
# Y3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTECEzMAAAOuLTVRyFOPVR0AAAAA
# A64wDQYJYIZIAWUDBAIBBQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEICsh
# WztRh9HKcMsFanZ6imgGTuUHAZCrXWeWOFWFtrPNMEIGCisGAQQBgjcCAQwxNDAy
# oBSAEgBNAGkAYwByAG8AcwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20wDQYJKoZIhvcNAQEBBQAEggEA6rBQJDSQJ8bit5pqDpl79BfpnCEYyOqWwlU1
# qhv1JTYsEev6XyHR1TFgaQqvNBzgoDI/aEK+x09gYZP1O6PRmr57nlBmyiXdAEOr
# BFs+lZaHVxGp27kxjqBuUiFI4hv1/kLcbdVdb/Y2KWsuKBdCq/g9wswOs04O3Exy
# Yut56PEWcJx1LxV86TVEzmPTiadJxxFFB5pCbzcrrpRD+kDwoMKx07xu4VqLao7e
# P1tDyVz0Q6ZaHfUMNToNnPozI4wjR2epoy4mQFRT31C5ce4SXJEsJb6rO4u/TuGS
# XCMO8MVXFodh0YJs5lyfcDKKg1Pc/lCzWYFD/oYa/qKQ6J9cYqGCFykwghclBgor
# BgEEAYI3AwMBMYIXFTCCFxEGCSqGSIb3DQEHAqCCFwIwghb+AgEDMQ8wDQYJYIZI
# AWUDBAIBBQAwggFZBgsqhkiG9w0BCRABBKCCAUgEggFEMIIBQAIBAQYKKwYBBAGE
# WQoDATAxMA0GCWCGSAFlAwQCAQUABCArE2Hy6XJVl2vhg44SZ2FzOoEuY+M+QA0D
# BoURmMfrmgIGZnMSXLGHGBMyMDI0MDcwNDA4MzA1OC44NjVaMASAAgH0oIHYpIHV
# MIHSMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQL
# EyRNaWNyb3NvZnQgSXJlbGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJjAkBgNVBAsT
# HVRoYWxlcyBUU1MgRVNOOkQwODItNEJGRC1FRUJBMSUwIwYDVQQDExxNaWNyb3Nv
# ZnQgVGltZS1TdGFtcCBTZXJ2aWNloIIReDCCBycwggUPoAMCAQICEzMAAAHcweCM
# wl9YXo4AAQAAAdwwDQYJKoZIhvcNAQELBQAwfDELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAg
# UENBIDIwMTAwHhcNMjMxMDEyMTkwNzA2WhcNMjUwMTEwMTkwNzA2WjCB0jELMAkG
# A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
# HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEtMCsGA1UECxMkTWljcm9z
# b2Z0IElyZWxhbmQgT3BlcmF0aW9ucyBMaW1pdGVkMSYwJAYDVQQLEx1UaGFsZXMg
# VFNTIEVTTjpEMDgyLTRCRkQtRUVCQTElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUt
# U3RhbXAgU2VydmljZTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAIvI
# syA1sjg9kSKJzelrUWF5ShqYWL83amn3SE5JyIVPUC7F6qTcLphhHZ9idf21f0Ra
# GrU8EHydF8NxPMR2KVNiAtCGPJa8kV1CGvn3beGB2m2ltmqJanG71mAywrkKATYn
# iwKLPQLJ00EkXw5TSwfmJXbdgQLFlHyfA5Kg+pUsJXzqumkIvEr0DXPvptAGqkdF
# LKwo4BTlEgnvzeTfXukzX8vQtTALfVJuTUgRU7zoP/RFWt3WagahZ6UloI0FC8Xl
# BQDVDX5JeMEsx7jgJDdEnK44Y8gHuEWRDq+SG9Xo0GIOjiuTWD5uv3vlEmIAyR/7
# rSFvcLnwAqMdqcy/iqQPMlDOcd0AbniP8ia1BQEUnfZT3UxyK9rLB/SRiKPyHDlg
# 8oWwXyiv3+bGB6dmdM61ur6nUtfDf51lPcKhK4Vo83pOE1/niWlVnEHQV9NJ5/Db
# USqW2RqTUa2O2KuvsyRGMEgjGJA12/SqrRqlvE2fiN5ZmZVtqSPWaIasx7a0GB+f
# dTw+geRn6Mo2S6+/bZEwS/0IJ5gcKGinNbfyQ1xrvWXPtXzKOfjkh75iRuXourGV
# PRqkmz5UYz+R5ybMJWj+mfcGqz2hXV8iZnCZDBrrnZivnErCMh5Flfg8496pT0ph
# jUTH2GChHIvE4SDSk2hwWP/uHB9gEs8p/9Pe/mt9AgMBAAGjggFJMIIBRTAdBgNV
# HQ4EFgQU6HPSBd0OfEX3uNWsdkSraUGe3dswHwYDVR0jBBgwFoAUn6cVXQBeYl2D
# 9OXSZacbUzUZ6XIwXwYDVR0fBFgwVjBUoFKgUIZOaHR0cDovL3d3dy5taWNyb3Nv
# ZnQuY29tL3BraW9wcy9jcmwvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUy
# MDIwMTAoMSkuY3JsMGwGCCsGAQUFBwEBBGAwXjBcBggrBgEFBQcwAoZQaHR0cDov
# L3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jZXJ0cy9NaWNyb3NvZnQlMjBUaW1l
# LVN0YW1wJTIwUENBJTIwMjAxMCgxKS5jcnQwDAYDVR0TAQH/BAIwADAWBgNVHSUB
# Af8EDDAKBggrBgEFBQcDCDAOBgNVHQ8BAf8EBAMCB4AwDQYJKoZIhvcNAQELBQAD
# ggIBANnrb8Ewr8eX/H1sKt3rnwTDx4AqgHbkMNQo+kUGwCINXS3y1GUcdqsK/R1g
# 6Tf7tNx1q0NpKk1JTupUJfHdExKtkuhHA+82lT7yISp/Y74dqJ03RCT4Q+8ooQXT
# MzxiewfErVLt8WefebncST0i6ypKv87pCYkxM24bbqbM/V+M5VBppCUs7R+cETiz
# /zEA1AbZL/viXtHmryA0CGd+Pt9c+adsYfm7qe5UMnS0f/YJmEEMkEqGXCzyLK+d
# h+UsFi0d4lkdcE+Zq5JNjIHesX1wztGVAtvX0DYDZdN2WZ1kk+hOMblUV/L8n1YW
# zhP/5XQnYl03AfXErn+1Eatylifzd3ChJ1xuGG76YbWgiRXnDvCiwDqvUJevVRY1
# qy4y4vlVKaShtbdfgPyGeeJ/YcSBONOc0DNTWbjMbL50qeIEC0lHSpL2rRYNVu3h
# sHzG8n5u5CQajPwx9PzpsZIeFTNHyVF6kujI4Vo9NvO/zF8Ot44IMj4M7UX9Za4Q
# wGf5B71x57OjaX53gxT4vzoHvEBXF9qCmHRgXBLbRomJfDn60alzv7dpCVQIuQ06
# 2nyIZKnsXxzuKFb0TjXWw6OFpG1bsjXpOo5DMHkysribxHor4Yz5dZjVyHANyKo0
# bSrAlVeihcaG5F74SZT8FtyHAW6IgLc5w/3D+R1obDhKZ21WMIIHcTCCBVmgAwIB
# AgITMwAAABXF52ueAptJmQAAAAAAFTANBgkqhkiG9w0BAQsFADCBiDELMAkGA1UE
# BhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc
# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0
# IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5IDIwMTAwHhcNMjEwOTMwMTgyMjI1
# WhcNMzAwOTMwMTgzMjI1WjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
# Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBv
# cmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDCC
# AiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAOThpkzntHIhC3miy9ckeb0O
# 1YLT/e6cBwfSqWxOdcjKNVf2AX9sSuDivbk+F2Az/1xPx2b3lVNxWuJ+Slr+uDZn
# hUYjDLWNE893MsAQGOhgfWpSg0S3po5GawcU88V29YZQ3MFEyHFcUTE3oAo4bo3t
# 1w/YJlN8OWECesSq/XJprx2rrPY2vjUmZNqYO7oaezOtgFt+jBAcnVL+tuhiJdxq
# D89d9P6OU8/W7IVWTe/dvI2k45GPsjksUZzpcGkNyjYtcI4xyDUoveO0hyTD4MmP
# frVUj9z6BVWYbWg7mka97aSueik3rMvrg0XnRm7KMtXAhjBcTyziYrLNueKNiOSW
# rAFKu75xqRdbZ2De+JKRHh09/SDPc31BmkZ1zcRfNN0Sidb9pSB9fvzZnkXftnIv
# 231fgLrbqn427DZM9ituqBJR6L8FA6PRc6ZNN3SUHDSCD/AQ8rdHGO2n6Jl8P0zb
# r17C89XYcz1DTsEzOUyOArxCaC4Q6oRRRuLRvWoYWmEBc8pnol7XKHYC4jMYcten
# IPDC+hIK12NvDMk2ZItboKaDIV1fMHSRlJTYuVD5C4lh8zYGNRiER9vcG9H9stQc
# xWv2XFJRXRLbJbqvUAV6bMURHXLvjflSxIUXk8A8FdsaN8cIFRg/eKtFtvUeh17a
# j54WcmnGrnu3tz5q4i6tAgMBAAGjggHdMIIB2TASBgkrBgEEAYI3FQEEBQIDAQAB
# MCMGCSsGAQQBgjcVAgQWBBQqp1L+ZMSavoKRPEY1Kc8Q/y8E7jAdBgNVHQ4EFgQU
# n6cVXQBeYl2D9OXSZacbUzUZ6XIwXAYDVR0gBFUwUzBRBgwrBgEEAYI3TIN9AQEw
# QTA/BggrBgEFBQcCARYzaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9E
# b2NzL1JlcG9zaXRvcnkuaHRtMBMGA1UdJQQMMAoGCCsGAQUFBwMIMBkGCSsGAQQB
# gjcUAgQMHgoAUwB1AGIAQwBBMAsGA1UdDwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/
# MB8GA1UdIwQYMBaAFNX2VsuP6KJcYmjRPZSQW9fOmhjEMFYGA1UdHwRPME0wS6BJ
# oEeGRWh0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01p
# Y1Jvb0NlckF1dF8yMDEwLTA2LTIzLmNybDBaBggrBgEFBQcBAQROMEwwSgYIKwYB
# BQUHMAKGPmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2kvY2VydHMvTWljUm9v
# Q2VyQXV0XzIwMTAtMDYtMjMuY3J0MA0GCSqGSIb3DQEBCwUAA4ICAQCdVX38Kq3h
# LB9nATEkW+Geckv8qW/qXBS2Pk5HZHixBpOXPTEztTnXwnE2P9pkbHzQdTltuw8x
# 5MKP+2zRoZQYIu7pZmc6U03dmLq2HnjYNi6cqYJWAAOwBb6J6Gngugnue99qb74p
# y27YP0h1AdkY3m2CDPVtI1TkeFN1JFe53Z/zjj3G82jfZfakVqr3lbYoVSfQJL1A
# oL8ZthISEV09J+BAljis9/kpicO8F7BUhUKz/AyeixmJ5/ALaoHCgRlCGVJ1ijbC
# HcNhcy4sa3tuPywJeBTpkbKpW99Jo3QMvOyRgNI95ko+ZjtPu4b6MhrZlvSP9pEB
# 9s7GdP32THJvEKt1MMU0sHrYUP4KWN1APMdUbZ1jdEgssU5HLcEUBHG/ZPkkvnNt
# yo4JvbMBV0lUZNlz138eW0QBjloZkWsNn6Qo3GcZKCS6OEuabvshVGtqRRFHqfG3
# rsjoiV5PndLQTHa1V1QJsWkBRH58oWFsc/4Ku+xBZj1p/cvBQUl+fpO+y/g75LcV
# v7TOPqUxUYS8vwLBgqJ7Fx0ViY1w/ue10CgaiQuPNtq6TPmb/wrpNPgkNWcr4A24
# 5oyZ1uEi6vAnQj0llOZ0dFtq0Z4+7X6gMTN9vMvpe784cETRkPHIqzqKOghif9lw
# Y1NNje6CbaUFEMFxBmoQtB1VM1izoXBm8qGCAtQwggI9AgEBMIIBAKGB2KSB1TCB
# 0jELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1Jl
# ZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEtMCsGA1UECxMk
# TWljcm9zb2Z0IElyZWxhbmQgT3BlcmF0aW9ucyBMaW1pdGVkMSYwJAYDVQQLEx1U
# aGFsZXMgVFNTIEVTTjpEMDgyLTRCRkQtRUVCQTElMCMGA1UEAxMcTWljcm9zb2Z0
# IFRpbWUtU3RhbXAgU2VydmljZaIjCgEBMAcGBSsOAwIaAxUAHDn/cz+3yRkIUCJf
# SbL3djnQEqaggYMwgYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
# Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBv
# cmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAN
# BgkqhkiG9w0BAQUFAAIFAOowrQQwIhgPMjAyNDA3MDQxMzA5MjRaGA8yMDI0MDcw
# NTEzMDkyNFowdDA6BgorBgEEAYRZCgQBMSwwKjAKAgUA6jCtBAIBADAHAgEAAgIH
# WDAHAgEAAgIUYTAKAgUA6jH+hAIBADA2BgorBgEEAYRZCgQCMSgwJjAMBgorBgEE
# AYRZCgMCoAowCAIBAAIDB6EgoQowCAIBAAIDAYagMA0GCSqGSIb3DQEBBQUAA4GB
# ACpai7jRnRY3M3TRB5Z0BM2nfG1PyahTg3ORrWL2N+g8cSQZ4gwBKeQxfUMMNFEh
# FIVK3lRx4fKlhfSny1mlDGl+5QhfaAlyI2+4GaSRcIBM322ab0o01ZbcmyAbuj14
# InA/Bpv1v0CWG4sFZPWUNDXXcW7psav/U1KYrl9pC8O/MYIEDTCCBAkCAQEwgZMw
# fDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1Jl
# ZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMd
# TWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTACEzMAAAHcweCMwl9YXo4AAQAA
# AdwwDQYJYIZIAWUDBAIBBQCgggFKMBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRAB
# BDAvBgkqhkiG9w0BCQQxIgQgz/y92/BXJmAqt1HhCL0nLQqWn262bRji+kgtt0Ro
# kQEwgfoGCyqGSIb3DQEJEAIvMYHqMIHnMIHkMIG9BCBTpxeKatlEP4y8qZzjuWL0
# Ou0IqxELDhX2TLylxIINNzCBmDCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQI
# EwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3Nv
# ZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBD
# QSAyMDEwAhMzAAAB3MHgjMJfWF6OAAEAAAHcMCIEICCBluLd0eUolj3CSWaUaUWj
# dTvs0FvbwL9IAgg0Haa+MA0GCSqGSIb3DQEBCwUABIICAEbOBG9MVy+LIhLIb7sn
# o+M5s5cxxHiZ1rs1Sn7aAXf7UKQv86L8/c6ljK5cbnQbSfI8YQ2azaK2viBTtthz
# CJNdV6cKEfiFdFMhh02KJgZOLlZfHM7vXKccTeecvH+tcfRBNc7E/pc93+iCO6w3
# qNCtFquTFA7SD5mL69/Wuhr2bwMjEhG4ajNlzYD94APH7HOFbSeMo8ILBlSVg6am
# VsDX5gw1i93iVpeTlV/qJNETNdSvbNRgwOcl0HcaaBoBeUj1xQIfHlatQwHfxNtS
# 28KTw/FtKnxIG9cWmEJEqhLrzaGqPnh5Y17eIyTrfegukWwJ/s5gw2tumUfZ9cX8
# N5aJbDdcSBZd2gRm8TxAyhH+E9x72/2b0aa4IEhavuSYyE9dwYX6HM7hgESEqEUm
# QL2zHzaJ9OvvuE8sFZdpDgapI9D5g6CSWhjmOcKqtGhSlPtmAAnqzej/vwr1wmm8
# BGHBhY+JPC9eZojOOZQnjXc51y6dw0pGTnOTLR3CSysUaRqmh5wEthckqHTfYjBx
# kNJeUlDs2a2KGcuYQEW6FcBr8KVgsRJxQNqppSpkK1sv2PxAHT7Sb1eDbyNy7uRW
# wm4EQ3n8oNlfRZPRwXlX2MYA+h/ZcuZcntyo3WNmFALir3nlWwiQ+qg1j0NahRre
# nnTtS6Vffa1qfrKci6dx7rpq
# SIG # End signature block
