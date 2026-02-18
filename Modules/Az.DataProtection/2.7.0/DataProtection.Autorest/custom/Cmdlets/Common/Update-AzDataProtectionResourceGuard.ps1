

function Update-AzDataProtectionResourceGuard
{   
	[OutputType('Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api202501.IResourceGuardResource')]
    [CmdletBinding(PositionalBinding=$false, SupportsShouldProcess)]
    [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Description('Updates a resource guard belonging to a resource group')]

    param(
        [Parameter(ParameterSetName="UpdateResourceGuardOperations", Mandatory=$false, HelpMessage='Subscription Id of the resource guard')]
        [System.String]
        ${SubscriptionId},

        [Parameter(ParameterSetName="UpdateResourceGuardOperations", Mandatory, HelpMessage='Resource Group name of the resource guard')]
        [System.String]
        ${ResourceGroupName},

        [Parameter(ParameterSetName="UpdateResourceGuardOperations", Mandatory, HelpMessage='Name of the resource guard')]
        [System.String]
        ${Name},

        [Parameter(ParameterSetName="UpdateResourceGuardOperations", Mandatory=$false, HelpMessage='Optional ETag')]
        [System.String]
        ${ETag},

        [Parameter(ParameterSetName="UpdateResourceGuardOperations", Mandatory=$false, HelpMessage='This parameter is no longer in use and will be depricated')]
        [System.String]
        ${IdentityType},
        
        [Parameter(ParameterSetName="UpdateResourceGuardOperations", Mandatory=$false, HelpMessage='Resource tags')]        
        [Hashtable]
        ${Tag},

        [Parameter(ParameterSetName="UpdateResourceGuardOperations", Mandatory=$false, HelpMessage='List of critical operations which are not protected by this resourceGuard. Supported values are DeleteProtection, UpdateProtection, UpdatePolicy, GetSecurityPin, DeleteBackupInstance, RecoveryServicesDisableImmutability, DataProtectionDisableImmutability, RecoveryServicesModifyEncryptionSettings, DataProtectionModifyEncryptionSettings')]
        [System.String[]]
        ${CriticalOperationExclusionList},
        
        [Parameter()]
        [Alias('AzureRMContext', 'AzureCredential')]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        # The credentials, account, tenant, and subscription used for communication with Azure.
        ${DefaultProfile},
    
        [Parameter(DontShow)]
        [System.Management.Automation.SwitchParameter]
        # Wait for .NET debugger to attach
        ${Break},
    
        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Runtime.SendAsyncStep[]]
        # SendAsync Pipeline Steps to be appended to the front of the pipeline
        ${HttpPipelineAppend},
    
        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Runtime.SendAsyncStep[]]
        # SendAsync Pipeline Steps to be prepended to the front of the pipeline
        ${HttpPipelinePrepend},
    
        [Parameter(DontShow)]
        [System.Uri]
        # The URI for the proxy server to use
        ${Proxy},
            
        [Parameter(DontShow)]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        # Credentials for a proxy server to use for the remote call
        ${ProxyCredential},
    
        [Parameter(DontShow)]
        [System.Management.Automation.SwitchParameter]
        # Use the default credentials for the proxy
        ${ProxyUseDefaultCredentials}
    )

    process
    {
        $ResGuard = $null
        if($SubscriptionId -ne $null){
            $ResGuard = Get-AzDataProtectionResourceGuard -Name $Name -ResourceGroupName $ResourceGroupName -SubscriptionId $SubscriptionId
        }
        else {
            $ResGuard = Get-AzDataProtectionResourceGuard -Name $Name -ResourceGroupName $ResourceGroupName
        }       
        
        # modify Critical operation exclusion list 
        $CriticalOperationsMap = @{ DeleteProtection = "Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems/delete"; UpdateProtection = "Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems/write"; UpdatePolicy = "Microsoft.RecoveryServices/vaults/backupPolicies/write"; GetSecurityPin = "Microsoft.RecoveryServices/vaults/backupSecurityPIN/action"; DeleteBackupInstance = "Microsoft.DataProtection/backupVaults/backupInstances/delete"; RecoveryServicesDisableImmutability = "Microsoft.RecoveryServices/vaults/write#reduceImmutabilityState"; DataProtectionDisableImmutability = "Microsoft.DataProtection/backupVaults/write#reduceImmutabilityState"; RecoveryServicesModifyEncryptionSettings = "Microsoft.RecoveryServices/vaults/write#modifyEncryptionSettings"; DataProtectionModifyEncryptionSettings = "Microsoft.DataProtection/backupVaults/write#modifyEncryptionSettings"}
       
        $CriticalOperationExclusionListInternal = [System.Collections.ArrayList]@()

        foreach($item in $CriticalOperationExclusionList)
        {
            if($CriticalOperationsMap.ContainsKey($item)){
                $arrayIndex = $CriticalOperationExclusionListInternal.Add($CriticalOperationsMap[$item])
            }
            else {
                $arrayIndex = $CriticalOperationExclusionListInternal.Add($item)
            }
        }

        if($PSBoundParameters.ContainsKey("CriticalOperationExclusionList"))
        {
            $null = $PSBoundParameters.Remove("CriticalOperationExclusionList")
            $null = $PSBoundParameters.Add("CriticalOperationExclusionList", $CriticalOperationExclusionListInternal)
        }

        # Add Location
        $null = $PSBoundParameters.Add("Location", $ResGuard.Location)
        
        if($PSBoundParameters.ContainsKey("IdentityType"))
        {
            $null = $PSBoundParameters.Remove("IdentityType")
            # TODO : need to move this to parameter level 
            Write-Warning "Parameter IdentityType is no longer in use and will be depricated in upcoming breaking change release"
        }

        Az.DataProtection.Internal\New-AzDataProtectionResourceGuard @PSBoundParameters
    }
}
# SIG # Begin signature block
# MIIoLAYJKoZIhvcNAQcCoIIoHTCCKBkCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCA+k+9UncmO5edC
# k2/M9Uz+tvqSNK9hFAakILBNndi6taCCDXYwggX0MIID3KADAgECAhMzAAAEBGx0
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
# /Xmfwb1tbWrJUnMTDXpQzTGCGgwwghoIAgEBMIGVMH4xCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNp
# Z25pbmcgUENBIDIwMTECEzMAAAQEbHQG/1crJ3IAAAAABAQwDQYJYIZIAWUDBAIB
# BQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIHGD8aEziS0w1FXySU9k/kz4
# oNnvoSatRiriw7WrWl7uMEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEB
# BQAEggEASFPyyvLX50U6oiJqjNCaN5NjI//VshAcnynR2SMcSNxdT1LOaJSCXvWI
# a9orqWKuy2X0om89FL3E+7KyZcps3kzk99tt8+BGRMeE7mT+OGStoeLX6XRyZYDE
# TSwmeKQFz9GRJ0KhkMpBDV//SQB8F7r8JZfUVpFgQhkfHPSuFWrYm4SaC/hmNIwz
# vKwsJdtkkmlSTgM3xBe8T10kHCVGeCG9wdREZf0/a0qzdeRxPiT602YFPElS321S
# dvhQRSFTayUDKToUldSiON2MuwyR1jYymyEAczDmUqZvGuBb1NL7r82Sy5skmQJp
# uUjH/1GIX7/7LIQGYJ2Kx2ApmL1YR6GCF5YwgheSBgorBgEEAYI3AwMBMYIXgjCC
# F34GCSqGSIb3DQEHAqCCF28wghdrAgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFRBgsq
# hkiG9w0BCRABBKCCAUAEggE8MIIBOAIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCDqe5xWGyJN1TqX5Oet+ANBzq69ZU9G7ChU563SCLo4kAIGZ/fWlH2G
# GBIyMDI1MDQzMDAyMjkwMy4xMVowBIACAfSggdGkgc4wgcsxCzAJBgNVBAYTAlVT
# MRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQK
# ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJTAjBgNVBAsTHE1pY3Jvc29mdCBBbWVy
# aWNhIE9wZXJhdGlvbnMxJzAlBgNVBAsTHm5TaGllbGQgVFNTIEVTTjpBMDAwLTA1
# RTAtRDk0NzElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2VydmljZaCC
# Ee0wggcgMIIFCKADAgECAhMzAAACCHidWF2Sx9lSAAEAAAIIMA0GCSqGSIb3DQEB
# CwUAMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQH
# EwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNV
# BAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwMB4XDTI1MDEzMDE5NDI1
# M1oXDTI2MDQyMjE5NDI1M1owgcsxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNo
# aW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29y
# cG9yYXRpb24xJTAjBgNVBAsTHE1pY3Jvc29mdCBBbWVyaWNhIE9wZXJhdGlvbnMx
# JzAlBgNVBAsTHm5TaGllbGQgVFNTIEVTTjpBMDAwLTA1RTAtRDk0NzElMCMGA1UE
# AxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2VydmljZTCCAiIwDQYJKoZIhvcNAQEB
# BQADggIPADCCAgoCggIBALXLcAjmUjPcinWcrkExRRsZGyNKcLP9UazffO9jQ16y
# Gw+B+V3f9nf/d1LxYoEuUOWiyZck5mUVKI1dR3oNMnED2KT9lsJ1YnvwsqNs3e0W
# RfZzpFGlEykDyyr+gFtGvI/dzxD+DGkkAocfPxy5Kft7B8IvOc2bGqWJOTdDkser
# PY+N5goP91sowFPZMABYC+6bjP8dcgnq0V0ag1XhZRFmzAJK3pE7BqpDWgBga8Sd
# 0f4NdmrX5seyC9w80J1NIilahtCIlL9QouJHTYo0KoHgj3JqMVNKWcwgQzP82Lnf
# ygYjrimFy82lR7b6popYdnx3hPUqCG9GZJIXhgXkM0QlvFoJTCzLudQuawWdNo6N
# U6hMVZZ9Ze8G44qQFxApYYq+uSL3vqPjH7l7MA/fp+re7p0dElMtkC7h0S46ihTf
# 6Qxmv5EFhaNMdAIpX7JnVJPR4aRsdegDaXLJEOU2MFByh5kjFYJm2z93f6d/WOJI
# s3p/rB0dpTPQAPA5ND9oSjUgLzl4V4+/IgprEUmQZTYyprpfOreoKrm2iQge2OGi
# CysSB8MpN4VdO12GXUg+0twJ8xxY4YYBeixVRTsb3jwXpb3rjbh/ZUcPwvcWjIAj
# 36vjPIhBSaqIRLO5BZ5alNOMVjAKaBdoY65INXxw05VAHog/M+d5mFVOPDFsBmVp
# AgMBAAGjggFJMIIBRTAdBgNVHQ4EFgQUozHi986pxROBg5UH1/Xz+aF6AU0wHwYD
# VR0jBBgwFoAUn6cVXQBeYl2D9OXSZacbUzUZ6XIwXwYDVR0fBFgwVjBUoFKgUIZO
# aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jcmwvTWljcm9zb2Z0JTIw
# VGltZS1TdGFtcCUyMFBDQSUyMDIwMTAoMSkuY3JsMGwGCCsGAQUFBwEBBGAwXjBc
# BggrBgEFBQcwAoZQaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jZXJ0
# cy9NaWNyb3NvZnQlMjBUaW1lLVN0YW1wJTIwUENBJTIwMjAxMCgxKS5jcnQwDAYD
# VR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAOBgNVHQ8BAf8EBAMC
# B4AwDQYJKoZIhvcNAQELBQADggIBAFGzMokrAB+zCp1pA8WJpgH9k0BhYNrTjRdN
# xCwJoK5rmewbUiyVhpKkfuaJMuvp5ASpdzNmip45r/G8OcwaJ8Y11rQIdtDC2mci
# Gy62so7aOGMRobCUmA4yqXbWvsiTpecHNrR7eEE67hQGQyX8sRf4BRG3uLv5FM2w
# Y3Rxc/A9JtMUT73PtZqAZtj2nBSj83GQYmx6oYJD/0rZUxTvhvDl7v7wgZSEzbGy
# kk+qdJ4c+FiZwHRZyU7FxUh+P9m5C/Cis9tMQRgNULNI3ftzTIKE8xjsUn4cYUE0
# nHB3mUoivsZh+rxrSA6ILaWMZiVziu3hwJ53VcqDzd/SX1pRWKZYFhe1815uGl+v
# otzeMPw2CysOHO3RaCch2dNkKLuPGOwgGKUf32ljn+HptBwsor8TooI/0TVg3vx8
# to5eRczI7rEuu9Bn64JKLWF1O58ULuhIH8JTlFt8hUdcbSPWjafW2d7h4Js18qpQ
# 9MTfW01tYFHbdiLLSveRCYd5gTUYtsvinCSepqKnUFGfpYhQwm2CdxrAQ3fd/wBg
# Znhrc2ceinMZVXqd598ZVqDhN27L6jLVgX6yEKGhd0yp+E9YWkd7e4kZPgYkSI2z
# j7bxr/AdS4X5pFpHRw3k/teU7BTXfrSJQIm1B28pBo0DAYjb0o7BLdAauJH0XaM4
# Y9QCWl4TMIIHcTCCBVmgAwIBAgITMwAAABXF52ueAptJmQAAAAAAFTANBgkqhkiG
# 9w0BAQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAO
# BgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEy
# MDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5IDIw
# MTAwHhcNMjEwOTMwMTgyMjI1WhcNMzAwOTMwMTgzMjI1WjB8MQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGlt
# ZS1TdGFtcCBQQ0EgMjAxMDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIB
# AOThpkzntHIhC3miy9ckeb0O1YLT/e6cBwfSqWxOdcjKNVf2AX9sSuDivbk+F2Az
# /1xPx2b3lVNxWuJ+Slr+uDZnhUYjDLWNE893MsAQGOhgfWpSg0S3po5GawcU88V2
# 9YZQ3MFEyHFcUTE3oAo4bo3t1w/YJlN8OWECesSq/XJprx2rrPY2vjUmZNqYO7oa
# ezOtgFt+jBAcnVL+tuhiJdxqD89d9P6OU8/W7IVWTe/dvI2k45GPsjksUZzpcGkN
# yjYtcI4xyDUoveO0hyTD4MmPfrVUj9z6BVWYbWg7mka97aSueik3rMvrg0XnRm7K
# MtXAhjBcTyziYrLNueKNiOSWrAFKu75xqRdbZ2De+JKRHh09/SDPc31BmkZ1zcRf
# NN0Sidb9pSB9fvzZnkXftnIv231fgLrbqn427DZM9ituqBJR6L8FA6PRc6ZNN3SU
# HDSCD/AQ8rdHGO2n6Jl8P0zbr17C89XYcz1DTsEzOUyOArxCaC4Q6oRRRuLRvWoY
# WmEBc8pnol7XKHYC4jMYctenIPDC+hIK12NvDMk2ZItboKaDIV1fMHSRlJTYuVD5
# C4lh8zYGNRiER9vcG9H9stQcxWv2XFJRXRLbJbqvUAV6bMURHXLvjflSxIUXk8A8
# FdsaN8cIFRg/eKtFtvUeh17aj54WcmnGrnu3tz5q4i6tAgMBAAGjggHdMIIB2TAS
# BgkrBgEEAYI3FQEEBQIDAQABMCMGCSsGAQQBgjcVAgQWBBQqp1L+ZMSavoKRPEY1
# Kc8Q/y8E7jAdBgNVHQ4EFgQUn6cVXQBeYl2D9OXSZacbUzUZ6XIwXAYDVR0gBFUw
# UzBRBgwrBgEEAYI3TIN9AQEwQTA/BggrBgEFBQcCARYzaHR0cDovL3d3dy5taWNy
# b3NvZnQuY29tL3BraW9wcy9Eb2NzL1JlcG9zaXRvcnkuaHRtMBMGA1UdJQQMMAoG
# CCsGAQUFBwMIMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIAQwBBMAsGA1UdDwQEAwIB
# hjAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQYMBaAFNX2VsuP6KJcYmjRPZSQW9fO
# mhjEMFYGA1UdHwRPME0wS6BJoEeGRWh0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9w
# a2kvY3JsL3Byb2R1Y3RzL01pY1Jvb0NlckF1dF8yMDEwLTA2LTIzLmNybDBaBggr
# BgEFBQcBAQROMEwwSgYIKwYBBQUHMAKGPmh0dHA6Ly93d3cubWljcm9zb2Z0LmNv
# bS9wa2kvY2VydHMvTWljUm9vQ2VyQXV0XzIwMTAtMDYtMjMuY3J0MA0GCSqGSIb3
# DQEBCwUAA4ICAQCdVX38Kq3hLB9nATEkW+Geckv8qW/qXBS2Pk5HZHixBpOXPTEz
# tTnXwnE2P9pkbHzQdTltuw8x5MKP+2zRoZQYIu7pZmc6U03dmLq2HnjYNi6cqYJW
# AAOwBb6J6Gngugnue99qb74py27YP0h1AdkY3m2CDPVtI1TkeFN1JFe53Z/zjj3G
# 82jfZfakVqr3lbYoVSfQJL1AoL8ZthISEV09J+BAljis9/kpicO8F7BUhUKz/Aye
# ixmJ5/ALaoHCgRlCGVJ1ijbCHcNhcy4sa3tuPywJeBTpkbKpW99Jo3QMvOyRgNI9
# 5ko+ZjtPu4b6MhrZlvSP9pEB9s7GdP32THJvEKt1MMU0sHrYUP4KWN1APMdUbZ1j
# dEgssU5HLcEUBHG/ZPkkvnNtyo4JvbMBV0lUZNlz138eW0QBjloZkWsNn6Qo3GcZ
# KCS6OEuabvshVGtqRRFHqfG3rsjoiV5PndLQTHa1V1QJsWkBRH58oWFsc/4Ku+xB
# Zj1p/cvBQUl+fpO+y/g75LcVv7TOPqUxUYS8vwLBgqJ7Fx0ViY1w/ue10CgaiQuP
# Ntq6TPmb/wrpNPgkNWcr4A245oyZ1uEi6vAnQj0llOZ0dFtq0Z4+7X6gMTN9vMvp
# e784cETRkPHIqzqKOghif9lwY1NNje6CbaUFEMFxBmoQtB1VM1izoXBm8qGCA1Aw
# ggI4AgEBMIH5oYHRpIHOMIHLMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
# Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBv
# cmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25zMScw
# JQYDVQQLEx5uU2hpZWxkIFRTUyBFU046QTAwMC0wNUUwLUQ5NDcxJTAjBgNVBAMT
# HE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2WiIwoBATAHBgUrDgMCGgMVAI2S
# +7Q0pxKN1grKuEllyzJc5RM0oIGDMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAg
# UENBIDIwMTAwDQYJKoZIhvcNAQELBQACBQDrvAimMCIYDzIwMjUwNDMwMDIyNTQy
# WhgPMjAyNTA1MDEwMjI1NDJaMHcwPQYKKwYBBAGEWQoEATEvMC0wCgIFAOu8CKYC
# AQAwCgIBAAICDJgCAf8wBwIBAAICEqAwCgIFAOu9WiYCAQAwNgYKKwYBBAGEWQoE
# AjEoMCYwDAYKKwYBBAGEWQoDAqAKMAgCAQACAwehIKEKMAgCAQACAwGGoDANBgkq
# hkiG9w0BAQsFAAOCAQEALbeKNO76wl1EDS69cVkMu1MrAi0bawFNpcHLU1zAdcLa
# EHl3bk9I1z1FgYJh/D7uhfsSabxC5FOBQircpS2wavfMRTisVSSyCQzOO0QiHHyA
# FkXelGL9ydFa7Q8HVqSNjQHqHFbVOufnGeTDIyP3614ecoNCY+jP8AXQwdl+eXcn
# JAH+LRNfP9tdx06M21TW22OMm2J/SMextf286VTQugW45lhz/vr34OP/w7nCIsTJ
# rB1IFvuhuK909l2oeZeGS80USGCAGNJpr9fQzUK2H82bz++WS5+y1oC9OPrN+K6+
# T0/YCC7RCJxor5g2WzDMcJ/nx2WDVtdM58mbrH/gPDGCBA0wggQJAgEBMIGTMHwx
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1p
# Y3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAACCHidWF2Sx9lSAAEAAAII
# MA0GCWCGSAFlAwQCAQUAoIIBSjAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQw
# LwYJKoZIhvcNAQkEMSIEIMc5tdmzLVb8vBGbu7a+9GVtzf+nhqyfE7DYIwVfOCCJ
# MIH6BgsqhkiG9w0BCRACLzGB6jCB5zCB5DCBvQQgj/+ObwkdrZbU73vvy334W3Zn
# k2Yqq20+TpD71FGmZ6kwgZgwgYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0Eg
# MjAxMAITMwAAAgh4nVhdksfZUgABAAACCDAiBCBruqZwnYWLZmsgiZBlK7JJCWeU
# s/+T+tDQQqA3FqCV9DANBgkqhkiG9w0BAQsFAASCAgCezZfd+R+G9bYIGZnI7ZKr
# 3WlMKVXcV1MKm6SkqRVfU47QEZpXvo6nyRCuCfCl2DCNKpepswLOtxNy42uShQUP
# ZJ9w49arfzW6/olgkx9GiHo8T7yJzvJPfxmmxYaJ/HsXNFKqj3K19uRA8ODB/pqX
# WLSwEoZejZqMzHSwfF7z/x8CbinKkghpl8kGjSZX2+eW2AeHZREI0Ra+KOFMDWSb
# 4wOo30lrKzSA8XMYY3/saCIkmbDfH28QyzGKpk26ThPZYRiEvxq5abMVjZ7PrrRr
# X7BGWqlqfdueYGHi282moqem2A1shAWe8hL8T7/E3q6BArj53Bo6QzPv5OLH9tyV
# UQV7LA3kiUVoXnuKRrgSgHuUrjqctSWz+ec/Lx3ZGJrmj1hAyuECNxTx1FR6//Xd
# o21AgjCJBWlXZ3VV+epoqLrvyiJf4dEjDrmSfYlqXK6Hqck/imSRCNhpKN+G9wlK
# +toJXbePPKLxrjikT2YugwTIJpupH2t72Bt65jR1CT+QOtGSK39VGN9RQNw31IRZ
# cnvK9IdNXAWGJ+tnqyLeSlGeGOekNfGbBiHI4zZ5MEaTHD/VgnE10EtQSYaiZIaK
# ugD5IHI4fl2471GJH4fOEP6+3BlihylLliwKXAu1mkfkOgo0jDTIkkrj9P26kDNo
# CyKMx9/kl01LHK+mjAOXlA==
# SIG # End signature block
