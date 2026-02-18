
# ----------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
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
Creates or updates a policy assignment.
.Description
The **New-AzPolicyAssignment** cmdlet creates or updates a policy assignment with the given scope and name.
Policy assignments apply to all resources contained within their scope.
For example, when you assign a policy at resource group scope, that policy applies to all resources in the group.
.Notes
## RELATED LINKS

[Get-AzPolicyAssignment](./Get-AzPolicyAssignment.md)

[Remove-AzPolicyAssignment](./Remove-AzPolicyAssignment.md)

[Update-AzPolicyAssignment](./Update-AzPolicyAssignment.md)
.Link
https://learn.microsoft.com/powershell/module/az.resources/new-azpolicyassignment
#>
function New-AzPolicyAssignment {
[OutputType([Microsoft.Azure.PowerShell.Cmdlets.Policy.Models.IPolicyAssignment])]
[CmdletBinding(DefaultParameterSetName='Default', SupportsShouldProcess=$true, ConfirmImpact='Low')]
param(
    [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [Alias('PolicyAssignmentName')]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Path')]
    [System.String]
    # The name of the policy assignment.
    ${Name},

    [Parameter(ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Path')]
    [System.String]
    # The scope of the policy assignment.
    # Valid scopes are: management group (format: '/providers/Microsoft.Management/managementGroups/{managementGroup}'), subscription (format: '/subscriptions/{subscriptionId}'), resource group (format: '/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}', or resource (format: '/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/{resourceProviderNamespace}/[{parentResourcePath}/]{resourceType}/{resourceName}'
    ${Scope},

    [Parameter(ValueFromPipelineByPropertyName)]
    [AllowEmptyCollection()]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Body')]
    [System.String[]]
    # The policy's excluded scopes.
    ${NotScope},

    [Parameter(ValueFromPipelineByPropertyName)]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Body')]
    [System.String]
    # The display name of the policy assignment.
    ${DisplayName},

    [Parameter(ValueFromPipelineByPropertyName)]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Body')]
    [System.String]
    # This message will be part of response in case of policy violation.
    ${Description},

    [Parameter(ParameterSetName='ParameterObject', ValueFromPipeline)]
    [Parameter(ParameterSetName='ParameterString', ValueFromPipeline)]
    [Parameter(ParameterSetName='PolicyDefinitionOrPolicySetDefinition', Mandatory, ValueFromPipeline)]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Body')]
    [PSCustomObject]
    [Alias('PolicySetDefinition')]
    # Accept policy definition or policy set definition object
    ${PolicyDefinition},

    [Parameter(ParameterSetName='ParameterObject')]
    [Parameter(ParameterSetName='ParameterString')]
    [Parameter(ParameterSetName='PolicyDefinitionOrPolicySetDefinition')]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Body')]
    [System.String]
    # Indicate version of policy definition or policy set definition
    ${DefinitionVersion},

    [Parameter(ParameterSetName='ParameterObject', Mandatory)]
    [ValidateNotNullOrEmpty()]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Body')]
    [hashtable]
    # The parameter values for the assigned policy rule.
    # The keys are the parameter names.
    ${PolicyParameterObject},

    [Parameter(ParameterSetName='ParameterString', Mandatory)]
    [ValidateNotNullOrEmpty()]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Body')]
    [System.String]
    # The parameter values for the assigned policy rule.
    # The keys are the parameter names.
    ${PolicyParameter},

    [Parameter(ValueFromPipelineByPropertyName)]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Body')]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Runtime.Info(PossibleTypes=([Microsoft.Azure.PowerShell.Cmdlets.Policy.Models.IPolicyAssignmentPropertiesMetadata]))]
    [System.String]
    # The policy assignment metadata.
    # Metadata is an open ended object and is typically a collection of key value pairs.
    ${Metadata},

    [Parameter(ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('Default', 'DoNotEnforce')]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.PSArgumentCompleterAttribute('Default', 'DoNotEnforce')]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Body')]
    [System.String]
    # The policy assignment enforcement mode.
    # Possible values are Default and DoNotEnforce.
    ${EnforcementMode},

    [Parameter()]
    [ValidateSet('None', 'SystemAssigned', 'UserAssigned')]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.PSArgumentCompleterAttribute('None', 'SystemAssigned', 'UserAssigned')]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Body')]
    [System.String]
    # The identity type.
    # This is the only required field when adding a system or user assigned identity to a resource.
    ${IdentityType},

    [Parameter()]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Body')]
    [System.String]
    # The user identity associated with the policy.
    # The user identity dictionary key references will be ARM resource ids in the form: '/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/{identityName}'.
    ${IdentityId},

    [Parameter(ValueFromPipelineByPropertyName)]
    [ArgumentCompleter({ LocationCompleter })]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Body')]
    [System.String]
    # The location of the policy assignment.
    # Only required when utilizing managed identity.
    ${Location},

    [Parameter(ValueFromPipelineByPropertyName)]
    [AllowEmptyCollection()]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Body')]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Runtime.Info(PossibleTypes=([Microsoft.Azure.PowerShell.Cmdlets.Policy.Models.INonComplianceMessage[]]))]
    [PSCustomObject[]]
    # The messages that describe why a resource is non-compliant with the policy.
    # To construct, see NOTES section for NONCOMPLIANCEMESSAGE properties and create a hash table.
    ${NonComplianceMessage},

    [Parameter()]
    [AllowEmptyCollection()]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Body')]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Models.IOverride[]]
    # The policy property value override.
    ${Override},

    [Parameter()]
    [AllowEmptyCollection()]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Body')]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Models.IResourceSelector[]]
    # The resource selector list to filter policies by resource properties.
    ${ResourceSelector},

    [Parameter()]
    [Obsolete('This parameter is a temporary bridge to new types and formats and will be removed in a future release.')]
    [System.Management.Automation.SwitchParameter]
    # Causes cmdlet to return artifacts using legacy format placing policy-specific properties in a property bag object.
    ${BackwardCompatible} = $false,

    [Parameter()]
    [Alias('AzureRMContext', 'AzureCredential')]
    [ValidateNotNull()]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Azure')]
    [System.Management.Automation.PSObject]
    # The DefaultProfile parameter is not functional.
    # Use the SubscriptionId parameter when available if executing the cmdlet against a different subscription.
    ${DefaultProfile},

    [Parameter(DontShow)]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Runtime')]
    [System.Management.Automation.SwitchParameter]
    # Wait for .NET debugger to attach
    ${Break},

    [Parameter(DontShow)]
    [ValidateNotNull()]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Runtime')]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Runtime.SendAsyncStep[]]
    # SendAsync Pipeline Steps to be appended to the front of the pipeline
    ${HttpPipelineAppend},

    [Parameter(DontShow)]
    [ValidateNotNull()]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Runtime')]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Runtime.SendAsyncStep[]]
    # SendAsync Pipeline Steps to be prepended to the front of the pipeline
    ${HttpPipelinePrepend},

    [Parameter(DontShow)]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Runtime')]
    [System.Uri]
    # The URI for the proxy server to use
    ${Proxy},

    [Parameter(DontShow)]
    [ValidateNotNull()]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Runtime')]
    [System.Management.Automation.PSCredential]
    # Credentials for a proxy server to use for the remote call
    ${ProxyCredential},

    [Parameter(DontShow)]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Runtime')]
    [System.Management.Automation.SwitchParameter]
    # Use the default credentials for the proxy
    ${ProxyUseDefaultCredentials}
)

DynamicParam
{
    # turn on console debug messages
    $writeln = ($PSCmdlet.MyInvocation.BoundParameters.Debug -as [bool]) -or ($PSCmdlet.MyInvocation.BoundParameters.Verbose -as [bool])

    if ($writeln) {
        Write-Host -ForegroundColor Cyan "begin:New-AzPolicyAssignment(" $PSBoundParameters ") - (ParameterSet: $($PSCmdlet.ParameterSetName))"
    }

    # generate dynamic parameters for assignement based on the policy definition being assigned
    if ($PolicyDefinition)
    {
        $parameters = [PSObject]$PolicyDefinition.Parameter
    }
    elseif ($PolicySetDefinition)
    {
        $parameters = [PSObject]$PolicySetDefinition.Parameter
    }

    $dynamicParameters = New-Object -TypeName 'System.Management.Automation.RuntimeDefinedParameterDictionary'
    if ($parameters)
    {
        foreach ($param in $parameters.PSObject.Properties)
        {
            $paramValue = [PSObject]$param.Value
            if ($paramValue)
            {
                $type = $paramValue.PSObject.Properties['type']
                if ($type) {
                    $typeString = $type.Value
                }

                $description = GetPSObjectProperty $paramValue 'metadata.description'
                if ($description) {
                    $helpString = $description
                }
                else {
                    $helpString = "The $($description) policy parameter."
                }

                $dp = New-Object -TypeName 'System.Management.Automation.RuntimeDefinedParameter'
                $dp.Name = $param.Name
                $dp.ParameterType = [string]
                if ($typeString -eq 'array') {
                    $dp.ParameterType = [string[]]
                }

                # Dynamic parameter should not be mandatory if it has a default value
                $pa = [System.Management.Automation.ParameterAttribute]@{
                    ParameterSetName = 'Default';
                    Mandatory = ($null -eq $paramValue.PSObject.Properties['defaultValue']);
                    ValueFromPipelineByPropertyName = $false;
                    HelpMessage = $helpString
                }

                $dp.Attributes.Add($pa);

                $dynamicParameters.Add($param.Name, $dp);
            }
        }
    }

    if ($writeln) {
        Write-Host -ForegroundColor Green "Found and registered $($dynamicParameters.Count) dynamic parameters from $($parameters.Count) input parameters."
    }

    return $dynamicParameters
}

begin {
    # turn on console debug messages
    $writeln = ($PSCmdlet.MyInvocation.BoundParameters.Debug -as [bool]) -or ($PSCmdlet.MyInvocation.BoundParameters.Verbose -as [bool])

    if ($writeln) {
        Write-Host -ForegroundColor Cyan "begin:New-AzPolicyAssignment(" $PSBoundParameters ") - (ParameterSet: $($PSCmdlet.ParameterSetName))"
    }

    # make mapping table
    $mapping = @{
        CreateExpanded = 'Az.Policy.private\New-AzPolicyAssignment_CreateExpanded';
        CreateExpanded1 = 'Az.Policy.private\New-AzPolicyAssignment_CreateExpanded1';
    }
}

process {
    if ($writeln) {
        Write-Host -ForegroundColor Cyan "process:New-AzPolicyAssignment(" $PSBoundParameters ") - (ParameterSet: $($PSCmdlet.ParameterSetName))"
    }

    $calledParameters = $PSBoundParameters
    # convert input parameter to generated parameter and remove
    if ($Name) {
        $calledParameters.Name = $Name
    }

    if (!$Scope) {
        $Scope = "/subscriptions/$($(Get-SubscriptionId))"
    }

    $calledParameters.Scope = $Scope

    # route the input policy id to the correct place
    if ($calledParameters.ContainsKey('PolicyDefinition')) {

        $definitionId = $PolicyDefinition
        if ($PolicyDefinition.Id) {
            $definitionId = $PolicyDefinition.Id
        }

        # parse the definition Id to determine the format (policy [set] definition and versioned or not)
        $parsedPolicyId = ParsePolicyId $definitionId
        if ($parsedPolicyId.ArtifactRef) {
            if ($DefinitionVersion) {
                $parsedVersion = ParsePolicyVersion $DefinitionVersion

                if ($writeln) {
                    Write-Host -ForegroundColor Cyan "Artifact: $($parsedPolicyId.Artifact), VersionRef: $($parsedVersion.VersionRef)."
                }

                if ($parsedPolicyId.VersionRef -ne $parsedVersion.VersionRef) {
                   throw "Definition version is ambiguous. PolicyDefinition version resolved to $($parsedPolicyId.VersionRef), but DefinitionVersion was $DefinitionVersion."
                }
            }
            else {
                # handle versioned policy [set] references
                $calledParameters.DefinitionVersion = $parsedPolicyId.VersionRef
            }
        }

        $calledParameters.PolicyDefinitionId = $parsedPolicyId.Artifact
        $null = $calledParameters.Remove('PolicyDefinition')
    }
    else {
        throw 'One of PolicyDefinition or PolicySetDefinition must be provided.'
    }

    # client side parameter validation
    if (!$Location -and $IdentityType -and ($IdentityType -ne 'None')) {
        throw 'Location needs to be specified if a managed identity is to be assigned to the policy assignment.'
    }

    if ($IdentityType -eq 'SystemAssigned' -and $IdentityId) {
        throw "Cannot specify an identity ID if identity type is 'SystemAssigned'."
    }

    if ($IdentityType -eq 'UserAssigned' -and !$IdentityId) {
        throw "A user assigned identity id needs to be specified if the identity type is 'UserAssigned'."
    }

    # resolve [string] 'metadata' input parameter to [hashtable]
    if ($Metadata) {
        $calledParameters.MetadataTable = (ResolvePolicyMetadataParameter -MetadataValue $Metadata -Debug $writeln)
    }
    elseif ($calledParameters.Metadata) {
        $calledParameters.MetadataTable = (ResolvePolicyMetadataParameter -MetadataValue $calledParameters.Metadata -Debug $writeln)
    }

    $null = $calledParameters.Remove('Metadata')

    # resolve [string] 'policyparameter' input parameter to [hashtable]
    if ($PolicyParameter) {
        $calledParameters.ParameterTable = (ResolvePolicyParameter -ParameterName 'PolicyParameter' -ParameterValue $PolicyParameter -Debug $writeln)
        $null = $calledParameters.Remove('PolicyParameter')
    }

    # resolve [hashtable] 'PolicyParameterObject' input parameter
    if ($PolicyParameterObject) {
        $calledParameters.ParameterTable = ConvertParameterObject -InputObject $PolicyParameterObject
        $null = $calledParameters.Remove('PolicyParameterObject')
    }

    # resolve [PSCustomObject[]] 'NonComplianceMessage' input parameter to [hashtable]
    if ($NonComplianceMessage) {
        $calledParameters.NonComplianceMessageTable = ConvertParameterArray $NonComplianceMessage
        $null = $calledParameters.Remove('NonComplianceMessage')
    }

    # resolve IdentityType
    switch ($IdentityType) {
        'SystemAssigned' {
            $calledParameters.EnableSystemAssignedIdentity = $true
        }
        default {
            $calledParameters.EnableSystemAssignedIdentity = $false
        }
    }

    $null = $calledParameters.Remove('IdentityType')

    # resolve IdentityId parameter
    if ($IdentityId) {
        $calledParameters.UserAssignedIdentity = @($IdentityId)
        $null = $calledParameters.Remove('IdentityId')
    }

    # remove switch unknown to generated cmdlets
    if ($calledParameters.BackwardCompatible) {
        $null = $calledParameters.Remove('BackwardCompatible')
    }

    # choose parameter set to call
    $calledParameterSet = 'CreateExpanded'

    if ($writeln) {
        Write-Host -ForegroundColor Blue -> $mapping[$calledParameterSet]'(' $calledParameters ')'
    }

    $cmdInfo = Get-Command -Name $mapping[$calledParameterSet]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Runtime.MessageAttributeHelper]::ProcessCustomAttributesAtRuntime($cmdInfo, $MyInvocation, $calledParameterSet, $PSCmdlet)
    $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand(($mapping[$calledParameterSet]), [System.Management.Automation.CommandTypes]::Cmdlet)
    $scriptCmd = {& $wrappedCmd @calledParameters}
    $item = Invoke-Command -ScriptBlock $scriptCmd

    # add property bag for backward compatibility with previous SDK cmdlets
    if ($BackwardCompatible) {
        $propertyBag = @{
            Description = $item.Description;
            DisplayName = $item.DisplayName;
            EnforcementMode = $item.EnforcementMode;
            Metadata = (ConvertObjectToPSObject $item.Metadata);
            NonComplianceMessages = (ConvertObjectToPSObject $item.NonComplianceMessage);
            NotScopes = (ConvertObjectToPSObject $item.NotScope);
            Parameters = (ConvertObjectToPSObject $item.Parameter);
            PolicyDefinitionId = $item.PolicyDefinitionId;
            Scope = $item.Scope
        }

        if ($item.IdentityType) {
            $identity = @{
                IdentityType = $item.IdentityType;
                PrincipalId = $item.IdentityPrincipalId;
                TenantId = $item.IdentityTenantId;
                UserAssignedIdentities = [PSCustomObject]$item.IdentityUserAssignedIdentity
            }
            $item | Add-Member -MemberType NoteProperty -Name 'Identity' -Value ([PSCustomObject]($identity))
        }

        $item | Add-Member -MemberType NoteProperty -Name 'Properties' -Value ([PSCustomObject]($propertyBag))
        $item | Add-Member -MemberType NoteProperty -Name 'ResourceId' -Value $item.Id
        $item | Add-Member -MemberType NoteProperty -Name 'ResourceName' -Value $item.Name
        $item | Add-Member -MemberType NoteProperty -Name 'ResourceType' -Value $item.Type
        $item | Add-Member -MemberType NoteProperty -Name 'PolicyAssignmentId' -Value $item.Id
    }

    $item | Add-Member -MemberType NoteProperty -Name 'Metadata' -Value (ConvertObjectToPSObject $item.Metadata) -Force
    $item | Add-Member -MemberType NoteProperty -Name 'NonComplianceMessage' -Value (ConvertObjectToPSObject $item.NonComplianceMessage) -Force
    $item | Add-Member -MemberType NoteProperty -Name 'NotScope' -Value (ConvertObjectToPSObject $item.NotScope) -Force
    $item | Add-Member -MemberType NoteProperty -Name 'Parameter' -Value (ConvertObjectToPSObject $item.Parameter) -Force
    $PSCmdlet.WriteObject($item)
}

end {
}
}

# SIG # Begin signature block
# MIIoPAYJKoZIhvcNAQcCoIIoLTCCKCkCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCABAcuzTsj8OlyY
# bViS8mqQo7oj3u73XB80niWBBlreBqCCDYUwggYDMIID66ADAgECAhMzAAAEhJji
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
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIIBD
# NCH57dh7VQHH8lLDm38rctO0FtZOFP+SFvflSh2FMEIGCisGAQQBgjcCAQwxNDAy
# oBSAEgBNAGkAYwByAG8AcwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20wDQYJKoZIhvcNAQEBBQAEggEAa8/cTe19LRD754fTNgebeCo7nwGHGvJa5xbF
# 5GRcfMdJr24kSfrjIN2ABp71yGlXyBpBDm0zyuFXlR+soaw00QbaPwJYAK6ITKx3
# 2Jy8PGHn4e1YnMmH8MfeHOf/p3qgkzz7zBXpRhU7027+lOzyNiN2Mtz40j20RjUC
# fO+JHSlIAD5mBozdpakMciNhUQlv5PqPMbQJmhGHgpsVLg/JFJWv6XK7H9BLyg4B
# Wjrzvu4XNYIl6BCFzJrniq3lKX/BNPSLuRHf7qtfighArIPKT0g+gJgenRyqi1lL
# sAbP0lsnJRCzZvSQUQ1FY7Qh/lzdN2HtSXVdss+HRqRg7dlk8KGCF5cwgheTBgor
# BgEEAYI3AwMBMYIXgzCCF38GCSqGSIb3DQEHAqCCF3AwghdsAgEDMQ8wDQYJYIZI
# AWUDBAIBBQAwggFSBgsqhkiG9w0BCRABBKCCAUEEggE9MIIBOQIBAQYKKwYBBAGE
# WQoDATAxMA0GCWCGSAFlAwQCAQUABCDCqGMM+tJrlw1hQai672yKTL8H2/y28JrI
# C06okV/mxgIGaEsgBNt2GBMyMDI1MDczMDAzNTEyMy4yOTZaMASAAgH0oIHRpIHO
# MIHLMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQL
# ExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxk
# IFRTUyBFU046ODkwMC0wNUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1l
# LVN0YW1wIFNlcnZpY2WgghHtMIIHIDCCBQigAwIBAgITMwAAAg4syyh9lSB1YwAB
# AAACDjANBgkqhkiG9w0BAQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAx
# MDAeFw0yNTAxMzAxOTQzMDNaFw0yNjA0MjIxOTQzMDNaMIHLMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1l
# cmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046ODkwMC0w
# NUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2Uw
# ggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCs5t7iRtXt0hbeo9ME78ZY
# jIo3saQuWMBFQ7X4s9vooYRABTOf2poTHatx+EwnBUGB1V2t/E6MwsQNmY5XpM/7
# 5aCrZdxAnrV9o4Tu5sBepbbfehsrOWRBIGoJE6PtWod1CrFehm1diz3jY3H8iFrh
# 7nqefniZ1SnbcWPMyNIxuGFzpQiDA+E5YS33meMqaXwhdb01Cluymh/3EKvknj4d
# IpQZEWOPM3jxbRVAYN5J2tOrYkJcdDx0l02V/NYd1qkvUBgPxrKviq5kz7E6AbOi
# fCDSMBgcn/X7RQw630Qkzqhp0kDU2qei/ao9IHmuuReXEjnjpgTsr4Ab33ICAKMY
# xOQe+n5wqEVcE9OTyhmWZJS5AnWUTniok4mgwONBWQ1DLOGFkZwXT334IPCqd4/3
# /Ld/ItizistyUZYsml/C4ZhdALbvfYwzv31Oxf8NTmV5IGxWdHnk2Hhh4bnzTKos
# EaDrJvQMiQ+loojM7f5bgdyBBnYQBm5+/iJsxw8k227zF2jbNI+Ows8HLeZGt8t6
# uJ2eVjND1B0YtgsBP0csBlnnI+4+dvLYRt0cAqw6PiYSz5FSZcbpi0xdAH/jd3dz
# yGArbyLuo69HugfGEEb/sM07rcoP1o3cZ8eWMb4+MIB8euOb5DVPDnEcFi4NDukY
# M91g1Dt/qIek+rtE88VS8QIDAQABo4IBSTCCAUUwHQYDVR0OBBYEFIVxRGlSEZE+
# 1ESK6UGI7YNcEIjbMB8GA1UdIwQYMBaAFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMF8G
# A1UdHwRYMFYwVKBSoFCGTmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMv
# Y3JsL01pY3Jvc29mdCUyMFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNybDBs
# BggrBgEFBQcBAQRgMF4wXAYIKwYBBQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0
# LmNvbS9wa2lvcHMvY2VydHMvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUy
# MDIwMTAoMSkuY3J0MAwGA1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUH
# AwgwDgYDVR0PAQH/BAQDAgeAMA0GCSqGSIb3DQEBCwUAA4ICAQB14L2TL+L8OXLx
# nGSal2h30mZ7FsBFooiYkUVOY05F9pnwPTVufEDGWEpNNy2OfaUHWIOoQ/9/rjwO
# 0hS2SpB0BzMAk2gyz92NGWOpWbpBdMvrrRDpiWZi/uLS4ZGdRn3P2DccYmlkNP+v
# aRAXvnv+mp27KgI79mJ9hGyCQbvtMIjkbYoLqK7sF7Wahn9rLjX1y5QJL4lvEy3Q
# mA9KRBj56cEv/lAvzDq7eSiqRq/pCyqyc8uzmQ8SeKWyWu6DjUA9vi84QsmLjqPG
# CnH4cPyg+t95RpW+73snhew1iCV+wXu2RxMnWg7EsD5eLkJHLszUIPd+XClD+FTv
# V03GfrDDfk+45flH/eKRZc3MUZtnhLJjPwv3KoKDScW4iV6SbCRycYPkqoWBrHf7
# SvDA7GrH2UOtz1Wa1k27sdZgpG6/c9CqKI8CX5vgaa+A7oYHb4ZBj7S8u8sgxwWK
# 7HgWDRByOH3CiJu4LJ8h3TiRkRArmHRp0lbNf1iAKuL886IKE912v0yq55t8jMxj
# BU7uoLsrYVIoKkzh+sAkgkpGOoZL14+dlxVM91Bavza4kODTUlwzb+SpXsSqVx8n
# uB6qhUy7pqpgww1q4SNhAxFnFxsxiTlaoL75GNxPR605lJ2WXehtEi7/+YfJqvH+
# vnqcpqCjyQ9hNaVzuOEHX4MyuqcjwjCCB3EwggVZoAMCAQICEzMAAAAVxedrngKb
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
# Y2EgT3BlcmF0aW9uczEnMCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOjg5MDAtMDVF
# MC1EOTQ3MSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloiMK
# AQEwBwYFKw4DAhoDFQBK6HY/ZWLnOcMEQsjkDAoB/JZWCKCBgzCBgKR+MHwxCzAJ
# BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jv
# c29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwMA0GCSqGSIb3DQEBCwUAAgUA7DOQ0DAi
# GA8yMDI1MDcyOTE4MjYyNFoYDzIwMjUwNzMwMTgyNjI0WjB3MD0GCisGAQQBhFkK
# BAExLzAtMAoCBQDsM5DQAgEAMAoCAQACAhvFAgH/MAcCAQACAhMMMAoCBQDsNOJQ
# AgEAMDYGCisGAQQBhFkKBAIxKDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMHoSCh
# CjAIAgEAAgMBhqAwDQYJKoZIhvcNAQELBQADggEBAKdyT+Z+SxvRG9p9Y9rvwCsY
# oCA1kCxBPmDD3/V4NMvh0+jhIbVkYLl4EN1nBalfAwckY29o8BUfmt02EDlVBusE
# oS8dZHevu35gGom/rNjUEMg2LYkKV2X7ivOBcVMUQtGlwMc11lLwZ8RVc5VF8mpa
# R8DpWr4LOmtNxPxyHuN4QVhiWEtfEz7x9FEwDIsu4F6/9qWmkj/ngsbx4CCfpxge
# FEKVtlvVaFoaQM4vtAhieVwtxz9Mw8HNvmNDbSJLNqLffAMMP2zGEHUssm2ReUhd
# 1EhR+T4d15DKbvGTgeN8NPRUM8SnOZ9UVYyeQxso3RqL0ucHQijdWX0JRfGads0x
# ggQNMIIECQIBATCBkzB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3Rv
# bjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0
# aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAA
# Ag4syyh9lSB1YwABAAACDjANBglghkgBZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkD
# MQ0GCyqGSIb3DQEJEAEEMC8GCSqGSIb3DQEJBDEiBCAkEM7WhWQw+eSn2P/UndCM
# jxtCh7NJM/kp15kK7oIPpDCB+gYLKoZIhvcNAQkQAi8xgeowgecwgeQwgb0EIAF0
# HXMl8OmBkK267mxobKSihwOdP0eUNXQMypPzTxKGMIGYMIGApH4wfDELMAkGA1UE
# BhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc
# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0
# IFRpbWUtU3RhbXAgUENBIDIwMTACEzMAAAIOLMsofZUgdWMAAQAAAg4wIgQgacI9
# uBQ9Gp4nktT0P9+wTdiPL3p8j7BcOmT5ySOJR9gwDQYJKoZIhvcNAQELBQAEggIA
# EFyg+gzSaaGn/cqjoR6ezvopCLtG9U71mgmU7aOLM0IWZu5q68JG67EwDesYBI/x
# Htfhzo2NNkWh9TjMlQeQIgA9hDUENunswKnujGX7ILd00eBuHleKtKpJgLxlSdte
# jz3vQeC6SU4j070rmkY/txh0++HmVJtlSycNXK0pFAdToo0zZuxA74eljq16CbOF
# AVkuZPVINNbjBEud15WDW68ZydeiamrDhc2CkDu+Yo8ZQD1Hk82axAY8Ed4EJx9n
# VR9gQtrGNEf8jRYzDNArHxXWp7rkRBOkSoCbC6uBLP/Mlnx4aOCDMOmNfrcVBO6p
# MIs5sjIy2vxBv51D3gEbQdaOxfE00vrmPspZ9M1X8RCNj4OJFEPiUfHSRnB22LsW
# 10e/1Zne1+qOwffFSlWBVglK38i7NSe2kCHaW9I1jdCj78QB/5bOcl0pRnTQqOIs
# l7CytZ7muFdRzsqj65gG5es4kkPE+XmcRGFr/GaFL3MvaxgFXUUE0T73aZePfa8N
# nRilklYT5vu3WwbnCzBLlk2+bLkqzN5Tdeg9qRFAq+/cXkjZXqZdnMlOBuCZ1KGn
# g89TYfOIXCXWfASmV+++xudkCenGoT0c8El1nzAGIpV59R8sLVgnGvBaZMmx3MCg
# XbZNEpqaR+gqD3nWOL6D0gaRVNFpSDW0vb8qvPkYQI0=
# SIG # End signature block
