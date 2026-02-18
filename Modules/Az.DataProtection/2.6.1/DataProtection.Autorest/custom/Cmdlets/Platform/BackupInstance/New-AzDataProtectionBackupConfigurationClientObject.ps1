
function New-AzDataProtectionBackupConfigurationClientObject{
	[OutputType('PSObject')]
    [CmdletBinding(PositionalBinding=$false)]
    [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Description('Creates new backup configuration object')]

    param(
        [Parameter(Mandatory, HelpMessage='Datasource Type')]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Support.DatasourceTypes]
        [ValidateSet('AzureKubernetesService', 'AzureBlob')]
        ${DatasourceType},
        
        [Parameter(Mandatory=$false, HelpMessage='List of resource types to be excluded from backup')]
        [System.String[]]
        ${ExcludedResourceType},

        [Parameter(Mandatory=$false, HelpMessage='List of resource types to be included for backup')]
        [System.String[]]
        ${IncludedResourceType},

        [Parameter(Mandatory=$false, HelpMessage='List of namespaces to be excluded from backup')]
        [System.String[]]
        ${ExcludedNamespace},

        [Parameter(Mandatory=$false, HelpMessage='List of namespaces to be included for backup')]
        [System.String[]]
        ${IncludedNamespace},

        [Parameter(Mandatory=$false, HelpMessage='List of labels for internal filtering for backup')]
        [System.String[]]
        ${LabelSelector},

        [Parameter(Mandatory=$false, HelpMessage='Boolean parameter to decide whether snapshot volumes are included for backup. By default this is taken as true.')]        
        [Nullable[System.Boolean]]
        ${SnapshotVolume},

        [Parameter(Mandatory=$false, HelpMessage='Boolean parameter to decide whether cluster scope resources are included for backup. By default this is taken as true.')]        
        [Nullable[System.Boolean]]
        ${IncludeClusterScopeResource},

        [Parameter(Mandatory=$false, HelpMessage='Hook reference to be executed during backup.')]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20240401.NamespacedNameResource[]]
        ${BackupHookReference},
        
        [Parameter(Mandatory=$false, HelpMessage='List of containers to be backed up inside the VaultStore. Use this parameter for DatasourceType AzureBlob.')]
        [System.String[]]
        ${VaultedBackupContainer},
        
        [Parameter(Mandatory=$false, HelpMessage='Switch parameter to include all containers to be backed up inside the VaultStore. Use this parameter for DatasourceType AzureBlob.')]
        [Switch]
        ${IncludeAllContainer},
        
        [Parameter(Mandatory=$false, HelpMessage='Storage account where the Datasource is present. Use this parameter for DatasourceType AzureBlob.')]
        [System.String]
        ${StorageAccountName},
        
        [Parameter(Mandatory=$false, HelpMessage='Storage account resource group name where the Datasource is present. Use this parameter for DatasourceType AzureBlob.')]
        [System.String]
        ${StorageAccountResourceGroupName}
    )

    process {        
        # need to have parameter validation when this command supports another DatasourceType           
        $dataSourceParam = $null

        if($DatasourceType.ToString() -eq "AzureKubernetesService"){

            # parameter validation
            if($VaultedBackupContainer -ne $null -or $IncludeAllContainer){
                $message = "Invalid parameter VaultedBackupContainer or IncludeAllContainer for given DatasourceType."
                throw $message
            }

            $dataSourceParam = [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20240401.KubernetesClusterBackupDatasourceParameters]::new()
            $dataSourceParam.ObjectType = "KubernetesClusterBackupDatasourceParameters"
        
            $dataSourceParam.ExcludedResourceType = $ExcludedResourceType
            $dataSourceParam.IncludedResourceType = $IncludedResourceType
            $dataSourceParam.ExcludedNamespace = $ExcludedNamespace
            $dataSourceParam.IncludedNamespace = $IncludedNamespace
            $dataSourceParam.LabelSelector = $LabelSelector
            $dataSourceParam.BackupHookReference = $BackupHookReference

            if ($SnapshotVolume -ne $null) {
                $dataSourceParam.SnapshotVolume = $SnapshotVolume
            }
            else{
                $dataSourceParam.SnapshotVolume = $true
            }

            if($IncludeClusterScopeResource -ne $null){
                $dataSourceParam.IncludeClusterScopeResource = $IncludeClusterScopeResource
            }
            else{
                $dataSourceParam.IncludeClusterScopeResource = $true        
            }
        }

        if($DatasourceType.ToString() -eq "AzureBlob"){
            $dataSourceParam = [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20240401.BlobBackupDatasourceParameters]::new()
            $dataSourceParam.ObjectType = "BlobBackupDatasourceParameters"
            
            if($VaultedBackupContainer -ne $null){

                # exclude containers which start with $ except $web, $root
                $unsupportedContainers = $VaultedBackupContainer | Where-Object { $_ -like '$*' -and $_ -ne "`$root" -and $_ -ne "`$web"}
                if($unsupportedContainers.Count -gt 0){
                    $message = "Following containers are not allowed for configure protection with AzureBlob - $unsupportedContainers. Please remove them and proceed."
                    throw $message
                }

                $dataSourceParam.ContainersList = $VaultedBackupContainer
            }
            elseif($IncludeAllContainer){
                if($StorageAccountName -eq $null -or $StorageAccountResourceGroupName -eq $null){
                    $message = "Please input StorageAccountName and StorageAccountResourceGroupName parameters for fetching all vaulted containers."
                    throw $message
                }

                CheckStorageModuleDependency
                $storageAccount = Get-AzStorageAccount -ResourceGroupName $StorageAccountResourceGroupName -Name $StorageAccountName 
                $containers = Get-AzStorageContainer -Context $storageAccount.Context

                # exclude containers which start with $ except $web, $root
                $allContainers = $containers.Name | Where-Object { -not($_ -like '$*' -and $_ -ne "`$root" -and $_ -ne "`$web")}
                $dataSourceParam.ContainersList = $allContainers
            }
            elseif($ExcludedResourceType -ne $null -or $IncludedResourceType -ne $null -or $ExcludedNamespace -ne $null -or $IncludedNamespace -ne $null -or $LabelSelector -ne $null -or $SnapshotVolume -ne $null -or $IncludeClusterScopeResource -ne $null){
                $message = "Invalid parameters ExcludedResourceType, IncludedResourceType, ExcludedNamespace, IncludedNamespace, LabelSelector, SnapshotVolume, IncludeClusterScopeResource for given DatasourceType."
                throw $message
            }
            else {
                 $message = "Please input VaultedBackupContainer or IncludeAllContainer parameters for given workload type."
                 throw $message
            }
        }

        $dataSourceParam
    }
}
# SIG # Begin signature block
# MIIoKgYJKoZIhvcNAQcCoIIoGzCCKBcCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCAz/vljNVQhaoz
# aLHT5bE//TAeDCvs9GYq3dOi/9E3VKCCDXYwggX0MIID3KADAgECAhMzAAAEBGx0
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
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIMn7retBgpZSYacJ8yjJdUOp
# RQoKcyPa+tVY8NLuVlcOMEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEB
# BQAEggEAVsK+MGusgGTNcGgA/fd3e4ph58SBHeHKo9v3+QqBRkNa56B1NhOMrvcW
# 3Zf5TaZdEmJ+oQhIF//gnsSuTklhucQMyPoRulvD7uyMu6B+Kessf1mg+WJaOYcw
# 9ee3Qk2oHkclu36qR/tNLCiO2t/TWadAP92MUwvJeqfhhQUd7f1anTeZ3Tt6p6ga
# RqCss0Tt8YwseapY3ia3d5m0YPBDpYq/Le2PbVYVApyNkikUK7PtpkEZnYJuai7r
# MNX+g71UfEvbnRG9U0cUJTmeYtviZFhj9cQ3mtzRhVmAm2pklc8Zknspf6yvnFA/
# m791STJ/bE1t6nBSGC3sZLJNbjKjSqGCF5QwgheQBgorBgEEAYI3AwMBMYIXgDCC
# F3wGCSqGSIb3DQEHAqCCF20wghdpAgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFSBgsq
# hkiG9w0BCRABBKCCAUEEggE9MIIBOQIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCD9bIADHo2HyRS1NS07Mqxy9UEF141YhfCQGoVod7USXQIGZ5I2MJRg
# GBMyMDI1MDIwNjAzMTkwOC4wOTNaMASAAgH0oIHRpIHOMIHLMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1l
# cmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046ODYwMy0w
# NUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2Wg
# ghHqMIIHIDCCBQigAwIBAgITMwAAAfGzRfUn6MAW1gABAAAB8TANBgkqhkiG9w0B
# AQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYD
# VQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAeFw0yMzEyMDYxODQ1
# NTVaFw0yNTAzMDUxODQ1NTVaMIHLMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25z
# MScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046ODYwMy0wNUUwLUQ5NDcxJTAjBgNV
# BAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2UwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQCxulCZttIf8X97rW9/J+Q4Vg9PiugB1ya1/DRxxLW2
# hwy4QgtU3j5fV75ZKa6XTTQhW5ClkGl6gp1nd5VBsx4Jb+oU4PsMA2foe8gP9bQN
# PVxIHMJu6TYcrrn39Hddet2xkdqUhzzySXaPFqFMk2VifEfj+HR6JheNs2LLzm8F
# DJm+pBddPDLag/R+APIWHyftq9itwM0WP5Z0dfQyI4WlVeUS+votsPbWm+RKsH4F
# QNhzb0t/D4iutcfCK3/LK+xLmS6dmAh7AMKuEUl8i2kdWBDRcc+JWa21SCefx5SP
# hJEFgYhdGPAop3G1l8T33cqrbLtcFJqww4TQiYiCkdysCcnIF0ZqSNAHcfI9SAv3
# gfkyxqQNJJ3sTsg5GPRF95mqgbfQbkFnU17iYbRIPJqwgSLhyB833ZDgmzxbKmJm
# dDabbzS0yGhngHa6+gwVaOUqcHf9w6kwxMo+OqG3QZIcwd5wHECs5rAJZ6PIyFM7
# Ad2hRUFHRTi353I7V4xEgYGuZb6qFx6Pf44i7AjXbptUolDcVzYEdgLQSWiuFajS
# 6Xg3k7Cy8TiM5HPUK9LZInloTxuULSxJmJ7nTjUjOj5xwRmC7x2S/mxql8nvHSCN
# 1OED2/wECOot6MEe9bL3nzoKwO8TNlEStq5scd25GA0gMQO+qNXV/xTDOBTJ8zBc
# GQIDAQABo4IBSTCCAUUwHQYDVR0OBBYEFLy2xe59sCE0SjycqE5Erb4YrS1gMB8G
# A1UdIwQYMBaAFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMF8GA1UdHwRYMFYwVKBSoFCG
# Tmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUy
# MFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNybDBsBggrBgEFBQcBAQRgMF4w
# XAYIKwYBBQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2Vy
# dHMvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUyMDIwMTAoMSkuY3J0MAwG
# A1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQD
# AgeAMA0GCSqGSIb3DQEBCwUAA4ICAQDhSEjSBFSCbJyl3U/QmFMW2eLPBknnlsfI
# D/7gTMvANEnhq08I9HHbbqiwqDEHSvARvKtL7j0znICYBbMrVSmvgDxU8jAGqMyi
# LoM80788So3+T6IZV//UZRJqBl4oM3bCIQgFGo0VTeQ6RzYL+t1zCUXmmpPmM4xc
# ScVFATXj5Tx7By4ShWUC7Vhm7picDiU5igGjuivRhxPvbpflbh/bsiE5tx5cuOJE
# JSG+uWcqByR7TC4cGvuavHSjk1iRXT/QjaOEeJoOnfesbOdvJrJdbm+leYLRI67N
# 3cd8B/suU21tRdgwOnTk2hOuZKs/kLwaX6NsAbUy9pKsDmTyoWnGmyTWBPiTb2rp
# 5ogo8Y8hMU1YQs7rHR5hqilEq88jF+9H8Kccb/1ismJTGnBnRMv68Ud2l5LFhOZ4
# nRtl4lHri+N1L8EBg7aE8EvPe8Ca9gz8sh2F4COTYd1PHce1ugLvvWW1+aOSpd8N
# nwEid4zgD79ZQxisJqyO4lMWMzAgEeFhUm40FshtzXudAsX5LoCil4rLbHfwYtGO
# pw9DVX3jXAV90tG9iRbcqjtt3vhW9T+L3fAZlMeraWfh7eUmPltMU8lEQOMelo/1
# ehkIGO7YZOHxUqeKpmF9QaW8LXTT090AHZ4k6g+tdpZFfCMotyG+E4XqN6ZWtKEB
# QiE3xL27BDCCB3EwggVZoAMCAQICEzMAAAAVxedrngKbSZkAAAAAABUwDQYJKoZI
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
# MCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOjg2MDMtMDVFMC1EOTQ3MSUwIwYDVQQD
# ExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloiMKAQEwBwYFKw4DAhoDFQD7
# n7Bk4gsM2tbU/i+M3BtRnLj096CBgzCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFBDQSAyMDEwMA0GCSqGSIb3DQEBCwUAAgUA605/wjAiGA8yMDI1MDIwNjAwMjQz
# NFoYDzIwMjUwMjA3MDAyNDM0WjB0MDoGCisGAQQBhFkKBAExLDAqMAoCBQDrTn/C
# AgEAMAcCAQACAha5MAcCAQACAhMkMAoCBQDrT9FCAgEAMDYGCisGAQQBhFkKBAIx
# KDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMHoSChCjAIAgEAAgMBhqAwDQYJKoZI
# hvcNAQELBQADggEBAIvZXo6WHnbF+tzopPMUm06EFXylkOcCIqJ3Mmi89NMUYOxv
# t+g06OkcdUIAaGJl97K8adSnDmz+S9XzlLQaiuWPiI7/OTuuN2DwqCXb9KxCmpDI
# /AYlgVyOfa1flV0ObPyBS72wclJBEkMOl38425rG0KHs8jr3WOE6yhVV0BzWVCra
# c2LrvKEJlq/JBGRJH2nG/x9z9M57ZALRU7YotdbcnsUIKsiKKXIB+3ZAMujfUmBS
# r0krrZtRAb4aWqtSUGgSiJpuNDEMAXmGCeEwIWiND1EeXmDjMq2aHz+JJ5r40PeD
# rnGNBQU/iCcsSWS0uqDtnlhdej1UbjSjEiUDe94xggQNMIIECQIBATCBkzB8MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNy
# b3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAfGzRfUn6MAW1gABAAAB8TAN
# BglghkgBZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMC8G
# CSqGSIb3DQEJBDEiBCCnRv600UMqMvNyOv3pz1+WX7LSY96wmAVwhwBfJUtNQTCB
# +gYLKoZIhvcNAQkQAi8xgeowgecwgeQwgb0EINV3/T5hS7ijwao466RosB7wwEib
# t0a1P5EqIwEj9hF4MIGYMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldh
# c2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBD
# b3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIw
# MTACEzMAAAHxs0X1J+jAFtYAAQAAAfEwIgQgwlqOzV2ErRIl+KifFfMkp1BOigV3
# Z1eTyzS4xV5LUvEwDQYJKoZIhvcNAQELBQAEggIAHuyZDPVhZl/EQLmUyQoDSiTy
# yhKWJL0MibOC/scf5gG23tv+8bPIvFyzQCz7gMq6+V/0s8sM4mzYvLZ3/2BeLLKN
# CKUKpIo0Df5hAQeifJ2N4NgXx4AB1VxNWvgBrdxF11ENR3gY36ZU0XK0+CuNZOER
# XueICCuariId2ELLj++OLNQTukHv/9BIweJ3c+3JQFlI0s7AnV1fGCZrzpsnIS6+
# fOUMg/kn/e8B0r/6PO6bQ5yoj6NNUNcLcmw8FcYUQLuQhz449XI2SQpIjpzsr7AJ
# aSz2nCnUDbSHqshHpjnr3G0kegt1rzgwhT0sPqc1s4fgiO5XuczUF0Xn1yJ/gbam
# 19n8HwEKbsFHxwjK05V7voA6O1CuwIiDyV6yDgNHn6bJWvkn7wKhoydv4PcRzBAB
# dDH/JT57tFC+TALBR/XfpEdq76jnb+3HXlEEvUIufs2Ad9FDouO8WNKn1gkpDPl4
# SidMKWnuLLEZ/p866UaMNMlkD3SlklJVqSoa5lrTnnNdGv7auM9QaRwCtvcgKTIz
# hG5udFViQ6lmYI0luU//5bZKCzoKM8Z913IUgurMSH8fpynH2jiMo6qHA1dp/o3L
# mhEO/9+GXIMXcwZAmFUpoatx0eQYSRWqON7GzOJgau7gGbrGQTaM+HqkCIt8r4Am
# n3OAujKYFMJIRpZKOIw=
# SIG # End signature block
