function Initialize-AzDataProtectionBackupInstance {
    [OutputType('Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20240401.IBackupInstanceResource')]
    [CmdletBinding(PositionalBinding=$false)]
    [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Description('Initializes Backup instance Request object for configuring backup')]

    param(
        [Parameter(Mandatory=$false, HelpMessage='Policy Id to be assiciated to Datasource')]
        [System.String]
        [ValidatePattern("/subscriptions/([A-z0-9\-]+)/resourceGroups/(?<rg>.+)/providers/(?<provider>.+)/backupVaults/(?<vault>.+)/backupPolicies/(?<name>.+)")]
        ${PolicyId},

        [Parameter(Mandatory=$false, HelpMessage='ID of the datasource to be protected')]
        [System.String]
        [ValidatePattern("/subscriptions/([A-z0-9\-]+)/resourceGroups/(?<rg>.+)/(?<id>.+)")]
        ${DatasourceId},

        [Parameter(Mandatory, HelpMessage='Datasource Type')]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Support.DatasourceTypes]
        ${DatasourceType},

        [Parameter(Mandatory, HelpMessage='Location of the Datasource to be protected.')]
        [System.String]
        ${DatasourceLocation},

        [Parameter(Mandatory=$false, HelpMessage='Secret uri for secret store authentication of data source. This parameter is only supported for AzureDatabaseForPostgreSQL currently.')]
        [System.String]
        ${SecretStoreURI},

        [Parameter(Mandatory=$false, HelpMessage='Secret store type for secret store authentication of data source. This parameter is only supported for AzureDatabaseForPostgreSQL currently.')]
        [ValidateSet("AzureKeyVault")]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Support.SecretStoreTypes]
        ${SecretStoreType},

        [Parameter(Mandatory=$false, HelpMessage='Sanpshot Resource Group')]
        [System.String]
        [ValidatePattern("/subscriptions/([A-z0-9\-]+)/resourceGroups/(?<rg>.+)")]
        ${SnapshotResourceGroupId},

        [Parameter(Mandatory=$false, HelpMessage='Friendly name for backup instance')]
        [System.String]
        ${FriendlyName},
                
        [Parameter(Mandatory=$false, HelpMessage='Backup configuration for backup. Use this parameter to configure protection for AzureKubernetesService,AzureBlob.')]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20240401.IBackupDatasourceParameters]
        ${BackupConfiguration},

        [Parameter(Mandatory=$false, HelpMessage='Use system assigned identity')]
        [System.Nullable[System.Boolean]]
        ${UseSystemAssignedIdentity},

        [Parameter(Mandatory=$false, HelpMessage='User assigned identity ARM Id')]
        [Alias('AssignUserIdentity')]
        [System.String]
        ${UserAssignedIdentityArmId}
    )

    process {

        $manifest = LoadManifest -DatasourceType $DatasourceType.ToString()
        $backupInstance = [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20240401.BackupInstance]::new()
        $backupInstance.ObjectType = "BackupInstance"

        if($manifest.snapshotRGPermissions.Length -eq 0 -and $SnapshotResourceGroupId -ne "")
        {
            $errormsg = "Snapshot Resource Group Id parameter is invalid for this resource"
            throw $errormsg
        }

        # can make DatasourceId a mandatory param
        if($PSBoundParameters.ContainsKey("DatasourceId"))
        {
            $backupInstance.DataSourceInfo = GetDatasourceInfo -ResourceId $DatasourceId -ResourceLocation $DatasourceLocation -DatasourceType $DatasourceType

            if($manifest.isProxyResource -eq $true)
            {
                $backupInstance.DataSourceSetInfo = GetDatasourceSetInfo -DatasourceInfo $backupInstance.DataSourceInfo -DatasourceType $DatasourceType
            }

            if(-not($manifest.friendlyNameRequired) -and -not($manifest.customFriendlyNameAllowed) -and $FriendlyName -ne ""){
                $errormsg = "FriendlyName parameter is not expected for the given DatasourceType"
                throw $errormsg
            }

            if($manifest.customFriendlyNameAllowed -and $FriendlyName -ne ""){
                $backupInstance.FriendlyName = $FriendlyName
            }
            elseif($backupInstance.DataSourceSetInfo.ResourceId -eq $null -or $manifest.customFriendlyNameAllowed){
                $backupInstance.FriendlyName = $backupInstance.DataSourceInfo.ResourceName
            }
            elseif($manifest.friendlyNameRequired){
                if($FriendlyName -eq ""){
                    $errormsg = "FriendlyName parameter is required for the given DatasourceType"
                    throw $errormsg
                }

                $backupInstance.FriendlyName = $backupInstance.DataSourceSetInfo.ResourceName + "\" + $FriendlyName
            }
            else{
                $backupInstance.FriendlyName = $backupInstance.DataSourceSetInfo.ResourceName + "\" + $backupInstance.DataSourceInfo.ResourceName
            }            
        }

        if($PSBoundParameters.ContainsKey("PolicyId"))
        {
            $backupInstance.PolicyInfo.PolicyId = $PolicyId
        }

        $hasUseSystemAssignedIdentity = $PSBoundParameters.Remove("UseSystemAssignedIdentity")
        $hasUserAssignedIdentityArmId = $PSBoundParameters.Remove("UserAssignedIdentityArmId")
        if ($hasUseSystemAssignedIdentity -or $hasUserAssignedIdentityArmId) {
            
            if ($hasUserAssignedIdentityArmId -and (!$hasUseSystemAssignedIdentity -or $UseSystemAssignedIdentity)) {
                throw "UserAssignedIdentityArmId cannot be provided without UseSystemAssignedIdentity and UseSystemAssignedIdentity must be false when UserAssignedIdentityArmId is provided."
            }
            
            $backupInstance.IdentityDetail = [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20240401.IdentityDetails]::new()
            $backupInstance.IdentityDetail.UseSystemAssignedIdentity = $UseSystemAssignedIdentity            

            if ($hasUserAssignedIdentityArmId) {
                $instance.Property.IdentityDetail.UserAssignedIdentityArmUrl = $UserAssignedIdentityArmId
            }
        }

        # secret store authentication
        if($PSBoundParameters.ContainsKey("SecretStoreURI"))
        {            
            if($manifest.supportSecretStoreAuthentication -eq $true){

                if(!($PSBoundParameters.ContainsKey("SecretStoreType")))
                {        
                    $errormsg = "Please input SecretStoreType"
        		    throw $errormsg                    
                }
                $backupInstance.DatasourceAuthCredentials = [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20240401.SecretStoreBasedAuthCredentials]::new()
                $backupInstance.DatasourceAuthCredentials.ObjectType = "SecretStoreBasedAuthCredentials"
                $backupInstance.DatasourceAuthCredentials.SecretStoreResource =  [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20240401.SecretStoreResource]::new()
                $backupInstance.DatasourceAuthCredentials.SecretStoreResource.SecretStoreType = $SecretStoreType
                $backupInstance.DatasourceAuthCredentials.SecretStoreResource.Uri = $SecretStoreURI
            }
            else{
                $errormsg = "Please ensure that secret store based authentication is supported for given data source"
        		throw $errormsg
            }
        }

        $backupInstanceResource = [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20240401.BackupInstanceResource]::new()
        $backupInstanceResource.Property = $backupInstance

        if($PSBoundParameters.ContainsKey("DatasourceId"))
        {
            $guid = (New-Guid).Guid
            $name = ""
            if($backupInstance.DataSourceSetInfo.ResourceId -eq $null){
                $name = $backupInstance.DataSourceInfo.ResourceName + "-" + $backupInstance.DatasourceInfo.ResourceName + "-" + $guid
            } else {
                $name = $backupInstance.DataSourceSetInfo.ResourceName + "-" + $backupInstance.DatasourceInfo.ResourceName + "-" + $guid
            }

            $backupInstanceResource.BackupInstanceName = $name
        }

        if($manifest.addDataStoreParametersList -eq $true)
        {
            $operationalParam = [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20240401.AzureOperationalStoreParameters]::new()
            $operationalParam.DataStoreType = "OperationalStore"
            $operationalParam.ObjectType = "AzureOperationalStoreParameters"
            $operationalParam.ResourceGroupId = "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}"
            $backupInstanceResource.Property.PolicyInfo.PolicyParameter.DataStoreParametersList += @($operationalParam)
            $backupInstanceResource.Property.PolicyInfo.PolicyParameter.DataStoreParametersList[0].ResourceGroupId = $SnapshotResourceGroupId
        }

        if($manifest.addBackupDatasourceParametersList -eq $true)
        {   
            if($BackupConfiguration -eq $null -and $manifest.backupConfigurationRequired -eq $true){                
                $errormsg = "Please input parameter BackupConfiguration for given DatasourceType. Use command New-AzDataProtectionBackupConfigurationClientObject for creating the BackupConfiguration."
    		    throw $errormsg
            }

            if($BackupConfiguration -ne $null){
                $backupInstanceResource.Property.PolicyInfo.PolicyParameter.BackupDatasourceParametersList += @($BackupConfiguration)
            }
        }
        elseif($ExcludedResourceType -ne $null -or $IncludedResourceType -ne $null -or $ExcludedNamespace -ne $null -or $IncludedNamespace -ne $null -or $LabelSelector -ne $null -or $SnapshotVolume -ne $null -or $IncludeClusterScopeResource -ne $null){
            $errormsg = "ExcludedResourceType, IncludedResourceType, ExcludedNamespace, IncludedNamespace, LabelSelector, SnapshotVolume, IncludeClusterScopeResource parameters are not applicable for given DatasourceType. Please ensure to remove them"
            throw $errormsg
        }

        return $backupInstanceResource
    }
}
# SIG # Begin signature block
# MIIoKgYJKoZIhvcNAQcCoIIoGzCCKBcCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDJasYmLYS9ugQG
# NC6qKf6GSpdKx1mkntnDZaeoNlXqCaCCDXYwggX0MIID3KADAgECAhMzAAAEBGx0
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
# /Xmfwb1tbWrJUnMTDXpQzTGCGgowghoGAgEBMIGVMH4xCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNp
# Z25pbmcgUENBIDIwMTECEzMAAAQEbHQG/1crJ3IAAAAABAQwDQYJYIZIAWUDBAIB
# BQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIIs/vO/6arJbp5JQvFpi3wA0
# b1HXLLGWqXQhME1BseeUMEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEB
# BQAEggEAiMOUPfuZNS2hp/RTUHXOOmjqrZpf+FqeQRtrFdh1BDRAIBQTuCCqKsiG
# 6krZmRDi39+ajxnfRua7MX4OMOIXNzenkeL97YSYguaGDHfQk+F/NNYHCWr2NHAl
# vAmeMfyCw4ju9osS9rbDnFYmU1j2+uik9vaEy0jX/MBlLUscU6BjPdDxsbT1kaVR
# 4an+Pq6nf0/E6LyDfAHboVwcaSOJr5xy38SK7TRp9k+VN7KeLlUK/WHhcuUOUnCu
# UTpkiBKXAmgoWUa1e4njQyA/PoXfaboh+TfsZbjJ2T+KGVukXsDtuGMgopy821W/
# 99/2F7fMyJSdC7xxhAxmQziNz5UcHaGCF5QwgheQBgorBgEEAYI3AwMBMYIXgDCC
# F3wGCSqGSIb3DQEHAqCCF20wghdpAgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFSBgsq
# hkiG9w0BCRABBKCCAUEEggE9MIIBOQIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCDrzdfzzbNmuETVc+QEbUMto9/wl/rW1gd2o1NjVL+NGwIGZ5Is8/n7
# GBMyMDI1MDIwNjAzMTkwOC4zOTdaMASAAgH0oIHRpIHOMIHLMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1l
# cmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046RTAwMi0w
# NUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2Wg
# ghHqMIIHIDCCBQigAwIBAgITMwAAAe4F0wIwspqdpwABAAAB7jANBgkqhkiG9w0B
# AQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYD
# VQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAeFw0yMzEyMDYxODQ1
# NDRaFw0yNTAzMDUxODQ1NDRaMIHLMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25z
# MScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046RTAwMi0wNUUwLUQ5NDcxJTAjBgNV
# BAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2UwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQC+8byl16KEia8xKS4vVL7REOOR7LzYCLXEtWgeqyOV
# lrzuEz+AoCa4tBGESjbHTXECeMOwP9TPeKaKalfTU5XSGjpJhpGx59fxMJoTYWPz
# zD0O2RAlyBmOBBmiLDXRDQJL1RtuAjvCiLulVQeiPI8V7+HhTR391TbC1beSxwXf
# dKJqY1onjDawqDJAmtwsA/gmqXgHwF9fZWcwKSuXiZBTbU5fcm3bhhlRNw5d04Ld
# 15ZWzVl/VDp/iRerGo2Is/0Wwn/a3eGOdHrvfwIbfk6lVqwbNQE11Oedn2uvRjKW
# EwerXL70OuDZ8vLzxry0yEdvQ8ky+Vfq8mfEXS907Y7rN/HYX6cCsC2soyXG3OwC
# tLA7o0/+kKJZuOrD5HUrSz3kfqgDlmWy67z8ZZPjkiDC1dYW1jN77t5iSl5Wp1HK
# Bp7JU8RiRI+vY2i1cb5X2REkw3WrNW/jbofXEs9t4bgd+yU8sgKn9MtVnQ65s6QG
# 72M/yaUZG2HMI31tm9mooH29vPBO9jDMOIu0LwzUTkIWflgd/vEWfTNcPWEQj7fs
# WuSoVuJ3uBqwNmRSpmQDzSfMaIzuys0pvV1jFWqtqwwCcaY/WXsb/axkxB/zCTdH
# SBUJ8Tm3i4PM9skiunXY+cSqH58jWkpHbbLA3Ofss7e+JbMjKmTdcjmSkb5oN8qU
# 1wIDAQABo4IBSTCCAUUwHQYDVR0OBBYEFBCIzT8a2dwgnr37xd+2v1/cdqYIMB8G
# A1UdIwQYMBaAFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMF8GA1UdHwRYMFYwVKBSoFCG
# Tmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUy
# MFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNybDBsBggrBgEFBQcBAQRgMF4w
# XAYIKwYBBQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2Vy
# dHMvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUyMDIwMTAoMSkuY3J0MAwG
# A1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQD
# AgeAMA0GCSqGSIb3DQEBCwUAA4ICAQB3ZyAva2EKOWSVpBnYkzX8f8GZjaOs577F
# 9o14Anh9lKy6tS34wXoPXEyQp1v1iI7rJzZVG7rpUznay2n9csfn3p6y7kYkHqtS
# ugCGmTiiBkwhFfSByKPI08MklgvJvKTZb673yGfpFwPjQwZeI6EPj/OAtpYkT7IU
# XqMki1CRMJKgeY4wURCccIujdWRkoVv4J3q/87KE0qPQmAR9fqMNxjI3ZClVxA4w
# iM3tNVlRbF9SgpOnjVo3P/I5p8Jd41hNSVCx/8j3qM7aLSKtDzOEUNs+ZtjhznmZ
# gUd7/AWHDhwBHdL57TI9h7niZkfOZOXncYsKxG4gryTshU6G6sAYpbqdME/+/g1u
# er7VGIHUtLq3W0Anm8lAfS9PqthskZt54JF28CHdsFq/7XVBtFlxL/KgcQylJNni
# a+anixUG60yUDt3FMGSJI34xG9NHsz3BpqSWueGtJhQ5ZN0K8ju0vNVgF+Dv05si
# rPg0ftSKf9FVECp93o8ogF48jh8CT/B32lz1D6Truk4Ezcw7E1OhtOMf7DHgPMWf
# 6WOdYnf+HaSJx7ZTXCJsW5oOkM0sLitxBpSpGcj2YjnNznCpsEPZat0h+6d7ulRa
# WR5RHAUyFFQ9jRa7KWaNGdELTs+nHSlYjYeQpK5QSXjigdKlLQPBlX+9zOoGAJho
# Zfrpjq4nQDCCB3EwggVZoAMCAQICEzMAAAAVxedrngKbSZkAAAAAABUwDQYJKoZI
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
# MCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOkUwMDItMDVFMC1EOTQ3MSUwIwYDVQQD
# ExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloiMKAQEwBwYFKw4DAhoDFQCI
# o6bVNvflFxbUWCDQ3YYKy6O+k6CBgzCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFBDQSAyMDEwMA0GCSqGSIb3DQEBCwUAAgUA6052hjAiGA8yMDI1MDIwNTIzNDUx
# MFoYDzIwMjUwMjA2MjM0NTEwWjB0MDoGCisGAQQBhFkKBAExLDAqMAoCBQDrTnaG
# AgEAMAcCAQACAgwzMAcCAQACAhK4MAoCBQDrT8gGAgEAMDYGCisGAQQBhFkKBAIx
# KDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMHoSChCjAIAgEAAgMBhqAwDQYJKoZI
# hvcNAQELBQADggEBAIblTVECT/nLCAfhw91VoU5j+vIYatAKWglJs0su+32GCNhR
# 1kJBwFFgzi08j+TkByxVmif5kGgDXApSYtqD6sFhjXVNp7Mh8HU9AJpP78pleKLE
# EBVtJsh8NKrdvAXD4ppglC7wUHrVK2rLYT5F4TO4n0fUt+p9N9ncgYPFx4hwg9ta
# MEOWs67IjOHg+FClchPXr4kuCWFg3jlyYuyA2V8vIqkYwZTMIOLLQYp20WzZHPYv
# RNu0zB9pn3N9DgMZGbpMz5xQKNIuFqVjE3m7QSgbRbcs/miaZG8qtqbFqYH1obon
# oqWbQBuUlcKMF+xKkyK8ETIGcizupIv4QMPTUCAxggQNMIIECQIBATCBkzB8MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNy
# b3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAe4F0wIwspqdpwABAAAB7jAN
# BglghkgBZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMC8G
# CSqGSIb3DQEJBDEiBCAXVxxMlESKA1zYIkHholbEN4gIId5+j4U5vD5KTkPhZTCB
# +gYLKoZIhvcNAQkQAi8xgeowgecwgeQwgb0EIE9QdxSVhfq+Vdf+DPs+5EIkBz9o
# CS/OQflHkVRhfjAhMIGYMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldh
# c2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBD
# b3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIw
# MTACEzMAAAHuBdMCMLKanacAAQAAAe4wIgQg8Uvl9NInaqH9SBmKNt5lTWoQS+4d
# z8VlHQqved6DU+gwDQYJKoZIhvcNAQELBQAEggIAGBB/8e8/abZTeQpSYUm1g9z5
# D61DRQSUoHMRLC5OBlzSAJ6GH4RfvlOIe7lNXcVIeXzOZEauRZ5/6bztfDdzjaFd
# fSp6Lc7qsttfyTVEyDEul+8SvjCBuk9h2XACQ1f1lFlS+ZnMqoOiMhpK1LN37ISy
# R8DVSC3a7OOZUW6kKaGqkFeUB6ROnGuVLmQV//zkFAXYQWq7M2WvuK1FhEo6YZ3X
# 55AhDJ7CUoa4MMYUmrystOqnEfaERnrhVgNqWj3MS3TwnkBbf91AuA4/8oyBexsq
# /vjlYk6alYyRW42+auAB/E5S2vhJoWSrwW2F6/OPDpaAac7zZI5OBlJqpi+CNHKm
# 9RynuqojQ9SP5/rorSJ2pq7D2vuSGI8xFS8tRkjFN2DOqEK9IVsV3A0r4n6Rv5GX
# HEYZ2mbIQ/RknD+xw0xn70E7zwKpi5aueXeIJCFO6bmzRYCXC6Y25eMOlGeIV+sq
# 6Q6j5QY8r3kxHqMDeBQBvxnoz4HrusoeZtGLRT6rx0ovBbCsajKBtcF33B6A39EU
# gt76G2UfiN806SzXiecMBolvXExXY01akAKRp3fgev1JfoVcPZSJWeFRi6L2wmaN
# 3Kd5gZzxInUY+ZeNusRxVJ6620ELLneKS9k4Zgf2TLZrvTzG1BQBcfgwpm/mVqXI
# tu9obBzWvttfvnjFsJQ=
# SIG # End signature block
