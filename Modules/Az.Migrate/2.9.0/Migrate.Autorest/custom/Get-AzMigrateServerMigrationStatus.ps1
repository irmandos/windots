
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
Retrieves the details of the replicating server status.
.Description
The Get-AzMigrateServerMigrationStatus cmdlet retrieves the replication status for the replicating server.
.Link
https://learn.microsoft.com/powershell/module/az.migrate/get-azmigrateservermigrationstatus
#>
function Get-AzMigrateServerMigrationStatus {
    [OutputType([PSCustomObject[]])]
    [CmdletBinding(DefaultParameterSetName = 'ListByName', PositionalBinding = $false)]
    param(
        [Parameter(ParameterSetName = 'ListByName', Mandatory)]
        [Parameter(ParameterSetName = 'GetByMachineName', Mandatory)]
        [Parameter(ParameterSetName = 'GetHealthByMachineName', Mandatory)]
        [Parameter(ParameterSetName = 'GetByApplianceName', Mandatory)]
        #[Parameter(ParameterSetName = 'GetByPrioritiseServer', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the Resource Group of the Azure Migrate Project in the current subscription.
        ${ResourceGroupName},

        [Parameter(ParameterSetName = 'ListByName', Mandatory)]
        [Parameter(ParameterSetName = 'GetByMachineName', Mandatory)]
        [Parameter(ParameterSetName = 'GetHealthByMachineName', Mandatory)]
        [Parameter(ParameterSetName = 'GetByApplianceName', Mandatory)]
        #[Parameter(ParameterSetName = 'GetByPrioritiseServer', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the Azure Migrate project  in the current subscription.
        ${ProjectName},

        [Parameter(ParameterSetName = 'GetByMachineName', Mandatory)]
        [Parameter(ParameterSetName = 'GetHealthByMachineName', Mandatory)]
        #[Parameter(ParameterSetName = 'GetByPrioritiseServer', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the display name of the replicating machine.
        ${MachineName},

        [Parameter(ParameterSetName = 'GetByApplianceName', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the name of the appliance.
        ${ApplianceName},

        [Parameter(ParameterSetName = 'GetHealthByMachineName', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.Management.Automation.SwitchParameter]
        # Specifies whether the health issues to show for replicating server.
        ${Health},

        [Parameter(ParameterSetName = 'ListByName')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Query')]
        [System.String]
        # OData filter options.
        ${Filter},
    
        [Parameter(ParameterSetName = 'ListByName')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Query')]
        [System.String]
        # The pagination token.
        ${SkipToken},
    
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
        Function MakeTable ($TableName, $ColumnArray) {
            foreach($Col in $ColumnArray) {
                $MCol = New-Object System.Data.DataColumn $Col;
                $TableName.Columns.Add($MCol)
            }
        }

        $appMap = @{}

        Function PopulateApplianceDetails ($projName, $rgName) {
            # Get vault name from SMS solution.
            $smsSolution = Get-AzMigrateSolution -MigrateProjectName $projName -ResourceGroupName $rgName -Name "Servers-Migration-ServerMigration"

            if (-not $smsSolution.DetailExtendedDetail.AdditionalProperties.vaultId) {
                throw 'Azure Migrate appliance not configured. Setup Azure Migrate appliance before proceeding.'
            }

            $VaultName = $smsSolution.DetailExtendedDetail.AdditionalProperties.vaultId.Split("/")[8]

            # Get all appliances and sites in the project from SDS solution.
            $sdsSolution = Get-AzMigrateSolution -MigrateProjectName $projName -ResourceGroupName $rgName -Name "Servers-Discovery-ServerDiscovery"

            if ($null -ne $sdsSolution.DetailExtendedDetail["applianceNameToSiteIdMapV2"]) {
                $appMapV2 = $sdsSolution.DetailExtendedDetail["applianceNameToSiteIdMapV2"] | ConvertFrom-Json
                # Fetch all appliances from V2 map first. Then these can be updated if found again in V3 map.
                foreach ($item in $appMapV2) {
                    $appMap[$item.SiteId.Split('/')[-1]] = $item.ApplianceName
                }
            }

            if ($null -ne $sdsSolution.DetailExtendedDetail["applianceNameToSiteIdMapV3"]) {
                $appMapV3 = $sdsSolution.DetailExtendedDetail["applianceNameToSiteIdMapV3"] | ConvertFrom-Json
                foreach ($item in $appMapV3) {
                    $t = $item.psobject.properties
                    $appMap[$t.Value.SiteId.Split('/')[-1]] = $t.Name
                }
            }
        }

        Function GetApplianceName ($site) {
            if (!$appMap.ContainsKey($site)) {
                return "No appliance found for site name: $site"
            }
            return $appMap[$site]
        }

        Function GetState {
            param(
                [string]$State,
                [object]$ReplicationMigrationItem
            )

            if ([string]::IsNullOrEmpty($State)) {
                if ($ReplicationMigrationItem.MigrationState -match "InitialSeedingInProgress" -or $ReplicationMigrationItem.MigrationState -match "EnableMigrationInProgress" -or $ReplicationMigrationItem.MigrationState -match "Replicating") {
                    return "InitialReplication Queued"
                }
                elseif ($ReplicationMigrationItem.MigrationState -match "InitialSeedingFailed") {
                    return "InitialReplication Failed"
                }
                return $ReplicationMigrationItem.MigrationState
            }

            if ($ReplicationMigrationItem.MigrationState -match "MigrationInProgress" -and $ReplicationMigrationItem.migrationProgressPercentage -eq $null) {
                return "FinalDeltaReplication Queued"
            }

            if ($ReplicationMigrationItem.MigrationState -eq "MigrationSucceeded") {
                return "Migration Completed"
            }

            $State = $State -replace "PlannedFailoverOverDeltaReplication", "FinalDeltaReplication"
            return $State
        }

        function Convert-MillisecondsToTime {
            param (
                [int]$Milliseconds
            )

            if ($Milliseconds -eq $null) {
                return $null
            }

            $TotalMinutes = [math]::Floor($Milliseconds / 60000)
            $Hours = [math]::Floor($TotalMinutes / 60)
            $Minutes = $TotalMinutes % 60

            if ($Hours -eq 0) {
                if ($Minutes -eq 0)
                {
                    return "-"
                }
                return "$Minutes min"
            } else {
                return "$Hours hr $Minutes min"
            }
        }

        function Convert-ToMbps {
            param (
                [double]$UploadSpeedInBytesPerSecond
            )

            if ($UploadSpeedInBytesPerSecond -eq $null -or $UploadSpeedInBytesPerSecond -eq 0) {
                return "-"
            }

            # Conversion factor: 1 byte = 8 bits
            $UploadSpeedInBitsPerSecond = $UploadSpeedInBytesPerSecond * 8

            # Conversion factor: 1 megabit = 1,000,000 bits
            $UploadSpeedInMbps = [math]::Round($UploadSpeedInBitsPerSecond / 1e6)

            return "$UploadSpeedInMbps Mbps"
        }

        function Add-Percent {
            param (
                [double]$Value
            )

            if ($Value -ne $null -and $Value -ne 0) {
                return "$Value%"
            } else {
                return "-"
            }
        }

        function ConvertToCustomTimeFormat {
            param (
                [string]$LocalTimeString
            )
            
            if ([string]::IsNullOrEmpty($LocalTimeString)) {
                return "-"
            }

            # Parse the input string
            $localTime = [datetime]::ParseExact($LocalTimeString, "MM/dd/yyyy HH:mm:ss", $null)

            # Format the local time as desired
            $formattedTime = Get-Date $localTime -Format "M/d/yyyy, h:mm:ss tt"

            return $formattedTime
        }

        $parameterSet = $PSCmdlet.ParameterSetName
        $null = $PSBoundParameters.Remove('ResourceGroupName')
        $null = $PSBoundParameters.Remove('ProjectName')
        $HasFilter = $PSBoundParameters.ContainsKey('Filter')
        $HasSkipToken = $PSBoundParameters.ContainsKey('SkipToken')
        $null = $PSBoundParameters.Remove('Filter')
        $null = $PSBoundParameters.Remove('SkipToken')
        $null = $PSBoundParameters.Remove('MachineName')
        $null = $PSBoundParameters.Remove('ApplianceName')
        $null = $PSBoundParameters.Remove('Health')
        #$null = $PSBoundParameters.Remove('Expedite')

        $output = New-Object System.Collections.ArrayList  # Create a hashtable to store the output.

        $null = $PSBoundParameters.Add("ResourceGroupName", $ResourceGroupName)
        $null = $PSBoundParameters.Add("Name", "Servers-Migration-ServerMigration")
        $null = $PSBoundParameters.Add("MigrateProjectName", $ProjectName)

        $solution = Az.Migrate\Get-AzMigrateSolution @PSBoundParameters
        if ($solution -and ($solution.Count -ge 1)) {
            $VaultName = $solution.DetailExtendedDetail.AdditionalProperties.vaultId.Split("/")[8]
        }
        else {
            throw "Solution not found."
        }


        $null = $PSBoundParameters.Remove("Name")
        $null = $PSBoundParameters.Remove("MigrateProjectName")
        $null = $PSBoundParameters.Add('ResourceName', $VaultName)

        if ($HasFilter) {
            $null = $PSBoundParameters.Add("Filter", $Filter)
        }
        if ($HasSkipToken) {
            $null = $PSBoundParameters.Add("SkipToken", $SkipToken)
        }

        PopulateApplianceDetails $ProjectName $ResourceGroupName

        if ($parameterSet -eq "GetByApplianceName" -and !$appMap.ContainsValue($ApplianceName))
        {
            throw "No appliance found with name $ApplianceName"
        }

        if ($parameterSet -eq "GetByMachineName" -or $parameterSet -eq "GetHealthByMachineName" -or $parameterSet -eq "GetByPrioritiseServer") {
            $ReplicationMigrationItems = Get-AzMigrateServerReplication -ProjectName $ProjectName -ResourceGroupName $ResourceGroupName -MachineName $MachineName
        }
        else {
            $ReplicationMigrationItems = Get-AzMigrateServerReplication -ProjectName $ProjectName -ResourceGroupName $ResourceGroupName
        }

        if ($ReplicationMigrationItems -eq $null) {
            if ($parameterSet -eq "GetByMachineName" -or $parameterSet -eq "GetHealthByMachineName") {
                Write-Host "No replicating machine found with name $MachineName."
            }
            else {
                Write-Host "No replicating machine found."
            }
            return;
        }

        $vmMigrationStatusTable = New-Object System.Data.DataTable("")

        if ($parameterSet -eq "GetByApplianceName") {
            $column = @("Server", "State", "Progress", "TimeElapsed", "TimeRemaining", "UploadSpeed", "Health", "LastSync", "Datastore")
        }
        elseif ($parameterSet -eq "ListByName") {
            $column = @("Appliance", "Server", "State", "Progress", "TimeElapsed", "TimeRemaining", "UploadSpeed", "Health", "LastSync", "Datastore")
        }
        else {
            $column = @("Appliance", "Server", "State", "Progress", "TimeElapsed", "TimeRemaining", "UploadSpeed", "LastSync", "Datastore")
        }

        MakeTable $vmMigrationStatusTable $column

        foreach ($ReplicationMigrationItem in $ReplicationMigrationItems) {
            if ($parameterSet -eq "GetByMachineName") {
                if ($ReplicationMigrationItem.health -eq "Normal") {
                    $op = $output.Add("`nServer $MachineName is currently healthy.")
                }
                elseif ($ReplicationMigrationItem.health -eq "None") {
                    $op = $output.Add("`nServer $MachineName is in $($ReplicationMigrationItems.ReplicationStatus) state.")
                }
                else {
                    $op = $output.Add("`nServer $MachineName is currently facing critical error/ warning. Please run the command given below to know about the errors and resolutions.`n`nGet-AzMigrateServerMigrationStatus -ProjectName <String> -ResourceGroupName <String> -Appliance <String> -MachineName <String> -Health")
                }
            }

            if ($parameterSet -eq "GetByMachineName" -or $parameterSet -eq "GetHealthByMachineName" -or $parameterSet -eq "GetByPrioritiseServer") {
                $ReplicationMigrationItem = Get-AzMigrateServerReplication -TargetObjectID $ReplicationMigrationItem.Id
            }

            $site = $ReplicationMigrationItem.ProviderSpecificDetail.vmwareMachineId.Split('/')[-3]
            $appName = GetApplianceName $site
            $row1 = $vmMigrationStatusTable.NewRow()
            if ($parameterSet -eq "GetByApplianceName" -and $appName -ne $ApplianceName) {
                continue;
            }
            if ($parameterSet -ne "GetByApplianceName") {
                $row1["Appliance"] = $appName
            }

            $row1["Server"] = $ReplicationMigrationItem.MachineName
            $row1["State"] = GetState -State $ReplicationMigrationItem.ProviderSpecificDetail.GatewayOperationDetailState -ReplicationMigrationItem $ReplicationMigrationItem
            if ($ReplicationMigrationItem.ReplicationStatus -match "Pause" -and $ReplicationMigrationItem.MigrationState -notmatch "migration") {
                $row1["State"] = $ReplicationMigrationItem.ReplicationStatus
                $row1["TimeRemaining"] = "-"
                $row1["UploadSpeed"] = "-"
                $row1["Progress"] = "-"
                $row1["TimeElapsed"] = "-"
            }
            elseif ($ReplicationMigrationItem.ReplicationStatus -match "Resum") {
                $row1["State"] = $ReplicationMigrationItem.ReplicationStatus
                $row1["TimeRemaining"] = Convert-MillisecondsToTime -Milliseconds $ReplicationMigrationItem.ProviderSpecificDetail.GatewayOperationDetailTimeRemaining
                $row1["UploadSpeed"] = Convert-ToMbps -UploadSpeedInBytesPerSecond $ReplicationMigrationItem.ProviderSpecificDetail.GatewayOperationDetailUploadSpeed
                $row1["Progress"] = Add-Percent -Value $ReplicationMigrationItem.ProviderSpecificDetail.GatewayOperationDetailProgressPercentage
                $row1["TimeElapsed"] = Convert-MillisecondsToTime -Milliseconds $ReplicationMigrationItem.ProviderSpecificDetail.GatewayOperationDetailTimeElapsed
            }
            elseif ($ReplicationMigrationItem.ProviderSpecificDetail.GatewayOperationDetailState -match "Completed") {
                $row1["TimeRemaining"] = "-"
                $row1["UploadSpeed"] = "-"
                $row1["Progress"] = "-"
                $row1["TimeElapsed"] = "-"
            }
            else {
                $row1["TimeRemaining"] = Convert-MillisecondsToTime -Milliseconds $ReplicationMigrationItem.ProviderSpecificDetail.GatewayOperationDetailTimeRemaining
                $row1["UploadSpeed"] = Convert-ToMbps -UploadSpeedInBytesPerSecond $ReplicationMigrationItem.ProviderSpecificDetail.GatewayOperationDetailUploadSpeed
                $row1["Progress"] = Add-Percent -Value $ReplicationMigrationItem.ProviderSpecificDetail.GatewayOperationDetailProgressPercentage
                $row1["TimeElapsed"] = Convert-MillisecondsToTime -Milliseconds $ReplicationMigrationItem.ProviderSpecificDetail.GatewayOperationDetailTimeElapsed
            }

            if ($parameterSet -eq "ListByName" -or $parameterSet -eq "GetByApplianceName") {
                if ([string]::IsNullOrEmpty($ReplicationMigrationItem.health) -or $ReplicationMigrationItem.health -eq "None") {
                    $row1["Health"] = "-"
                }
                else {
                    $row1["Health"] = $ReplicationMigrationItem.health
                }
            }
            $row1["LastSync"] = ConvertToCustomTimeFormat -LocalTimeString $ReplicationMigrationItem.ProviderSpecificDetail.lastRecoveryPointReceived

            #$row1["ESXiHost"] = $ReplicationMigrationItem.ProviderSpecificDetail.GatewayOperationDetailHostName
            if (-not [string]::IsNullOrEmpty($ReplicationMigrationItem.ProviderSpecificDetail.GatewayOperationDetailDataStore)) {
                $row1["Datastore"] = $ReplicationMigrationItem.ProviderSpecificDetail.GatewayOperationDetailDataStore -join ', '
            }
            else {
                $row1["Datastore"] = "-"
            }

            $vmMigrationStatusTable.Rows.Add($row1)

            if( $parameterSet -eq "GetByMachineName" -or $parameterSet -eq "GetHealthByMachineName" -or $parameterSet -eq "GetByPrioritiseServer") {
                if ($parameterSet -eq "GetHealthByMachineName" -or $parameterSet -eq "GetByPrioritiseServer") {
                    $op = $output.Add("`nServer Information:")
                }

                $vmMigrationStatusTable = $vmMigrationStatusTable | Format-Table -AutoSize | Out-String
                $op = $output.Add($vmMigrationStatusTable)  # Store the table in the output hashtable

                $diskStatusTable = New-Object System.Data.DataTable("")
                $diskcolumn = @("Disk", "State", "Progress", "TimeElapsed", "TimeRemaining", "UploadSpeed", "Datastore")

                MakeTable $diskStatusTable $diskcolumn

                foreach($disk in $ReplicationMigrationItem.ProviderSpecificDetail.ProtectedDisk) {
                    $row = $diskStatusTable.NewRow()
                    $row["Disk"] = $disk.DiskName
                    $row["State"] = GetState -State $disk.GatewayOperationDetailState -ReplicationMigrationItem $ReplicationMigrationItem

                    if ($ReplicationMigrationItem.ReplicationStatus -match "Pause" -and $ReplicationMigrationItem.MigrationState -notmatch "migration") {
                        $row["State"] = $ReplicationMigrationItem.ReplicationStatus
                        $row["TimeRemaining"] = "-"
                        $row["UploadSpeed"] = "-"
                        $row["Progress"] = "-"
                        $row["TimeElapsed"] = "-"
                    }
                    elseif ($ReplicationMigrationItem.ReplicationStatus -match "Resum") {
                        $row["State"] = $ReplicationMigrationItem.ReplicationStatus
                        #$row["TimeRemaining"] = Convert-MillisecondsToTime -Milliseconds $disk.GatewayOperationDetailTimeRemaining
                        $row["TimeRemaining"] = "-"
                        $row["UploadSpeed"] = "-"
                        #$row["UploadSpeed"] = Convert-ToMbps -UploadSpeedInBytesPerSecond $disk.GatewayOperationDetailUploadSpeed
                        #$row["Progress"] = Add-Percent -Value $disk.GatewayOperationDetailProgressPercentage
                        $row["Progress"] = "-"
                        $row["TimeElapsed"] = "-"
                        #$row["TimeElapsed"] = Convert-MillisecondsToTime -Milliseconds $disk.GatewayOperationDetailTimeElapsed
                    }
                    elseif ($disk.GatewayOperationDetailState -match "Completed") {
                        $row["Progress"] = "-"
                        $row["TimeElapsed"] = "-"
                        $row["TimeRemaining"] = "-"
                        $row["UploadSpeed"] = "-"
                    }
                    else {
                        $row["TimeRemaining"] = Convert-MillisecondsToTime -Milliseconds $disk.GatewayOperationDetailTimeRemaining
                        $row["UploadSpeed"] = Convert-ToMbps -UploadSpeedInBytesPerSecond $disk.GatewayOperationDetailUploadSpeed
                        $row["Progress"] = Add-Percent -Value $disk.GatewayOperationDetailProgressPercentage
                        $row["TimeElapsed"] = Convert-MillisecondsToTime -Milliseconds $disk.GatewayOperationDetailTimeElapsed
                    }

                    if (-not [string]::IsNullOrEmpty($disk.GatewayOperationDetailDataStore)) {
                        $row["Datastore"] = $disk.GatewayOperationDetailDataStore -join ', '
                    }
                    else {
                        $row["Datastore"] = "-"
                    }
                    $diskStatusTable.Rows.Add($row)
                }

                if ($parameterSet -eq "GetHealthByMachineName" -or $parameterSet -eq "GetByPrioritiseServer") {
                    $op = $output.Add("`nDisk Level Operation Status:")
                }

                $diskStatusTable = $diskStatusTable | Format-Table -AutoSize | Out-String
                $op = $output.Add($diskStatusTable)  # Store the table in the output hashtable
            }

            if ($parameterSet -eq "GetHealthByMachineName") {
                if ($ReplicationMigrationItem.health -eq "Normal") {
                    $op = $output.Add("No warnings or critical errors for this server.")
                }
                else {
                    $op = $output.Add("List of warning or critical errors for this server with their resolutions: `n")
                    $healthError = $ReplicationMigrationItem.HealthError
                    foreach ($error in $healthError) {
                        $op = $output.Add("Error Message: $($error.ErrorMessage)`nPossible Causes: $($error.PossibleCaus)`nRecommended Actions: $($error.RecommendedAction)`n`n")
                    }
                }
            }

            <#if( $parameterSet -eq "GetByPrioritiseServer") {
                $vmMigrationTable = New-Object System.Data.DataTable("")
                $column = @("Appliance", "Server", "State", "TimeRemaining", "ESXiHost", "Datastore")
                MakeTable $vmMigrationTable $column

                foreach($MigrationItem in $ReplicationMigrationItems) {
                    $site = $MigrationItem.ProviderSpecificDetail.vmwareMachineId.Split('/')[-3]
                    $appName1 = GetApplianceName $site
                    if ($MigrationItem.MachineName -eq $ReplicationMigrationItem.MachineName -and $appName1 -eq $appName) {
                        continue;
                    }

                    if ($appName1 -ne $appName) {
                        continue;
                    }

                    $row1 = $vmMigrationTable.NewRow()
                    $row1["Appliance"] = $appName1
                    $row1["Server"] = $MigrationItem.MachineName
                    $row1["State"] = $MigrationItem.ProviderSpecificDetail.GatewayOperationDetailState
                    $row1["TimeRemaining"] = $MigrationItem.ProviderSpecificDetail.GatewayOperationDetailTimeRemaining
                    $row1["ESXiHost"] = $MigrationItem.ProviderSpecificDetail.GatewayOperationDetailHostName
                    $row1["Datastore"] = $MigrationItem.ProviderSpecificDetail.GatewayOperationDetailDataStore
                    $vmMigrationTable.Rows.Add($row1)
                }
                $op = $output.Add("Resource Sharing: `n`nVM $($ReplicationMigrationItem.MachineName) shares at least one resource with the following VM. These include ESXi host, Datastore or primary appliance.")
                $vmMigrationTable = $vmMigrationTable | Format-Table -AutoSize | Out-String
                $op = $output.Add($vmMigrationTable)

                $resourceUtilizationTable = New-Object System.Data.DataTable("")
                $column = @("Resource", "Capacity", "Utilization for server migrations", "Total utilization", "Status")
                MakeTable $resourceUtilizationTable $column
                $row1 = $resourceUtilizationTable.NewRow()
                $row1["Resource"] = "Appliance RAM Sum : Primary and scale out appliances"
                $row1["Capacity"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.RamDetailCapacity
                $row1["Utilization for server migrations"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.RamDetailProcessUtilization
                $row1["Total utilization"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.RamDetailTotalUtilization
                $row1["Status"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.RamDetailStatus
                $resourceUtilizationTable.Rows.Add($row1)

                $row2 = $resourceUtilizationTable.NewRow()
                $row2["Resource"] = "Appliance CPU Sum : Primary and scale out appliances"
                $row2["Capacity"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.CpuDetailCapacity
                $row2["Utilization for server migrations"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.CpuDetailProcessUtilization
                $row2["Total utilization"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.CpuDetailTotalUtilization
                $row2["Status"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.CpuDetailStatus
                $resourceUtilizationTable.Rows.Add($row2)

                $row3 = $resourceUtilizationTable.NewRow()
                $row3["Resource"] = "Network bandwidth Sum : Primary and scale out appliances"
                $row3["Capacity"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.NetworkBandwidthCapacity
                $row3["Utilization for server migrations"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.NetworkBandwidthProcessUtilization
                $row3["Total utilization"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.NetworkBandwidthTotalUtilization
                $row3["Status"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.NetworkBandwidthStatus
                $resourceUtilizationTable.Rows.Add($row3)

                $row4 = $resourceUtilizationTable.NewRow()
                $row4["Resource"] = "ESXi host NFC buffer"
                $row4["Capacity"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.EsxiNfcBufferCapacity
                $row4["Utilization for server migrations"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.EsxiNfcBufferProcessUtilization
                $row4["Total utilization"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.EsxiNfcBufferTotalUtilization
                $row4["Status"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.EsxiNfcBufferStatus
                $resourceUtilizationTable.Rows.Add($row4)

                $row5 = $resourceUtilizationTable.NewRow()
                $row5["Resource"] = "Parallel Disks Replicated Sum : Primary and scale out appliances"
                $row5["Capacity"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.DiskReplicationDetailCapacity
                $row5["Utilization for server migrations"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.DiskReplicationDetailProcessUtilization
                $row5["Total utilization"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.DiskReplicationDetailTotalUtilization
                $row5["Status"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.DiskReplicationDetailStatus
                $resourceUtilizationTable.Rows.Add($row5)

                $row6 = $resourceUtilizationTable.NewRow()
                $row6["Resource"] = "Datastore Snapshot Count (for each datastore corresponding to the server s disks)"
                $row6["Capacity"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.DatastoreSnapshotCapacity
                $row6["Utilization for server migrations"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.DatastoreSnapshotProcessUtilization
                $row6["Total utilization"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.DatastoreSnapshotTotalUtilization
                $row6["Status"] = $ReplicationMigrationItem.ProviderSpecificDetail.ApplianceMonitoringDetail.DatastoreSnapshotStatus
                $resourceUtilizationTable.Rows.Add($row6)

                $op = $output.Add("Resource utilization information for migration operations:")
                $resourceUtilizationTable = $resourceUtilizationTable | Format-Table -AutoSize | Out-String
                $op = $output.Add($resourceUtilizationTable)
                
                # <To-do> Add Recommendation actions logic for expedite.

                Write-Host "Based on the resource utilization seen above following are suggestion you can take to expedite server $($ReplicationMigrationItem.MachineName) migration :" -ForegroundColor White
                Write-Host "1. Pause replication for servers S2, S3, in delta sync who are migrating under appliance A1."
                Write-Host "2. Stop replication for servers S4 in Initial replication migrating under appliance A1."
                Write-Host "3. Increase the Network bandwidth available for appliances so that upload speeds can increase."
                Write-Host "4. Increase the NFC buffer size to increase the upload speed."
                Write-Host "5. Perform storage Vmotion on server $($ReplicationMigrationItem.MachineName)."
            }#>
        }

        if ($parameterSet -eq "GetByApplianceName" -or $parameterSet -eq "ListByName") {
            $vmMigrationStatusTable = $vmMigrationStatusTable | Format-Table -AutoSize | Out-String
            $op = $output.Add($vmMigrationStatusTable)

            $diskStatusTable = $diskStatusTable | Format-Table -AutoSize | Out-String
            $op = $output.Add($diskStatusTable)
#            $op = $output.Add("To check expedite the operation of a server use the command")
#            $op = $output.Add("Get-AzMigrateServerMigrationStatus  -ProjectName <String> -ResourceGroupName <String> -MachineName <String> -Expedite`n")
            $op = $output.Add("To resolve the health issue use the command")
            $op = $output.Add("Get-AzMigrateServerMigrationStatus -ProjectName <String> -ResourceGroupName <String> -MachineName <String> -Health`n")
        }

        return $output;
    }
}
# SIG # Begin signature block
# MIIoUgYJKoZIhvcNAQcCoIIoQzCCKD8CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCA999qg7zF1BK+n
# HnUrcaAFV951y9JBXmnAS5tnrxZwIqCCDYUwggYDMIID66ADAgECAhMzAAAEhJji
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
# cVZOSEXAQsmbdlsKgEhr/Xmfwb1tbWrJUnMTDXpQzTGCGiMwghofAgEBMIGVMH4x
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01p
# Y3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTECEzMAAASEmOIS4HijMV0AAAAA
# BIQwDQYJYIZIAWUDBAIBBQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIA3B
# 5v6kQC0XdkhYbDWsJfQ6tKMswLl/IG5l7KoXQ6UqMEIGCisGAQQBgjcCAQwxNDAy
# oBSAEgBNAGkAYwByAG8AcwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20wDQYJKoZIhvcNAQEBBQAEggEAqrfcRM6yazc3NCktppEiYl1Zh/tGd7FX4KHx
# H5JwBRNBya25Kv/XZVs2H5Kwg9rGDrbxM92hJ1jtIXde6Jxz/PCHmNV1GBoz1jtX
# paTYsRZqZrD5+ibaEqriarb8LfptFCaZLjW31iBpvsajwFKzQ9/nw2Z0qW9LX9uQ
# wrL4R+OUAhIEOJvvDHEK9i73XRk+6NDyKM7fQM7xM+9rkCDBIowUa8Scd7/nirGG
# KECd4oFTFnYfapHLhVOLZxNXKhn+6hQNOu03gqJf/TUDKVf9m+dhfXd3+KrxZrKw
# B+bIE7pn/Ww5gV6WrvZtm/nkwdbFCxQeHHb6S1ifBPXninfoOaGCF60wghepBgor
# BgEEAYI3AwMBMYIXmTCCF5UGCSqGSIb3DQEHAqCCF4YwgheCAgEDMQ8wDQYJYIZI
# AWUDBAIBBQAwggFaBgsqhkiG9w0BCRABBKCCAUkEggFFMIIBQQIBAQYKKwYBBAGE
# WQoDATAxMA0GCWCGSAFlAwQCAQUABCA/h1ksT704SxjvXTjUgI2gH4V/NnsCqyu8
# UAImFQJZMQIGaHpWY+0XGBMyMDI1MDczMDAzNTEyMC45NzJaMASAAgH0oIHZpIHW
# MIHTMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQL
# EyRNaWNyb3NvZnQgSXJlbGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJzAlBgNVBAsT
# Hm5TaGllbGQgVFNTIEVTTjo0MzFBLTA1RTAtRDk0NzElMCMGA1UEAxMcTWljcm9z
# b2Z0IFRpbWUtU3RhbXAgU2VydmljZaCCEfswggcoMIIFEKADAgECAhMzAAAB+vs7
# RNN3M8bTAAEAAAH6MA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFBDQSAyMDEwMB4XDTI0MDcyNTE4MzExMVoXDTI1MTAyMjE4MzExMVowgdMxCzAJ
# BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xLTArBgNVBAsTJE1pY3Jv
# c29mdCBJcmVsYW5kIE9wZXJhdGlvbnMgTGltaXRlZDEnMCUGA1UECxMeblNoaWVs
# ZCBUU1MgRVNOOjQzMUEtMDVFMC1EOTQ3MSUwIwYDVQQDExxNaWNyb3NvZnQgVGlt
# ZS1TdGFtcCBTZXJ2aWNlMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA
# yhZVBM3PZcBfEpAf7fIIhygwYVVP64USeZbSlRR3pvJebva0LQCDW45yOrtpwIpG
# yDGX+EbCbHhS5Td4J0Ylc83ztLEbbQD7M6kqR0Xj+n82cGse/QnMH0WRZLnwggJd
# enpQ6UciM4nMYZvdQjybA4qejOe9Y073JlXv3VIbdkQH2JGyT8oB/LsvPL/kAnJ4
# 5oQIp7Sx57RPQ/0O6qayJ2SJrwcjA8auMdAnZKOixFlzoooh7SyycI7BENHTpkVK
# rRV5YelRvWNTg1pH4EC2KO2bxsBN23btMeTvZFieGIr+D8mf1lQQs0Ht/tMOVdah
# 14t7Yk+xl5P4Tw3xfAGgHsvsa6ugrxwmKTTX1kqXH5XCdw3TVeKCax6JV+ygM5i1
# NroJKwBCW11Pwi0z/ki90ZeO6XfEE9mCnJm76Qcxi3tnW/Y/3ZumKQ6X/iVIJo7L
# k0Z/pATRwAINqwdvzpdtX2hOJib4GR8is2bpKks04GurfweWPn9z6jY7GBC+js8p
# SwGewrffwgAbNKm82ZDFvqBGQQVJwIHSXpjkS+G39eyYOG2rcILBIDlzUzMFFJbN
# h5tDv3GeJ3EKvC4vNSAxtGfaG/mQhK43YjevsB72LouU78rxtNhuMXSzaHq5fFiG
# 3zcsYHaa4+w+YmMrhTEzD4SAish35BjoXP1P1Ct4Va0CAwEAAaOCAUkwggFFMB0G
# A1UdDgQWBBRjjHKbL5WV6kd06KocQHphK9U/vzAfBgNVHSMEGDAWgBSfpxVdAF5i
# XYP05dJlpxtTNRnpcjBfBgNVHR8EWDBWMFSgUqBQhk5odHRwOi8vd3d3Lm1pY3Jv
# c29mdC5jb20vcGtpb3BzL2NybC9NaWNyb3NvZnQlMjBUaW1lLVN0YW1wJTIwUENB
# JTIwMjAxMCgxKS5jcmwwbAYIKwYBBQUHAQEEYDBeMFwGCCsGAQUFBzAChlBodHRw
# Oi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMFRp
# bWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNydDAMBgNVHRMBAf8EAjAAMBYGA1Ud
# JQEB/wQMMAoGCCsGAQUFBwMIMA4GA1UdDwEB/wQEAwIHgDANBgkqhkiG9w0BAQsF
# AAOCAgEAuFbCorFrvodG+ZNJH3Y+Nz5QpUytQVObOyYFrgcGrxq6MUa4yLmxN4xW
# dL1kygaW5BOZ3xBlPY7Vpuf5b5eaXP7qRq61xeOrX3f64kGiSWoRi9EJawJWCzJf
# UQRThDL4zxI2pYc1wnPp7Q695bHqwZ02eaOBudh/IfEkGe0Ofj6IS3oyZsJP1yat
# cm4kBqIH6db1+weM4q46NhAfAf070zF6F+IpUHyhtMbQg5+QHfOuyBzrt67CiMJS
# KcJ3nMVyfNlnv6yvttYzLK3wS+0QwJUibLYJMI6FGcSuRxKlq6RjOhK9L3QOjh0V
# CM11rHM11ZmN0euJbbBCVfQEufOLNkG88MFCUNE10SSbM/Og/CbTko0M5wbVvQJ6
# CqLKjtHSoeoAGPeeX24f5cPYyTcKlbM6LoUdO2P5JSdI5s1JF/On6LiUT50adpRs
# tZajbYEeX/N7RvSbkn0djD3BvT2Of3Wf9gIeaQIHbv1J2O/P5QOPQiVo8+0AKm6M
# 0TKOduihhKxAt/6Yyk17Fv3RIdjT6wiL2qRIEsgOJp3fILw4mQRPu3spRfakSoQe
# 5N0e4HWFf8WW2ZL0+c83Qzh3VtEPI6Y2e2BO/eWhTYbIbHpqYDfAtAYtaYIde87Z
# ymXG3MO2wUjhL9HvSQzjoquq+OoUmvfBUcB2e5L6QCHO6qTO7WowggdxMIIFWaAD
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
# Hm5TaGllbGQgVFNTIEVTTjo0MzFBLTA1RTAtRDk0NzElMCMGA1UEAxMcTWljcm9z
# b2Z0IFRpbWUtU3RhbXAgU2VydmljZaIjCgEBMAcGBSsOAwIaAxUA94Z+bUJn+nKw
# BvII6sg0Ny7aPDaggYMwgYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAx
# MDANBgkqhkiG9w0BAQsFAAIFAOwz/VQwIhgPMjAyNTA3MzAwMjA5MjRaGA8yMDI1
# MDczMTAyMDkyNFowdDA6BgorBgEEAYRZCgQBMSwwKjAKAgUA7DP9VAIBADAHAgEA
# AgJ4yDAHAgEAAgISUzAKAgUA7DVO1AIBADA2BgorBgEEAYRZCgQCMSgwJjAMBgor
# BgEEAYRZCgMCoAowCAIBAAIDB6EgoQowCAIBAAIDAYagMA0GCSqGSIb3DQEBCwUA
# A4IBAQB+suGqrLqoO46AVEaoRsDRCibNZu39yiBpcl2HHc0eeFRgW2hkjyKcV3ls
# lOW7Fpf1r/Zp/Z+/wmFXt4jzmWBFT701R640vIu6/U29x8gk+HR6Gw7tvhtzO9xX
# ZNQ+a7JYaWKxZqqWVtxBhJvXL5NhJOqW/Wir5bmNebhFWGnG2phBYEbBzKhCo+3z
# j2+L/iwjDiCAYBf5vHQhwXkAqsudTlY3c/zVO5SRTeIpNz1tHwJpF7/y36fKjC//
# cX8nnQoKXDhlmFSuf5m8TBj7kp2Iv4Af6Cc3qXQbVLlSqgQqZ1/czirO2gU5t6jI
# 7g2H4vo0UBBVuV9MSboVLrb6erRlMYIEDTCCBAkCAQEwgZMwfDELMAkGA1UEBhMC
# VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNV
# BAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRp
# bWUtU3RhbXAgUENBIDIwMTACEzMAAAH6+ztE03czxtMAAQAAAfowDQYJYIZIAWUD
# BAIBBQCgggFKMBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAvBgkqhkiG9w0B
# CQQxIgQgYgcMkMoNVNN2DyvTGBXZoIg4pOUJ/v2Y0cdDBVNCA5swgfoGCyqGSIb3
# DQEJEAIvMYHqMIHnMIHkMIG9BCB98n8tya8+B2jjU/dpJRIwHwHHpco5ogNStYoc
# bkOeVjCBmDCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9u
# MRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRp
# b24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAAB
# +vs7RNN3M8bTAAEAAAH6MCIEIJvEtHVprQBK7worjN4slcojJ38NQVArcn9JntSD
# jHuMMA0GCSqGSIb3DQEBCwUABIICAB2p3ro2yZZXHLuCU1AjNmpISh3+MhsuLPgD
# VR9+AjBm6TVoSDKpwPvBgMxIzlVAwsLEZG5yH0mTvxz0prvCDwDeCUR3JvvFqyEd
# dgo0A4Re2fmlxl1Xez8zoKX3aLkRBo2qIvEXmkU5Bl0OoZE3Xb8lazTT62bdoinp
# 3rxyTVdACj6Q4kkagzP53ab6Wmt7/QBm0ZS8FGLxi0+2yHpkMcDthQ7xa7CYlfYw
# BOfpcz2mCpVGX/nTkOIJIt/6AdEaUVkVo7MtdZBumdhZOwjtaAua+CjGXafT3Gs+
# LasepPEuHHvyzybpJH4F1HSsxFdNTdjvKpzs4t+PDhjq1aRvBUCELwPcIYQPo3dn
# ljxGgLlUuLiK/dKMIL5qQMwe3AFhbRKNKbpXBRebUVvIHB0re5T9zydW3InafM6e
# j3q5AE7NinY9shUrLrUcq9omnmd2cZHc3yl4SdyF03q1/HPtlCrOnFEtOXid90kK
# PFoI4NRdFBSS5qwXGthHfMS+V9Z5CGmMTkB34fDYI1eQmGauvLiZATTm+KVyWTDP
# Mi5uMQhBUVrUqrFQkkTERdGpnXnJObGT7wniQY7s92TOczzBQTHcYUZ+1jXUKffz
# NpZbK4zd/6r2nHi4jPgDMlzol5snfHDRCi2awttknW2A2UM6cf9N0BGnUXt+yQOB
# IGYlLVjk
# SIG # End signature block
