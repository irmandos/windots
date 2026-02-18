
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
Updates an existing server. The request body can contain one to many of the properties present in the normal server definition. Use Update-AzPostSqlConfiguration instead if you want update server parameters such as wait_timeout or net_retry_count.
.Description
Updates an existing server. The request body can contain one to many of the properties present in the normal server definition. Use Update-AzPostSqlConfiguration instead if you want update server parameters such as wait_timeout or net_retry_count.
#>
function Update-AzPostgreSqlServer {
    [OutputType([Microsoft.Azure.PowerShell.Cmdlets.PostgreSql.Models.Api20171201.IServer])]
    [CmdletBinding(DefaultParameterSetName='UpdateExpanded', PositionalBinding=$false, SupportsShouldProcess, ConfirmImpact='Medium')]
    param(
        [Parameter(ParameterSetName='UpdateExpanded', Mandatory, HelpMessage='The name of the server.')]
        [Alias('ServerName')]
        [Microsoft.Azure.PowerShell.Cmdlets.PostgreSql.Category('Path')]
        [System.String]
        ${Name},

        [Parameter(ParameterSetName='UpdateExpanded', Mandatory, HelpMessage='The name of the resource group that contains the resource. You can obtain this value from the Azure Resource Manager API or the portal.')]
        [Microsoft.Azure.PowerShell.Cmdlets.PostgreSql.Category('Path')]
        [System.String]
        ${ResourceGroupName},

        [Parameter(ParameterSetName='UpdateExpanded', HelpMessage='The subscription ID that identifies an Azure subscription.')]
        [Microsoft.Azure.PowerShell.Cmdlets.PostgreSql.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.PostgreSql.Runtime.DefaultInfo(Script='(Get-AzContext).Subscription.Id')]
        [System.String]
        ${SubscriptionId},

        [Parameter(ParameterSetName='UpdateViaIdentityExpanded', Mandatory, ValueFromPipeline, HelpMessage='Identity Parameter. To construct, see NOTES section for INPUTOBJECT properties and create a hash table.')]
        [Microsoft.Azure.PowerShell.Cmdlets.PostgreSql.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.PostgreSql.Models.IPostgreSqlIdentity]
        ${InputObject},

        [Parameter(HelpMessage='The password of the administrator login.')]
        [Microsoft.Azure.PowerShell.Cmdlets.PostgreSql.Category('Body')]
        [System.Security.SecureString]
        ${AdministratorLoginPassword},

        [Parameter(HelpMessage='The replication role of the server.')]
        [Microsoft.Azure.PowerShell.Cmdlets.PostgreSql.Category('Body')]
        [System.String]
        ${ReplicationRole},

        [Parameter(HelpMessage='The scale up/out capacity, representing server''s compute units.')]
        [Microsoft.Azure.PowerShell.Cmdlets.PostgreSql.Category('Body')]
        [System.Int32]
        ${SkuCapacity},

        [Parameter(HelpMessage='The family of hardware.')]
        [Microsoft.Azure.PowerShell.Cmdlets.PostgreSql.Category('Body')]
        [System.String]
        ${SkuFamily},

        [Parameter(HelpMessage='The name of the sku, typically, tier + family + cores, e.g. B_Gen4_1, GP_Gen5_8.')]
        [Microsoft.Azure.PowerShell.Cmdlets.PostgreSql.Category('Body')]
        [System.String]
        ${Sku},

        [Parameter(HelpMessage='The tier of the particular SKU, e.g. Basic.')]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.PostgreSql.Support.SkuTier])]
        [Microsoft.Azure.PowerShell.Cmdlets.PostgreSql.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.PostgreSql.Support.SkuTier]
        ${SkuTier},

        [Parameter(HelpMessage='Enable ssl enforcement or not when connect to server.')]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.PostgreSql.Support.SslEnforcementEnum])]
        [Microsoft.Azure.PowerShell.Cmdlets.PostgreSql.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.PostgreSql.Support.SslEnforcementEnum]
        ${SslEnforcement},

        [Parameter(HelpMessage = 'Set the minimal TLS version for connections to server when SSL is enabled. Default is TLSEnforcementDisabled.accepted values: TLS1_0, TLS1_1, TLS1_2, TLSEnforcementDisabled.')]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.PostgreSql.Support.MinimalTlsVersionEnum])]
        [Microsoft.Azure.PowerShell.Cmdlets.PostgreSql.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.PostgreSql.Support.MinimalTlsVersionEnum]
        # Enforce a minimal Tls version for the server.
        ${MinimalTlsVersion},
        
        [Parameter(HelpMessage='Backup retention days for the server. Day count is between 7 and 35.')]
        [Microsoft.Azure.PowerShell.Cmdlets.PostgreSql.Category('Body')]
        [System.Int32]
        ${BackupRetentionDay},

        [Parameter(HelpMessage='Enable Storage Auto Grow.')]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.PostgreSql.Support.StorageAutogrow])]
        [Validateset('Enabled', 'Disabled')]
        [Microsoft.Azure.PowerShell.Cmdlets.PostgreSql.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.PostgreSql.Support.StorageAutogrow]
        ${StorageAutogrow},

        [Parameter(HelpMessage='Max storage allowed for a server.')]
        [Microsoft.Azure.PowerShell.Cmdlets.PostgreSql.Category('Body')]
        [System.Int32]
        ${StorageInMb},

        [Parameter(HelpMessage='Application-specific metadata in the form of key-value pairs.')]
        [Microsoft.Azure.PowerShell.Cmdlets.PostgreSql.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.PostgreSql.Runtime.Info(PossibleTypes=([Microsoft.Azure.PowerShell.Cmdlets.PostgreSql.Models.Api20171201.IServerUpdateParametersTags]))]
        [System.Collections.Hashtable]
        ${Tag},

        [Parameter(HelpMessage='Enable or disable public network access')]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.PostgreSql.Support.PublicNetworkAccessEnum])]
        [Microsoft.Azure.PowerShell.Cmdlets.PostgreSql.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.PostgreSql.Support.PublicNetworkAccessEnum]
        ${PublicNetworkAccess},

        [Parameter(HelpMessage = 'The credentials, account, tenant, and subscription used for communication with Azure.')]
        [Alias('AzureRMContext', 'AzureCredential')]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.PostgreSql.Category('Azure')]
        [System.Management.Automation.PSObject]
        ${DefaultProfile},

        [Parameter(HelpMessage = 'Run the command as a job.')]
        [Microsoft.Azure.PowerShell.Cmdlets.PostgreSql.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        ${AsJob},

        [Parameter(DontShow, HelpMessage = 'Wait for .NET debugger to attach.')]
        [Microsoft.Azure.PowerShell.Cmdlets.PostgreSql.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        ${Break},

        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.PostgreSql.Category('Runtime')]
        [Microsoft.Azure.PowerShell.Cmdlets.PostgreSql.Runtime.SendAsyncStep[]]
        # SendAsync Pipeline Steps to be appended to the front of the pipeline.
        ${HttpPipelineAppend},

        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.PostgreSql.Category('Runtime')]
        [Microsoft.Azure.PowerShell.Cmdlets.PostgreSql.Runtime.SendAsyncStep[]]
        # SendAsync Pipeline Steps to be prepended to the front of the pipeline.
        ${HttpPipelinePrepend},

        [Parameter(HelpMessage = 'Run the command asynchronously.')]
        [Microsoft.Azure.PowerShell.Cmdlets.PostgreSql.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        ${NoWait},

        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.PostgreSql.Category('Runtime')]
        [System.Uri]
        # The URI for the proxy server to use.
        ${Proxy},

        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.PostgreSql.Category('Runtime')]
        [System.Management.Automation.PSCredential]
        # Credentials for a proxy server to use for the remote call.
        ${ProxyCredential},

        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.PostgreSql.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Use the default credentials for the proxy.
        ${ProxyUseDefaultCredentials}
    )

    process {
        try {
            if ($PSBoundParameters.ContainsKey('StorageInMb')) {
                $PSBoundParameters.Add('StorageProfileStorageMb', $PSBoundParameters['StorageInMb'])
                $null = $PSBoundParameters.Remove('StorageInMb')
            }

            if ($PSBoundParameters.ContainsKey('Sku')) {
                $PSBoundParameters.Add('SkuName', $PSBoundParameters['Sku'])
                $null = $PSBoundParameters.Remove('Sku')
            }

            if ($PSBoundParameters.ContainsKey('BackupRetentionDay')) {
                $PSBoundParameters.Add('StorageProfileBackupRetentionDay', $PSBoundParameters['BackupRetentionDay'])
                $null = $PSBoundParameters.Remove('BackupRetentionDay')
            }

            if ($PSBoundParameters.ContainsKey('StorageAutogrow')) {
                $PSBoundParameters.Add('StorageProfileStorageAutogrow', $PSBoundParameters['StorageAutogrow'])
                $null = $PSBoundParameters.Remove('StorageAutogrow')
            }

            Az.PostgreSql.internal\Update-AzPostgreSqlServer @PSBoundParameters
        } catch {
            throw
        }
    }
}

# SIG # Begin signature block
# MIIoLQYJKoZIhvcNAQcCoIIoHjCCKBoCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBZD413PM2k7/Zc
# GbBzke8d4XNfsPWzvax1SGTbuywSBqCCDXYwggX0MIID3KADAgECAhMzAAAEhV6Z
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
# /Xmfwb1tbWrJUnMTDXpQzTGCGg0wghoJAgEBMIGVMH4xCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNp
# Z25pbmcgUENBIDIwMTECEzMAAASFXpnsDlkvzdcAAAAABIUwDQYJYIZIAWUDBAIB
# BQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIMtvoTEX7O4jDhMZdfqR9ERu
# aM4bL5o+oTTIJBWZOiR/MEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEB
# BQAEggEAnoUSf/CeC7A/DrD6lndvBroeECTK9A0fjJ/NKk8joY9sR2uIpnnzvF2S
# k2nTikFrkICWAdCqrWzWAU0q2Amaucy1/qaOu65tvZaWmkCQcg4j6ZRAQLGeIfnH
# zOhA2cw22/PCZw4aP+7hyimYzjPqp9K3t7hzRgeJV/539XVowHM6stnyA27RRKFo
# W8sTWXtjcJJBoxFUC72A2tyBgS6Dn4w/C34UqDj4PkvYfh9aTFD5hK39g/pUhcUk
# FYVO54tdXnlll61vxkBYuu2y+Ivlqn9CeiyhYgBfYqXoYrBnTM89Ca+FlXLlGotf
# GLFfO2Xmwqe0urNEe0m1FtG3yD/Q/qGCF5cwgheTBgorBgEEAYI3AwMBMYIXgzCC
# F38GCSqGSIb3DQEHAqCCF3AwghdsAgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFSBgsq
# hkiG9w0BCRABBKCCAUEEggE9MIIBOQIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCARNobQR8vx5+nVg2CyjUD3CAYQ38KYO1JgDjkiPmDjOgIGaEtOPBRr
# GBMyMDI1MDczMDAzNTI0Ni44MDVaMASAAgH0oIHRpIHOMIHLMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1l
# cmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046RTAwMi0w
# NUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2Wg
# ghHtMIIHIDCCBQigAwIBAgITMwAAAgsRnVYpkvm/hQABAAACCzANBgkqhkiG9w0B
# AQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYD
# VQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAeFw0yNTAxMzAxOTQy
# NThaFw0yNjA0MjIxOTQyNThaMIHLMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25z
# MScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046RTAwMi0wNUUwLUQ5NDcxJTAjBgNV
# BAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2UwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQCqrPitRjAXqFh2IHzQYD3uykDPyJF+79e5CkY4aYsb
# 93QVun4fZ3Ju/0WHrtAF3JswSiAVl7p1H2zFKrvyhaVuRYcSc7YuyP0GHEVq7YVS
# 5uF3YLlLeoyGOPKSXGs6agW60CqVBhPQ+2n49e6YD9wGv6Y0HmBKmnQqY/AKJijg
# UiRulb1ovNEcTZmTNRu1mY+0JjiEus+eF66VNoBv1a2MW0JPYbFBhPzFHlddFXcj
# f2qIkb5BYWsFL7QlBjXApf2HmNrPzG36g1ybo/KnRjSgIRpHeYXxBIaCEGtR1Emp
# J90OSFHxUu7eIjVfenqnVtag0yAQY7zEWSXMN6+CHjv3SBNtm5ZIRyyCsUZG8454
# K+865bw7FwuH8vk5Q+07K5lFY02eBDw3UKzWjWvqTp2pK8MTa4kozvlKgrSGp5sh
# 57GnkjlvNvt78NXbZTVIrwS7xcIGjbvS/2r5lRDT+Q3P2tT+g6KDPdLntlcbFdHu
# uzyJyx0WfCr8zHv8wGCB3qPObRXK4opAInSQ4j5iS28KATJGwQabRueZvhvd9Od0
# wcFYOb4orUv1dD5XwFyKlGDPMcTPOQr0gxmEQVrLiJEoLyyW8EV/aDFUXToxyhfz
# WZ6Dc0l9eeth1Et2NQ3A/qBR5x33pjKdHJVJ5xpp2AI3ZzNYLDCqO1lthz1GaSz+
# PQIDAQABo4IBSTCCAUUwHQYDVR0OBBYEFGZcLIjfr+l6WeMuhE9gsxe98j/+MB8G
# A1UdIwQYMBaAFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMF8GA1UdHwRYMFYwVKBSoFCG
# Tmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUy
# MFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNybDBsBggrBgEFBQcBAQRgMF4w
# XAYIKwYBBQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2Vy
# dHMvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUyMDIwMTAoMSkuY3J0MAwG
# A1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQD
# AgeAMA0GCSqGSIb3DQEBCwUAA4ICAQCaKPVn6GLcnkbPEdM0R9q4Zm0+7JfG05+p
# mqP6nA4SwT26k9HlJQjqw/+WkiQLD4owJxooIr9MDZbiZX6ypPhF+g1P5u8BOEXP
# YYkOWpzFGLRLtlZHvfxpqAIa7mjLGHDzKr/102AXaD4mGydEwaLGhUn9DBGdMm5d
# hiisWAqb/LN4lm4OuX4YLqKcW/0yScHKgprGgLY+6pqv0zPU74j7eCr+PDTNYM8t
# FJ/btUnBNLyOE4WZwBIq4tnvXjd2cCOtgUnoQjFU1ZY7ZWdny3BJbf3hBrb3NB2I
# U4nu622tVrb1fNkwdvT501WRUBMd9oFf4xifj2j2Clbv1XGljXmd6yJjvt+bBuvJ
# LUuc9m+vMKOWyRwUdvOl/E5a8zV3MrjCnY6fIrLQNzBOZ6klICPCi+2GqbViM0CI
# 6CbZypei5Rr9hJbH8rZEzjaYWLnr/XPsU0wr2Tn6L9dJx2q/LAoK+oviAInj0aP4
# iRrMyUSO6KL2KwY6zJc6SDxbHkwYHdQRrPNP3SutMg6LgBSvtmfqwgaXIHkCoiUF
# EAz9cGIqvgjGpGppKTcTuoo3EEgp/zRd0wxW0QqmV3ygYGicen30KAWHrKFC8Sbw
# c6qC4podVZYJZmirHBP/uo7sQne5H0xtdvDmXDUfy5gNjLljQIUsJhQSyyXbSjSb
# 2a5jhOUfxzCCB3EwggVZoAMCAQICEzMAAAAVxedrngKbSZkAAAAAABUwDQYJKoZI
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
# MCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOkUwMDItMDVFMC1EOTQ3MSUwIwYDVQQD
# ExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloiMKAQEwBwYFKw4DAhoDFQCo
# QndUJN3Ppq2xh8RhtsR35NCZwaCBgzCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFBDQSAyMDEwMA0GCSqGSIb3DQEBCwUAAgUA7DO/DTAiGA8yMDI1MDcyOTIxNDM0
# MVoYDzIwMjUwNzMwMjE0MzQxWjB3MD0GCisGAQQBhFkKBAExLzAtMAoCBQDsM78N
# AgEAMAoCAQACAgy0AgH/MAcCAQACAhNPMAoCBQDsNRCNAgEAMDYGCisGAQQBhFkK
# BAIxKDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMHoSChCjAIAgEAAgMBhqAwDQYJ
# KoZIhvcNAQELBQADggEBAEMBdmS3s3lW61vZ7RgS1Yr9jhZHmNKvPjHAy+2+MaI5
# QP3sTpZPmHRHy2TfDME5WB6zquFHZFx4FKes1zcldYrwwuk0hTj2vOZbquzed0kV
# S6Rgv2B0VfC7A9//ZPR0orC+RC9eVCCepKRaWvG5/1E5g+Lff/b9hoSYzq6DrmfM
# IkWHRE9jvsjfKYgyOt9+BfxCNDgnWsOVsbrJTaPJNEYgyH2X3DqyN2szXNb7Ph1c
# rf5IaN1skcdTSQUSIX7op1UMx/+mCRuly/EdyGFrpqhiLlW/PRW+vuj0b05BA0mj
# gsoOjMrSvVfnhlS0MNpfUuUwNsBaIiXRMy9QfXk55CAxggQNMIIECQIBATCBkzB8
# MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVk
# bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1N
# aWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAgsRnVYpkvm/hQABAAAC
# CzANBglghkgBZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEE
# MC8GCSqGSIb3DQEJBDEiBCCmc1aMI5TgQn6Rs3GQc/CpMp9xR9VSXyBAMCVKFpI7
# ODCB+gYLKoZIhvcNAQkQAi8xgeowgecwgeQwgb0EIDTVdKu6N77bh0wdOyF+ogRN
# 8vKJcw5jnf2/EussYkozMIGYMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29m
# dCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENB
# IDIwMTACEzMAAAILEZ1WKZL5v4UAAQAAAgswIgQg4tqUGsV21uox/+tmN2xz4kvh
# 9Sgr0VIlGLPunSvbFYAwDQYJKoZIhvcNAQELBQAEggIAjJ95PAKFyJAib3LPG0PY
# nKvtQboCWilk3GuKwXsaokZiKBHt0TFrrgyA9IU1R13O+W07om81CTMmoiC3ZQ/6
# n8x2LAxvGvNL1IStBZxJNo1qeUibgFqx81YliN7Wya1erBhV96o/AQmZMsoEnSqw
# 80k6FNhg8Bacnejw8CMmj8QMk8BOLBSOoF4OSg/nGpr2MYeyBWu6lom4W+/QmA9B
# zBsKJfsvG0SdHQtf3lzO2OBMMbysReKP4e1gIuGZlkyL6Ai1QM17Q0vjvUFjmQ2n
# OufI1aFZ8DKRVNOv0uMPbM4FrSwZ5wI4L3UesX8q5HvUHMGnVPisLg5XJqFijbl4
# krm2lQ9lQu0GaN3O3gAoxUbD21JHiwLsjG1TW/vyZNkyVlEPyMTI688a0h/gcI4V
# I6UcwF3uFSiNwwOLGZIGRkm0BSyp8PNKow2lwQ6UOK2OjNsTCV132tLChC446Eq6
# xj/DMBCeVPsT1/2TcNxnrqtJCPiPkffGF0gypnzKhSPvd84W7WZuX5/dth80t6un
# R0lajdkU/sanY4OUgiyAGUhhlcNyKmKQiDXUIxLWAlWh4XMUYDbGMj8HoAw3x0Dt
# 9Wxfa5I+Bg3919Xks7woIboouD5SiILi4yyHo72JaRA69RwB6zuG40k+rzr7XCJ2
# mf5NcrfFWPb1Hr8Wgjn/OHY=
# SIG # End signature block
