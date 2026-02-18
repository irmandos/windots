
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
Updates the alert rule.
.Description
Updates the alert rule.

.Link
https://learn.microsoft.com/powershell/module/az.securityinsights/Update-azsentinelalertrule
#>
function Update-AzSentinelAlertRule {
    [OutputType([Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Models.Api20210901Preview.AlertRule])]
    [CmdletBinding(DefaultParameterSetName = 'UpdateScheduled', PositionalBinding = $false, SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [Parameter(ParameterSetName = 'UpdateFusionMLTI')]
        [Parameter(ParameterSetName = 'UpdateMicrosoftSecurityIncidentCreation')]
        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Runtime.DefaultInfo(Script = '(Get-AzContext).Subscription.Id')]
        [System.String]
        # Gets subscription credentials which uniquely identify Microsoft Azure subscription.
        # The subscription ID forms part of the URI for every service call.
        ${SubscriptionId},
        
        [Parameter(ParameterSetName = 'UpdateFusionMLTI', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateMicrosoftSecurityIncidentCreation', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateNRT', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateScheduled', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Path')]
        [System.String]
        # The Resource Group Name.
        ${ResourceGroupName},

        [Parameter(ParameterSetName = 'UpdateFusionMLTI', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateMicrosoftSecurityIncidentCreation', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateNRT', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateScheduled', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Path')]
        [System.String]
        # The name of the workspace.
        ${WorkspaceName},

        [Parameter(ParameterSetName = 'UpdateFusionMLTI', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateMicrosoftSecurityIncidentCreation', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateNRT', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateScheduled', Mandatory)]
        #[Alias('RuleId')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Path')]
        [System.String]
        # The name of Operational Insights Resource Provider.
        ${RuleId},

        [Parameter(ParameterSetName = 'UpdateViaIdentityFusionMLTI', Mandatory, ValueFromPipeline)]
        [Parameter(ParameterSetName = 'UpdateViaIdentityMicrosoftSecurityIncidentCreation', Mandatory, ValueFromPipeline)]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT', Mandatory, ValueFromPipeline)]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled', Mandatory, ValueFromPipeline)]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Models.ISecurityInsightsIdentity]
        # Identity Parameter
        # To construct, see NOTES section for INPUTOBJECT properties and create a hash table.
        ${InputObject},

        [Parameter(ParameterSetName = 'UpdateFusionMLTI', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateViaIdentityFusionMLTI', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        ${FusionMLorTI},

        [Parameter(ParameterSetName = 'UpdateMicrosoftSecurityIncidentCreation', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateViaIdentityMicrosoftSecurityIncidentCreation', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        ${MicrosoftSecurityIncidentCreation},

        [Parameter(ParameterSetName = 'UpdateNRT', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        ${NRT},

        [Parameter(ParameterSetName = 'UpdateScheduled', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        ${Scheduled},

        [Parameter(ParameterSetName = 'UpdateFusionMLTI')]
        [Parameter(ParameterSetName = 'UpdateMicrosoftSecurityIncidentCreation')]
        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityFusionMLTI')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityMicrosoftSecurityIncidentCreation')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String]
        ${AlertRuleTemplateName},
        
        [Parameter(ParameterSetName = 'UpdateFusionMLTI')]
        [Parameter(ParameterSetName = 'UpdateMicrosoftSecurityIncidentCreation')]
        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityFusionMLTI')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityMicrosoftSecurityIncidentCreation')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Switch]
        ${Enabled},

        [Parameter(ParameterSetName = 'UpdateFusionMLTI')]
        [Parameter(ParameterSetName = 'UpdateMicrosoftSecurityIncidentCreation')]
        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityFusionMLTI')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityMicrosoftSecurityIncidentCreation')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Switch]
        ${Disabled},

        [Parameter(ParameterSetName = 'UpdateMicrosoftSecurityIncidentCreation')]
        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityMicrosoftSecurityIncidentCreation')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String]
        ${Description},

        [Parameter(ParameterSetName = 'UpdateMicrosoftSecurityIncidentCreation')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityMicrosoftSecurityIncidentCreation')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String[]]
        ${DisplayNamesFilter},

        [Parameter(ParameterSetName = 'UpdateMicrosoftSecurityIncidentCreation')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityMicrosoftSecurityIncidentCreation')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String[]]
        ${DisplayNamesExcludeFilter},


        [Parameter(ParameterSetName = 'UpdateMicrosoftSecurityIncidentCreation')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityMicrosoftSecurityIncidentCreation')]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Support.MicrosoftSecurityProductName])]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Support.MicrosoftSecurityProductName]
        ${ProductFilter},
            
        [Parameter(ParameterSetName = 'UpdateMicrosoftSecurityIncidentCreation')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityMicrosoftSecurityIncidentCreation')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Support.AlertSeverity[]]
        #High, Medium, Low, Informational
        ${SeveritiesFilter},

        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String]
        ${Query},
        
        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String]
        ${DisplayName},

        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Runtime.DefaultInfo(Script = 'New-TimeSpan -Hours 5')]
        [System.TimeSpan]
        ${SuppressionDuration},

        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Switch]
        ${SuppressionEnabled},

        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Support.AlertSeverity])]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Support.AlertSeverity]
        ${Severity},

        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Support.AttackTactic])]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Support.AttackTactic]
        [System.String[]]
        ${Tactic},
            
        
        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Switch]
        ${CreateIncident},

        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Switch]
        ${GroupingConfigurationEnabled},

        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Switch]
        ${ReOpenClosedIncident},

        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Runtime.DefaultInfo(Script = 'New-TimeSpan -Hours 5')]
        [System.TimeSpan]
        ${LookbackDuration},

        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Runtime.DefaultInfo(Script = '"AllEntities"')]
        [ValidateSet('AllEntities', 'AnyAlert', 'Selected')]
        [System.String]
        ${MatchingMethod},
            
        
        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Support.AlertDetail])]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Support.AlertDetail[]]
        ${GroupByAlertDetail}, 
        
        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [string[]] 
        ${GroupByCustomDetail},
        
        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Support.EntityMappingType])]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Support.EntityMappingType[]]
        ${GroupByEntity},
    
        
        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        #'Account', 'Host', 'IP', 'Malware', 'File', 'Process', 'CloudApplication', 'DNS', 'AzureResource', 'FileHash', 'RegistryKey', 'RegistryValue', 'SecurityGroup', 'URL', 'Mailbox', 'MailCluster', 'MailMessage', 'SubmissionMail'
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Models.Api20210901Preview.EntityMapping[]]
        ${EntityMapping},

        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String]
        ${AlertDescriptionFormat},

        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String]
        ${AlertDisplayNameFormat},

        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String]
        ${AlertSeverityColumnName},

        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String]
        ${AlertTacticsColumnName},


        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.TimeSpan]
        ${QueryFrequency},

        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.TimeSpan]
        ${QueryPeriod},

        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Support.TriggerOperator])]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Support.TriggerOperator]
        ${TriggerOperator},
        
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [int]
        ${TriggerThreshold},

        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Support.EventGroupingAggregationKind])]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Support.EventGroupingAggregationKind]
        ${EventGroupingSettingAggregationKind},
            
        [Parameter()]
        [Alias('AzureRMContext', 'AzureCredential')]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Azure')]
        [System.Management.Automation.PSObject]
        # The credentials, account, tenant, and subscription used for communication with Azure.
        ${DefaultProfile},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Run the command as a job
        ${AsJob},

        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Wait for .NET debugger to attach
        ${Break},

        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Runtime')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Runtime.SendAsyncStep[]]
        # SendAsync Pipeline Steps to be appended to the front of the pipeline
        ${HttpPipelineAppend},

        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Runtime')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Runtime.SendAsyncStep[]]
        # SendAsync Pipeline Steps to be prepended to the front of the pipeline
        ${HttpPipelinePrepend},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Run the command asynchronously
        ${NoWait},

        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Runtime')]
        [System.Uri]
        # The URI for the proxy server to use
        ${Proxy},

        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Runtime')]
        [System.Management.Automation.PSCredential]
        # Credentials for a proxy server to use for the remote call
        ${ProxyCredential},

        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Use the default credentials for the proxy
        ${ProxyUseDefaultCredentials}
    )

    process {
        try {
            $null = $PSBoundParameters.Remove('FusionMLorTI')
            $null = $PSBoundParameters.Remove('MicrosoftSecurityIncidentCreation')
            $null = $PSBoundParameters.Remove('NRT')
            $null = $PSBoundParameters.Remove('Scheduled')
            #Handle Get
            $GetPSBoundParameters = @{}
            if($PSBoundParameters['InputObject']){
                $GetPSBoundParameters.Add('InputObject', $PSBoundParameters['InputObject'])
            }
            else {
                $GetPSBoundParameters.Add('ResourceGroupName', $PSBoundParameters['ResourceGroupName'])
                $GetPSBoundParameters.Add('WorkspaceName', $PSBoundParameters['WorkspaceName'])
                $GetPSBoundParameters.Add('RuleId', $PSBoundParameters['RuleId'])
            }
            $AlertRule = Az.SecurityInsights\Get-AzSentinelAlertRule @GetPSBoundParameters

            #Fusion
            if ($AlertRule.Kind -eq 'Fusion'){
                If($PSBoundParameters['AlertTemplateName']){
                    $AlertRule.AlertRuleTemplateName = $PSBoundParameters['AlertRuleTemplateName']
                    $null = $PSBoundParameters.Remove('AlertRuleTemplateName')
                }
                
                If($PSBoundParameters['Enabled']){
                    $AlertRule.Enabled = $true
                    $null = $PSBoundParameters.Remove('Enabled')
                }
                if($PSBoundParameters['Disabled']) {
                    $AlertRule.Enabled = $false
                    $null = $PSBoundParameters.Remove('Disabled')
                }
            }
            #MSIC
            if($AlertRule.Kind -eq 'MicrosoftSecurityIncidentCreation'){
                If($PSBoundParameters['AlertRuleTemplateName']){
                    $AlertRule.AlertRuleTemplateName = $PSBoundParameters['AlertRuleTemplateName']
                    $null = $PSBoundParameters.Remove('AlertRuleTemplateName')
                }
                
                If($PSBoundParameters['Enabled']){
                    $AlertRule.Enabled = $true
                    $null = $PSBoundParameters.Remove('Enabled')
                }
                if($PSBoundParameters['Disabled']) {
                    $AlertRule.Enabled = $false
                    $null = $PSBoundParameters.Remove('Disabled')
                }
                
                If($PSBoundParameters['Description']){
                    $AlertRule.Description = $PSBoundParameters['Description']
                    $null = $PSBoundParameters.Remove('Description')
                }
                
                If($PSBoundParameters['DisplayNamesFilter']){
                    $AlertRule.DisplayNamesFilter = $PSBoundParameters['DisplayNamesFilter']
                    $null = $PSBoundParameters.Remove('DisplayNamesFilter')
                }
                
                If($PSBoundParameters['DisplayNamesExcludeFilter']){
                    $AlertRule.DisplayNamesExcludeFilter = $PSBoundParameters['DisplayNamesExcludeFilter']
                    $null = $PSBoundParameters.Remove('DisplayNamesExcludeFilter')
                }
                
                If($PSBoundParameters['ProductFilter']){
                    $AlertRule.ProductFilter = $PSBoundParameters['ProductFilter']
                    $null = $PSBoundParameters.Remove('ProductFilter')
                }

                If($PSBoundParameters['SeveritiesFilter']){
                    $Parameter.SeveritiesFilter = $PSBoundParameters['SeveritiesFilter']
                    $null = $PSBoundParameters.Remove('SeveritiesFilter')
                }
            }
            #ML
            if ($AlertRule.Kind -eq 'MLBehaviorAnalytics'){
                If($PSBoundParameters['AlertRuleTemplateName']){
                    $AlertRule.AlertRuleTemplateName = $PSBoundParameters['AlertRuleTemplateName']
                    $null = $PSBoundParameters.Remove('AlertRuleTemplateName')
                }
                
                If($PSBoundParameters['Enabled']){
                    $AlertRule.Enabled = $true
                    $null = $PSBoundParameters.Remove('Enabled')
                }
                if($PSBoundParameters['Disabled']) {
                    $AlertRule.Enabled = $false
                    $null = $PSBoundParameters.Remove('Disabled')
                }
            }

            #NRT
            if($AlertRule.Kind -eq 'NRT'){
                If($PSBoundParameters['AlertRuleTemplateName']){
                    $AlertRule.Enabled = $PSBoundParameters['AlertRuleTemplateName']
                    $null = $PSBoundParameters.Remove('AlertRuleTemplateName')
                }
                
                If($PSBoundParameters['Enabled']){
                    $AlertRule.Enabled = $true
                    $null = $PSBoundParameters.Remove('Enabled')
                }
                if($PSBoundParameters['Disabled']) {
                    $AlertRule.Enabled = $false
                    $null = $PSBoundParameters.Remove('Disabled')
                }
                
                If($PSBoundParameters['Description']){
                    $AlertRule.Description = $PSBoundParameters['Description']
                    $null = $PSBoundParameters.Remove('Description')
                }
                
                If($PSBoundParameters['Query']){
                    $AlertRule.Query = $PSBoundParameters['Query']
                    $null = $PSBoundParameters.Remove('Query')
                }

                If($PSBoundParameters['DisplayName']){
                    $AlertRule.DisplayName = $PSBoundParameters['DisplayName']
                    $null = $PSBoundParameters.Remove('DisplayName')
                }

                If($PSBoundParameters['SuppressionDuration']){
                    $AlertRule.SuppressionDuration = $PSBoundParameters['SuppressionDuration']
                    $null = $PSBoundParameters.Remove('SuppressionDuration')
                }

                If($PSBoundParameters['SuppressionEnabled']){
                    $AlertRule.SuppressionEnabled = $true
                    $null = $PSBoundParameters.Remove('SuppressionEnabled')
                }
                else{
                    $AlertRule.SuppressionEnabled = $false
                }
                
                If($PSBoundParameters['Severity']){
                    $AlertRule.Severity = $PSBoundParameters['Severity']
                    $null = $PSBoundParameters.Remove('Severity')
                }
                
                If($PSBoundParameters['Tactic']){
                    $AlertRule.Tactic = $PSBoundParameters['Tactic']
                    $null = $PSBoundParameters.Remove('Tactic')
                }
                
                If($PSBoundParameters['IncidentConfigurationCreateIncident']){
                    $AlertRule.IncidentConfigurationCreateIncident = $true
                    $null = $PSBoundParameters.Remove('IncidentConfigurationCreateIncident')
                }
                else{
                    $AlertRule.IncidentConfigurationCreateIncident = $false
                }
                
                If($PSBoundParameters['Enabled']){
                    $AlertRule.GroupingConfigurationEnabled = $true
                    $null = $PSBoundParameters.Remove('Enabled')
                }
                else{
                    $AlertRule.GroupingConfigurationEnabled = $false
                }
                
                If($PSBoundParameters['ReOpenClosedIncident']){
                    $AlertRule.GroupingConfigurationReOpenClosedIncident = $true
                    $null = $PSBoundParameters.Remove('ReOpenClosedIncident')
                }
                else{
                    $AlertRule.GroupingConfigurationReOpenClosedIncident = $false
                }
                
                If($PSBoundParameters['LookbackDuration']){
                    $AlertRule.GroupingConfigurationLookbackDuration = $PSBoundParameters['LookbackDuration']
                    $null = $PSBoundParameters.Remove('LookbackDuration')
                }

                If($PSBoundParameters['MatchingMethod']){
                    $AlertRule.GroupingConfigurationMatchingMethod = $PSBoundParameters['MatchingMethod']
                    $null = $PSBoundParameters.Remove('MatchingMethod')
                }

                If($PSBoundParameters['GroupByAlertDetail']){
                    $AlertRule.GroupingConfigurationGroupByAlertDetail = $PSBoundParameters['GroupByAlertDetail']
                    $null = $PSBoundParameters.Remove('GroupByAlertDetail')
                }

                If($PSBoundParameters['GroupByCustomDetail']){
                    $AlertRule.GroupingConfigurationGroupByCustomDetail = $PSBoundParameters['GroupByCustomDetail']
                    $null = $PSBoundParameters.Remove('GroupByCustomDetail')
                }
                
                If($PSBoundParameters['GroupByEntity']){
                    $AlertRule.GroupingConfigurationGroupByEntity = $PSBoundParameters['GroupByEntity']
                    $null = $PSBoundParameters.Remove('GroupByEntity')
                }

                If($PSBoundParameters['EntityMapping']){
                    $AlertRule.EntityMapping = $PSBoundParameters['EntityMapping']
                    $null = $PSBoundParameters.Remove('EntityMapping')
                }

                If($PSBoundParameters['AlertDescriptionFormat']){
                    $AlertRule.AlertDetailOverrideAlertDescriptionFormat = $PSBoundParameters['AlertDescriptionFormat']
                    $null = $PSBoundParameters.Remove('AlertDescriptionFormat')
                }

                If($PSBoundParameters['AlertDisplayNameFormat']){
                    $AlertRule.AlertDetailOverrideAlertDisplayNameFormat = $PSBoundParameters['AlertDisplayNameFormat']
                    $null = $PSBoundParameters.Remove('AlertDisplayNameFormat')
                }

                If($PSBoundParameters['AlertSeverityColumnName']){
                    $AlertRule.AlertDetailOverrideAlertSeverityColumnName = $PSBoundParameters['AlertSeverityColumnName']
                    $null = $PSBoundParameters.Remove('AlertSeverityColumnName')
                }

                If($PSBoundParameters['AlertTacticsColumnName']){
                    $AlertRule.AlertDetailOverrideAlertTacticsColumnName = $PSBoundParameters['AlertTacticsColumnName']
                    $null = $PSBoundParameters.Remove('AlertTacticsColumnName')
                }
                
            }
            #Scheduled
            if ($AlertRule.Kind -eq 'Scheduled'){
                If($PSBoundParameters['AlertRuleTemplateName']){
                    $AlertRule.Enabled = $PSBoundParameters['AlertRuleTemplateName']
                    $null = $PSBoundParameters.Remove('AlertRuleTemplateName')
                }
                
                If($PSBoundParameters['Enabled']){
                    $AlertRule.Enabled = $true
                    $null = $PSBoundParameters.Remove('Enabled')
                }
                if($PSBoundParameters['Disabled']) {
                    $AlertRule.Enabled = $false
                    $null = $PSBoundParameters.Remove('Disabled')
                }
                
                If($PSBoundParameters['Description']){
                    $AlertRule.Description = $PSBoundParameters['Description']
                    $null = $PSBoundParameters.Remove('Description')
                }
                
                If($PSBoundParameters['Query']){
                    $AlertRule.Query = $PSBoundParameters['Query']
                    $null = $PSBoundParameters.Remove('Query')
                }

                If($PSBoundParameters['DisplayName']){
                    $AlertRule.DisplayName = $PSBoundParameters['DisplayName']
                    $null = $PSBoundParameters.Remove('DisplayName')
                }

                If($PSBoundParameters['SuppressionDuration']){
                    $AlertRule.SuppressionDuration = $PSBoundParameters['SuppressionDuration']
                    $null = $PSBoundParameters.Remove('SuppressionDuration')
                }

                If($PSBoundParameters['SuppressionEnabled']){
                    $AlertRule.SuppressionEnabled = $true
                    $null = $PSBoundParameters.Remove('SuppressionEnabled')
                }
                else{
                    $AlertRule.SuppressionEnabled = $false
                }
                
                If($PSBoundParameters['Severity']){
                    $AlertRule.Severity = $PSBoundParameters['Severity']
                    $null = $PSBoundParameters.Remove('Severity')
                }

                If($PSBoundParameters['Tactic']){
                    $AlertRule.Tactic = $PSBoundParameters['Tactic']
                    $null = $PSBoundParameters.Remove('Tactic')
                }
                
                If($PSBoundParameters['CreateIncident']){
                    $AlertRule.IncidentConfigurationCreateIncident = $true
                    $null = $PSBoundParameters.Remove('CreateIncident')
                }
                else{
                    $AlertRule.IncidentConfigurationCreateIncident = $false
                }
                
                If($PSBoundParameters['GroupingConfigurationEnabled']){
                    $AlertRule.GroupingConfigurationEnabled = $true
                    $null = $PSBoundParameters.Remove('GroupingConfigurationEnabled')
                }
                else{
                    $AlertRule.GroupingConfigurationEnabled = $false
                }
                
                If($PSBoundParameters['ReOpenClosedIncident']){
                    $AlertRule.GroupingConfigurationReOpenClosedIncident = $PSBoundParameters['ReOpenClosedIncident']
                    $null = $PSBoundParameters.Remove('ReOpenClosedIncident')
                }
                else{
                    $AlertRule.GroupingConfigurationReOpenClosedIncident = $false
                }
                
                If($PSBoundParameters['LookbackDuration']){
                    $AlertRule.GroupingConfigurationLookbackDuration = $PSBoundParameters['LookbackDuration']
                    $null = $PSBoundParameters.Remove('LookbackDuration')
                }

                If($PSBoundParameters['MatchingMethod']){
                    $AlertRule.GroupingConfigurationMatchingMethod = $PSBoundParameters['MatchingMethod']
                    $null = $PSBoundParameters.Remove('MatchingMethod')
                }

                If($PSBoundParameters['GroupByAlertDetail']){
                    $AlertRule.GroupingConfigurationGroupByAlertDetail = $PSBoundParameters['GroupByAlertDetail']
                    $null = $PSBoundParameters.Remove('GroupByAlertDetail')
                }

                If($PSBoundParameters['GroupByCustomDetail']){
                    $AlertRule.GroupingConfigurationGroupByCustomDetail = $PSBoundParameters['GroupByCustomDetail']
                    $null = $PSBoundParameters.Remove('GroupByCustomDetail')
                }
                
                If($PSBoundParameters['GroupByEntity']){
                    $AlertRule.GroupingConfigurationGroupByEntity = $PSBoundParameters['GroupByEntity']
                    $null = $PSBoundParameters.Remove('GroupByEntity')
                }

                If($PSBoundParameters['EntityMapping']){
                    $AlertRule.EntityMapping = $PSBoundParameters['EntityMapping']
                    $null = $PSBoundParameters.Remove('EntityMapping')
                }

                If($PSBoundParameters['AlertDescriptionFormat']){
                    $AlertRule.AlertDetailOverrideAlertDescriptionFormat = $PSBoundParameters['AlertDescriptionFormat']
                    $null = $PSBoundParameters.Remove('AlertDescriptionFormat')
                }

                If($PSBoundParameters['AlertDisplayNameFormat']){
                    $AlertRule.AlertDetailOverrideAlertDisplayNameFormat = $PSBoundParameters['AlertDisplayNameFormat']
                    $null = $PSBoundParameters.Remove('AlertDisplayNameFormat')
                }

                If($PSBoundParameters['AlertSeverityColumnName']){
                    $AlertRule.AlertDetailOverrideAlertSeverityColumnName = $PSBoundParameters['AlertSeverityColumnName']
                    $null = $PSBoundParameters.Remove('AlertSeverityColumnName')
                }

                If($PSBoundParameters['AlertTacticsColumnName']){
                    $AlertRule.AlertDetailOverrideAlertTacticsColumnName = $PSBoundParameters['AlertTacticsColumnName']
                    $null = $PSBoundParameters.Remove('AlertTacticsColumnName')
                }

                If($PSBoundParameters['QueryFrequency']){
                    $AlertRule.QueryFrequency = $PSBoundParameters['QueryFrequency']
                    $null = $PSBoundParameters.Remove('QueryFrequency')
                }

                If($PSBoundParameters['QueryPeriod']){
                    $AlertRule.QueryPeriod = $PSBoundParameters['QueryPeriod']
                    $null = $PSBoundParameters.Remove('QueryPeriod')
                }

                If($PSBoundParameters['TriggerOperator']){
                    $AlertRule.TriggerOperator = $PSBoundParameters['TriggerOperator']
                    $null = $PSBoundParameters.Remove('TriggerOperator')
                }

                If($null -ne $PSBoundParameters['TriggerThreshold']){
                    $AlertRule.TriggerThreshold = $PSBoundParameters['TriggerThreshold']
                    $null = $PSBoundParameters.Remove('TriggerThreshold')
                }

                If($PSBoundParameters['EventGroupingSettingAggregationKind']){
                    $AlertRule.EventGroupingSettingAggregationKind = $PSBoundParameters['EventGroupingSettingAggregationKind']
                    $null = $PSBoundParameters.Remove('EventGroupingSettingAggregationKind')
                }
            }
            #TI
            if ($AlertRule.Kind -eq 'ThreatIntelligence'){
                If($PSBoundParameters['AlertRuleTemplateName']){
                    $AlertRule.AlertRuleTemplateName = $PSBoundParameters['AlertRuleTemplateName']
                    $null = $PSBoundParameters.Remove('AlertRuleTemplateName')
                }

                If($PSBoundParameters['Enabled']){
                    $AlertRule.Enabled = $true
                    $null = $PSBoundParameters.Remove('Enabled')
                }
                if($PSBoundParameters['Disabled']) {
                    $AlertRule.Enabled = $false
                    $null = $PSBoundParameters.Remove('Disabled')
                }
            }
            
            $null = $PSBoundParameters.Add('AlertRule', $AlertRule) 

            Az.SecurityInsights.internal\Update-AzSentinelAlertRule @PSBoundParameters
        }
        catch {
            throw
        }
    }
}

# SIG # Begin signature block
# MIIoUgYJKoZIhvcNAQcCoIIoQzCCKD8CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCABPsycJ7BsYY2E
# kLPOfFIMTvaLzczMlBCUSLq8EWnuQ6CCDYUwggYDMIID66ADAgECAhMzAAAEA73V
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
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIHvL
# 1/dnSgtlnyAvjmL+ba/3Cb7j+Qay4EsCYNCqSwfOMEIGCisGAQQBgjcCAQwxNDAy
# oBSAEgBNAGkAYwByAG8AcwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20wDQYJKoZIhvcNAQEBBQAEggEAFW+yP7ZN+SLhgeSuv0J0Xj7M5oGJS9XttRwd
# sHi4HggolrRMJoQfhgGBHGCqWXFSj5BzRyoFjls+Va9myluobnOduj8RiH4Dye9e
# 1BHLAsAUjePjZsL4uZ+LbqbemUAanK5IBhbKteNSqiG7RJR/ULHRWSsRkXT8Zbu0
# O5YTG2IK/y6kGR0U5+GQBddzBNlUF9MgwqHn04iK5CfRTMW5iFz5BXbejcIXP40J
# uhe+7tD1IsDOxRqUyyN6ynt443fTI782dGT98qYxUNi9VZjqvaFzHE5R4wP7eQGa
# K+dw7C2XE9h7wmiKlmnlXpcH8iyqg7kgcw9I5uxTbO4CHaYJKaGCF60wghepBgor
# BgEEAYI3AwMBMYIXmTCCF5UGCSqGSIb3DQEHAqCCF4YwgheCAgEDMQ8wDQYJYIZI
# AWUDBAIBBQAwggFaBgsqhkiG9w0BCRABBKCCAUkEggFFMIIBQQIBAQYKKwYBBAGE
# WQoDATAxMA0GCWCGSAFlAwQCAQUABCA1h0ByiW7WT0GuCwlZXMRt1FjiypTGy5sy
# +O2d6hq0hgIGZ2LrqqY7GBMyMDI1MDEwOTA2Mzc0NS4yOTNaMASAAgH0oIHZpIHW
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
# MDANBgkqhkiG9w0BAQsFAAIFAOspwXEwIhgPMjAyNTAxMDkwMzMwNTdaGA8yMDI1
# MDExMDAzMzA1N1owdDA6BgorBgEEAYRZCgQBMSwwKjAKAgUA6ynBcQIBADAHAgEA
# AgIPSDAHAgEAAgIUAzAKAgUA6ysS8QIBADA2BgorBgEEAYRZCgQCMSgwJjAMBgor
# BgEEAYRZCgMCoAowCAIBAAIDB6EgoQowCAIBAAIDAYagMA0GCSqGSIb3DQEBCwUA
# A4IBAQA3zubBdy8ooU7Y/ApZJqOdCEt24exR81ppAPvZCDYNM/vczg9Ke7XjOI2U
# srxaTXguT0wz5vnZ32ZPMsGfLYuIRqEpP1dx06jaKXZxzDGHC1FZo8TTs3R/ECAs
# WrM56HxHEVxilYsvdQR+t33lsoHIBE2NLH72lW2p2M0PhWgv6v2FC5ZwIpycHN9C
# tBBsvzJ9L7/xPxY3wmlWF+Kw6n4qJZLyedVjFcBFR6oT41JbX3OKbvtvi0GyUQaa
# V+1YsWKZ0sh7WDRa+fmN3JxJ4YrRQgexwH0+K/6LrTfdF0hNEF0bRF0yFKLgWp8k
# KtYONwPRqBHwnqPqDq/8UbU6uGUlMYIEDTCCBAkCAQEwgZMwfDELMAkGA1UEBhMC
# VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNV
# BAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRp
# bWUtU3RhbXAgUENBIDIwMTACEzMAAAH0F0aFwMs/OeUAAQAAAfQwDQYJYIZIAWUD
# BAIBBQCgggFKMBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAvBgkqhkiG9w0B
# CQQxIgQg/uxyhgNFRRIod4W6bN0S7GzymFbgGfjEJ5tqxtgKOhMwgfoGCyqGSIb3
# DQEJEAIvMYHqMIHnMIHkMIG9BCA/WMJ8biaT6njvkknB8Q7hSQIi8ys6vIBvZg60
# RBjWazCBmDCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9u
# MRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRp
# b24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAAB
# 9BdGhcDLPznlAAEAAAH0MCIEINDgenXN04FQ2zqQw+cuPTDIFNqxzKvL1OfxvDhE
# WSXDMA0GCSqGSIb3DQEBCwUABIICACmD0JglSPna5oAk8shCu7XK5QWfPuGr7QdO
# XyXrkX2Br5w8vYSdynlviEin6+zS4N3pYQMF7LO6edBqPW2ZPtvC0lRNaJ4Mkjl7
# nEsidJ/HKZ0i97GWtBiLoCZVOyGeXOtRsbaXE9FJe9uDYinTy4Y01rZRCFjL9jc6
# 6rKUiK7+SJ7jn3PMPimd1tx02eo7WFTkWAZTwwrGx2JV/3qiiNj29gm49Dhc9n0t
# L6f+ThmkpS2hqhblPXCQeDiT5FRWZXz6lrhLBtjSA8ASaAzseT33rfwQ3cMrbboN
# yHM1YeOwFEzXQ09y39fE8RGfx92wlVPsHLpwQ3RkqL19T9H41uEpb9Lqfon7M8DL
# fS7Tl6JCBw3e+/woG6KoQ9kBXx281b4I/eZ1WJGxZSXX3spz/OKAZWv52PfmQzcR
# 2/MNFnjgW7e8v5+PToK4OIRvX+mT24vHh/j7jJlvKXeQRo+C1LYGPSB7mEKuSCOX
# jobMZQyqW1ZXVa9NJDclJzjgwocQAfC/WH42O8hboBuuuuFbaBbrJ/ALSVmScypr
# 883u1B//HBdhWI7mbteiG6u6A0ITpVnOBf94joIhfsOstppoS4iCIidfG2AXjgAD
# Sjbfm0+QM3e3U9ltwQs49bCIJr6t//fIllF0uEbX//L894Vi1amSAs4ZTzpSDc8W
# nDFA2nme
# SIG # End signature block
