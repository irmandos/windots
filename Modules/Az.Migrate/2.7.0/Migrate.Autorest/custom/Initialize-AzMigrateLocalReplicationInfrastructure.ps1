
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
Initializes the infrastructure for the migrate project.
.Description
The Initialize-AzMigrateLocalReplicationInfrastructure cmdlet initializes the infrastructure for the migrate project in AzLocal scenario.
.Link
https://learn.microsoft.com/powershell/module/az.migrate/initialize-azmigratelocalreplicationinfrastructure
#>

function Initialize-AzMigrateLocalReplicationInfrastructure {
    [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Runtime.PreviewMessageAttribute("This cmdlet is using a preview API version and is subject to breaking change in a future release.")]
    [OutputType([System.Boolean], ParameterSetName = 'AzLocal')]
    [CmdletBinding(DefaultParameterSetName = 'AzLocal', PositionalBinding = $false, SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the Resource Group of the Azure Migrate Project in the current subscription.
        ${ResourceGroupName},

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the name of the Azure Migrate project to be used for server migration.
        ${ProjectName},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the Storage Account ARM Id to be used for private endpoint scenario.
        ${CacheStorageAccountId},

        [Parameter()]
        [System.String]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Runtime.DefaultInfo(Script = '(Get-AzContext).Subscription.Id')]
        # Azure Subscription ID.
        ${SubscriptionId},

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

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Returns true when the command succeeds
        ${PassThru},
    
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

        CheckResourcesModuleDependency
        CheckStorageModuleDependency
        Import-Module Az.Resources
        Import-Module Az.Storage

        $context = Get-AzContext
        # Get SubscriptionId
        if ([string]::IsNullOrEmpty($SubscriptionId)) {
            Write-Host "No -SubscriptionId provided. Using the one from Get-AzContext."

            $SubscriptionId = $context.Subscription.Id
            if ([string]::IsNullOrEmpty($SubscriptionId)) {
                throw "Please login to Azure to select a subscription."
            }
        }
        Write-Host "*Selected Subscription Id: '$($SubscriptionId)'"
    
        # Get resource group
        $resourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorVariable notPresent -ErrorAction SilentlyContinue
        if ($null -eq $resourceGroup) {
            throw "Resource group '$($ResourceGroupName)' does not exist in the subscription. Please create the resource group and try again."
        }
        Write-Host "*Selected Resource Group: '$($ResourceGroupName)'"

        # Verify user validity
        $userObject = Get-AzADUser -UserPrincipalName $context.Subscription.ExtendedProperties.Account

        if (-not $userObject) {
            $userObject = Get-AzADUser -Mail $context.Subscription.ExtendedProperties.Account
        }

        if (-not $userObject) {
            $mailNickname = "{0}#EXT#" -f $($context.Account.Id -replace '@', '_')

            $userObject = Get-AzADUser | 
            Where-Object { $_.MailNickname -eq $mailNickname }
        }

        if (-not $userObject) {
            if ($context.Account.Id.StartsWith("MSI@")) {
                $hostname = $env:COMPUTERNAME
                $userObject = Get-AzADServicePrincipal -DisplayName $hostname
            }
            else {
                $userObject = Get-AzADServicePrincipal -ApplicationID $context.Account.Id
            }
        }

        if (-not $userObject) {
            throw 'User Object Id Not Found!'
        }

        # Get Migrate Project
        $migrateProject = InvokeAzMigrateGetCommandWithRetries `
            -CommandName "Az.Migrate\Get-AzMigrateProject" `
            -Parameters @{"Name" = $ProjectName; "ResourceGroupName" = $ResourceGroupName} `
            -ErrorMessage "Migrate project '$($ProjectName)' not found."

        # Access Discovery Service
        $discoverySolutionName = "Servers-Discovery-ServerDiscovery"
        $discoverySolution = InvokeAzMigrateGetCommandWithRetries `
            -CommandName "Az.Migrate\Get-AzMigrateSolution" `
            -Parameters @{"SubscriptionId" = $SubscriptionId; "ResourceGroupName" = $ResourceGroupName; "MigrateProjectName" = $ProjectName; "Name" = $discoverySolutionName} `
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
        if ($sourceSiteId -match $hyperVSiteTypeRegex -and $targetSiteId -match $hyperVSiteTypeRegex) {
            $instanceType = $AzLocalInstanceTypes.HyperVToAzLocal
        }
        elseif ($sourceSiteId -match $vmwareSiteTypeRegex -and $targetSiteId -match $hyperVSiteTypeRegex) {
            $instanceType = $AzLocalInstanceTypes.VMwareToAzLocal
        }
        else {
            throw "Error encountered in matching the given source appliance name '$SourceApplianceName' and target appliance name '$TargetApplianceName'. Please verify the VM site type to be either for HyperV or VMware for both source and target appliances, and the appliance names are correct."
        }

        # Get Data Replication Service, or the AMH solution
        $amhSolutionName = "Servers-Migration-ServerMigration_DataReplication"
        $amhSolution = InvokeAzMigrateGetCommandWithRetries `
            -CommandName "Az.Migrate\Get-AzMigrateSolution" `
            -Parameters @{"SubscriptionId" = $SubscriptionId; "ResourceGroupName" = $ResourceGroupName; "MigrateProjectName" = $ProjectName; "Name" = $amhSolutionName} `
            -ErrorMessage "No Data Replication Service Solution '$amhSolutionName' found. Please verify your appliance setup."

        # Get Source and Target Fabrics
        $allFabrics = Az.Migrate\Get-AzMigrateLocalReplicationFabric -ResourceGroupName $ResourceGroupName
        foreach ($fabric in $allFabrics) {
            if ($fabric.Property.CustomProperty.MigrationSolutionId -ne $amhSolution.Id) {
                continue
            }

            if (($instanceType -eq $AzLocalInstanceTypes.HyperVToAzLocal) -and
                ($fabric.Property.CustomProperty.InstanceType -ceq $FabricInstanceTypes.HyperVInstance)) {
                $sourceFabric = $fabric
            }
            elseif (($instanceType -eq $AzLocalInstanceTypes.VMwareToAzLocal) -and
                ($fabric.Property.CustomProperty.InstanceType -ceq $FabricInstanceTypes.VMwareInstance)) {
                $sourceFabric = $fabric
            }
            elseif ($fabric.Property.CustomProperty.InstanceType -ceq $FabricInstanceTypes.AzLocalInstance) {
                $targetFabric = $fabric
            }

            if (($null -ne $sourceFabric) -and ($null -ne $targetFabric)) {
                break
            }
        }

        if ($null -eq $sourceFabric) {
            throw "No source Fabric found. Please verify your appliance setup."
        }
        Write-Host "*Selected Source Fabric: '$($sourceFabric.Name)'"

        if ($null -eq $targetFabric) {
            throw "No target Fabric found. Please verify your appliance setup."
        }
        Write-Host "*Selected Target Fabric: '$($targetFabric.Name)'"

        # Get Source and Target Dras from Fabrics
        $sourceDras = InvokeAzMigrateGetCommandWithRetries `
            -CommandName "Az.Migrate.Internal\Get-AzMigrateFabricAgent" `
            -Parameters @{"FabricName" = $sourceFabric.Name; "ResourceGroupName" = $ResourceGroupName} `
            -ErrorMessage "No source Fabric Agent (DRA) found. Please verify your appliance setup."

        $sourceDra = $sourceDras[0]
        Write-Host "*Selected Source Dra: '$($sourceDra.Name)'"

        $targetDras = InvokeAzMigrateGetCommandWithRetries `
            -CommandName "Az.Migrate.Internal\Get-AzMigrateFabricAgent" `
            -Parameters @{"FabricName" = $targetFabric.Name; "ResourceGroupName" = $ResourceGroupName} `
            -ErrorMessage "No target Fabric Agent (DRA) found. Please verify your appliance setup."

        $targetDra = $targetDras[0]
        Write-Host "*Selected Target Dra: '$($targetDra.Name)'"
        
        # Get Replication Vault
        $replicationVaultName = $amhSolution.DetailExtendedDetail["vaultId"].Split("/")[8]
        $replicationVault = InvokeAzMigrateGetCommandWithRetries `
            -CommandName "Az.Migrate.Internal\Get-AzMigrateVault" `
            -Parameters @{"ResourceGroupName" = $ResourceGroupName; "Name" = $replicationVaultName} `
            -ErrorMessage "No Replication Vault '$replicationVaultName' found in Resource Group '$ResourceGroupName'."

        # Put Policy
        $policyName = $replicationVault.Name + $instanceType + "policy"
        $policy = Az.Migrate.Internal\Get-AzMigratePolicy `
            -ResourceGroupName $ResourceGroupName `
            -Name $policyName `
            -VaultName $replicationVault.Name `
            -SubscriptionId $SubscriptionId `
            -ErrorVariable notPresent `
            -ErrorAction SilentlyContinue
        
        # Default policy is found
        if ($null -ne $policy) {
            # Give time for create/update to reach a terminal state. Timeout after 10min
            if ($policy.Property.ProvisioningState -eq [ProvisioningState]::Creating -or
                $policy.Property.ProvisioningState -eq [ProvisioningState]::Updating) {
                Write-Host "Policy '$($policyName)' found in Provisioning State '$($policy.Property.ProvisioningState)'."

                for ($i = 0; $i -lt 20; $i++) {
                    Start-Sleep -Seconds 30
                    $policy = Az.Migrate.Internal\Get-AzMigratePolicy -InputObject $policy

                    if (-not (
                            $policy.Property.ProvisioningState -eq [ProvisioningState]::Creating -or
                            $policy.Property.ProvisioningState -eq [ProvisioningState]::Updating)) {
                        break
                    }
                }

                # Make sure Policy is no longer in Creating or Updating state
                if ($policy.Property.ProvisioningState -eq [ProvisioningState]::Creating -or
                    $policy.Property.ProvisioningState -eq [ProvisioningState]::Updating) {
                    throw "Policy '$($policyName)' times out with Provisioning State: '$($policy.Property.ProvisioningState)'. Please re-run this command or contact support if help needed."
                }
            }

            # Check and remove if policy is in a bad terminal state
            if ($policy.Property.ProvisioningState -eq [ProvisioningState]::Canceled -or
                $policy.Property.ProvisioningState -eq [ProvisioningState]::Failed) {
                Write-Host "Policy '$($policyName)' found but in an unusable terminal Provisioning State '$($policy.Property.ProvisioningState)'.`nRemoving policy..."
                    
                # Remove policy
                try {
                    Az.Migrate.Internal\Remove-AzMigratePolicy -InputObject $policy | Out-Null
                }
                catch {
                    if ($_.Exception.Message -notmatch "Status: OK") {
                        throw $_.Exception.Message
                    }
                }

                Start-Sleep -Seconds 30
                $policy = Az.Migrate.Internal\Get-AzMigratePolicy `
                    -InputObject $policy `
                    -ErrorVariable notPresent `
                    -ErrorAction SilentlyContinue

                # Make sure Policy is no longer in Canceled or Failed state
                if ($null -ne $policy -and
                    ($policy.Property.ProvisioningState -eq [ProvisioningState]::Canceled -or
                    $policy.Property.ProvisioningState -eq [ProvisioningState]::Failed)) {
                    throw "Failed to change the Provisioning State of policy '$($policyName)'by removing. Please re-run this command or contact support if help needed."
                }
            }

            # Give time to remove policy. Timeout after 10min
            if ($null -eq $policy -and $policy.Property.ProvisioningState -eq [ProvisioningState]::Deleting) {
                Write-Host "Policy '$($policyName)' found in Provisioning State '$($policy.Property.ProvisioningState)'."

                for ($i = 0; $i -lt 20; $i++) {
                    Start-Sleep -Seconds 30
                    $policy = Az.Migrate.Internal\Get-AzMigratePolicy `
                        -InputObject $policy `
                        -ErrorVariable notPresent `
                        -ErrorAction SilentlyContinue
                    
                    if ($null -eq $policy -or $policy.Property.ProvisioningState -eq [ProvisioningState]::Deleted) {
                        break
                    }
                    elseif ($policy.Property.ProvisioningState -eq [ProvisioningState]::Deleting) {
                        continue
                    }

                    throw "Policy '$($policyName)' has an unexpected Provisioning State of '$($policy.Property.ProvisioningState)' during removal process. Please re-run this command or contact support if help needed."
                }

                # Make sure Policy is no longer in Deleting state
                if ($null -ne $policy -and $policy.Property.ProvisioningState -eq [ProvisioningState]::Deleting) {
                    throw "Policy '$($policyName)' times out with Provisioning State: '$($policy.Property.ProvisioningState)'. Please re-run this command or contact support if help needed."
                }
            }

            # Indicate policy was removed
            if ($null -eq $policy -or $policy.Property.ProvisioningState -eq [ProvisioningState]::Deleted) {
                Write-Host "Policy '$($policyName)' was removed."
            }
        }

        # Refresh local policy object if exists
        if ($null -ne $policy) {
            $policy = Az.Migrate.Internal\Get-AzMigratePolicy -InputObject $policy
        }

        # Create policy if not found or previously deleted
        if ($null -eq $policy -or $policy.Property.ProvisioningState -eq [ProvisioningState]::Deleted) {
            Write-Host "Creating Policy..."

            $params = @{
                InstanceType                     = $instanceType;
                RecoveryPointHistoryInMinute     = $ReplicationDetails.PolicyDetails.DefaultRecoveryPointHistoryInMinutes;
                CrashConsistentFrequencyInMinute = $ReplicationDetails.PolicyDetails.DefaultCrashConsistentFrequencyInMinutes;
                AppConsistentFrequencyInMinute   = $ReplicationDetails.PolicyDetails.DefaultAppConsistentFrequencyInMinutes;
            }

            # Setup Policy deployment parameters
            $policyProperties = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.PolicyModelProperties]::new()
            if ($instanceType -eq $AzLocalInstanceTypes.HyperVToAzLocal) {
                $policyCustomProperties = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.HyperVToAzStackHcipolicyModelCustomProperties]::new()
            }
            elseif ($instanceType -eq $AzLocalInstanceTypes.VMwareToAzLocal) {
                $policyCustomProperties = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.VMwareToAzStackHcipolicyModelCustomProperties]::new()
            }
            else {
                throw "Instance type '$($instanceType)' is not supported. Currently, for AzLocal scenario, only HyperV and VMware as the source is supported."
            }
            $policyCustomProperties.InstanceType = $params.InstanceType
            $policyCustomProperties.RecoveryPointHistoryInMinute = $params.RecoveryPointHistoryInMinute
            $policyCustomProperties.CrashConsistentFrequencyInMinute = $params.CrashConsistentFrequencyInMinute
            $policyCustomProperties.AppConsistentFrequencyInMinute = $params.AppConsistentFrequencyInMinute
            $policyProperties.CustomProperty = $policyCustomProperties
        
            try {
                Az.Migrate.Internal\New-AzMigratePolicy `
                    -Name $policyName `
                    -ResourceGroupName $ResourceGroupName `
                    -VaultName $replicationVaultName `
                    -Property $policyProperties `
                    -SubscriptionId $SubscriptionId `
                    -NoWait | Out-Null
            }
            catch {
                if ($_.Exception.Message -notmatch "Status: OK") {
                    throw $_.Exception.Message
                }
            }

            # Check Policy creation status every 30s. Timeout after 10min
            for ($i = 0; $i -lt 20; $i++) {
                Start-Sleep -Seconds 30
                $policy = Az.Migrate.Internal\Get-AzMigratePolicy `
                    -ResourceGroupName $ResourceGroupName `
                    -Name $policyName `
                    -VaultName $replicationVault.Name `
                    -SubscriptionId $SubscriptionId `
                    -ErrorVariable notPresent `
                    -ErrorAction SilentlyContinue
                if ($null -eq $policy) {
                    continue
                }
                
                # Stop if policy reaches a terminal state
                if ($policy.Property.ProvisioningState -eq [ProvisioningState]::Succeeded -or
                    $policy.Property.ProvisioningState -eq [ProvisioningState]::Deleted -or
                    $policy.Property.ProvisioningState -eq [ProvisioningState]::Canceled -or
                    $policy.Property.ProvisioningState -eq [ProvisioningState]::Failed) {
                    break
                }
            }

            # Make sure Policy is in a terminal state
            if (-not (
                    $policy.Property.ProvisioningState -eq [ProvisioningState]::Succeeded -or
                    $policy.Property.ProvisioningState -eq [ProvisioningState]::Deleted -or
                    $policy.Property.ProvisioningState -eq [ProvisioningState]::Canceled -or
                    $policy.Property.ProvisioningState -eq [ProvisioningState]::Failed)) {
                throw "Policy '$($policyName)' times out with Provisioning State: '$($policy.Property.ProvisioningState)' during creation process. Please re-run this command or contact support if help needed."
            }
        }
        
        if ($policy.Property.ProvisioningState -ne [ProvisioningState]::Succeeded) {
            throw "Policy '$($policyName)' has an unexpected Provisioning State of '$($policy.Property.ProvisioningState)'. Please re-run this command or contact support if help needed."
        }

        $policy = Az.Migrate.Internal\Get-AzMigratePolicy `
            -ResourceGroupName $ResourceGroupName `
            -Name $policyName `
            -VaultName $replicationVault.Name `
            -SubscriptionId $SubscriptionId `
            -ErrorVariable notPresent `
            -ErrorAction SilentlyContinue
        if ($null -eq $policy) {
            throw "Unexpected error occurred during policy creation. Please re-run this command or contact support if help needed."
        }
        elseif ($policy.Property.ProvisioningState -ne [ProvisioningState]::Succeeded) {
            throw "Policy '$($policyName)' has an unexpected Provisioning State of '$($policy.Property.ProvisioningState)'. Please re-run this command or contact support if help needed."
        }
        else {
            Write-Host "*Selected Policy: '$($policyName)'"
        }

        # Put Cache Storage Account
        $amhSolution = Az.Migrate\Get-AzMigrateSolution `
            -ResourceGroupName $ResourceGroupName `
            -MigrateProjectName $ProjectName `
            -Name "Servers-Migration-ServerMigration_DataReplication" `
            -SubscriptionId $SubscriptionId `
            -ErrorVariable notPresent `
            -ErrorAction SilentlyContinue
        if ($null -eq $amhSolution) {
            throw "No Data Replication Service Solution found. Please verify your appliance setup."
        }

        $amhStoredStorageAccountId = $amhSolution.DetailExtendedDetail["replicationStorageAccountId"]
        
        # Record of rsa found in AMH solution
        if (![string]::IsNullOrEmpty($amhStoredStorageAccountId)) {
            $amhStoredStorageAccountName = $amhStoredStorageAccountId.Split("/")[8]
            $amhStoredStorageAccount = Get-AzStorageAccount `
                -ResourceGroupName $ResourceGroupName `
                -Name $amhStoredStorageAccountName `
                -ErrorVariable notPresent `
                -ErrorAction SilentlyContinue

            # Wait for amhStoredStorageAccount to reach a terminal state
            if ($null -ne $amhStoredStorageAccount -and
                $null -ne $amhStoredStorageAccount.ProvisioningState -and
                $amhStoredStorageAccount.ProvisioningState -ne [StorageAccountProvisioningState]::Succeeded) {
                # Check rsa state every 30s if not Succeeded already. Timeout after 10min
                for ($i = 0; $i -lt 20; $i++) {
                    Start-Sleep -Seconds 30
                    $amhStoredStorageAccount = Get-AzStorageAccount `
                        -ResourceGroupName $ResourceGroupName `
                        -Name $amhStoredStorageAccountName `
                        -ErrorVariable notPresent `
                        -ErrorAction SilentlyContinue
                        # Stop if amhStoredStorageAccount is not found or in a terminal state
                    if ($null -eq $amhStoredStorageAccount -or
                        $null -eq $amhStoredStorageAccount.ProvisioningState -or
                        $amhStoredStorageAccount.ProvisioningState -eq [StorageAccountProvisioningState]::Succeeded) {
                        break
                    }
                }
            }
            
            # amhStoredStorageAccount exists and in Succeeded state
            if ($null -ne $amhStoredStorageAccount -and
                $amhStoredStorageAccount.ProvisioningState -eq [StorageAccountProvisioningState]::Succeeded) {
                # Use amhStoredStorageAccount and ignore user provided Cache Storage Account Id
                if (![string]::IsNullOrEmpty($CacheStorageAccountId) -and $amhStoredStorageAccount.Id -ne $CacheStorageAccountId) {
                    Write-Host "A Cache Storage Account '$($amhStoredStorageAccountName)' has been linked already. The given -CacheStorageAccountId '$($CacheStorageAccountId)' will be ignored."
                }

                $cacheStorageAccount = $amhStoredStorageAccount
            }
            elseif ($null -eq $amhStoredStorageAccount -or $null -eq $amhStoredStorageAccount.ProvisioningState) {
                # amhStoredStorageAccount is found but in a bad state, so log to ask user to remove
                if ($null -ne $amhStoredStorageAccount -and $null -eq $amhStoredStorageAccount.ProvisioningState) {
                    Write-Host "A previously linked Cache Storage Account with Id '$($amhStoredStorageAccountId)' is found but in a unusable state. Please remove it manually and re-run this command."
                }

                # amhStoredStorageAccount is not found or in a bad state but AMH has a record of it, so remove the record
                if ($amhSolution.DetailExtendedDetail.ContainsKey("replicationStorageAccountId")) {
                    $amhSolution.DetailExtendedDetail.Remove("replicationStorageAccountId") | Out-Null
                    $amhSolution.DetailExtendedDetail.Add("replicationStorageAccountId", $null) | Out-Null
                    Az.Migrate.Internal\Set-AzMigrateSolution `
                        -MigrateProjectName $ProjectName `
                        -Name $amhSolution.Name `
                        -ResourceGroupName $ResourceGroupName `
                        -DetailExtendedDetail $amhSolution.DetailExtendedDetail.AdditionalProperties | Out-Null
                }
            }
            else {
                throw "A linked Cache Storage Account with Id '$($amhStoredStorageAccountId)' times out with Provisioning State: '$($amhStoredStorageAccount.ProvisioningState)'. Please re-run this command or contact support if help needed."
            }

            $amhSolution = Az.Migrate\Get-AzMigrateSolution `
                -ResourceGroupName $ResourceGroupName `
                -MigrateProjectName $ProjectName `
                -Name "Servers-Migration-ServerMigration_DataReplication" `
                -SubscriptionId $SubscriptionId `
                -ErrorVariable notPresent `
                -ErrorAction SilentlyContinue
                # Check if AMH record is removed
            if (($null -eq $amhStoredStorageAccount -or $null -eq $amhStoredStorageAccount.ProvisioningState) -and
                ![string]::IsNullOrEmpty($amhSolution.DetailExtendedDetail["replicationStorageAccountId"])) {
                throw "Unexpected error occurred in unlinking Cache Storage Account with Id '$($amhSolution.DetailExtendedDetail["replicationStorageAccountId"])'. Please re-run this command or contact support if help needed."
            }
        }

        # No linked Cache Storage Account found in AMH solution but user provides a Cache Storage Account Id
        if ($null -eq $cacheStorageAccount -and ![string]::IsNullOrEmpty($CacheStorageAccountId)) {
            $userProvidedStorageAccountIdSegs = $CacheStorageAccountId.Split("/")
            if ($userProvidedStorageAccountIdSegs.Count -ne 9) {
                throw "Invalid Cache Storage Account Id '$($CacheStorageAccountId)' provided. Please provide a valid one."
            }

            $userProvidedStorageAccountName = ($userProvidedStorageAccountIdSegs[8]).ToLower()

            # Check if user provided Cache Storage Account exists
            $userProvidedStorageAccount = Get-AzStorageAccount `
                -ResourceGroupName $ResourceGroupName `
                -Name $userProvidedStorageAccountName `
                -ErrorVariable notPresent `
                -ErrorAction SilentlyContinue

            # Wait for userProvidedStorageAccount to reach a terminal state
            if ($null -ne $userProvidedStorageAccount -and
                $null -ne $userProvidedStorageAccount.ProvisioningState -and
                $userProvidedStorageAccount.ProvisioningState -ne [StorageAccountProvisioningState]::Succeeded) {
                # Check rsa state every 30s if not Succeeded already. Timeout after 10min
                for ($i = 0; $i -lt 20; $i++) {
                    Start-Sleep -Seconds 30
                    $userProvidedStorageAccount = Get-AzStorageAccount `
                        -ResourceGroupName $ResourceGroupName `
                        -Name $userProvidedStorageAccountName `
                        -ErrorVariable notPresent `
                        -ErrorAction SilentlyContinue
                    # Stop if userProvidedStorageAccount is not found or in a terminal state
                    if ($null -eq $userProvidedStorageAccount -or
                        $null -eq $userProvidedStorageAccount.ProvisioningState -or
                        $userProvidedStorageAccount.ProvisioningState -eq [StorageAccountProvisioningState]::Succeeded) {
                        break
                    }
                }
            }

            if ($null -ne $userProvidedStorageAccount -and
                $userProvidedStorageAccount.ProvisioningState -eq [StorageAccountProvisioningState]::Succeeded) {
                $cacheStorageAccount = $userProvidedStorageAccount
            }
            elseif ($null -eq $userProvidedStorageAccount) {
                throw "Cache Storage Account with Id '$($CacheStorageAccountId)' is not found. Please re-run this command without -CacheStorageAccountId to create one automatically or re-create the Cache Storage Account yourself and try again."
            }
            elseif ($null -eq $userProvidedStorageAccount.ProvisioningState) {
                throw "Cache Storage Account with Id '$($CacheStorageAccountId)' is found but in an unusable state. Please re-run this command without -CacheStorageAccountId to create one automatically or re-create the Cache Storage Account yourself and try again."
            }
            else {
                throw "Cache Storage Account with Id '$($CacheStorageAccountId)' is found but times out with Provisioning State: '$($userProvidedStorageAccount.ProvisioningState)'. Please re-run this command or contact support if help needed."
            }
        }

        # No Cache Storage Account found or provided, so create one
        if ($null -eq $cacheStorageAccount) {
            $suffix = (GenerateHashForArtifact -Artifact "$($sourceSiteId)/$($SourceApplianceName)").ToString()
            if ($suffixHash.Length -gt 14) {
                $suffix = $suffixHash.Substring(0, 14)
            }
            $cacheStorageAccountName = "migratersa" + $suffix
            $cacheStorageAccountId = "/subscriptions/$($SubscriptionId)/resourceGroups/$($ResourceGroupName)/providers/Microsoft.Storage/storageAccounts/$($cacheStorageAccountName)"

            # Check if default Cache Storage Account already exists, which it shoudln't
            $cacheStorageAccount = Get-AzStorageAccount `
                -ResourceGroupName $ResourceGroupName `
                -Name $cacheStorageAccountName `
                -ErrorVariable notPresent `
                -ErrorAction SilentlyContinue
            if ($null -ne $cacheStorageAccount) {
                throw "Unexpected error encountered: Cache Storage Account '$($cacheStorageAccountName)' already exists. Please re-run this command to create a different one or contact support if help needed."
            }

            Write-Host "Creating Cache Storage Account with default name '$($cacheStorageAccountName)'..."

            $params = @{
                name                                = $cacheStorageAccountName;
                location                            = $migrateProject.Location;
                migrateProjectName                  = $migrateProject.Name;
                skuName                             = "Standard_LRS";
                tags                                = @{ "Migrate Project" = $migrateProject.Name };
                kind                                = "StorageV2";
                encryption                          = @{ services = @{blob = @{ enabled = $true }; file = @{ enabled = $true } } };
            }

            # Create Cache Storage Account
            $cacheStorageAccount = New-AzStorageAccount `
                -ResourceGroupName $ResourceGroupName `
                -Name $params.name `
                -SkuName $params.skuName `
                -Location $params.location `
                -Kind $params.kind `
                -Tags $params.tags `
                -AllowBlobPublicAccess $true

            if ($null -ne $cacheStorageAccount -and
                $null -ne $cacheStorageAccount.ProvisioningState -and
                $cacheStorageAccount.ProvisioningState -ne [StorageAccountProvisioningState]::Succeeded) {
                # Check rsa state every 30s if not Succeeded already. Timeout after 10min
                for ($i = 0; $i -lt 20; $i++) {
                    Start-Sleep -Seconds 30
                    $cacheStorageAccount = Get-AzStorageAccount `
                        -ResourceGroupName $ResourceGroupName `
                        -Name $params.name `
                        -ErrorVariable notPresent `
                        -ErrorAction SilentlyContinue
                    # Stop if cacheStorageAccount is not found or in a terminal state
                    if ($null -eq $cacheStorageAccount -or
                        $null -eq $cacheStorageAccount.ProvisioningState -or
                        $cacheStorageAccount.ProvisioningState -eq [StorageAccountProvisioningState]::Succeeded) {
                        break
                    }
                }
            }

            if ($null -eq $cacheStorageAccount -or $null -eq $cacheStorageAccount.ProvisioningState) {
                throw "Unexpected error occurs during Cache Storgae Account creation process. Please re-run this command or provide -CacheStorageAccountId of the one created own your own."
            }
            elseif ($cacheStorageAccount.ProvisioningState -ne [StorageAccountProvisioningState]::Succeeded) {
                throw "Cache Storage Account with Id '$($cacheStorageAccount.Id)' times out with Provisioning State: '$($cacheStorageAccount.ProvisioningState)' during creation process. Please remove it manually and re-run this command or contact support if help needed."
            }
        }

        # Sanity check
        if ($null -eq $cacheStorageAccount -or
            $null -eq $cacheStorageAccount.ProvisioningState -or
            $cacheStorageAccount.ProvisioningState -ne [StorageAccountProvisioningState]::Succeeded) {
            throw "Unexpected error occurs during Cache Storgae Account selection process. Please re-run this command or contact support if help needed."
        }

        $params = @{
            contributorRoleDefId                = [System.Guid]::parse($RoleDefinitionIds.ContributorId);
            storageBlobDataContributorRoleDefId = [System.Guid]::parse($RoleDefinitionIds.StorageBlobDataContributorId);
            sourceAppAadId                      = $sourceDra.ResourceAccessIdentityObjectId;
            targetAppAadId                      = $targetDra.ResourceAccessIdentityObjectId;
        }

        # Grant vault Identity Aad access to Cache Storage Account
        if (![string]::IsNullOrEmpty($replicationVault.IdentityPrincipalId))
        {
            $params.vaultIdentityAadId = $replicationVault.IdentityPrincipalId

            # Grant vault Identity Aad access to Cache Storage Account as "Contributor"
            $hasAadAppAccess = Get-AzRoleAssignment `
                -ObjectId $params.vaultIdentityAadId `
                -RoleDefinitionId $params.contributorRoleDefId `
                -Scope $cacheStorageAccount.Id `
                -ErrorVariable notPresent `
                -ErrorAction SilentlyContinue
            if ($null -eq $hasAadAppAccess) {
                New-AzRoleAssignment `
                    -ObjectId $params.vaultIdentityAadId `
                    -RoleDefinitionId $params.contributorRoleDefId `
                    -Scope $cacheStorageAccount.Id | Out-Null
            }
    
            # Grant vault Identity Aad access to Cache Storage Account as "StorageBlobDataContributor"
            $hasAadAppAccess = Get-AzRoleAssignment `
                -ObjectId $params.vaultIdentityAadId `
                -RoleDefinitionId $params.storageBlobDataContributorRoleDefId `
                -Scope $cacheStorageAccount.Id `
                -ErrorVariable notPresent `
                -ErrorAction SilentlyContinue
            if ($null -eq $hasAadAppAccess) {
                New-AzRoleAssignment `
                    -ObjectId $params.vaultIdentityAadId `
                    -RoleDefinitionId $params.storageBlobDataContributorRoleDefId `
                    -Scope $cacheStorageAccount.Id | Out-Null
            }
        }

        # Grant Source Dra AAD App access to Cache Storage Account as "Contributor"
        $hasAadAppAccess = Get-AzRoleAssignment `
            -ObjectId $params.sourceAppAadId `
            -RoleDefinitionId $params.contributorRoleDefId `
            -Scope $cacheStorageAccount.Id `
            -ErrorVariable notPresent `
            -ErrorAction SilentlyContinue
        if ($null -eq $hasAadAppAccess) {
            New-AzRoleAssignment `
                -ObjectId $params.sourceAppAadId `
                -RoleDefinitionId $params.contributorRoleDefId `
                -Scope $cacheStorageAccount.Id | Out-Null
        }

        # Grant Source Dra AAD App access to Cache Storage Account as "StorageBlobDataContributor"
        $hasAadAppAccess = Get-AzRoleAssignment `
            -ObjectId $params.sourceAppAadId `
            -RoleDefinitionId $params.storageBlobDataContributorRoleDefId `
            -Scope $cacheStorageAccount.Id `
            -ErrorVariable notPresent `
            -ErrorAction SilentlyContinue
        if ($null -eq $hasAadAppAccess) {
            New-AzRoleAssignment `
                -ObjectId $params.sourceAppAadId `
                -RoleDefinitionId $params.storageBlobDataContributorRoleDefId `
                -Scope $cacheStorageAccount.Id | Out-Null
        }

        # Grant Target Dra AAD App access to Cache Storage Account as "Contributor"
        $hasAadAppAccess = Get-AzRoleAssignment `
            -ObjectId $params.targetAppAadId `
            -RoleDefinitionId $params.contributorRoleDefId `
            -Scope $cacheStorageAccount.Id `
            -ErrorVariable notPresent `
            -ErrorAction SilentlyContinue
        if ($null -eq $hasAadAppAccess) {
            New-AzRoleAssignment `
                -ObjectId $params.targetAppAadId `
                -RoleDefinitionId $params.contributorRoleDefId `
                -Scope $cacheStorageAccount.Id | Out-Null
        }

        # Grant Target Dra AAD App access to Cache Storage Account as "StorageBlobDataContributor"
        $hasAadAppAccess = Get-AzRoleAssignment `
            -ObjectId $params.targetAppAadId `
            -RoleDefinitionId $params.storageBlobDataContributorRoleDefId `
            -Scope $cacheStorageAccount.Id `
            -ErrorVariable notPresent `
            -ErrorAction SilentlyContinue
        if ($null -eq $hasAadAppAccess) {
            New-AzRoleAssignment `
                -ObjectId $params.targetAppAadId `
                -RoleDefinitionId $params.storageBlobDataContributorRoleDefId `
                -Scope $cacheStorageAccount.Id | Out-Null
        }

        # Give time for role assignments to be created. Times out after 2min
        $rsaPermissionGranted = $false
        for ($i = 0; $i -lt 3; $i++) {
            # Check Source Dra AAD App access to Cache Storage Account as "Contributor"
            $hasAadAppAccess = Get-AzRoleAssignment `
                -ObjectId $params.sourceAppAadId `
                -RoleDefinitionId $params.contributorRoleDefId `
                -Scope $cacheStorageAccount.Id `
                -ErrorVariable notPresent `
                -ErrorAction SilentlyContinue
            $rsaPermissionGranted = $null -ne $hasAadAppAccess

            # Check Source Dra AAD App access to Cache Storage Account as "StorageBlobDataContributor"
            $hasAadAppAccess = Get-AzRoleAssignment `
                -ObjectId $params.sourceAppAadId `
                -RoleDefinitionId $params.storageBlobDataContributorRoleDefId `
                -Scope $cacheStorageAccount.Id `
                -ErrorVariable notPresent `
                -ErrorAction SilentlyContinue
            $rsaPermissionGranted = $rsaPermissionGranted -and ($null -ne $hasAadAppAccess)

            # Check Target Dra AAD App access to Cache Storage Account as "Contributor"
            $hasAadAppAccess = Get-AzRoleAssignment `
                -ObjectId $params.targetAppAadId `
                -RoleDefinitionId $params.contributorRoleDefId `
                -Scope $cacheStorageAccount.Id `
                -ErrorVariable notPresent `
                -ErrorAction SilentlyContinue
            $rsaPermissionGranted = $rsaPermissionGranted -and ($null -ne $hasAadAppAccess)

            # Check Target Dra AAD App access to Cache Storage Account as "StorageBlobDataContributor"
            $hasAadAppAccess = Get-AzRoleAssignment `
                -ObjectId $params.targetAppAadId `
                -RoleDefinitionId $params.storageBlobDataContributorRoleDefId `
                -Scope $cacheStorageAccount.Id `
                -ErrorVariable notPresent `
                -ErrorAction SilentlyContinue
            $rsaPermissionGranted = $rsaPermissionGranted -and ($null -ne $hasAadAppAccess)

            if ($rsaPermissionGranted) {
                break
            }

            Start-Sleep -Seconds 30
        }

        if (!$rsaPermissionGranted) {
            throw "Failed to grant Cache Storage Account permissions. Please re-run this command or contact support if help needed."
        }

        $amhSolution = Az.Migrate\Get-AzMigrateSolution `
            -ResourceGroupName $ResourceGroupName `
            -MigrateProjectName $ProjectName `
            -Name "Servers-Migration-ServerMigration_DataReplication" `
            -SubscriptionId $SubscriptionId
        if ($amhSolution.DetailExtendedDetail.ContainsKey("replicationStorageAccountId")) {
            $amhStoredStorageAccountId = $amhSolution.DetailExtendedDetail["replicationStorageAccountId"]
            if ([string]::IsNullOrEmpty($amhStoredStorageAccountId)) {
                # Remove "replicationStorageAccountId" key
                $amhSolution.DetailExtendedDetail.Remove("replicationStorageAccountId")  | Out-Null
            }
            elseif ($amhStoredStorageAccountId -ne $cacheStorageAccount.Id) {
                # Record of rsa mismatch
                throw "Unexpected error occurred in linking Cache Storage Account with Id '$($cacheStorageAccount.Id)'. Please re-run this command or contact support if help needed."
            }
        }

        # Update AMH record with chosen Cache Storage Account
        if (!$amhSolution.DetailExtendedDetail.ContainsKey("replicationStorageAccountId")) {
            $amhSolution.DetailExtendedDetail.Add("replicationStorageAccountId", $cacheStorageAccount.Id)
            Az.Migrate.Internal\Set-AzMigrateSolution `
                -MigrateProjectName $ProjectName `
                -Name $amhSolution.Name `
                -ResourceGroupName $ResourceGroupName `
                -DetailExtendedDetail $amhSolution.DetailExtendedDetail.AdditionalProperties | Out-Null
        }

        Write-Host "*Selected Cache Storage Account: '$($cacheStorageAccount.StorageAccountName)' in Resource Group '$($ResourceGroupName)' at Location '$($cacheStorageAccount.Location)' for Migrate Project '$($migrateProject.Name)'"

        # Put replication extension
        $replicationExtensionName = ($sourceFabric.Id -split '/')[-1] + "-" + ($targetFabric.Id -split '/')[-1] + "-MigReplicationExtn"
        $replicationExtension = Az.Migrate.Internal\Get-AzMigrateReplicationExtension `
            -ResourceGroupName $ResourceGroupName `
            -Name $replicationExtensionName `
            -VaultName $replicationVaultName `
            -SubscriptionId $SubscriptionId `
            -ErrorVariable notPresent `
            -ErrorAction SilentlyContinue

        # Remove replication extension if does not match the selected Cache Storage Account
        if ($null -ne $replicationExtension -and $replicationExtension.Property.CustomProperty.StorageAccountId -ne $cacheStorageAccount.Id) {
            Write-Host "Replication Extension '$($replicationExtensionName)' found but linked to a different Cache Storage Account '$($replicationExtension.Property.CustomProperty.StorageAccountId)'."
        
            try {
                Az.Migrate.Internal\Remove-AzMigrateReplicationExtension -InputObject $replicationExtension | Out-Null
            }
            catch {
                if ($_.Exception.Message -notmatch "Status: OK") {
                    throw $_.Exception.Message
                }
            }

            Write-Host "Removing Replication Extension and waiting for 2 minutes..."
            Start-Sleep -Seconds 120
            $replicationExtension = Az.Migrate.Internal\Get-AzMigrateReplicationExtension `
                -InputObject $replicationExtension `
                -ErrorVariable notPresent `
                -ErrorAction SilentlyContinue

            if ($null -eq $replicationExtension) {
                Write-Host "Replication Extension '$($replicationExtensionName)' was removed."
            }
        }

        # Replication extension exists
        if ($null -ne $replicationExtension) {
            # Give time for create/update to reach a terminal state. Timeout after 10min
            if ($replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Creating -or
                $replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Updating) {
                Write-Host "Replication Extension '$($replicationExtensionName)' found in Provisioning State '$($replicationExtension.Property.ProvisioningState)'."

                for ($i = 0; $i -lt 20; $i++) {
                    Start-Sleep -Seconds 30
                    $replicationExtension = Az.Migrate.Internal\Get-AzMigrateReplicationExtension `
                        -InputObject $replicationExtension `
                        -ErrorVariable notPresent `
                        -ErrorAction SilentlyContinue

                    if (-not (
                            $replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Creating -or
                            $replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Updating)) {
                        break
                    }
                }

                # Make sure replication extension is no longer in Creating or Updating state
                if ($replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Creating -or
                    $replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Updating) {
                    throw "Replication Extension '$($replicationExtensionName)' times out with Provisioning State: '$($replicationExtension.Property.ProvisioningState)'. Please re-run this command or contact support if help needed."
                }
            }

            # Check and remove if replication extension is in a bad terminal state
            if ($replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Canceled -or
                $replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Failed) {
                Write-Host "Replication Extension '$($replicationExtensionName)' found but in an unusable terminal Provisioning State '$($replicationExtension.Property.ProvisioningState)'.`nRemoving Replication Extension..."
                    
                # Remove replication extension
                try {
                    Az.Migrate.Internal\Remove-AzMigrateReplicationExtension -InputObject $replicationExtension | Out-Null
                }
                catch {
                    if ($_.Exception.Message -notmatch "Status: OK") {
                        throw $_.Exception.Message
                    }
                }

                Start-Sleep -Seconds 30
                $replicationExtension = Az.Migrate.Internal\Get-AzMigrateReplicationExtension `
                    -InputObject $replicationExtension `
                    -ErrorVariable notPresent `
                    -ErrorAction SilentlyContinue

                # Make sure replication extension is no longer in Canceled or Failed state
                if ($null -ne $replicationExtension -and
                    ($replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Canceled -or
                    $replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Failed)) {
                    throw "Failed to change the Provisioning State of Replication Extension '$($replicationExtensionName)'by removing. Please re-run this command or contact support if help needed."
                }
            }

            # Give time to remove replication extension. Timeout after 10min
            if ($null -ne $replicationExtension -and
                $replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Deleting) {
                Write-Host "Replication Extension '$($replicationExtensionName)' found in Provisioning State '$($replicationExtension.Property.ProvisioningState)'."

                for ($i = 0; $i -lt 20; $i++) {
                    Start-Sleep -Seconds 30
                    $replicationExtension = Az.Migrate.Internal\Get-AzMigrateReplicationExtension `
                        -InputObject $replicationExtension `
                        -ErrorVariable notPresent `
                        -ErrorAction SilentlyContinue

                    if ($null -eq $replicationExtension -or $replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Deleted) {
                        break
                    }
                    elseif ($replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Deleting) {
                        continue
                    }

                    throw "Replication Extension '$($replicationExtensionName)' has an unexpected Provisioning State of '$($replicationExtension.Property.ProvisioningState)' during removal process. Please re-run this command or contact support if help needed."
                }

                # Make sure replication extension is no longer in Deleting state
                if ($null -ne $replicationExtension -and $replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Deleting) {
                    throw "Replication Extension '$($replicationExtensionName)' times out with Provisioning State: '$($replicationExtension.Property.ProvisioningState)'. Please re-run this command or contact support if help needed."
                }
            }

            # Indicate replication extension was removed
            if ($null -eq $replicationExtension -or $replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Deleted) {
                Write-Host "Replication Extension '$($replicationExtensionName)' was removed."
            }
        }

        # Refresh local replication extension object if exists
        if ($null -ne $replicationExtension) {
            $replicationExtension = Az.Migrate.Internal\Get-AzMigrateReplicationExtension -InputObject $replicationExtension
        }

        # Create replication extension if not found or previously deleted
        if ($null -eq $replicationExtension -or $replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Deleted) {
            Write-Host "Waiting 2 minutes for permissions to sync before creating Replication Extension..."
            Start-Sleep -Seconds 120

            Write-Host "Creating Replication Extension..."
            $params = @{
                InstanceType                = $instanceType;
                SourceFabricArmId           = $sourceFabric.Id;
                TargetFabricArmId           = $targetFabric.Id;
                StorageAccountId            = $cacheStorageAccount.Id;
                StorageAccountSasSecretName = $null;
            }

            # Setup Replication Extension deployment parameters
            $replicationExtensionProperties = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.ReplicationExtensionModelProperties]::new()
        
            if ($instanceType -eq $AzLocalInstanceTypes.HyperVToAzLocal) {
                $replicationExtensionCustomProperties = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.HyperVToAzStackHcireplicationExtensionModelCustomProperties]::new()
                $replicationExtensionCustomProperties.HyperVFabricArmId = $params.SourceFabricArmId
                
            }
            elseif ($instanceType -eq $AzLocalInstanceTypes.VMwareToAzLocal) {
                $replicationExtensionCustomProperties = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20240901.VMwareToAzStackHcireplicationExtensionModelCustomProperties]::new()
                $replicationExtensionCustomProperties.VMwareFabricArmId = $params.SourceFabricArmId
            }
            else {
                throw "Currently, for AzLocal scenario, only HyperV and VMware as the source is supported."
            }
            $replicationExtensionCustomProperties.InstanceType = $params.InstanceType
            $replicationExtensionCustomProperties.AzStackHCIFabricArmId = $params.TargetFabricArmId
            $replicationExtensionCustomProperties.StorageAccountId = $params.StorageAccountId
            $replicationExtensionCustomProperties.StorageAccountSasSecretName = $params.StorageAccountSasSecretName
            $replicationExtensionProperties.CustomProperty = $replicationExtensionCustomProperties

            try {
                Az.Migrate.Internal\New-AzMigrateReplicationExtension `
                    -Name $replicationExtensionName `
                    -ResourceGroupName $ResourceGroupName `
                    -VaultName $replicationVaultName `
                    -Property $replicationExtensionProperties `
                    -SubscriptionId $SubscriptionId `
                    -NoWait | Out-Null
            }
            catch {
                if ($_.Exception.Message -notmatch "Status: OK") {
                    throw $_.Exception.Message
                }
            }

            # Check replication extension creation status every 30s. Timeout after 10min
            for ($i = 0; $i -lt 20; $i++) {
                Start-Sleep -Seconds 30
                $replicationExtension = Az.Migrate.Internal\Get-AzMigrateReplicationExtension `
                    -ResourceGroupName $ResourceGroupName `
                    -Name $replicationExtensionName `
                    -VaultName $replicationVaultName `
                    -SubscriptionId $SubscriptionId `
                    -ErrorVariable notPresent `
                    -ErrorAction SilentlyContinue

                if ($null -eq $replicationExtension) {
                   continue
                }
                
                # Stop if replication extension reaches a terminal state
                if ($replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Succeeded -or
                    $replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Deleted -or
                    $replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Canceled -or
                    $replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Failed) {
                    break
                }
            }

            # Make sure replicationExtension is in a terminal state
            if (-not (
                    $replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Succeeded -or
                    $replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Deleted -or
                    $replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Canceled -or
                    $replicationExtension.Property.ProvisioningState -eq [ProvisioningState]::Failed)) {
                throw "Replication Extension '$($replicationExtensionName)' times out with Provisioning State: '$($replicationExtension.Property.ProvisioningState)' during creation process. Please re-run this command or contact support if help needed."
            }
        }
        
        if ($replicationExtension.Property.ProvisioningState -ne [ProvisioningState]::Succeeded) {
            throw "Replication Extension '$($replicationExtensionName)' has an unexpected Provisioning State of '$($replicationExtension.Property.ProvisioningState)'. Please re-run this command or contact support if help needed."
        }

        $replicationExtension = Az.Migrate.Internal\Get-AzMigrateReplicationExtension `
            -ResourceGroupName $ResourceGroupName `
            -Name $replicationExtensionName `
            -VaultName $replicationVaultName `
            -SubscriptionId $SubscriptionId `
            -ErrorVariable notPresent `
            -ErrorAction SilentlyContinue
        if ($null -eq $replicationExtension) {
            throw "Unexpected error occurred during Replication Extension creation. Please re-run this command or contact support if help needed."
        }
        elseif ($replicationExtension.Property.ProvisioningState -ne [ProvisioningState]::Succeeded) {
            throw "Replication Extension '$($replicationExtensionName)' has an unexpected Provisioning State of '$($replicationExtension.Property.ProvisioningState)'. Please re-run this command or contact support if help needed."
        }
        else {
            Write-Host "*Selected Replication Extension: '$($replicationExtensionName)'"
        }

        if ($PassThru) {
            return $true
        }
    }
}
# SIG # Begin signature block
# MIIoUgYJKoZIhvcNAQcCoIIoQzCCKD8CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBIQ74O/eYehIbs
# xnEwfLblo7Z3oBj2I1CF8o4pVWZtEKCCDYUwggYDMIID66ADAgECAhMzAAAEA73V
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
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIMiz
# 8Vz9znJ+vFxCGZ7LXcY0r1eOYvVGn5BK/0hdddfMMEIGCisGAQQBgjcCAQwxNDAy
# oBSAEgBNAGkAYwByAG8AcwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20wDQYJKoZIhvcNAQEBBQAEggEAl1t9mM33WH7jKg05CkyI6Ds55igKGWAuJXX3
# M7CGc7ibLHAqIS+KK6qJzG0eBxWTo+96wvyc6sDzGzEsCk7r5/F9QyK2Q1tep41n
# Y7XRV8d3Fmwfyz3ecAn2JMGPf2FgaC26MOzg2YTbkfQlfJd7bHqyR/9Xr0nSjbIN
# ULkzuW4jAXUQJ2uSgc3Skkm6cxu581+r+/pZD1PNdeDtWTES7jb7jpHrOYUfZ2xG
# qIZ5efNqwE6EBgjXXrN0DCk9Z5gi9h58CeY/zZchfE2cwvnhCq2wsMKKDIGrfDO5
# DjYwZX6Y7Ebs+m5I9BEiMIFCyvgx0kcwaluCesKw6kcxmsUZyKGCF60wghepBgor
# BgEEAYI3AwMBMYIXmTCCF5UGCSqGSIb3DQEHAqCCF4YwgheCAgEDMQ8wDQYJYIZI
# AWUDBAIBBQAwggFaBgsqhkiG9w0BCRABBKCCAUkEggFFMIIBQQIBAQYKKwYBBAGE
# WQoDATAxMA0GCWCGSAFlAwQCAQUABCDXTKkIbxJu6god8g77YEsrpXWjB83UB/OA
# 71zmOkfckgIGZ7YtnDkGGBMyMDI1MDIyNTA3MDMzMS41MThaMASAAgH0oIHZpIHW
# MIHTMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQL
# EyRNaWNyb3NvZnQgSXJlbGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJzAlBgNVBAsT
# Hm5TaGllbGQgVFNTIEVTTjo2RjFBLTA1RTAtRDk0NzElMCMGA1UEAxMcTWljcm9z
# b2Z0IFRpbWUtU3RhbXAgU2VydmljZaCCEfswggcoMIIFEKADAgECAhMzAAAB/Big
# r8xpWoc6AAEAAAH8MA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFBDQSAyMDEwMB4XDTI0MDcyNTE4MzExNFoXDTI1MTAyMjE4MzExNFowgdMxCzAJ
# BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xLTArBgNVBAsTJE1pY3Jv
# c29mdCBJcmVsYW5kIE9wZXJhdGlvbnMgTGltaXRlZDEnMCUGA1UECxMeblNoaWVs
# ZCBUU1MgRVNOOjZGMUEtMDVFMC1EOTQ3MSUwIwYDVQQDExxNaWNyb3NvZnQgVGlt
# ZS1TdGFtcCBTZXJ2aWNlMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA
# p1DAKLxpbQcPVYPHlJHyW7W5lBZjJWWDjMfl5WyhuAylP/LDm2hb4ymUmSymV0EF
# RQcmM8BypwjhWP8F7x4iO88d+9GZ9MQmNh3jSDohhXXgf8rONEAyfCPVmJzM7yts
# urZ9xocbuEL7+P7EkIwoOuMFlTF2G/zuqx1E+wANslpPqPpb8PC56BQxgJCI1LOF
# 5lk3AePJ78OL3aw/NdlkvdVl3VgBSPX4Nawt3UgUofuPn/cp9vwKKBwuIWQEFZ83
# 7GXXITshd2Mfs6oYfxXEtmj2SBGEhxVs7xERuWGb0cK6afy7naKkbZI2v1UqsxuZ
# t94rn/ey2ynvunlx0R6/b6nNkC1rOTAfWlpsAj/QlzyM6uYTSxYZC2YWzLbbRl0l
# RtSz+4TdpUU/oAZSB+Y+s12Rqmgzi7RVxNcI2lm//sCEm6A63nCJCgYtM+LLe9pT
# shl/Wf8OOuPQRiA+stTsg89BOG9tblaz2kfeOkYf5hdH8phAbuOuDQfr6s5Ya6W+
# vZz6E0Zsenzi0OtMf5RCa2hADYVgUxD+grC8EptfWeVAWgYCaQFheNN/ZGNQMkk7
# 8V63yoPBffJEAu+B5xlTPYoijUdo9NXovJmoGXj6R8Tgso+QPaAGHKxCbHa1QL9A
# SMF3Os1jrogCHGiykfp1dKGnmA5wJT6Nx7BedlSDsAkCAwEAAaOCAUkwggFFMB0G
# A1UdDgQWBBSY8aUrsUazhxByH79dhiQCL/7QdjAfBgNVHSMEGDAWgBSfpxVdAF5i
# XYP05dJlpxtTNRnpcjBfBgNVHR8EWDBWMFSgUqBQhk5odHRwOi8vd3d3Lm1pY3Jv
# c29mdC5jb20vcGtpb3BzL2NybC9NaWNyb3NvZnQlMjBUaW1lLVN0YW1wJTIwUENB
# JTIwMjAxMCgxKS5jcmwwbAYIKwYBBQUHAQEEYDBeMFwGCCsGAQUFBzAChlBodHRw
# Oi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMFRp
# bWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNydDAMBgNVHRMBAf8EAjAAMBYGA1Ud
# JQEB/wQMMAoGCCsGAQUFBwMIMA4GA1UdDwEB/wQEAwIHgDANBgkqhkiG9w0BAQsF
# AAOCAgEAT7ss/ZAZ0bTaFsrsiJYd//LQ6ImKb9JZSKiRw9xs8hwk5Y/7zign9gGt
# weRChC2lJ8GVRHgrFkBxACjuuPprSz/UYX7n522JKcudnWuIeE1p30BZrqPTOnsc
# D98DZi6WNTAymnaS7it5qAgNInreAJbTU2cAosJoeXAHr50YgSGlmJM+cN6mYLAL
# 6TTFMtFYJrpK9TM5Ryh5eZmm6UTJnGg0jt1pF/2u8PSdz3dDy7DF7KDJad2qHxZO
# RvM3k9V8Yn3JI5YLPuLso2J5s3fpXyCVgR/hq86g5zjd9bRRyyiC8iLIm/N95q6H
# WVsCeySetrqfsDyYWStwL96hy7DIyLL5ih8YFMd0AdmvTRoylmADuKwE2TQCTvPn
# jnLk7ypJW29t17Yya4V+Jlz54sBnPU7kIeYZsvUT+YKgykP1QB+p+uUdRH6e79Va
# iz+iewWrIJZ4tXkDMmL21nh0j+58E1ecAYDvT6B4yFIeonxA/6Gl9Xs7JLciPCIC
# 6hGdliiEBpyYeUF0ohZFn7NKQu80IZ0jd511WA2bq6x9aUq/zFyf8Egw+dunUj1K
# tNoWpq7VuJqapckYsmvmmYHZXCjK1Eus7V1I+aXjrBYuqyM9QpeFZU4U01YG15uW
# wUCaj0uZlah/RGSYMd84y9DCqOpfeKE6PLMk7hLnhvcOQrnxP6kwggdxMIIFWaAD
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
# Hm5TaGllbGQgVFNTIEVTTjo2RjFBLTA1RTAtRDk0NzElMCMGA1UEAxMcTWljcm9z
# b2Z0IFRpbWUtU3RhbXAgU2VydmljZaIjCgEBMAcGBSsOAwIaAxUATkEpJXOaqI2w
# fqBsw4NLVwqYqqqggYMwgYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAx
# MDANBgkqhkiG9w0BAQsFAAIFAOtnQzIwIhgPMjAyNTAyMjQxOTEyNTBaGA8yMDI1
# MDIyNTE5MTI1MFowdDA6BgorBgEEAYRZCgQBMSwwKjAKAgUA62dDMgIBADAHAgEA
# AgIRqTAHAgEAAgISTTAKAgUA62iUsgIBADA2BgorBgEEAYRZCgQCMSgwJjAMBgor
# BgEEAYRZCgMCoAowCAIBAAIDB6EgoQowCAIBAAIDAYagMA0GCSqGSIb3DQEBCwUA
# A4IBAQCW6DUndrGzA6eec20ipYQae+/kx88wJZRuYw2Wy6B9gItK0+CU+vKR8Iu3
# pV20dmpLZZDob3ciFJpgkBJNNIetQWIBS4app8OuFqJPHbYCkzgfLJxZMl7aqh79
# 28pnFn0XHK3RPHgoPy8wQ7Vw7zCzszMckEgF7opLOm8dAyhVEDNDopVvgM4t4Fu/
# Ym6lnAZJcHlXGK8nAeD4+GWZ7SMJAtrpIOn6x8OJKv/1tvrNxfot667nnbT2Oum7
# Pg7wpOhb90ksTKEcAjBJFOE+g6rPN2gx1PHjWDppBYab93oDrxW6PiEJKXrJFwPy
# kZYetJxLqeMj5FXNsdkRSXG8mTyxMYIEDTCCBAkCAQEwgZMwfDELMAkGA1UEBhMC
# VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNV
# BAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRp
# bWUtU3RhbXAgUENBIDIwMTACEzMAAAH8GKCvzGlahzoAAQAAAfwwDQYJYIZIAWUD
# BAIBBQCgggFKMBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAvBgkqhkiG9w0B
# CQQxIgQg4UZqQSh+ocfBtY7ZCEAbDaeV5aYFkZT0FPmwKZsyIbEwgfoGCyqGSIb3
# DQEJEAIvMYHqMIHnMIHkMIG9BCCVQq+Qu+/h/BOVP4wweUwbHuCUhh+T7hq3d5MC
# aNEtYjCBmDCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9u
# MRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRp
# b24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAAB
# /Bigr8xpWoc6AAEAAAH8MCIEIMz7bolfJL3nj1zHUE9E7aMRc3VPpLEIsxLJ33Et
# rOd+MA0GCSqGSIb3DQEBCwUABIICAGZ1W2OTYkAzm03s0/SWKbXR8O1c5at78HnY
# 23ZZ7ngofzA9gnHs3Ua9G/uafDx+mRFlQ09QFTKV/RlE3/MWtndcdm3l87FvRBi6
# 9RHyqWnT5PQYOtWuwkFvMOoeH15qEWAtSB4y0WgEcZg5osnmSu/k3JsCZVp06NX4
# VDHDNS+H4L5QdADbd0ua7Y6+wg7bri/h37FUKponrA9pH67EZTYiNrQLC/ngMIqH
# W645BGJF0t5ABaQodf0MC9rWF2ckBSKPnFnhGsewq8r2j0OaOkJ5stfEp7bldNPN
# 8wZiob3plJl271IxynPO5vI9HzFIIK0hOlGN+oR+bUX/EK68wxqjzp180qOuer8n
# l0oatGvB4mh+uptGgbXAwuKzunlz5cNwfXee3SWkM44MhRwhHJYFK1CVW0VmwX2B
# M0ls2M/7hnV+D0YfbsUdxo77BcOLQiV4s+n9qWcuXkdKSHaUaVjzqz3eg981p4lN
# T7GT97So1T7V5pZaOVtYhlN79056+lKSOP9+PZhuGLdK40xI281xP+GYbj27NJDV
# JDoCsi+KjfqK7d+/Kvb6WSaJs/Qqj7lypRYhGGvT4gRxcLjHdjJZpZd1rn+fvyvd
# FakU4hAYt1qmR9u3bZMBHrUSzNAqqRYz73UVPxt7HcHIBRwRsInk3a3aFe+aMkYX
# O+lHzbDN
# SIG # End signature block
