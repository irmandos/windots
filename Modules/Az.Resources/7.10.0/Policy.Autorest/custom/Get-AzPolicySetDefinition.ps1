
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
Gets policy set definitions.
.Description
The **Get-AzPolicySetDefinition** cmdlet gets a collection of policy set definitions or a specific policy set definition identified by name or ID.
.Notes
## RELATED LINKS

[New-AzPolicySetDefinition](./New-AzPolicySetDefinition.md)

[Remove-AzPolicySetDefinition](./Remove-AzPolicySetDefinition.md)

[Update-AzPolicySetDefinition](./Update-AzPolicySetDefinition.md)
.Link
https://learn.microsoft.com/powershell/module/az.resources/get-azpolicysetdefinition
#>
function Get-AzPolicySetDefinition {
[OutputType([Microsoft.Azure.PowerShell.Cmdlets.Policy.Models.IPolicySetDefinition])]
[CmdletBinding(DefaultParameterSetName='Name')]
param(
    [Parameter(ParameterSetName='Name', ValueFromPipelineByPropertyName)]
    [Parameter(ParameterSetName='ManagementGroupName', ValueFromPipelineByPropertyName)]
    [Parameter(ParameterSetName='SubscriptionId', ValueFromPipelineByPropertyName)]
    [Parameter(ParameterSetName='Version', ValueFromPipelineByPropertyName)]
    [Parameter(ParameterSetName='ListVersion', ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [Alias('PolicySetDefinitionName')]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Path')]
    [System.String]
    # The name of the policy definition to get.
    ${Name},

    [Parameter(ParameterSetName='Id', Mandatory, ValueFromPipelineByPropertyName)]
    [Parameter(ParameterSetName='Version', ValueFromPipelineByPropertyName)]
    [Parameter(ParameterSetName='ListVersion', ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [Alias('ResourceId')]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Path')]
    [System.String]
    # The full Id of the policy definition to get.
    ${Id},

    [Parameter(ParameterSetName='ManagementGroupName', Mandatory, ValueFromPipelineByPropertyName)]
    [Parameter(ParameterSetName='Builtin', ValueFromPipelineByPropertyName)]
    [Parameter(ParameterSetName='Custom', ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Path')]
    [System.String]
    # The name of the management group.
    ${ManagementGroupName},

    [Parameter(ParameterSetName='SubscriptionId', Mandatory, ValueFromPipelineByPropertyName)]
    [Parameter(ParameterSetName='Builtin', ValueFromPipelineByPropertyName)]
    [Parameter(ParameterSetName='Custom', ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Path')]
    [System.String]
    # The ID of the target subscription.
    ${SubscriptionId},

    [Parameter(ParameterSetName='Builtin', Mandatory, ValueFromPipelineByPropertyName)]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Query')]
    [System.Management.Automation.SwitchParameter]
    # Causes cmdlet to return only built-in policy definitions.
    ${Builtin},

    [Parameter(ParameterSetName='Custom', Mandatory, ValueFromPipelineByPropertyName)]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Query')]
    [System.Management.Automation.SwitchParameter]
    # Causes cmdlet to return only custom policy definitions.
    ${Custom},

    [Parameter(ParameterSetName='Version', Mandatory, ValueFromPipelineByPropertyName)]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Body')]
    [ValidateNotNullOrEmpty()]
    [Alias('PolicySetDefinitionVersion')]
    [System.String]
    # The policy definition version in #.#.# format.
    ${Version},

    [Parameter(ParameterSetName='ListVersion', Mandatory, ValueFromPipelineByPropertyName)]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Query')]
    [System.Management.Automation.SwitchParameter]
    # Causes cmdlet to return only custom policy definitions.
    ${ListVersion},

    [Parameter()]
    [Obsolete('This parameter is a temporary bridge to new types and formats and will be removed in a future release.')]
    [System.Management.Automation.SwitchParameter]
    # Causes cmdlet to return artifacts using legacy format placing policy-specific properties in a property bag object.
    ${BackwardCompatible} = $false,

    [Parameter(DontShow)]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Query')]
    [System.String]
    # The filter to apply on the operation.
    # Valid values for $filter are: 'atExactScope()', 'policyType -eq {value}' or 'category eq '{value}''.
    # If $filter is not provided, no filtering is performed.
    # If $filter=atExactScope() is provided, the returned list only includes all policy set definitions that at the given scope.
    # If $filter='policyType -eq {value}' is provided, the returned list only includes all policy set definitions whose type match the {value}.
    # Possible policyType values are NotSpecified, Builtin, Custom, and Static.
    # If $filter='category -eq {value}' is provided, the returned list only includes all policy set definitions whose category match the {value}.
    ${Filter},

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

begin {
    # turn on console debug messages
    $writeln = ($PSCmdlet.MyInvocation.BoundParameters.Debug -as [bool]) -or ($PSCmdlet.MyInvocation.BoundParameters.Verbose -as [bool])

    if ($writeln) {
        Write-Host -ForegroundColor Cyan "begin:Get-AzPolicySetDefinition(" $PSBoundParameters ") - (ParameterSet: $($PSCmdlet.ParameterSetName))"
    }

    # mapping table of generated cmdlet parameter sets
    if ($Version -or $ListVersion) {
        $mapping = @{
            NameSub = 'Az.Policy.private\Get-AzPolicySetDefinitionVersion_Get';               # Name, SubscriptionId
            NameMG = 'Az.Policy.private\Get-AzPolicySetDefinitionVersion_Get1';               # Name, ManagementGroupName
            MG = 'Az.Policy.private\Get-AzPolicySetDefinitionVersion_List';                   # ManagementGroupName
            Sub = 'Az.Policy.private\Get-AzPolicySetDefinitionVersion_List1';                 # SubscriptionId
            BuiltinId='Az.Policy.private\Get-AzPolicySetDefinitionVersionBuilt_Get';          # Id
            BuiltinGet='Az.Policy.private\Get-AzPolicySetDefinitionVersionBuilt_Get';         # Name
        }
    }
    else {
        $mapping = @{
            NameSub = 'Az.Policy.private\Get-AzPolicySetDefinition_Get';                      # Name, SubscriptionId
            NameMG = 'Az.Policy.private\Get-AzPolicySetDefinition_Get1';                      # Name, ManagementGroupName
            Sub = 'Az.Policy.private\Get-AzPolicySetDefinition_List';                         # SubscriptionId
            MG = 'Az.Policy.private\Get-AzPolicySetDefinition_List1';                         # ManagementGroupName
            BuiltinId='Az.Policy.private\Get-AzPolicySetDefinitionBuilt_Get';                 # Id
            BuiltinGet='Az.Policy.private\Get-AzPolicySetDefinitionBuilt_Get';                # Name
        }
    }

    if ($ListVersion) {
        $mapping['NameSub'] = 'Az.Policy.private\Get-AzPolicySetDefinitionVersion_List2';         # Name, SubscriptionId
        $mapping['NameMG'] = 'Az.Policy.private\Get-AzPolicySetDefinitionVersion_List3';          # Name, ManagementGroup
        $mapping['BuiltinId'] = 'Az.Policy.private\Get-AzPolicySetDefinitionVersionBuilt_List';   # Id
        $mapping['BuiltinGet'] = 'Az.Policy.private\Get-AzPolicySetDefinitionVersionBuilt_List';  # Name
   }
}

process {
    if ($writeln) {
        Write-Host -ForegroundColor Cyan "process:Get-AzPolicySetDefinition(" $PSBoundParameters ") - (ParameterSet: $($PSCmdlet.ParameterSetName))"
    }

    # ensure fallback try/catch is invoked if necessary
    $PSBoundParameters['ErrorAction'] = 'Stop'

    # handle disallowed cases not handled by PS parameter attributes
    if ($PSBoundParameters['SubscriptionId'] -and $PSBoundParameters['ManagementGroupName']) {
        throw 'Only ManagementGroupName or SubscriptionId can be provided, not both.'
    }

    if ($PSBoundParameters['Version'] -and !$PSBoundParameters['Name'] -and !$PSBoundParameters['Id']) {
        throw 'Version is only allowed if Name or Id  are provided.'
    }

    if ($PSBoundParameters['ListVersion'] -and !$PSBoundParameters['Name'] -and !$PSBoundParameters['Id']) {
        throw 'ListVersion is only allowed if Name or Id  are provided.'
    }

    # handle specific parameter sets
    $parameterSet = $PSCmdlet.ParameterSetName
    $calledParameterSet = 'Sub'

    switch ($parameterSet) {
        'Builtin' {
            $PSBoundParameters.Add('Filter', "policyType eq 'Builtin'")
        }
        'Custom' {
            $PSBoundParameters.Add('Filter', "policyType eq 'Custom'")
        }
        default {
            if ($Id) {
                $parsed = ParsePolicySetDefinitionId $Id   # function is imported from Helpers.psm1
                switch ($parsed.ScopeType)
                {
                    'subid' {
                        $PSBoundParameters['SubscriptionId'] = $parsed['SubscriptionId']
                        if ($parsed['Name']) {
                            $calledParameterSet = 'NameSub';
                            $PSBoundParameters['Name'] = $parsed['Name']
                        }
                    }
                    'mgname' {
                        $PSBoundParameters['ManagementGroupName'] = $parsed['ManagementGroupName']
                        $PSBoundParameters['Name'] = $parsed['Name']
                        $calledParameterSet = 'NameMG';
                    }
                    'builtin' {
                        $calledParameterSet = 'BuiltinId'
                        $PSBoundParameters['PolicySetDefinitionName'] = $parsed['Name']
                    }
                }
            }
        }
    }

    # this check is needed because builtin Ids are special (no subId, no mgId)
    if ($calledParameterSet -ne 'BuiltinId') {
        # determine parameter set for call to generated cmdlet
        if ($PSBoundParameters['SubscriptionId']) {
            if ($PSBoundParameters['Name']) {
                $calledParameterSet = 'NameSub';
            }
            else {
                $calledParameterSet = 'Sub';
            }
        }
        elseif ($PSBoundParameters['ManagementGroupName']) {
            $PSBoundParameters['ManagementGroupId'] = $PSBoundParameters['ManagementGroupName']
            if ($PSBoundParameters['Name']) {
                $calledParameterSet = 'NameMG'
            }
            else {
                $calledParameterSet = 'MG'
            }
        }
        elseif ($parameterSet -ne 'Id') {
            $PSBoundParameters['SubscriptionId'] = (Get-SubscriptionId)
            if ($PSBoundParameters['Name']) {
                $calledParameterSet = 'NameSub'
            }
        }
    }

    if ($PSBoundParameters['Name']) {
        $PSBoundParameters['PolicySetDefinitionName'] = $PSBoundParameters['Name']
        $null = $PSBoundParameters.Remove('Name')
    }

    if ($PSBoundParameters['Version']) {
        $PSBoundParameters['PolicyDefinitionVersion'] = $PSBoundParameters['Version']
        $null = $PSBoundParameters.Remove('Version')
    }

    # remove parameters not used by generated cmdlets
    $null = $PSBoundParameters.Remove('BackwardCompatible')
    $null = $PSBoundParameters.Remove('ManagementGroupName')
    $null = $PSBoundParameters.Remove('Id')
    $null = $PSBoundParameters.Remove('Builtin')
    $null = $PSBoundParameters.Remove('Custom')
    $null = $PSBoundParameters.Remove('ListVersion')

    if ($writeln) {
        Write-Host -ForegroundColor Blue -> $mapping[$calledParameterSet]'(' $PSBoundParameters ')'
    }

    $cmdInfo = Get-Command -Name $mapping[$calledParameterSet]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Runtime.MessageAttributeHelper]::ProcessCustomAttributesAtRuntime($cmdInfo, $MyInvocation, $calledParameterSet, $PSCmdlet)
    $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand(($mapping[$calledParameterSet]), [System.Management.Automation.CommandTypes]::Cmdlet)
    $scriptCmd = {& $wrappedCmd @PSBoundParameters}

    # get output and fix up for backward compatibility
    try {
        $output = Invoke-Command -ScriptBlock $scriptCmd
    }
    catch {
        if (($_.Exception.Message -like '*PolicySetDefinitionNotFound*') -and $PSBoundParameters.PolicySetDefinitionName -and $PSBoundParameters.SubscriptionId) {

            # failed by name at subscription level, try builtins
            $null = $PSBoundParameters.Remove('SubscriptionId')

            $cmdInfo = Get-Command -Name $mapping['BuiltinGet']
            [Microsoft.Azure.PowerShell.Cmdlets.Policy.Runtime.MessageAttributeHelper]::ProcessCustomAttributesAtRuntime($cmdInfo, $MyInvocation, $calledParameterSet, $PSCmdlet)
            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand(($mapping['BuiltinGet']), [System.Management.Automation.CommandTypes]::Cmdlet)
            $scriptCmd = {& $wrappedCmd @PSBoundParameters}

            if ($writeln) {
                Write-Host -ForegroundColor Blue -> $mapping['BuiltinGet']'(' $PSBoundParameters ')'
            }

            $output = Invoke-Command -ScriptBlock $scriptCmd
        }
        else {
            throw
        }
    }

    foreach ($item in $output) {
        # add property bag for backward compatibility with previous SDK cmdlets
        if ($BackwardCompatible) {
            $propertyBag = @{
                Description = $item.Description;
                DisplayName = $item.DisplayName;
                Metadata = ConvertObjectToPSObject $item.Metadata;
                Parameters = ConvertObjectToPSObject $item.Parameter;
                PolicyDefinitionGroups = ConvertObjectToPSObject $item.PolicyDefinitionGroup;
                PolicyDefinitions = ConvertObjectToPSObject $item.PolicyDefinition;
                PolicyType = $item.PolicyType
            }

            $item | Add-Member -MemberType NoteProperty -Name 'Properties' -Value ([PSCustomObject]($propertyBag))
            $item | Add-Member -MemberType NoteProperty -Name 'ResourceId' -Value $item.Id
            $item | Add-Member -MemberType NoteProperty -Name 'ResourceName' -Value $item.Name
            $item | Add-Member -MemberType NoteProperty -Name 'ResourceType' -Value $item.Type
            $item | Add-Member -MemberType NoteProperty -Name 'PolicySetDefinitionId' -Value $item.Id
        }

        # use PSCustomObject for JSON properties
        $item | Add-Member -MemberType NoteProperty -Name 'Metadata' -Value (ConvertObjectToPSObject $item.Metadata) -Force
        $item | Add-Member -MemberType NoteProperty -Name 'Parameter' -Value (ConvertObjectToPSObject $item.Parameter) -Force
        $item | Add-Member -MemberType NoteProperty -Name 'PolicyDefinitionGroup' -Value (ConvertObjectToPSObject $item.PolicyDefinitionGroup) -Force
        $item | Add-Member -MemberType NoteProperty -Name 'PolicyDefinition' -Value (ConvertObjectToPSObject $item.PolicyDefinition) -Force
        $item | Add-Member -MemberType NoteProperty -Name 'Versions' -Value ([array]($item.Versions)) -Force
        $PSCmdlet.WriteObject($item)
    }
}

end {
}
}

# SIG # Begin signature block
# MIIoLQYJKoZIhvcNAQcCoIIoHjCCKBoCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCB7ynP0a7utjc3d
# zj94ca+NhyxlyTaeMqjLndsiMmhQhKCCDXYwggX0MIID3KADAgECAhMzAAAEBGx0
# Bv9XKydyAAAAAAQEMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjQwOTEyMjAxMTE0WhcNMjUwOTExMjAxMTE0WjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQC0KDfaY50MDqsEGdlIzDHBd6CqIMRQWW9Af1LHDDTuFjfDsvna0nEuDSYJmNyz
# NB10jpbg0lhvkT1AzfX2TLITSXwS8D+mBzGCWMM/wTpciWBV/pbjSazbzoKvRrNo
# DV/u9omOM2Eawyo5JJJdNkM2d8qzkQ0bRuRd4HarmGunSouyb9NY7egWN5E5lUc3
# a2AROzAdHdYpObpCOdeAY2P5XqtJkk79aROpzw16wCjdSn8qMzCBzR7rvH2WVkvF
# HLIxZQET1yhPb6lRmpgBQNnzidHV2Ocxjc8wNiIDzgbDkmlx54QPfw7RwQi8p1fy
# 4byhBrTjv568x8NGv3gwb0RbAgMBAAGjggFzMIIBbzAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQU8huhNbETDU+ZWllL4DNMPCijEU4w
# RQYDVR0RBD4wPKQ6MDgxHjAcBgNVBAsTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEW
# MBQGA1UEBRMNMjMwMDEyKzUwMjkyMzAfBgNVHSMEGDAWgBRIbmTlUAXTgqoXNzci
# tW2oynUClTBUBgNVHR8ETTBLMEmgR6BFhkNodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpb3BzL2NybC9NaWNDb2RTaWdQQ0EyMDExXzIwMTEtMDctMDguY3JsMGEG
# CCsGAQUFBwEBBFUwUzBRBggrBgEFBQcwAoZFaHR0cDovL3d3dy5taWNyb3NvZnQu
# Y29tL3BraW9wcy9jZXJ0cy9NaWNDb2RTaWdQQ0EyMDExXzIwMTEtMDctMDguY3J0
# MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQADggIBAIjmD9IpQVvfB1QehvpC
# Ge7QeTQkKQ7j3bmDMjwSqFL4ri6ae9IFTdpywn5smmtSIyKYDn3/nHtaEn0X1NBj
# L5oP0BjAy1sqxD+uy35B+V8wv5GrxhMDJP8l2QjLtH/UglSTIhLqyt8bUAqVfyfp
# h4COMRvwwjTvChtCnUXXACuCXYHWalOoc0OU2oGN+mPJIJJxaNQc1sjBsMbGIWv3
# cmgSHkCEmrMv7yaidpePt6V+yPMik+eXw3IfZ5eNOiNgL1rZzgSJfTnvUqiaEQ0X
# dG1HbkDv9fv6CTq6m4Ty3IzLiwGSXYxRIXTxT4TYs5VxHy2uFjFXWVSL0J2ARTYL
# E4Oyl1wXDF1PX4bxg1yDMfKPHcE1Ijic5lx1KdK1SkaEJdto4hd++05J9Bf9TAmi
# u6EK6C9Oe5vRadroJCK26uCUI4zIjL/qG7mswW+qT0CW0gnR9JHkXCWNbo8ccMk1
# sJatmRoSAifbgzaYbUz8+lv+IXy5GFuAmLnNbGjacB3IMGpa+lbFgih57/fIhamq
# 5VhxgaEmn/UjWyr+cPiAFWuTVIpfsOjbEAww75wURNM1Imp9NJKye1O24EspEHmb
# DmqCUcq7NqkOKIG4PVm3hDDED/WQpzJDkvu4FrIbvyTGVU01vKsg4UfcdiZ0fQ+/
# V0hf8yrtq9CkB8iIuk5bBxuPMIIHejCCBWKgAwIBAgIKYQ6Q0gAAAAAAAzANBgkq
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
# /Xmfwb1tbWrJUnMTDXpQzTGCGg0wghoJAgEBMIGVMH4xCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNp
# Z25pbmcgUENBIDIwMTECEzMAAAQEbHQG/1crJ3IAAAAABAQwDQYJYIZIAWUDBAIB
# BQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIKC9TqgXYMdmHkrEXb5hyzqG
# HmjJOK1Uya5ou3+d3bgPMEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEB
# BQAEggEArkLLl7NWiXqEodyCtTR7gQFu3EbIpR//q9ZLZiyUcFaBHQYazq0PgLWj
# PZSm7cjOA/praHoH5PO+SvM4HkHi/nlqNrIWKdgbfv7ZEJtzHet13SsuCWNcDVCJ
# 1fn7Dl47iCnx6A3pdiTy67h+mjUuwuktLiJw91eZXk/fDF6N2h6ZgSO459Oeq+4z
# 6WF046FGtyOSUMEvU/m7+5CjJ8jWfBMfJT4d2lDtOYStV5lojpZ0yKOo3xAQMeSY
# vtRAKLYbg8Kzp+6e0fZs0XHPu/O9x153nBtvm+vCnNw7Il7SOU/3nYGoFmhG3AJr
# fLKSzFBh6suAxIxPLG3cyLDFPRq3UKGCF5cwgheTBgorBgEEAYI3AwMBMYIXgzCC
# F38GCSqGSIb3DQEHAqCCF3AwghdsAgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFSBgsq
# hkiG9w0BCRABBKCCAUEEggE9MIIBOQIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCBK96JXZN6dl5cUmNNlFAkVQ2j/k9rteR6zGUBZ1QvlrwIGZ9v93EiV
# GBMyMDI1MDMyNjA3MzcwMi40MTRaMASAAgH0oIHRpIHOMIHLMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1l
# cmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046QTQwMC0w
# NUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2Wg
# ghHtMIIHIDCCBQigAwIBAgITMwAAAgJ5UHQhFH24oQABAAACAjANBgkqhkiG9w0B
# AQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYD
# VQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAeFw0yNTAxMzAxOTQy
# NDRaFw0yNjA0MjIxOTQyNDRaMIHLMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25z
# MScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046QTQwMC0wNUUwLUQ5NDcxJTAjBgNV
# BAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2UwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQC3eSp6cucUGOkcPg4vKWKJfEQeshK2ZBsYU1tDWvQu
# 6L9lp+dnqrajIdNeH1HN3oz3iiGoJWuN2HVNZkcOt38aWGebM0gUUOtPjuLhuO5d
# 67YpQsHBJAWhcve/MVdoQPj1njiAjSiOrL8xFarFLI46RH8NeDhAPXcJpWn7AIzC
# yIjZOaJ2DWA+6QwNzwqjBgIpf1hWFwqHvPEedy0notXbtWfT9vCSL9sdDK6K/HH9
# HsaY5wLmUUB7SfuLGo1OWEm6MJyG2jixqi9NyRoypdF8dRyjWxKRl2JxwvbetlDT
# io66XliTOckq2RgM+ZocZEb6EoOdtd0XKh3Lzx29AhHxlk+6eIwavlHYuOLZDKod
# POVN6j1IJ9brolY6mZboQ51Oqe5nEM5h/WJX28GLZioEkJN8qOe5P5P2Yx9HoOqL
# ugX00qCzxq4BDm8xH85HKxvKCO5KikopaRGGtQlXjDyusMWlrHcySt56DhL4dcVn
# n7dFvL50zvQlFZMhVoehWSQkkWuUlCCqIOrTe7RbmnbdJosH+7lC+n53gnKy4OoZ
# zuUeqzCnSB1JNXPKnJojP3De5xwspi5tUvQFNflfGTsjZgQAgDBdg/DO0TGgLRDK
# vZQCZ5qIuXpQRyg37yc51e95z8U2mysU0XnSpWeigHqkyOAtDfcIpq5Gv7HV+da2
# RwIDAQABo4IBSTCCAUUwHQYDVR0OBBYEFNoGubUPjP2f8ifkIKvwy1rlSHTZMB8G
# A1UdIwQYMBaAFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMF8GA1UdHwRYMFYwVKBSoFCG
# Tmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUy
# MFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNybDBsBggrBgEFBQcBAQRgMF4w
# XAYIKwYBBQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2Vy
# dHMvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUyMDIwMTAoMSkuY3J0MAwG
# A1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQD
# AgeAMA0GCSqGSIb3DQEBCwUAA4ICAQCD83aFQUxN37HkOoJDM1maHFZVUGcqTQcP
# nOD6UoYRMmDKv0GabHlE82AYgLPuVlukn7HtJPF2z0jnTgAfRMn26JFLPG7O/XbK
# K25hrBPJ30lBuwjATVt58UA1BWo7lsmnyrur/6h8AFzrXyrXtlvzQYqaRYY9k0UF
# Y5GM+n9YaEEK2D268e+a+HDmWe+tYL2H+9O4Q1MQLag+ciNwLkj/+QlxpXiWou9K
# vAP0tIk+fH8F3ww5VOTi9aZ9+qPjszw31H4ndtivBZaH5s5boJmH2JbtMuf2y7hS
# dJdE0UW2B0FEZPLImemlKhslJNVqEO7RPgl7c81QuVSO58ffpmbwtSxhYrES3VsP
# glXn9ODF7DqmPMG/GysB4o/QkpNUq+wS7bORTNzqHMtH+ord2YSma+1byWBr/izI
# KggOCdEzaZDfym12GM6a4S+Iy6AUIp7/KIpAmfWfXrcMK7V7EBzxoezkLREEWI4X
# tPwpEBntOa1oDH3Z/+dRxsxL0vgya7jNfrO7oizTAln/2ZBYB9ioUeobj5AGL45m
# 2mcKSk7HE5zUReVkILpYKBQ5+X/8jFO1/pZyqzQeI1/oJ/RLoic1SieLXfET9EWZ
# IBjZMZ846mDbp1ynK9UbNiCjSwmTF509Yn9M47VQsxsv1olQu51rVVHkSNm+rTrL
# wK1tvhv0mTCCB3EwggVZoAMCAQICEzMAAAAVxedrngKbSZkAAAAAABUwDQYJKoZI
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
# 6Xu/OHBE0ZDxyKs6ijoIYn/ZcGNTTY3ugm2lBRDBcQZqELQdVTNYs6FwZvKhggNQ
# MIICOAIBATCB+aGB0aSBzjCByzELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
# bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
# b3JhdGlvbjElMCMGA1UECxMcTWljcm9zb2Z0IEFtZXJpY2EgT3BlcmF0aW9uczEn
# MCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOkE0MDAtMDVFMC1EOTQ3MSUwIwYDVQQD
# ExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloiMKAQEwBwYFKw4DAhoDFQBJ
# iUhpCWA/3X/jZyIy0ye6RJwLzqCBgzCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFBDQSAyMDEwMA0GCSqGSIb3DQEBCwUAAgUA6428EjAiGA8yMDI1MDMyNTIzMzQ0
# MloYDzIwMjUwMzI2MjMzNDQyWjB3MD0GCisGAQQBhFkKBAExLzAtMAoCBQDrjbwS
# AgEAMAoCAQACAgg2AgH/MAcCAQACAhS3MAoCBQDrjw2SAgEAMDYGCisGAQQBhFkK
# BAIxKDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMHoSChCjAIAgEAAgMBhqAwDQYJ
# KoZIhvcNAQELBQADggEBAAg8USDUAI4ag7Kz5LLcXiz+Dzj4HMEboIWE1UTvqBz4
# lcjZfozVnC+NOz9koO9iEHeB/nK+1G2irmx+FJGgkdB8RFNakp0pR5urhBp3X1X1
# DHMS4IweMQzb74cjILDQxCAzR7YCvRdPIBUnXySPlILvIqbNmHXC4b2ilpzp7LGH
# pMhkpLtNi5ZemQ/mlkUDHfFgZwq23EKKpNIqKSlVhj4Yy9rLjyf33mNxhbUNZhLe
# ncdgm2tyL+UMUyqUJqC33dzTrGS5o+LVSbkEwm+5WEKCwVVsZYarCjMMf+yOYGyo
# s1RDQ8fZ5i/B4MfVfD64g4tw5t4jfksMOJQBmFfkYvsxggQNMIIECQIBATCBkzB8
# MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVk
# bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1N
# aWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAgJ5UHQhFH24oQABAAAC
# AjANBglghkgBZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEE
# MC8GCSqGSIb3DQEJBDEiBCA9rbucHbFEnFZW+i4VXGA1uI8QdlQoBQOzJhC65Jit
# pTCB+gYLKoZIhvcNAQkQAi8xgeowgecwgeQwgb0EIPON6gEYB5bLzXLWuUmL8Zd8
# xXAsqXksedFyolfMlF/sMIGYMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29m
# dCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENB
# IDIwMTACEzMAAAICeVB0IRR9uKEAAQAAAgIwIgQgp76O8V7hFF+8XgvkeR+iVz49
# 8IPWKJXSrrv3EPw0wiUwDQYJKoZIhvcNAQELBQAEggIAmNo0DztErXVODRSb565/
# 9RC5gUDDHllGBG3dt6BYcGlbuP55zDZnjrEZs/dSDV5qKExf+u+1sbrrvswABi0L
# KrFxjJHl33a9NftDkE1x/RPKMOUKz5BmBdeWom8ppcxSh+5cPKffF9R12m8CWGFb
# ROXFNqzkq2mKX40vWajqpTODB26U+VWilh2SUL7RFKDcGgKjdmXgQgzCYXFOgJm0
# Sh8ExGCZQ1pblP/2MJTHY1AOrNQ5Smdc3zlU8mfydMKELvHNZpR5ebKgXmRfU14s
# jc46ERtUp3IalHY9eUMOB2yV+I0ysjupYsZvPY49zXttOjUtc5AM3CJLsZQSPG8t
# PTs9HTPeRkCHCjtdeKyWPP4WkCDgxgo2iK5VTCjPCDlBTNJ00qvHaC3l9v6hWNi8
# VI/1gWKE/Qe75VYtSP8EBiS97z5cfYuNj2enXS+fShM3UgM7PXw8vj1GcAUabVaZ
# FEgZkegnPtkULCgy1plUTJHO1b5rapQ9w+NKvjfXKONX6iy1ehnSAvA+ei/5dAxi
# GG+4ujwLJQHOkfZ8G4HS4/5rN01+/r8+6sA2/aWF5ccCzaF2LpDCihD9Qk4MvtNu
# WUb9yIY3peuneGT+8PKHqHQjaBsuQZl2Bkkuh79BjYRuXAfsLGJx7G329A/5b5/J
# m96FwPFtJXi30XdziZyBI88=
# SIG # End signature block
