
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
Get the marketplace registration definition for the marketplace identifier.
.Description
Get the marketplace registration definition for the marketplace identifier.
.Example
PS C:\> {{ Add code here }}

{{ Add output here }}
.Example
PS C:\> {{ Add code here }}

{{ Add output here }}

.Inputs
Microsoft.Azure.PowerShell.Cmdlets.ManagedServices.Models.IManagedServicesIdentity
.Outputs
Microsoft.Azure.PowerShell.Cmdlets.ManagedServices.Models.Api20200201Preview.IMarketplaceRegistrationDefinition
.Notes
COMPLEX PARAMETER PROPERTIES

To create the parameters described below, construct a hash table containing the appropriate properties. For information on hash tables, run Get-Help about_Hash_Tables.

INPUTOBJECT <IManagedServicesIdentity>: Identity Parameter
  [Id <String>]: Resource identity path
  [MarketplaceIdentifier <String>]: The Azure Marketplace identifier. Expected formats: {publisher}.{product[-preview]}.{planName}.{version} or {publisher}.{product[-preview]}.{planName} or {publisher}.{product[-preview]} or {publisher}).
  [RegistrationAssignmentId <String>]: The GUID of the registration assignment.
  [RegistrationDefinitionId <String>]: The GUID of the registration definition.
  [Scope <String>]: The scope of the resource.
.Link
https://learn.microsoft.com/powershell/module/az.managedservices/get-azmanagedservicesmarketplacedefinition
#>
function Get-AzManagedServicesMarketplaceDefinition {
    [OutputType([Microsoft.Azure.PowerShell.Cmdlets.ManagedServices.Models.Api20200201Preview.IMarketplaceRegistrationDefinition])]
    [CmdletBinding(DefaultParameterSetName='ListWithScope', PositionalBinding=$false)]
    param(
        [Parameter(ParameterSetName='GetWithScope', Mandatory)]
        [Parameter(ParameterSetName='GetWithoutScope', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.ManagedServices.Category('Path')]
        [System.String]
        # The Azure Marketplace identifier.
        # Expected formats: {publisher}.{product[-preview]}.{planName}.{version} or {publisher}.{product[-preview]}.{planName} or {publisher}.{product[-preview]} or {publisher}).
        ${MarketplaceIdentifier},
    
        [Parameter(ParameterSetName='GetWithScope')]
        [Parameter(ParameterSetName='ListWithScope')]
        [Microsoft.Azure.PowerShell.Cmdlets.ManagedServices.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.ManagedServices.Runtime.DefaultInfo(Script='"subscriptions/" + (Get-AzContext).Subscription.Id')]
        [System.String]
        # The scope of the resource.
        ${Scope},
    
        [Parameter(ParameterSetName='GetViaIdentity', Mandatory, ValueFromPipeline)]
        [Microsoft.Azure.PowerShell.Cmdlets.ManagedServices.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.ManagedServices.Models.IManagedServicesIdentity]
        # Identity Parameter
        # To construct, see NOTES section for INPUTOBJECT properties and create a hash table.
        ${InputObject},
    
        [Parameter(ParameterSetName='ListWithScope')]
        [Parameter(ParameterSetName='ListWithoutScope')]
        [Microsoft.Azure.PowerShell.Cmdlets.ManagedServices.Category('Query')]
        [System.String]
        # The filter query parameter to filter marketplace registration definitions by plan identifier, publisher, version etc.
        ${Filter},

        [Parameter(ParameterSetName='ListWithoutScope', Mandatory)]
        [Parameter(ParameterSetName='GetWithoutScope', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.ManagedServices.Category('Query')]
        [System.Management.Automation.SwitchParameter]
        # The filter query parameter to filter marketplace registration definitions by plan identifier, publisher, version etc.
        ${Tenant},
    
        [Parameter()]
        [Alias('AzureRMContext', 'AzureCredential')]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.ManagedServices.Category('Azure')]
        [System.Management.Automation.PSObject]
        # The credentials, account, tenant, and subscription used for communication with Azure.
        ${DefaultProfile},
    
        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.ManagedServices.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Wait for .NET debugger to attach
        ${Break},
    
        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.ManagedServices.Category('Runtime')]
        [Microsoft.Azure.PowerShell.Cmdlets.ManagedServices.Runtime.SendAsyncStep[]]
        # SendAsync Pipeline Steps to be appended to the front of the pipeline
        ${HttpPipelineAppend},
    
        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.ManagedServices.Category('Runtime')]
        [Microsoft.Azure.PowerShell.Cmdlets.ManagedServices.Runtime.SendAsyncStep[]]
        # SendAsync Pipeline Steps to be prepended to the front of the pipeline
        ${HttpPipelinePrepend},
    
        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.ManagedServices.Category('Runtime')]
        [System.Uri]
        # The URI for the proxy server to use
        ${Proxy},
    
        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.ManagedServices.Category('Runtime')]
        [System.Management.Automation.PSCredential]
        # Credentials for a proxy server to use for the remote call
        ${ProxyCredential},
    
        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.ManagedServices.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Use the default credentials for the proxy
        ${ProxyUseDefaultCredentials}
    )
    
    process {
        try {
            if ($PSCmdlet.ParameterSetName -eq 'GetWithScope') {
                return Az.ManagedServices.internal\Get-AzManagedServicesMarketplaceDefinition @PSBoundParameters
            }

            if (($PSCmdlet.ParameterSetName -eq 'ListWithoutScope') -or ($PSCmdlet.ParameterSetName -eq 'GetWithoutScope')) {
                $PSBoundParameters.Remove("Tenant") | Out-Null;
                return Az.ManagedServices.internal\Get-AzManagedServicesMarketplaceDefinitionsWithoutScope @PSBoundParameters
            }

            if ($PSCmdlet.ParameterSetName -eq 'GetViaIdentity') {
                if ($InputObject.Id -match "^/providers/.*") {
                    return Az.ManagedServices.internal\Get-AzManagedServicesMarketplaceDefinitionsWithoutScope @PSBoundParameters
                } else {
                    return Az.ManagedServices.internal\Get-AzManagedServicesMarketplaceDefinition @PSBoundParameters
                }
            }
            # Default ParameterSetName(ListWithScope)
            return Az.ManagedServices.internal\Get-AzManagedServicesMarketplaceDefinition @PSBoundParameters
        } catch {
            throw
        }
    }
    
    }
    
# SIG # Begin signature block
# MIIoOAYJKoZIhvcNAQcCoIIoKTCCKCUCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCaFQyE7XfsQKVd
# Qob1ODrU6KEX+DPVPYGCQ452PNuKSaCCDYUwggYDMIID66ADAgECAhMzAAAEhJji
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
# cVZOSEXAQsmbdlsKgEhr/Xmfwb1tbWrJUnMTDXpQzTGCGgkwghoFAgEBMIGVMH4x
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01p
# Y3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTECEzMAAASEmOIS4HijMV0AAAAA
# BIQwDQYJYIZIAWUDBAIBBQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIE++
# 872vkqQxHt2pu4Os0I2Sfa4tG4/PIZZfSx2X49XcMEIGCisGAQQBgjcCAQwxNDAy
# oBSAEgBNAGkAYwByAG8AcwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20wDQYJKoZIhvcNAQEBBQAEggEAb36dmhkLiF97nhDP1NskSHAehcBW/ew8UsMW
# yd63QfuQBn2PwRXlXv92JMQpUq9MV9fnaDveZfoSlNyg34Gs3f/bVn2K2bXcxcRK
# KcIbfFrLnfwi9SvRCIJNT2v+v6CJaoEIITDhGeFrJOTIpyPCoROokhNrOZf/lARH
# IcFBfDZk0gJfYapq142wdOK1QreD74MtCDBdnsNPZJnAbLRqD47eHZuCoHOcdkv5
# aTFz2diZj62zfL941wTN8krCS3X4rZ6BrW9xCsGMipDha0A5p41JuKv26wedFFkS
# Mtb3rXgNCPpkCsJyeTbe3pMAXRiw6LtXCaiifaYDYzj1mMvd26GCF5MwghePBgor
# BgEEAYI3AwMBMYIXfzCCF3sGCSqGSIb3DQEHAqCCF2wwghdoAgEDMQ8wDQYJYIZI
# AWUDBAIBBQAwggFRBgsqhkiG9w0BCRABBKCCAUAEggE8MIIBOAIBAQYKKwYBBAGE
# WQoDATAxMA0GCWCGSAFlAwQCAQUABCAfoHJoJbzbGJxArRZcIrT3NTW7TNmO1K5O
# QQ3t2z7D6wIGaHBrcjdfGBIyMDI1MDczMDAzNTEyNi4wNVowBIACAfSggdGkgc4w
# gcsxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdS
# ZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJTAjBgNVBAsT
# HE1pY3Jvc29mdCBBbWVyaWNhIE9wZXJhdGlvbnMxJzAlBgNVBAsTHm5TaGllbGQg
# VFNTIEVTTjo5MjAwLTA1RTAtRDk0NzElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUt
# U3RhbXAgU2VydmljZaCCEeowggcgMIIFCKADAgECAhMzAAACCQgH4PlcjOZVAAEA
# AAIJMA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNo
# aW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29y
# cG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEw
# MB4XDTI1MDEzMDE5NDI1NVoXDTI2MDQyMjE5NDI1NVowgcsxCzAJBgNVBAYTAlVT
# MRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQK
# ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJTAjBgNVBAsTHE1pY3Jvc29mdCBBbWVy
# aWNhIE9wZXJhdGlvbnMxJzAlBgNVBAsTHm5TaGllbGQgVFNTIEVTTjo5MjAwLTA1
# RTAtRDk0NzElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2VydmljZTCC
# AiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAMKUSjD3Lgzd/VL3PXG00QRP
# BYvW8SKLDSgPtJcR2/ix0/TGxXKJ2/ojauYSXw9iz0txmPOxY4cjt1CREvbwY/cJ
# dy9jRmrqdawdjZBqYJkUsXYiVEfoEfHZGQ3tlEMqazsE6jggYFGUIyRS/033+3A7
# MCSlY2wzdv8FDFzCFWCxCq1Dw0Q9S6JH4ZXmt1AdRPimOKFlOQnCtqWLPRltilRM
# fk6SLd3cGnH2qI+uIHqGE18Y+OXQ8inbcPnv2ulbpmY+o9PyPXYpfvJJnA27Gzc9
# i8X/DXcaxFeTMhsjIsoQ/OP2XOaasXbCO+9SvH0BnDsYtJeTbwOfVdJ/raFuQW5Q
# bA8UuncRtGohWYFnjbBzPmZIggLLdCz+HCERiFSd2cAGA2kPlq8As5XuxR8mscNl
# dfp/2CBuMgDqPaeFIBIiqXwXkuwoHDRE+0O7LePYI/G1OZmjNssrxMy3EOIwKDFO
# l+DmJhS/KFXhqpoMvBEGygFGE7/6HDJsqdjBfEp546uw7BAudo4TkGYUlhYE4XPd
# 3zwsEr1BEGB0QfkItWHvCSAwh6H3pwfn4fTES+aDq3u7O2VdfZJXvF1Rg/EDe+ON
# XcSRXtptIcPkcdBlOt3cWqwP9U5gAJRUE+vEX6RStkZfFgidlOmtgxgSrpQgbUNP
# ikJU/0NxoIsYg5gQnWDTAgMBAAGjggFJMIIBRTAdBgNVHQ4EFgQUSYvo0cRdOOW9
# 8C9AzbV3MxaTytIwHwYDVR0jBBgwFoAUn6cVXQBeYl2D9OXSZacbUzUZ6XIwXwYD
# VR0fBFgwVjBUoFKgUIZOaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9j
# cmwvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUyMDIwMTAoMSkuY3JsMGwG
# CCsGAQUFBwEBBGAwXjBcBggrBgEFBQcwAoZQaHR0cDovL3d3dy5taWNyb3NvZnQu
# Y29tL3BraW9wcy9jZXJ0cy9NaWNyb3NvZnQlMjBUaW1lLVN0YW1wJTIwUENBJTIw
# MjAxMCgxKS5jcnQwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcD
# CDAOBgNVHQ8BAf8EBAMCB4AwDQYJKoZIhvcNAQELBQADggIBAFxefG84PCTiH+Nt
# QGycWUW2tK4EFlvvBJl9rmUpExM182WZoALht3tajQjmEzGwQlTK6kfCHiQPmqRF
# lzMhzSMgAFBDXENQFr5ZPGun9QCoLXuKMUJ49kphWM2sd/8GaPPsVo4jjWTG55GH
# As0hxDaCYGoNHlbhNLaG1EljJkCzuN8mZsO1NxQ4yESXU5aXH8We9xBui3lU/NpT
# CJPo2J7yXo9mOhCy7GJqy5ICbEohB2wecnlCiSrB3KpeLUVkO0RNW9td8Oyh/NO1
# rh6fap/jyHMRnBS9uTPmya3z3SdUAruTPZyuvM3eGmd8W5+2n+tctZO/E9Bx9ZeI
# S4hR3YaDt5HxC3Iq0kNTz48PAQKTOhomNsYIqrH0RKAUnPOtc3CGFfpFzyDYRT/7
# reaapZ4IX+Qk4WDZ4nDtq79psRKCrcRrPIPVWUv4dpf4wEcbNCYe286bdCXjBVM3
# darxfxsJHryqIXmsVqybhHEXrNqNl5IcL+pLnffr/howOqxXo7zpGU88JgYk4+1/
# Yxso7tckl4v9RA3Rze6LHlExOjrp1sBPE9QUQbk+Hg8fMaNRsQ7sPfku4QGKIbxi
# uUxE6QaXd8FCX1tZuDD0IhRBvCrlxNoTGV8Skx1KjJ0miVRNAPkQsobPVMlqFOJ1
# 3bTCXCLkGTfpcibOwfhizXmJdF8CMIIHcTCCBVmgAwIBAgITMwAAABXF52ueAptJ
# mQAAAAAAFTANBgkqhkiG9w0BAQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29m
# dCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlmaWNh
# dGUgQXV0aG9yaXR5IDIwMTAwHhcNMjEwOTMwMTgyMjI1WhcNMzAwOTMwMTgzMjI1
# WjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQD
# Ex1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDCCAiIwDQYJKoZIhvcNAQEB
# BQADggIPADCCAgoCggIBAOThpkzntHIhC3miy9ckeb0O1YLT/e6cBwfSqWxOdcjK
# NVf2AX9sSuDivbk+F2Az/1xPx2b3lVNxWuJ+Slr+uDZnhUYjDLWNE893MsAQGOhg
# fWpSg0S3po5GawcU88V29YZQ3MFEyHFcUTE3oAo4bo3t1w/YJlN8OWECesSq/XJp
# rx2rrPY2vjUmZNqYO7oaezOtgFt+jBAcnVL+tuhiJdxqD89d9P6OU8/W7IVWTe/d
# vI2k45GPsjksUZzpcGkNyjYtcI4xyDUoveO0hyTD4MmPfrVUj9z6BVWYbWg7mka9
# 7aSueik3rMvrg0XnRm7KMtXAhjBcTyziYrLNueKNiOSWrAFKu75xqRdbZ2De+JKR
# Hh09/SDPc31BmkZ1zcRfNN0Sidb9pSB9fvzZnkXftnIv231fgLrbqn427DZM9itu
# qBJR6L8FA6PRc6ZNN3SUHDSCD/AQ8rdHGO2n6Jl8P0zbr17C89XYcz1DTsEzOUyO
# ArxCaC4Q6oRRRuLRvWoYWmEBc8pnol7XKHYC4jMYctenIPDC+hIK12NvDMk2ZItb
# oKaDIV1fMHSRlJTYuVD5C4lh8zYGNRiER9vcG9H9stQcxWv2XFJRXRLbJbqvUAV6
# bMURHXLvjflSxIUXk8A8FdsaN8cIFRg/eKtFtvUeh17aj54WcmnGrnu3tz5q4i6t
# AgMBAAGjggHdMIIB2TASBgkrBgEEAYI3FQEEBQIDAQABMCMGCSsGAQQBgjcVAgQW
# BBQqp1L+ZMSavoKRPEY1Kc8Q/y8E7jAdBgNVHQ4EFgQUn6cVXQBeYl2D9OXSZacb
# UzUZ6XIwXAYDVR0gBFUwUzBRBgwrBgEEAYI3TIN9AQEwQTA/BggrBgEFBQcCARYz
# aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9Eb2NzL1JlcG9zaXRvcnku
# aHRtMBMGA1UdJQQMMAoGCCsGAQUFBwMIMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIA
# QwBBMAsGA1UdDwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQYMBaAFNX2
# VsuP6KJcYmjRPZSQW9fOmhjEMFYGA1UdHwRPME0wS6BJoEeGRWh0dHA6Ly9jcmwu
# bWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY1Jvb0NlckF1dF8yMDEw
# LTA2LTIzLmNybDBaBggrBgEFBQcBAQROMEwwSgYIKwYBBQUHMAKGPmh0dHA6Ly93
# d3cubWljcm9zb2Z0LmNvbS9wa2kvY2VydHMvTWljUm9vQ2VyQXV0XzIwMTAtMDYt
# MjMuY3J0MA0GCSqGSIb3DQEBCwUAA4ICAQCdVX38Kq3hLB9nATEkW+Geckv8qW/q
# XBS2Pk5HZHixBpOXPTEztTnXwnE2P9pkbHzQdTltuw8x5MKP+2zRoZQYIu7pZmc6
# U03dmLq2HnjYNi6cqYJWAAOwBb6J6Gngugnue99qb74py27YP0h1AdkY3m2CDPVt
# I1TkeFN1JFe53Z/zjj3G82jfZfakVqr3lbYoVSfQJL1AoL8ZthISEV09J+BAljis
# 9/kpicO8F7BUhUKz/AyeixmJ5/ALaoHCgRlCGVJ1ijbCHcNhcy4sa3tuPywJeBTp
# kbKpW99Jo3QMvOyRgNI95ko+ZjtPu4b6MhrZlvSP9pEB9s7GdP32THJvEKt1MMU0
# sHrYUP4KWN1APMdUbZ1jdEgssU5HLcEUBHG/ZPkkvnNtyo4JvbMBV0lUZNlz138e
# W0QBjloZkWsNn6Qo3GcZKCS6OEuabvshVGtqRRFHqfG3rsjoiV5PndLQTHa1V1QJ
# sWkBRH58oWFsc/4Ku+xBZj1p/cvBQUl+fpO+y/g75LcVv7TOPqUxUYS8vwLBgqJ7
# Fx0ViY1w/ue10CgaiQuPNtq6TPmb/wrpNPgkNWcr4A245oyZ1uEi6vAnQj0llOZ0
# dFtq0Z4+7X6gMTN9vMvpe784cETRkPHIqzqKOghif9lwY1NNje6CbaUFEMFxBmoQ
# tB1VM1izoXBm8qGCA00wggI1AgEBMIH5oYHRpIHOMIHLMQswCQYDVQQGEwJVUzET
# MBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMV
# TWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmlj
# YSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046OTIwMC0wNUUw
# LUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2WiIwoB
# ATAHBgUrDgMCGgMVAHzvras9NB3sicMJB1vWSAUpCQJEoIGDMIGApH4wfDELMAkG
# A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
# HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9z
# b2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAwDQYJKoZIhvcNAQELBQACBQDsM/VpMCIY
# DzIwMjUwNzMwMDEzNTM3WhgPMjAyNTA3MzEwMTM1MzdaMHQwOgYKKwYBBAGEWQoE
# ATEsMCowCgIFAOwz9WkCAQAwBwIBAAICGZcwBwIBAAICEvowCgIFAOw1RukCAQAw
# NgYKKwYBBAGEWQoEAjEoMCYwDAYKKwYBBAGEWQoDAqAKMAgCAQACAwehIKEKMAgC
# AQACAwGGoDANBgkqhkiG9w0BAQsFAAOCAQEAgfBld6OIhwEQnLxL7xyTQPcaZo3P
# LSfQhc4Yvab73+dFkViACyk5HxgA0LO0T5bfGORRXKJA4vVzw9gCmywU7+fEdbQT
# gFj4peLfzrA5LZsvrxklF3jLP4ruEiSMA2AJmFKTY2EBadqy0MxM4WQgp9wiI9D9
# /L0Y7qRZD7eWA7DMdgIRzYYORP5gaf6ED7dXqOm4M9xgxVJe0/Z9gi7A2+DG+XyB
# dfYf0GUpq9i41CyLhLkO6ECgNg+EA2OXlRcFFSi9ZVjZ8zLGBYmJ/+SHV6/WSClf
# voYk5B83kQ87sZb+2NjHD/d9DzfvsEyxCG1oviEcfSiuEmIB15ePbOjoWjGCBA0w
# ggQJAgEBMIGTMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAw
# DgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24x
# JjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAACCQgH
# 4PlcjOZVAAEAAAIJMA0GCWCGSAFlAwQCAQUAoIIBSjAaBgkqhkiG9w0BCQMxDQYL
# KoZIhvcNAQkQAQQwLwYJKoZIhvcNAQkEMSIEICaIqD2+71KWpmxTGyNdMknzQaPx
# SqNy2ZffG7Vsk1q3MIH6BgsqhkiG9w0BCRACLzGB6jCB5zCB5DCBvQQgaBssHsi9
# 9AIuZQ5RmGN1SorxuKR8HplVV2hOM3CFEz4wgZgwgYCkfjB8MQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGlt
# ZS1TdGFtcCBQQ0EgMjAxMAITMwAAAgkIB+D5XIzmVQABAAACCTAiBCDo2M85RyS1
# 4H0OyIikJxp3zOP9TGXnNJm+gYoU/ysknzANBgkqhkiG9w0BAQsFAASCAgAz40IE
# NxfKJNjAnwgQUhxrnGDa5p5j1+0osfMNKZ8MNlaO4q8IGLb5sLmbyljcBG3KLPG2
# gwZBbwL24DTRBqSEmcoSQh9CAkNLdlnUWOB3SZBWcOR2sPQi+44AyiOksVDOU3so
# ts5vtSVQ/VvKl7tauv4ShkQi4nlNLR+wZiuRHalA5NYC6iQlchgFJjqqAU+NesmU
# DPashb4DXAueVOUgZud2y5cB2w8DDOGBAAxydADXsVw6p+O0JNSrRLezfbr0Zi9y
# ywQ0FNW2X/L9MJ7jHQKbPmRn5evWsdaRNHLqFUv9Oxs5n94HspIP1uofPeJq2Nn/
# aRIjyCTMsMmwj+Ik5qITgreC0gwup0SdglskUxgRUPFiFO46wfWMU+MAfoCUM+Bk
# iF9jV4zEDUyADCEi6gNAM/apxAByv/vBHPQbHEL7EyqJblWKQP7/vAE1A1rGtDeT
# lhWzafFob2VM2LJb7tXlAG1w77TJI+wWwwnvlwQQfiOR6L5/yfBUYOJCuxXgQHAj
# /hEwymF0xvjJ1zNoTcu/sGTVvei+3NJ0FZGZty2N5Acvh+x+D6ikRToz6pmr4S1g
# d2ymwdTAwMD9FNnUNg6JV+tdI2V0P2SSGNqT7slS9Eg2ixmn2e7Kbr2rUsAJqFu0
# DBPzBV2T/06gU4vDJW6zmRzwPHVUlxDKkAMafQ==
# SIG # End signature block
