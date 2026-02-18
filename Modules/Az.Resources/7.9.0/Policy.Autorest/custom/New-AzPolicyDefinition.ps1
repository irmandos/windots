
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
Creates or updates a policy definition.
.Description
The **New-AzPolicyDefinition** cmdlet creates or updates a policy definition that includes a policy rule JSON format.
.Notes
## RELATED LINKS

[Get-AzPolicyDefinition](./Get-AzPolicyDefinition.md)

[Remove-AzPolicyDefinition](./Remove-AzPolicyDefinition.md)

[Update-AzPolicyDefinition](./Update-AzPolicyDefinition.md)
.Link
https://learn.microsoft.com/powershell/module/az.resources/new-azpolicydefinition
#>
function New-AzPolicyDefinition {
[OutputType([Microsoft.Azure.PowerShell.Cmdlets.Policy.Models.IPolicyDefinition])]
[CmdletBinding(DefaultParameterSetName='Name', SupportsShouldProcess=$true, ConfirmImpact='Low')]
param(
    [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [Alias('PolicyDefinitionName')]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Path')]
    [System.String]
    # The name of the policy definition to create.
    ${Name},

    [Parameter(ValueFromPipelineByPropertyName)]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Body')]
    [System.String]
    # The display name of the policy definition.
    ${DisplayName},

    [Parameter(ValueFromPipelineByPropertyName)]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Body')]
    [System.String]
    # The policy definition description.
    ${Description},

    [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Body')]
    [System.String]
    # The policy rule.
    ${Policy},

    [Parameter(ValueFromPipelineByPropertyName)]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Body')]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Runtime.Info(PossibleTypes=([Microsoft.Azure.PowerShell.Cmdlets.Policy.Models.IPolicyDefinitionPropertiesMetadata]))]
    [System.String]
    # The policy definition metadata.
    # Metadata is an open ended object and is typically a collection of key value pairs.
    ${Metadata},

    [Parameter(ValueFromPipelineByPropertyName)]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Body')]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Runtime.Info(PossibleTypes=([Microsoft.Azure.PowerShell.Cmdlets.Policy.Models.IParameterDefinitions]))]
    [System.String]
    # The parameter definitions for parameters used in the policy rule.
    # The keys are the parameter names.
    ${Parameter},

    [Parameter(ValueFromPipelineByPropertyName)]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Body')]
    [System.String]
    # The policy definition mode.
    # Some examples are All, Indexed, Microsoft.KeyVault.Data.
    ${Mode},

    [Parameter(ParameterSetName='ManagementGroupName', Mandatory, ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Path')]
    [System.String]
    # The ID of the management group.
    ${ManagementGroupName},

    [Parameter(ParameterSetName='SubscriptionId', Mandatory, ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [Microsoft.Azure.PowerShell.Cmdlets.Policy.Category('Path')]
    [System.String]
    # The ID of the target subscription.
    ${SubscriptionId},

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

begin {
    # turn on console debug messages
    $writeln = ($PSCmdlet.MyInvocation.BoundParameters.Debug -as [bool]) -or ($PSCmdlet.MyInvocation.BoundParameters.Verbose -as [bool])

    if ($writeln) {
        Write-Host -ForegroundColor Cyan "begin:New-AzPolicyDefinition(" $PSBoundParameters ") - (ParameterSet: $($PSCmdlet.ParameterSetName))"
    }

    # mapping table of generated cmdlet parameter sets
    $mapping = @{
        CreateExpanded = 'Az.Policy.private\New-AzPolicyDefinition_CreateExpanded';
        CreateExpanded1 = 'Az.Policy.private\New-AzPolicyDefinition_CreateExpanded1';
        CreateViaIdentityExpanded1 = 'Az.Policy.private\New-AzPolicyDefinition_CreateViaIdentityExpanded1';
    }
}

process {
    if ($writeln) {
        Write-Host -ForegroundColor Cyan "process:New-AzPolicyDefinition(" $PSBoundParameters ") - (ParameterSet: $($PSCmdlet.ParameterSetName))"
    }

    # parameters hash table for called cmdlet
    $calledParameters = $PSBoundParameters

    # convert input/legacy policy parameter to correct set of parameters and remove
    if ($Policy) {
        $resolved = ResolvePolicyParameter -ParameterName 'Policy' -ParameterValue $Policy -Debug $writeln
        if ($resolved.policyRule) {
            foreach ($key in $resolved.Keys) {

                if ($key -eq 'name' -or $key -eq 'type' -or $key -eq 'id') {
                    continue
                }

                $value = $resolved.($key)

                if ($key -eq 'parameters') {
                    $key = 'Parameter'
                }

                if (!($calledParameters.($key))) {
                    $calledParameters.($key) = $value
                }
            }
        } else {
            $calledParameters.PolicyRule = $resolved
        }

        $null = $calledParameters.Remove('Policy')
    }

    # preserve default mode behavior of previous SDK-based cmdlets
    if (!$calledParameters.Mode) {
        $calledParameters.Mode = 'All'
    }

    # resolve [string] 'metadata' input parameter to [hashtable]
    if ($Metadata) {
        $calledParameters.MetadataTable = (ResolvePolicyMetadataParameter -MetadataValue $Metadata -Debug $writeln)
    }
    elseif ($calledParameters.Metadata) {
        $calledParameters.MetadataTable = (ResolvePolicyMetadataParameter -MetadataValue $calledParameters.Metadata -Debug $writeln)
    }

    $null = $calledParameters.Remove('Metadata')

    # resolve [string] 'parameter' input parameter (could be a path)
    if ($Parameter) {
        $calledParameters.Parameter = (ResolvePolicyParameter -ParameterName 'Parameter' -ParameterValue $Parameter -Debug $writeln)
    }

    # rename [string] 'parameter' parameter to 'parametertable' (needs to be string to construct properly)
    if ($calledParameters.Parameter) {
        $calledParameters.ParameterTable = $calledParameters.Parameter
        $null = $calledParameters.Remove('Parameter')
    }

    # determine called parameterset and convert ManagementGroupName parameter to ManagementGroupId if needed
    if ($calledParameters.ManagementGroupName) {
        $calledParameterSet = 'CreateExpanded1'
        $calledParameters.ManagementGroupId = $calledParameters.ManagementGroupName
        $null = $calledParameters.Remove('ManagementGroupName')
    } else {
        $calledParameterSet = 'CreateExpanded'
        if (!$SubscriptionId) {
            $calledParameters.SubscriptionId = (Get-SubscriptionId)
        }
    }

    # remove switch unknown to generated cmdlets
    if ($calledParameters.BackwardCompatible) {
        $null = $calledParameters.Remove('BackwardCompatible')
    }

    if ($writeln) {
        Write-Host -ForegroundColor Blue -> $mapping[$calledParameterSet]'(' $calledParameters ')'
    }

    # call internal generated cmdlet, convert generic JSON output properties to PSCustomObject
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
            Metadata = (ConvertObjectToPSObject $item.Metadata);
            Mode = $item.Mode;
            Parameters = (ConvertObjectToPSObject $item.Parameter);
            PolicyRule = (ConvertObjectToPSObject $item.PolicyRule);
            PolicyType = $item.PolicyType
        }

        $item | Add-Member -MemberType NoteProperty -Name 'Properties' -Value ([PSCustomObject]($propertyBag))
        $item | Add-Member -MemberType NoteProperty -Name 'ResourceId' -Value $item.Id
        $item | Add-Member -MemberType NoteProperty -Name 'ResourceName' -Value $item.Name
        $item | Add-Member -MemberType NoteProperty -Name 'ResourceType' -Value $item.Type
        $item | Add-Member -MemberType NoteProperty -Name 'PolicyDefinitionId' -Value $item.Id
    }

    $item | Add-Member -MemberType NoteProperty -Name 'Metadata' -Value (ConvertObjectToPSObject $item.Metadata) -Force
    $item | Add-Member -MemberType NoteProperty -Name 'Parameter' -Value (ConvertObjectToPSObject $item.Parameter) -Force
    $item | Add-Member -MemberType NoteProperty -Name 'PolicyRule' -Value (ConvertObjectToPSObject $item.PolicyRule) -Force
    $item | Add-Member -MemberType NoteProperty -Name 'Versions' -Value ([array]($item.Versions)) -Force
    $PSCmdlet.WriteObject($item)
}

end {
}
}
# SIG # Begin signature block
# MIIoUgYJKoZIhvcNAQcCoIIoQzCCKD8CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCYAsfReKPk6+gd
# +BvWfQf0vOEAzabD4NlQBLJK8GUyqqCCDYUwggYDMIID66ADAgECAhMzAAAEA73V
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
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIH0G
# bDDy7KqKLHdReMEIx6sk02wK75LsKucMjH/qEpPJMEIGCisGAQQBgjcCAQwxNDAy
# oBSAEgBNAGkAYwByAG8AcwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20wDQYJKoZIhvcNAQEBBQAEggEAdKtWTEdjs0HuzyX1uWxwDVDcEFxTX0Hsc4B+
# 2w6zAZGiLdJIvtgQRPZQB9UJk5FjtJi/T9supMyPJtFDNNhQStjH2038+CNk9teG
# 0D5H6Xv0FueZFbA3C0ay2k1mRnJ46eEZYFu4SMnR5YdkOq6+rXrrZzj0uF8qSBIO
# HpZRRBryOogij9sR0vZRDN7+sIMUBavOf0M8MTC6AQsVpXQmqtZO84qj2UhDdZnW
# 6AP+Cmonse1kFvUIs2t3L1EGn2iFj+4ssN8yIkuiKwjSPFSp9NMuqAGn6nGLvFGh
# A4et0G0wSaFtX9MXWLG/g4G8glP1OcTR2Sg7Cup0reTcZfBgcKGCF60wghepBgor
# BgEEAYI3AwMBMYIXmTCCF5UGCSqGSIb3DQEHAqCCF4YwgheCAgEDMQ8wDQYJYIZI
# AWUDBAIBBQAwggFaBgsqhkiG9w0BCRABBKCCAUkEggFFMIIBQQIBAQYKKwYBBAGE
# WQoDATAxMA0GCWCGSAFlAwQCAQUABCDWYKdCFglyJutc3LZxWwJWZCr5AebGHp3t
# WtgEI+MTuAIGZ7YsQOfIGBMyMDI1MDIyNTA3MDMzNC4yODRaMASAAgH0oIHZpIHW
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
# CQQxIgQgP2p+7kW3vvjb94tRNumYo9HIX2MYmh7QpSpyVrLH30cwgfoGCyqGSIb3
# DQEJEAIvMYHqMIHnMIHkMIG9BCDvzDPyXw1UkAUFYt8bR4UdjM90Qv5xnVaiKD3I
# 0Zz3WjCBmDCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9u
# MRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRp
# b24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAAB
# +KOhJgwMQEj+AAEAAAH4MCIEIJVggWP1VL9W6Bl4hJL958t+C0gnFrXP+DclWHt4
# V4OKMA0GCSqGSIb3DQEBCwUABIICAINW9qSc+MVXqrmnIzymAS7fFj1CU3J98Uw4
# R/i+Z3EpUpMm4iv2w1qrsxieknHZoKm9tKwPWl3IqJJDePdvYN38XdsCrhePRkOs
# 9hZR+PhEVB1whYhv47DxxwIQHXhUW3fkRwJl3LBugaGflrzbqhrnjUK7OllpNjd4
# 7Fgk7WUgHKaOwWmDZKpWcPr3hCBBFZGq2lF4dn+3IQDG56cQtiPbcjodU/yXbhOD
# dYJw7chJVUgInIqF02cDZabRUe0GJYwzWul2OkC3Y7NVe2afhCcvM0NiuxLoL0Zr
# nYhR7PoFiXRQgcy6X+XMtSd9xY84my0P/k+oGSN1swLavRoGXd89rjGxluKH85jc
# dsz8fqvN6Fyd9D63fcB10zv7fVx+bE0n9+hwgv00PXNWQSv5RLoR2GMsAa8p1hES
# hCWOzxcO2fFtVjA3lj8bFbwErCYH2zXDQbjv34wqzaFHE831Id4hqMtVUOQt8MAQ
# MEyyYD1p2JPTd4tIXTyci9hvK+AJKMBt96B63zmnWDnaFwYsC9g0AorQ16M1xdKc
# b3AaKJNnGuVkgH+M3dR08pcMwyNRtS6Q7zpwR1o9AhDfNHUesro+G5IPS+5LOyZQ
# 9G0oX+hg2H/aZykDJ30g4u7TzZZnxU8mIquKFz0Uv5SGonl7HgcG7pzrCgh6Mwr1
# G8/yZDBf
# SIG # End signature block
