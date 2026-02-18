
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
Create or update a Kusto pool.
.Description
Create or update a Kusto pool.
.Example
PS C:\> New-AzSynapseKustoPool -ResourceGroupName testrg -WorkspaceName testws -Name testnewkustopool -Location 'East US' -SkuName "Storage optimized" -SkuSize Medium

Location  Name                    Type                                    Etag
--------  ----                    ----                                    ----
East US 2 testws/testnewkustopool Microsoft.Synapse/workspaces/kustoPools 

.Outputs
Microsoft.Azure.PowerShell.Cmdlets.Synapse.Models.Api20210601Preview.IKustoPool
.Link
https://learn.microsoft.com/powershell/module/az.synapse/new-azsynapsekustopool
#>
function New-AzSynapseKustoPool {
    [OutputType([Microsoft.Azure.PowerShell.Cmdlets.Synapse.Models.Api20210601Preview.IKustoPool])]
    [CmdletBinding(PositionalBinding=$false, SupportsShouldProcess, ConfirmImpact='Medium')]
    param(
        [Parameter(Mandatory)]
        [Alias('KustoPoolName')]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Path')]
        [System.String]
        # The name of the Kusto pool.
        ${Name},

        [Parameter(Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Path')]
        [System.String]
        # The name of the resource group.
        # The name is case insensitive.
        ${ResourceGroupName},

        [Parameter(Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Path')]
        [System.String]
        # The name of the workspace
        ${WorkspaceName},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Runtime.DefaultInfo(Script='(Get-AzContext).Subscription.Id')]
        [System.String]
        # The ID of the target subscription.
        ${SubscriptionId},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Header')]
        [System.String]
        # The ETag of the Kusto Pool.
        # Omit this value to always overwrite the current Kusto Pool.
        # Specify the last-seen ETag value to prevent accidentally overwriting concurrent changes.
        ${IfMatch},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Header')]
        [System.String]
        # Set to '*' to allow a new Kusto Pool to be created, but to prevent updating an existing Kusto Pool.
        # Other values will result in a 412 Pre-condition Failed response.
        ${IfNoneMatch},

        [Parameter(Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Body')]
        [System.String]
        # The geo-location where the resource lives
        ${Location},

        [Parameter(Mandatory)]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.Synapse.Support.SkuName])]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Support.SkuName]
        # SKU name.
        ${SkuName},

        [Parameter(Mandatory)]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.Synapse.Support.SkuSize])]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Support.SkuSize]
        # SKU size.
        ${SkuSize},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Body')]
        [System.Management.Automation.SwitchParameter]
        # A boolean value that indicates if the purge operations are enabled.
        ${EnablePurge},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Body')]
        [System.Management.Automation.SwitchParameter]
        # A boolean value that indicates if the streaming ingest is enabled.
        ${EnableStreamingIngest},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Body')]
        [System.Management.Automation.SwitchParameter]
        # A boolean value that indicate if the optimized autoscale feature is enabled or not.
        ${OptimizedAutoscaleIsEnabled},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Body')]
        [System.Int32]
        # Maximum allowed instances count.
        ${OptimizedAutoscaleMaximum},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Body')]
        [System.Int32]
        # Minimum allowed instances count.
        ${OptimizedAutoscaleMinimum},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Body')]
        [System.Int32]
        # The version of the template defined, for instance 1.
        ${OptimizedAutoscaleVersion},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Body')]
        [System.Int32]
        # The number of instances of the cluster.
        ${SkuCapacity},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Runtime.Info(PossibleTypes=([Microsoft.Azure.PowerShell.Cmdlets.Synapse.Models.Api10.ITrackedResourceTags]))]
        [System.Collections.Hashtable]
        # Resource tags.
        ${Tag},

        [Parameter()]
        [Alias('AzureRMContext', 'AzureCredential')]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Azure')]
        [System.Management.Automation.PSObject]
        # The credentials, account, tenant, and subscription used for communication with Azure.
        ${DefaultProfile},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Run the command as a job
        ${AsJob},

        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Wait for .NET debugger to attach
        ${Break},

        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Runtime')]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Runtime.SendAsyncStep[]]
        # SendAsync Pipeline Steps to be appended to the front of the pipeline
        ${HttpPipelineAppend},

        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Runtime')]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Runtime.SendAsyncStep[]]
        # SendAsync Pipeline Steps to be prepended to the front of the pipeline
        ${HttpPipelinePrepend},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Run the command asynchronously
        ${NoWait},

        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Runtime')]
        [System.Uri]
        # The URI for the proxy server to use
        ${Proxy},

        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Runtime')]
        [System.Management.Automation.PSCredential]
        # Credentials for a proxy server to use for the remote call
        ${ProxyCredential},

        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Use the default credentials for the proxy
        ${ProxyUseDefaultCredentials}
    )

    process {
        try {
            $Parameter = [Microsoft.Azure.PowerShell.Cmdlets.Synapse.Models.Api20210601Preview.KustoPool]::new()

            $Parameter.Location = $PSBoundParameters['Location']
            $null = $PSBoundParameters.Remove('Location')

            $Parameter.SkuName = $PSBoundParameters['SkuName']
            $null = $PSBoundParameters.Remove('SkuName')

            $Parameter.SkuSize = $PSBoundParameters['SkuSize']
            $null = $PSBoundParameters.Remove('SkuSize')

            $ws = Get-AzSynapseWorkspace -ResourceGroupName $PSBoundParameters['ResourceGroupName'] -Name $PSBoundParameters['WorkspaceName']

            $Parameter.WorkspaceUid = $ws.WorkspaceUid

            if ($PSBoundParameters.ContainsKey('EnablePurge')) {
                $Parameter.EnablePurge = $PSBoundParameters['EnablePurge']
                $null = $PSBoundParameters.Remove('EnablePurge')
            }

            if ($PSBoundParameters.ContainsKey('EnableStreamingIngest')) {
                $Parameter.EnableStreamingIngest = $PSBoundParameters['EnableStreamingIngest']
                $null = $PSBoundParameters.Remove('EnableStreamingIngest')
            }
            
            if ($PSBoundParameters.ContainsKey('OptimizedAutoscaleIsEnabled')) {
                $Parameter.OptimizedAutoscaleIsEnabled = $PSBoundParameters['OptimizedAutoscaleIsEnabled']
                $null = $PSBoundParameters.Remove('OptimizedAutoscaleIsEnabled')
            }

            if ($PSBoundParameters.ContainsKey('OptimizedAutoscaleMaximum')) {
                $Parameter.OptimizedAutoscaleMaximum = $PSBoundParameters['OptimizedAutoscaleMaximum']
                $null = $PSBoundParameters.Remove('OptimizedAutoscaleMaximum')
            }

            if ($PSBoundParameters.ContainsKey('OptimizedAutoscaleMinimum')) {
                $Parameter.OptimizedAutoscaleMinimum = $PSBoundParameters['OptimizedAutoscaleMinimum']
                $null = $PSBoundParameters.Remove('OptimizedAutoscaleMinimum')
            }

            if ($PSBoundParameters.ContainsKey('OptimizedAutoscaleVersion')) {
                $Parameter.OptimizedAutoscaleVersion = $PSBoundParameters['OptimizedAutoscaleVersion']
                $null = $PSBoundParameters.Remove('OptimizedAutoscaleVersion')
            }

            if ($PSBoundParameters.ContainsKey('SkuCapacity')) {
                $Parameter.SkuCapacity = $PSBoundParameters['SkuCapacity']
                $null = $PSBoundParameters.Remove('SkuCapacity')
            }

            if ($PSBoundParameters.ContainsKey('Tag')) {
                $Parameter.Tag = $PSBoundParameters['Tag']
                $null = $PSBoundParameters.Remove('Tag')
            }

            $null = $PSBoundParameters.Add('Parameter', $Parameter)

            Az.Synapse.internal\New-AzSynapseKustoPool @PSBoundParameters
        } catch {
            throw
        }
    }
}



# SIG # Begin signature block
# MIIoKgYJKoZIhvcNAQcCoIIoGzCCKBcCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCyseCw5leULIHj
# 0qqmGPcCMuwC2GsUc6OTFUBAujmTG6CCDXYwggX0MIID3KADAgECAhMzAAAEhV6Z
# 7A5ZL83XAAAAAASFMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjUwNjE5MTgyMTM3WhcNMjYwNjE3MTgyMTM3WjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQDASkh1cpvuUqfbqxele7LCSHEamVNBfFE4uY1FkGsAdUF/vnjpE1dnAD9vMOqy
# 5ZO49ILhP4jiP/P2Pn9ao+5TDtKmcQ+pZdzbG7t43yRXJC3nXvTGQroodPi9USQi
# 9rI+0gwuXRKBII7L+k3kMkKLmFrsWUjzgXVCLYa6ZH7BCALAcJWZTwWPoiT4HpqQ
# hJcYLB7pfetAVCeBEVZD8itKQ6QA5/LQR+9X6dlSj4Vxta4JnpxvgSrkjXCz+tlJ
# 67ABZ551lw23RWU1uyfgCfEFhBfiyPR2WSjskPl9ap6qrf8fNQ1sGYun2p4JdXxe
# UAKf1hVa/3TQXjvPTiRXCnJPAgMBAAGjggFzMIIBbzAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQUuCZyGiCuLYE0aU7j5TFqY05kko0w
# RQYDVR0RBD4wPKQ6MDgxHjAcBgNVBAsTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEW
# MBQGA1UEBRMNMjMwMDEyKzUwNTM1OTAfBgNVHSMEGDAWgBRIbmTlUAXTgqoXNzci
# tW2oynUClTBUBgNVHR8ETTBLMEmgR6BFhkNodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpb3BzL2NybC9NaWNDb2RTaWdQQ0EyMDExXzIwMTEtMDctMDguY3JsMGEG
# CCsGAQUFBwEBBFUwUzBRBggrBgEFBQcwAoZFaHR0cDovL3d3dy5taWNyb3NvZnQu
# Y29tL3BraW9wcy9jZXJ0cy9NaWNDb2RTaWdQQ0EyMDExXzIwMTEtMDctMDguY3J0
# MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQADggIBACjmqAp2Ci4sTHZci+qk
# tEAKsFk5HNVGKyWR2rFGXsd7cggZ04H5U4SV0fAL6fOE9dLvt4I7HBHLhpGdE5Uj
# Ly4NxLTG2bDAkeAVmxmd2uKWVGKym1aarDxXfv3GCN4mRX+Pn4c+py3S/6Kkt5eS
# DAIIsrzKw3Kh2SW1hCwXX/k1v4b+NH1Fjl+i/xPJspXCFuZB4aC5FLT5fgbRKqns
# WeAdn8DsrYQhT3QXLt6Nv3/dMzv7G/Cdpbdcoul8FYl+t3dmXM+SIClC3l2ae0wO
# lNrQ42yQEycuPU5OoqLT85jsZ7+4CaScfFINlO7l7Y7r/xauqHbSPQ1r3oIC+e71
# 5s2G3ClZa3y99aYx2lnXYe1srcrIx8NAXTViiypXVn9ZGmEkfNcfDiqGQwkml5z9
# nm3pWiBZ69adaBBbAFEjyJG4y0a76bel/4sDCVvaZzLM3TFbxVO9BQrjZRtbJZbk
# C3XArpLqZSfx53SuYdddxPX8pvcqFuEu8wcUeD05t9xNbJ4TtdAECJlEi0vvBxlm
# M5tzFXy2qZeqPMXHSQYqPgZ9jvScZ6NwznFD0+33kbzyhOSz/WuGbAu4cHZG8gKn
# lQVT4uA2Diex9DMs2WHiokNknYlLoUeWXW1QrJLpqO82TLyKTbBM/oZHAdIc0kzo
# STro9b3+vjn2809D0+SOOCVZMIIHejCCBWKgAwIBAgIKYQ6Q0gAAAAAAAzANBgkq
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
# /Xmfwb1tbWrJUnMTDXpQzTGCGgowghoGAgEBMIGVMH4xCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNp
# Z25pbmcgUENBIDIwMTECEzMAAASFXpnsDlkvzdcAAAAABIUwDQYJYIZIAWUDBAIB
# BQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIEStAXl+PzumUPy3jP55o0QU
# XrUgLVgOUs8rj1pWxRC2MEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEB
# BQAEggEAknQqKTXfQUbuZ5hsjNpxQSKkwdMg+Ym0Q9HkQCNKJcRSQuld+xr4JJ3k
# ZLo1U/xHKffQrhU75irCLlIntIHc6EYTOO6GUKthPYzFWaeb2SUKEpEtLPSEZXIl
# +GcFZkbmzXvlPs04GaRFI6Gnt1wdgrhiQDyLHjIiYV9hmFBUBU48nV/WUEdlq8xv
# lQdKzT84axLc8hn/QPdKZZaDBwRKjC0ogdTHsnINGGVAPbsW/qKkBzRZMQQBtNFv
# xf0yPCdpH1xS3k/TFylY8WXHCeiCxlnUddmwGiJqrKsWxAd0ZaTiRoRo2qx7STYD
# DERviZUzm9AOZcJqB/oe+DmgQ5a61KGCF5QwgheQBgorBgEEAYI3AwMBMYIXgDCC
# F3wGCSqGSIb3DQEHAqCCF20wghdpAgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFSBgsq
# hkiG9w0BCRABBKCCAUEEggE9MIIBOQIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCBibiu2/jBVYIBJx1hDe3l3UUPl6Gzwi7+sdlC01dGP0gIGaEsTNvNP
# GBMyMDI1MDczMDAzNTExNi4yMzRaMASAAgH0oIHRpIHOMIHLMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1l
# cmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046N0YwMC0w
# NUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2Wg
# ghHqMIIHIDCCBQigAwIBAgITMwAAAgbXvFE4mCPsLAABAAACBjANBgkqhkiG9w0B
# AQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYD
# VQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAeFw0yNTAxMzAxOTQy
# NTBaFw0yNjA0MjIxOTQyNTBaMIHLMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25z
# MScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046N0YwMC0wNUUwLUQ5NDcxJTAjBgNV
# BAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2UwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQDpRIWbIM3Rlr397cjHaYx85l7I+ZVWGMCBCM911BpU
# 6+IGWCqksqgqefZFEjKzNVDYC9YcgITAz276NGgvECm4ZfNv/FPwcaSDz7xbDbsO
# oxbwQoHUNRro+x5ubZhT6WJeU97F06+vDjAw/Yt1vWOgRTqmP/dNr9oqIbE5oCLY
# dH3wI/noYmsJVc7966n+B7UAGAWU2se3Lz+xdxnNsNX4CR6zIMVJTSezP/2STNcx
# JTu9k2sl7/vzOhxJhCQ38rdaEoqhGHrXrmVkEhSv+S00DMJc1OIXxqfbwPjMqEVp
# 7K3kmczCkbum1BOIJ2wuDAbKuJelpteNZj/S58NSQw6khfuJAluqHK3igkS/Oux4
# 9qTP+rU+PQeNuD+GtrCopFucRmanQvxISGNoxnBq3UeDTqphm6aI7GMHtFD6DOjJ
# lllH1gVWXPTyivf+4tN8TmO6yIgB4uP00bH9jn/dyyxSjxPQ2nGvZtgtqnvq3h3T
# RjRnkc+e1XB1uatDa1zUcS7r3iodTpyATe2hgkVX3m4DhRzI6A4SJ6fbJM9isLH8
# AGKcymisKzYupAeFSTJ10JEFa6MjHQYYohoCF77R0CCwMNjvE4XfLHu+qKPY8GQf
# sZdigQ9clUAiydFmVt61hytoxZP7LmXbzjD0VecyzZoL4Equ1XszBsulAr5Ld2Kw
# cwIDAQABo4IBSTCCAUUwHQYDVR0OBBYEFO0wsLKdDGpT97cx3Iymyo/SBm4SMB8G
# A1UdIwQYMBaAFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMF8GA1UdHwRYMFYwVKBSoFCG
# Tmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUy
# MFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNybDBsBggrBgEFBQcBAQRgMF4w
# XAYIKwYBBQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2Vy
# dHMvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUyMDIwMTAoMSkuY3J0MAwG
# A1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQD
# AgeAMA0GCSqGSIb3DQEBCwUAA4ICAQB23GZOfe9ThTUvD29i4t6lDpxJhpVRMme+
# UbyZhBFCZhoGTtjDdphAArU2Q61WYg3YVcl2RdJm5PUbZ2bA77zk+qtLxC+3dNxV
# sTcdtxPDSSWgwBHxTj6pCmoDNXolAYsWpvHQFCHDqEfAiBxX1dmaXbiTP1d0Xffv
# gR6dshUcqaH/mFfjDZAxLU1s6HcVgCvBQJlJ7xEG5jFKdtqapKWcbUHwTVqXQGbI
# lHVClNJ3yqW6Z3UJH/CFcYiLV/e68urTmGtiZxGSYb4SBSPArTrTYeHOlQIj/7lo
# VWmfWX2y4AGV/D+MzyZMyvFw4VyL0Vgq96EzQKyteiVeBaVEjxQKo3AcPULRF4Uz
# z98P2tCM5XbFZ3Qoj9PLg3rgFXr0oJEhfh2tqUrhTJd13+i4/fek9zWicoshlwXg
# Fu002ZWBVzASEFuqED48qyulZ/2jGJBcta+Fdk2loP2K3oSj4PQQe1MzzVZO52AX
# O42MHlhm3SHo3/RhQ+I1A0Ny+9uAehkQH6LrxkrVNvZG4f0PAKMbqUcXG7xznKJ0
# x0HYr5ayWGbHKZRcObU+/34ZpL9NrXOedVDXmSd2ylKSl/vvi1QwNJqXJl/+gJkQ
# EetqmHAUFQkFtemi8MUXQG2w/RDHXXwWAjE+qIDZLQ/k4z2Z216tWaR6RDKHGkwe
# CoDtQtzkHTCCB3EwggVZoAMCAQICEzMAAAAVxedrngKbSZkAAAAAABUwDQYJKoZI
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
# 6Xu/OHBE0ZDxyKs6ijoIYn/ZcGNTTY3ugm2lBRDBcQZqELQdVTNYs6FwZvKhggNN
# MIICNQIBATCB+aGB0aSBzjCByzELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
# bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
# b3JhdGlvbjElMCMGA1UECxMcTWljcm9zb2Z0IEFtZXJpY2EgT3BlcmF0aW9uczEn
# MCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOjdGMDAtMDVFMC1EOTQ3MSUwIwYDVQQD
# ExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloiMKAQEwBwYFKw4DAhoDFQAE
# a0f118XHM/VNdqKBs4QXxNnN96CBgzCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFBDQSAyMDEwMA0GCSqGSIb3DQEBCwUAAgUA7DOEAzAiGA8yMDI1MDcyOTE3MzE0
# N1oYDzIwMjUwNzMwMTczMTQ3WjB0MDoGCisGAQQBhFkKBAExLDAqMAoCBQDsM4QD
# AgEAMAcCAQACAg6GMAcCAQACAhN5MAoCBQDsNNWDAgEAMDYGCisGAQQBhFkKBAIx
# KDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMHoSChCjAIAgEAAgMBhqAwDQYJKoZI
# hvcNAQELBQADggEBAIxzNWOsW5WI2gVo69VfFjVikarl6ng14eJIL5Rb1a0DZXN0
# icXq8WxaGmb2UevxfBDF2Mk2mCEGmgghyYBAW+f5r78YxCOuHLHHSq5pZQfMJXMw
# SqBFUAyjymPNLOf/rDUZlCqArrfvJIj3W5DsWcoaxTfXaDfAUuK/8eOEFyJNwyIq
# uVg0geTU1Sier04JLFvyxz8o753v2g6lcB8c5MqedODn30RFmZKXTBBuUrkavTyk
# MAY+C94hFoO2hMR4oGrtIa0hdjIfBz92wZXnWW2zfLppkCDE2WlYeWX0lc84kQ6w
# D7rVNBaIy7SGlagIa4VzuEiCCZKmgJmoG1qkWoYxggQNMIIECQIBATCBkzB8MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNy
# b3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAgbXvFE4mCPsLAABAAACBjAN
# BglghkgBZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMC8G
# CSqGSIb3DQEJBDEiBCDwfnJl6GggfcCzRchbLSZqdOFat8JxyfY9iLh4h8x7SDCB
# +gYLKoZIhvcNAQkQAi8xgeowgecwgeQwgb0EIODo9ZSIkZ6dVtKT+E/uZx2WAy7K
# iXM5R1JIOhNJf0vSMIGYMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldh
# c2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBD
# b3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIw
# MTACEzMAAAIG17xROJgj7CwAAQAAAgYwIgQgx6Ai4KQzeZzpdGRY4OdGIvFlP3KQ
# 2uGK6uSaTJqqVPYwDQYJKoZIhvcNAQELBQAEggIAHT1ZzZ4hdHIy4xY6suDw4RjN
# AdCZ/15KnW9frnSbXVo2ndVjxsl4WeHk90Mzrs7qe1hUEjvB2ysC0Lt7IBtoyy0C
# oGJ7wU/FPihiAKL3urhT3zDu03MbETFvWZC5G/ovd8Kbf69/gvvpwYSCMpIURCy2
# QR20MGCX8TU1yIej0P7Zw8oyp7gpUsmNuzM5euzXH6pytTNuYcPjaX0I4tdjXVCI
# 6AvC6H3n/BurGeuOTCDCo1EwMSDdB+eLYvp+xr1RsxFCB3r2WC5Zkqgh30uvYdEC
# qaDn4p/VyxqC0rtBBxSZwQdbtm/zanB2kBpOd6CObo7PadAsoqGmWxjsULvfQ4mz
# nKaUVmsKGGj/iILzL5+znDObMsqq5fB+08j72qFwR3e1jCfl9EumSO047KNNggnp
# AI/Z49RlT5bkRz/sHoyM4Znj7cYCnGapeSElMhbJND28AA+w0DwQw/l+uiDLHN/Y
# guA8J4WJSEfoPa1fOQTbrHHmKqR8ZwCMwyQDApLV2SpTu9PO75/Z5lPTvpQxZXBW
# vwn/jMpxpf/qqOOfoeik6wOLBUer919qpSNlXExkZJdLn3IboF7be2Su0OS13kff
# grd5T3RxMSjDAduX8MsfOVvWfN7/NjkRhbcnWEduNZE83LBe9uLEgD+0CQhPNr4w
# urM7jKF9dOzlz+LIZfw=
# SIG # End signature block
