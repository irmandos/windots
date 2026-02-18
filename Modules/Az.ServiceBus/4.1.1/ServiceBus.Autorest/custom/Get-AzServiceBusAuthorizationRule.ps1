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
Gets the Authorization Rule of a ServiceBus namespace, queue or topic.
.Description
Gets the Authorization Rule of a ServiceBus namespace, queue or topic.
#>

function Get-AzServiceBusAuthorizationRule{
	[OutputType([Microsoft.Azure.PowerShell.Cmdlets.ServiceBus.Models.ISbAuthorizationRule])]
    [CmdletBinding(DefaultParameterSetName = 'GetExpandedNamespace', PositionalBinding = $false, ConfirmImpact = 'Medium')]
	param(
        [Parameter(ParameterSetName = 'GetExpandedQueue', HelpMessage = "The name of the Authorization Rule")]
        [Parameter(ParameterSetName = 'GetExpandedTopic', HelpMessage = "The name of the Authorization Rule")]
        [Parameter(ParameterSetName = 'GetExpandedNamespace', HelpMessage = "The name of the Authorization Rule")]
        [Parameter(ParameterSetName = 'GetExpandedAlias', HelpMessage = "The name of the Authorization Rule")]
        [Alias('AuthorizationRuleName')]
        [Microsoft.Azure.PowerShell.Cmdlets.ServiceBus.Category('Path')]
        [System.String]
        # The name of the Authorization Rule.
        ${Name},

        [Parameter(ParameterSetName = 'GetExpandedAlias', Mandatory, HelpMessage = "The name of the disaster recovery config")]
        [Microsoft.Azure.PowerShell.Cmdlets.ServiceBus.Category('Path')]
        [System.String]
        # The name of the disaster recovery config
        ${AliasName},

        [Parameter(ParameterSetName = 'GetExpandedQueue', Mandatory, HelpMessage = "The name of the Service Bus queue.")]
        [Microsoft.Azure.PowerShell.Cmdlets.ServiceBus.Category('Path')]
        [System.String]
        # The name of the Service Bus queue.
        ${QueueName},

        [Parameter(ParameterSetName = 'GetExpandedTopic', Mandatory, HelpMessage = "The name of the Service Bus topic.")]
        [Microsoft.Azure.PowerShell.Cmdlets.ServiceBus.Category('Path')]
        [System.String]
        # The name of the Service Bus topic.
        ${TopicName},

        [Parameter(ParameterSetName = 'GetExpandedNamespace', Mandatory, HelpMessage = "The name of ServiceBus namespace")]
        [Parameter(ParameterSetName = 'GetExpandedQueue', Mandatory, HelpMessage = "The name of the ServiceBus namespace.")]
        [Parameter(ParameterSetName = 'GetExpandedTopic', Mandatory, HelpMessage = "The name of the ServiceBus namespace.")]
        [Parameter(ParameterSetName = 'GetExpandedAlias', Mandatory, HelpMessage = "The name of the ServiceBus namespace.")]
        [Microsoft.Azure.PowerShell.Cmdlets.ServiceBus.Category('Path')]
        [System.String]
        # The name of ServiceBus namespace
        ${NamespaceName},

        [Parameter(ParameterSetName = 'GetExpandedNamespace', Mandatory, HelpMessage = "The name of the resource group. The name is case insensitive.")]
        [Parameter(ParameterSetName = 'GetExpandedQueue', Mandatory, HelpMessage = "The name of the resource group. The name is case insensitive.")]
        [Parameter(ParameterSetName = 'GetExpandedTopic', Mandatory, HelpMessage = "The name of the resource group. The name is case insensitive.")]
        [Parameter(ParameterSetName = 'GetExpandedAlias', Mandatory, HelpMessage = "The name of the resource group. The name is case insensitive.")]
        [Microsoft.Azure.PowerShell.Cmdlets.ServiceBus.Category('Path')]
        [System.String]
        # The name of the resource group.
        # The name is case insensitive.
        ${ResourceGroupName},

        [Parameter(ParameterSetName = 'GetExpandedNamespace', HelpMessage = "The ID of the target subscription.")]
        [Parameter(ParameterSetName = 'GetExpandedQueue', HelpMessage = "The ID of the target subscription.")]
        [Parameter(ParameterSetName = 'GetExpandedTopic', HelpMessage = "The ID of the target subscription.")]
        [Parameter(ParameterSetName = 'GetExpandedAlias', HelpMessage = "The ID of the target subscription.")]
        [Microsoft.Azure.PowerShell.Cmdlets.ServiceBus.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.ServiceBus.Runtime.DefaultInfo(Script = '(Get-AzContext).Subscription.Id')]
        [System.String[]]
        # The ID of the target subscription.
        ${SubscriptionId},

        [Parameter(ParameterSetName = 'GetViaIdentityExpanded', Mandatory, ValueFromPipeline, HelpMessage = "Identity parameter. To construct, see NOTES section for INPUTOBJECT properties and create a hash table.")]
        [Microsoft.Azure.PowerShell.Cmdlets.ServiceBus.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.ServiceBus.Models.IServiceBusIdentity]
        # Identity Parameter
        # To construct, see NOTES section for INPUTOBJECT properties and create a hash table.
        ${InputObject},
		
        [Parameter(HelpMessage = "The credentials, account, tenant, and subscription used for communication with Azure.")]
        [Alias('AzureRMContext', 'AzureCredential')]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.ServiceBus.Category('Azure')]
        [System.Management.Automation.PSObject]
        # The credentials, account, tenant, and subscription used for communication with Azure.
        ${DefaultProfile},

        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.ServiceBus.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Wait for .NET debugger to attach
        ${Break},

        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.ServiceBus.Category('Runtime')]
        [Microsoft.Azure.PowerShell.Cmdlets.ServiceBus.Runtime.SendAsyncStep[]]
        # SendAsync Pipeline Steps to be appended to the front of the pipeline
        ${HttpPipelineAppend},

        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.ServiceBus.Category('Runtime')]
        [Microsoft.Azure.PowerShell.Cmdlets.ServiceBus.Runtime.SendAsyncStep[]]
        # SendAsync Pipeline Steps to be prepended to the front of the pipeline
        ${HttpPipelinePrepend},

        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.ServiceBus.Category('Runtime')]
        [System.Uri]
        # The URI for the proxy server to use
        ${Proxy},

        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.ServiceBus.Category('Runtime')]
        [System.Management.Automation.PSCredential]
        # Credentials for a proxy server to use for the remote call
        ${ProxyCredential},

        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.ServiceBus.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Use the default credentials for the proxy
        ${ProxyUseDefaultCredentials}
	)
	process{
		try{
            $null = $PSBoundParameters.Remove('WhatIf')
            $null = $PSBoundParameters.Remove('Confirm')

            if ($PSCmdlet.ParameterSetName -eq 'GetExpandedNamespace') {
                if(-not $PSBoundParameters.ContainsKey('Name')) {
                    Az.ServiceBus.private\Get-AzServiceBusNamespaceAuthorizationRule_List @PSBoundParameters
                }
                else {
                    Az.ServiceBus.private\Get-AzServiceBusNamespaceAuthorizationRule_Get @PSBoundParameters
                }
            }

            elseif ($PSCmdlet.ParameterSetName -eq 'GetExpandedQueue'){
                if (-not $PSBoundParameters.ContainsKey('Name')) {
                    Az.ServiceBus.private\Get-AzServiceBusQueueAuthorizationRule_List @PSBoundParameters
                }
                else {
                    Az.ServiceBus.private\Get-AzServiceBusQueueAuthorizationRule_Get @PSBoundParameters
                }
            }

            elseif ($PSCmdlet.ParameterSetName -eq 'GetExpandedTopic'){
                if (-not $PSBoundParameters.ContainsKey('Name')) {
                    Az.ServiceBus.private\Get-AzServiceBusTopicAuthorizationRule_List @PSBoundParameters
                }
                else {
                    Az.ServiceBus.private\Get-AzServiceBusTopicAuthorizationRule_Get @PSBoundParameters
                }
            }

            elseif ($PSCmdlet.ParameterSetName -eq 'GetExpandedAlias'){
                $null = $PSBoundParameters.Remove('AliasName')
                if (-not $PSBoundParameters.ContainsKey('Name')) {
                    Az.ServiceBus.private\Get-AzServiceBusDisasterRecoveryConfigAuthorizationRule_List -Alias $AliasName @PSBoundParameters
                }
                else {
                    Az.ServiceBus.private\Get-AzServiceBusDisasterRecoveryConfigAuthorizationRule_Get -Alias $AliasName @PSBoundParameters
                }
            }

            elseif ($PSCmdlet.ParameterSetName -eq 'GetViaIdentityExpanded'){

                if($InputObject.Id -ne $null) {
                    $ResourceHashTable = ParseResourceId -ResourceId $InputObject.Id
                }
                else {
                    $ResourceHashTable = ParseResourceId -ResourceId $InputObject
                }

                if ($ResourceHashTable['QueueName'] -ne $null) {
                    Az.ServiceBus.private\Get-AzServiceBusQueueAuthorizationRule_GetViaIdentity @PSBoundParameters
                }
                elseif ($ResourceHashTable['TopicName'] -ne $null) {
                    Az.ServiceBus.private\Get-AzServiceBusTopicAuthorizationRule_GetViaIdentity @PSBoundParameters
                }
                elseif ($ResourceHashTable['AliasName'] -ne $null) {
                    Az.ServiceBus.private\Get-AzServiceBusDisasterRecoveryConfigAuthorizationRule_GetViaIdentity @PSBoundParameters
                }
                elseif ($ResourceHashTable['NamespaceName'] -ne $null) {
                    Az.ServiceBus.private\Get-AzServiceBusNamespaceAuthorizationRule_GetViaIdentity @PSBoundParameters
                }
                else {
                    throw 'Invalid -InputObject'
                }

            }
		}
		catch{
			throw
		}
	}
}

function ParseResourceId{
    param (
        [string]$ResourceId
    )
    $array = $resourceID.ToLower().Split('/')
    $indexSubscription = 0..($array.Length -1) | where {$array[$_] -eq 'subscriptions'}
    $indexResourceGroup = 0..($array.Length -1) | where {$array[$_] -eq 'resourcegroups'}
    $indexNamespace = 0..($array.Length -1) | where {$array[$_] -eq 'namespaces'}
    $indexQueue = 0..($array.Length -1) | where {$array[$_] -eq 'queues'}
    $indexTopic = 0..($array.Length -1) | where {$array[$_] -eq 'topics'}
    $indexAlias = 0..($array.Length -1) | where {$array[$_] -eq 'disasterrecoveryconfigs'}
    $indexAuthRule = 0..($array.Length -1) | where {$array[$_] -eq 'authorizationrules'}
    
    if (($indexResourceGroup+1) > $array.Length){
        throw 'Invalid -InputObject Id'
    }
    if (($indexNamespace+1) > $array.Length){
        throw 'Invalid -InputObject Id'
    }

    $result = @{
        'ResourceGroupName' = $array.get($indexResourceGroup+1)
        'NamespaceName' = $array.get($indexNamespace+1)
    }

    if ($indexQueue -ne $null){
        if (($indexQueue+1) > $array.Length){
            throw 'Invalid -InputObject Id'
        }
        else{
            $result.add('QueueName', $array.get($indexQueue+1))
        }
    }

    if ($indexTopic -ne $null){
        if (($indexTopic+1) > $array.Length){
            throw 'Invalid -InputObject Id'
        }
        else{
            $result.add('TopicName', $array.get($indexTopic+1))
        }
    }

    if ($indexSubscription -ne $null){
        if (($indexSubscription+1) > $array.Length){
            throw 'Invalid -InputObject Id'
        }
        else{
            $result.add('SubscriptionName', $array.get($indexSubscription+1))
        }
    }

    if ($indexAuthRule -ne $null){
        if (($indexAuthRule+1) > $array.Length){
            throw 'Invalid -InputObject Id'
        }
        else{
            $result.add('AuthorizationRuleName', $array.get($indexAuthRule+1))
        }
    }

    if ($indexAlias -ne $null){
        if (($indexAlias+1) > $array.Length){
            throw 'Invalid -InputObject Id'
        }
        else{
            $result.add('AliasName', $array.get($indexAlias+1))
        }
    }

    return $result
}

# SIG # Begin signature block
# MIIoUgYJKoZIhvcNAQcCoIIoQzCCKD8CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBcYB/znBVwNocw
# GaPCrHAlkaAd2FByfnoHgab9vzWQvKCCDYUwggYDMIID66ADAgECAhMzAAAEA73V
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
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIGd0
# dQUp/KrLwnBhM+zhh3qFIxgjpxyxZJ6f5gediCiUMEIGCisGAQQBgjcCAQwxNDAy
# oBSAEgBNAGkAYwByAG8AcwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20wDQYJKoZIhvcNAQEBBQAEggEAns4sdEs5Tsxo/a6c68+tibV1E2137KVyUUfu
# XAsxCb+rJ6pIbGcHdEEWTvRMiy2v8ZTqBVkl71YtMlfYlJTWdytx8tv/NPKIdjXu
# ca1UK40ppKsNQ1esDWwrAoP026akasv55YCAmtFedoLY51ARkm3It9SQz3rKtcKc
# iTVVzQk6fWVnEMJ0+hqePXxA23aI39+ClZLs/fi8zuJJNQB6xHEGY0K2fodqwKb0
# k+ImYPiC4OtgkAE0XQDIXJxDW4bFaXIU3/BDX3vNSJ+H1WPhEtTmuztJOenZ0AtQ
# UYiWKAX6S5jWxt1YSrpVdAdpFspGMl2p7zcr4MpiWVHBukSXUKGCF60wghepBgor
# BgEEAYI3AwMBMYIXmTCCF5UGCSqGSIb3DQEHAqCCF4YwgheCAgEDMQ8wDQYJYIZI
# AWUDBAIBBQAwggFaBgsqhkiG9w0BCRABBKCCAUkEggFFMIIBQQIBAQYKKwYBBAGE
# WQoDATAxMA0GCWCGSAFlAwQCAQUABCC0F5GxHRJMi4FuDOYQZiHTLlATCwK2Jdj4
# V8uDdjXVkQIGZ7Yf/Y1nGBMyMDI1MDIyNTA3MDMyOS44MjNaMASAAgH0oIHZpIHW
# MIHTMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQL
# EyRNaWNyb3NvZnQgSXJlbGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJzAlBgNVBAsT
# Hm5TaGllbGQgVFNTIEVTTjo0QzFBLTA1RTAtRDk0NzElMCMGA1UEAxMcTWljcm9z
# b2Z0IFRpbWUtU3RhbXAgU2VydmljZaCCEfswggcoMIIFEKADAgECAhMzAAAB/xI4
# fPfBZdahAAEAAAH/MA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFBDQSAyMDEwMB4XDTI0MDcyNTE4MzExOVoXDTI1MTAyMjE4MzExOVowgdMxCzAJ
# BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xLTArBgNVBAsTJE1pY3Jv
# c29mdCBJcmVsYW5kIE9wZXJhdGlvbnMgTGltaXRlZDEnMCUGA1UECxMeblNoaWVs
# ZCBUU1MgRVNOOjRDMUEtMDVFMC1EOTQ3MSUwIwYDVQQDExxNaWNyb3NvZnQgVGlt
# ZS1TdGFtcCBTZXJ2aWNlMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA
# yeiV0pB7bg8/qc/mkiDdJXnzJWPYgk9mTGeI3pzQpsyrRJREWcKYHd/9db+g3z4d
# U4VCkAZEXqvkxP5QNTtBG5Ipexpph4PhbiJKwvX+US4KkSFhf1wflDAY1tu9CQqh
# hxfHFV7vhtmqHLCCmDxhZPmCBh9/XfFJQIUwVZR8RtUkgzmN9bmWiYgfX0R+bDAn
# ncUdtp1xjGmCpdBMygk/K0h3bUTUzQHb4kPf2ylkKPoWFYn2GNYgWw8PGBUO0vTM
# KjYD6pLeBP0hZDh5P3f4xhGLm6x98xuIQp/RFnzBbgthySXGl+NT1cZAqGyEhT7L
# 0SdR7qQlv5pwDNerbK3YSEDKk3sDh9S60hLJNqP71iHKkG175HAyg6zmE5p3fONr
# 9/fIEpPAlC8YisxXaGX4RpDBYVKpGj0FCZwisiZsxm0X9w6ZSk8OOXf8JxTYWIqf
# RuWzdUir0Z3jiOOtaDq7XdypB4gZrhr90KcPTDRwvy60zrQca/1D1J7PQJAJObbi
# aboi12usV8axtlT/dCePC4ndcFcar1v+fnClhs9u3Fn6LkHDRZfNzhXgLDEwb6dA
# 4y3s6G+gQ35o90j2i6amaa8JsV/cCF+iDSGzAxZY1sQ1mrdMmzxfWzXN6sPJMy49
# tdsWTIgZWVOSS9uUHhSYkbgMxnLeiKXeB5MB9QMcOScCAwEAAaOCAUkwggFFMB0G
# A1UdDgQWBBTD+pXk/rT/d7E/0QE7hH0wz+6UYTAfBgNVHSMEGDAWgBSfpxVdAF5i
# XYP05dJlpxtTNRnpcjBfBgNVHR8EWDBWMFSgUqBQhk5odHRwOi8vd3d3Lm1pY3Jv
# c29mdC5jb20vcGtpb3BzL2NybC9NaWNyb3NvZnQlMjBUaW1lLVN0YW1wJTIwUENB
# JTIwMjAxMCgxKS5jcmwwbAYIKwYBBQUHAQEEYDBeMFwGCCsGAQUFBzAChlBodHRw
# Oi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMFRp
# bWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNydDAMBgNVHRMBAf8EAjAAMBYGA1Ud
# JQEB/wQMMAoGCCsGAQUFBwMIMA4GA1UdDwEB/wQEAwIHgDANBgkqhkiG9w0BAQsF
# AAOCAgEAOSNN5MpLiyunm866frWIi0hdazKNLgRp3WZPfhYgPC3K/DNMzLliYQUA
# p6WtgolIrativXjOG1lIjayG9r6ew4H1n5XZdDfJ12DLjopap5e1iU/Yk0eutPyf
# OievfbsIzTk/G51+uiUJk772nVzau6hI2KGyGBJOvAbAVFR0g8ppZwLghT4z3mkG
# Zjq/O4Z/PcmVGtjGps2TCtI4rZjPNW8O4c/4aJRmYQ/NdW91JRrOXRpyXrTKUPe3
# kN8N56jpl9kotLhdvd89RbOsJNf2XzqbAV7XjV4caCglA2btzDxcyffwXhLu9HMU
# 3dLYTAI91gTNUF7BA9q1EvSlCKKlN8N10Y4iU0nyIkfpRxYyAbRyq5QPYPJHGA0T
# y0PD83aCt79Ra0IdDIMSuwXlpUnyIyxwrDylgfOGyysWBwQ/js249bqQOYPdpyOd
# gRe8tXdGrgDoBeuVOK+cRClXpimNYwr61oZ2/kPMzVrzRUYMkBXe9WqdSezh8tyt
# uulYYcRK95qihF0irQs6/WOQJltQX79lzFXE9FFln9Mix0as+C4HPzd+S0bBN3A3
# XRROwAv016ICuT8hY1InyW7jwVmN+OkQ1zei66LrU5RtAz0nTxx5OePyjnTaItTS
# Y4OGuGU1SXaH49JSP3t8yGYA/vorbW4VneeD721FgwaJToHFkOIwggdxMIIFWaAD
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
# Hm5TaGllbGQgVFNTIEVTTjo0QzFBLTA1RTAtRDk0NzElMCMGA1UEAxMcTWljcm9z
# b2Z0IFRpbWUtU3RhbXAgU2VydmljZaIjCgEBMAcGBSsOAwIaAxUAqROMbMS8JcUl
# cnPkwRLFRPXFspmggYMwgYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAx
# MDANBgkqhkiG9w0BAQsFAAIFAOtn3lMwIhgPMjAyNTAyMjUwNjE0NDNaGA8yMDI1
# MDIyNjA2MTQ0M1owdDA6BgorBgEEAYRZCgQBMSwwKjAKAgUA62feUwIBADAHAgEA
# AgILLDAHAgEAAgIU7DAKAgUA62kv0wIBADA2BgorBgEEAYRZCgQCMSgwJjAMBgor
# BgEEAYRZCgMCoAowCAIBAAIDB6EgoQowCAIBAAIDAYagMA0GCSqGSIb3DQEBCwUA
# A4IBAQAZ2RUivHIRsrbcjuiKn9Qgxiyvzd0NAk40p/EtY15Ytuj2Efpc9n4j2wEA
# VqBMidDsPxh8ycSwlBnAFWt32MU35D7aZQVFh7R2jTtUQv2tHAVNbcmzGolefSBr
# /JsHpsMwTU/9D1FEDHkEL0/j5xdGfKCSnR73ygMmcl7Cp/mpgHUd+WmdUHG6kl78
# Q9NGWOx0JAk4L90yjxCQ0myKdSLMpdrOVwzruwpdfyAuAostrmcbx2QnGF0a/Ehs
# /seeQM2CyaNoQbKSqu36iXTsWU9+LRSTB+NGUc2i8NtEfcrFe/tL6p66G4vTfagE
# yl9p7eEiMDwrRtQSu980q+1nDmjEMYIEDTCCBAkCAQEwgZMwfDELMAkGA1UEBhMC
# VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNV
# BAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRp
# bWUtU3RhbXAgUENBIDIwMTACEzMAAAH/Ejh898Fl1qEAAQAAAf8wDQYJYIZIAWUD
# BAIBBQCgggFKMBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAvBgkqhkiG9w0B
# CQQxIgQgQL9vPEePFhhn8+ywt7ZIc85r/eJZIg9qI2Z0aspo9wcwgfoGCyqGSIb3
# DQEJEAIvMYHqMIHnMIHkMIG9BCDkMu++yQJ3aaycIuMT6vA7JNuMaVOI3qDjSEV8
# upyn/TCBmDCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9u
# MRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRp
# b24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAAB
# /xI4fPfBZdahAAEAAAH/MCIEIG+lAhpYgegO4pAF040v/hyREjDhSsr36NfKoSPe
# skizMA0GCSqGSIb3DQEBCwUABIICAGRdVJ5GWErvXmC1zcbMkddE6R86l97bMYKq
# RIFif9aMmn12MSlrM7jVo/mVhiea5AdT+M9uyKYhS5tBUGlmHesfIUjCkVFUis4G
# Y3objLHxLi2uKAYFAsLcGS7lF6NizXWyjqSh841rwa0Nh3dCNMmB1swYXa5VS1EV
# B21MZWt2Dql9IRBcaBIbm5ryw8mMuMG2FVnAFu2PtC4U2apRfaVIkAF6Dluv93mj
# ynJ82p1Lv10j2oS4/Czpi/Unuvi6pPM67ZUc9HZj+QHL+XNS6jRBxkZY4JRHvYbS
# Stmv9hJ3CEOgXFMks1tTtlSwhC7m0V5mZe8Jyjpb4lS87pxgKIUCeaMLBlD1K5PE
# FksPNy8N7SSjNiWDcA3v49WDET7L/DRWCcwpC9/7rxmHOUu6iq5XqH0C7wHKln+O
# aK62rBfvv4D7pd25twc3JL52U2lfdRxDew9a/gTorNEbzTDuKsPX0o3Vvce2bkNT
# HfUINeM2ymDFgjf8tW+sm2o6HQolAsnCbO7Vw3kZh3B5JNoTv9IFxKiY1IcxJjqO
# 1O8nzIejFLnGKpGKDFr+wQNT8ZAHXnMbgUS7dILnsIpjU4ywCwpJa4FtJgvhf7Bn
# HSGpe0JJSuCy0t/j7dlMOEyKt/PZHRXXNlxERu+fpZlugKE5JLz6fjnrAXaT/QBg
# 8yOo9hYF
# SIG # End signature block
