function Update-AzDataProtectionBackupVault
{
	[OutputType('Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api202501.IBackupVaultResource')]
    [CmdletBinding(DefaultParameterSetName="UpdateExpanded", PositionalBinding=$false, SupportsShouldProcess)]
    [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Description('Updates a BackupVault resource belonging to a resource group. For example updating tags for a resource.')]

    param(
        [Parameter(ParameterSetName="UpdateExpanded",Mandatory=$false, HelpMessage='The ID of the target subscription. The value must be an UUID.')]
        [System.String]
        ${SubscriptionId},

        [Parameter(ParameterSetName="UpdateExpanded",Mandatory, HelpMessage='The name of the resource group. The name is case insensitive.')]
        [System.String]
        ${ResourceGroupName},

        [Parameter(ParameterSetName="UpdateExpanded",Mandatory, HelpMessage='The name of the backup vault.')]
        [System.String]
        ${VaultName},

        [Parameter(ParameterSetName="UpdateExpanded",HelpMessage='The identityType which can take values: "SystemAssigned", "UserAssigned", "SystemAssigned,UserAssigned", "None"')]
        [System.String]
        ${IdentityType},

        [Parameter(ParameterSetName="UpdateExpanded",Mandatory=$false, HelpMessage='Parameter to Enable or Disable built-in azure monitor alerts for job failures. Security alerts cannot be disabled.')]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Support.AlertsState]
        [ValidateSet('Enabled','Disabled')]
        ${AzureMonitorAlertsForAllJobFailure},

        [Parameter(ParameterSetName="UpdateExpanded",Mandatory=$false, HelpMessage='Immutability state of the vault. Allowed values are Disabled, Unlocked, Locked.')]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Support.ImmutabilityState]
        [ValidateSet('Disabled','Unlocked', 'Locked')]
        ${ImmutabilityState},

        [Parameter(ParameterSetName="UpdateExpanded",Mandatory=$false, HelpMessage='Cross region restore state of the vault. Allowed values are Disabled, Enabled.')]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Support.CrossRegionRestoreState]
        [ValidateSet('Disabled','Enabled')]
        ${CrossRegionRestoreState},
        
        [Parameter(ParameterSetName="UpdateExpanded",Mandatory=$false, HelpMessage='Cross subscription restore state of the vault. Allowed values are Disabled, Enabled, PermanentlyDisabled.')]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Support.CrossSubscriptionRestoreState]
        [ValidateSet('Disabled','Enabled', 'PermanentlyDisabled')]
        ${CrossSubscriptionRestoreState},
        
        [Parameter(ParameterSetName="UpdateExpanded",Mandatory=$false, HelpMessage='Soft delete retention duration in days')]
        [System.Double]
        ${SoftDeleteRetentionDurationInDay},

        [Parameter(ParameterSetName="UpdateExpanded",Mandatory=$false, HelpMessage='Soft delete state of the vault. Allowed values are Off, On, AlwaysOn')]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Support.SoftDeleteState]
        [ValidateSet('Off','On', 'AlwaysOn')]  
        ${SoftDeleteState},

        [Parameter(ParameterSetName="UpdateExpanded",HelpMessage='Resource tags.')]
        [System.Collections.Hashtable]
        ${Tag},

        [Parameter(ParameterSetName="UpdateExpanded",Mandatory=$false, HelpMessage='Gets or sets the user assigned identities.')]
        [Alias('UserAssignedIdentity', 'AssignUserIdentity')]
        [System.Collections.Hashtable]
        ${IdentityUserAssignedIdentity},

        [Parameter(ParameterSetName="UpdateExpanded",Mandatory=$false, HelpMessage='Enable CMK encryption state for a Backup Vault.')]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Support.EncryptionState]
        ${CmkEncryptionState},

        [Parameter(ParameterSetName="UpdateExpanded",Mandatory=$false, HelpMessage='The identity type to be used for CMK encryption - SystemAssigned or UserAssigned Identity.')]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Support.IdentityType]
        ${CmkIdentityType},

        [Parameter(ParameterSetName="UpdateExpanded",Mandatory=$false, HelpMessage='This parameter is required if the identity type is UserAssigned. Add the user assigned managed identity id to be used which has access permissions to the Key Vault.')]
        [System.String]
        ${CmkUserAssignedIdentityId},

        [Parameter(ParameterSetName="UpdateExpanded",Mandatory=$false, HelpMessage='The Key URI of the CMK key to be used for encryption. To enable auto-rotation of keys, exclude the version component from the Key URI. ')]
        [System.String]
        ${CmkEncryptionKeyUri},
        
        [Parameter(ParameterSetName="UpdateExpanded", Mandatory=$false, HelpMessage='Resource guard operation request in the format similar to <ResourceGuard-ARMID>/operationName/default. Here operationName can be any of dppReduceImmutabilityStateRequests, dppReduceSoftDeleteSecurityRequests, dppModifyEncryptionSettingsRequests. Use this parameter when the operation is MUA protected.')]
        [System.String[]]
        ${ResourceGuardOperationRequest},

        [Parameter(Mandatory=$false, HelpMessage='Parameter deprecate. Please use SecureToken instead.')]
        [System.String]
        ${Token},

        [Parameter(Mandatory=$false, HelpMessage='Parameter to authorize operations protected by cross tenant resource guard. Use command (Get-AzAccessToken -TenantId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx -AsSecureString").Token to fetch authorization token for different tenant.')]
        [System.Security.SecureString]
        ${SecureToken},

        [Parameter(HelpMessage='The DefaultProfile parameter is not functional. Use the SubscriptionId parameter when available if executing the cmdlet against a different subscription.')]
        [Alias('AzureRMContext', 'AzureCredential')]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        # The credentials, account, tenant, and subscription used for communication with Azure.
        ${DefaultProfile},
            
        [Parameter(HelpMessage='Run the command as a job')]
        [System.Management.Automation.SwitchParameter]
        # Run the command as a job
        ${AsJob},
    
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

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        # Run the command asynchronously
        ${NoWait},
    
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
        $hasToken = $PSBoundParameters.Remove("Token")
        $hasSecureToken = $PSBoundParameters.Remove("SecureToken")
        if($hasToken -or $hasSecureToken)
        {   
            if($hasSecureToken -and $hasToken){
                throw "Both Token and SecureToken parameters cannot be provided together"
            }
            elseif($hasToken){
                Write-Warning -Message 'The Token parameter is deprecated and will be removed in future versions. Please use SecureToken instead.'
                $null = $PSBoundParameters.Add("Token", "Bearer $Token")
            }
            else{
                $plainToken = UnprotectSecureString -SecureString $SecureToken
                $null = $PSBoundParameters.Add("Token", "Bearer $plainToken")
            }
        }

        $hasCmkEncryptionState = $PSBoundParameters.Remove("CmkEncryptionState")
        $hasCmkIdentityType = $PSBoundParameters.Remove("CmkIdentityType")
        $hasCmkUserAssignedIdentityId = $PSBoundParameters.Remove("CmkUserAssignedIdentityId")
        $hasCmkEncryptionKeyUri = $PSBoundParameters.Remove("CmkEncryptionKeyUri")

        if (-not $hasCmkEncryptionState -and -not $hasCmkIdentityType -and -not $hasCmkUserAssignedIdentityId -and -not $hasCmkEncryptionKeyUri) {
            Az.DataProtection.Internal\Update-AzDataProtectionBackupVault @PSBoundParameters
            return
        }

        $hasIdentityType = $PSBoundParameters.Remove("IdentityType")
        $hasAzureMonitorAlertsForAllJobFailure = $PSBoundParameters.Remove("AzureMonitorAlertsForAllJobFailure")
        $hasImmutabilityState = $PSBoundParameters.Remove("ImmutabilityState")
        $hasCrossRegionRestoreState = $PSBoundParameters.Remove("CrossRegionRestoreState")
        $hasCrossSubscriptionRestoreState = $PSBoundParameters.Remove("CrossSubscriptionRestoreState")
        $hasSoftDeleteRetentionDurationInDay = $PSBoundParameters.Remove("SoftDeleteRetentionDurationInDay")
        $hasSoftDeleteState = $PSBoundParameters.Remove("SoftDeleteState")
        $hasTag = $PSBoundParameters.Remove("Tag")
        $hasUserAssignedIdentity = $PSBoundParameters.Remove("UserAssignedIdentity")

        $vault = Az.DataProtection\Get-AzDataProtectionBackupVault @PSBoundParameters

        $encryptionSettings = $null

        if ($vault.EncryptionSetting -ne $null) { $encryptionSettings = $vault.EncryptionSetting }
        else { 
            $encryptionSettings = [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api202501.EncryptionSettings]::new()
            $encryptionSettings.CmkIdentity = [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api202501.CmkKekIdentity]::new()
            $encryptionSettings.CmkKeyVaultProperty = [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api202501.CmkKeyVaultProperties]::new()
        }

        if ($hasCmkEncryptionState) { $encryptionSettings.State = $CmkEncryptionState }
        if ($hasCmkIdentityType) { 
            $encryptionSettings.CmkIdentity.IdentityType = $CmkIdentityType 
            if ( $CmkIdentityType -eq "SystemAssigned" ) {
                $encryptionSettings.CmkIdentity.IdentityId = $null
            }
        }
        if ($hasCmkUserAssignedIdentityId) { $encryptionSettings.CmkIdentity.IdentityId = $CmkUserAssignedIdentityId }
        if ($hasCmkEncryptionKeyUri) { $encryptionSettings.CmkKeyVaultProperty.KeyUri = $CmkEncryptionKeyUri }

        $PSBoundParameters.Add("EncryptionSetting", $encryptionSettings)

        if ($hasIdentityType) { $PSBoundParameters.Add("IdentityType", $IdentityType) }
        if ($hasAzureMonitorAlertsForAllJobFailure) { $PSBoundParameters.Add("AzureMonitorAlertsForAllJobFailure", $AzureMonitorAlertsForAllJobFailure) }
        if ($hasImmutabilityState) { $PSBoundParameters.Add("ImmutabilityState", $ImmutabilityState) }
        if ($hasCrossRegionRestoreState) { $PSBoundParameters.Add("CrossRegionRestoreState", $CrossRegionRestoreState) }
        if ($hasCrossSubscriptionRestoreState) { $PSBoundParameters.Add("CrossSubscriptionRestoreState", $CrossSubscriptionRestoreState) }
        if ($hasSoftDeleteRetentionDurationInDay) { $PSBoundParameters.Add("SoftDeleteRetentionDurationInDay", $SoftDeleteRetentionDurationInDay) }
        if ($hasSoftDeleteState) { $PSBoundParameters.Add("SoftDeleteState", $SoftDeleteState) }
        if ($hasTag) { $PSBoundParameters.Add("Tag", $Tag) }
        if ($hasUserAssignedIdentity) { $PSBoundParameters.Add("UserAssignedIdentity", $UserAssignedIdentity) }

        Az.DataProtection.Internal\Update-AzDataProtectionBackupVault @PSBoundParameters
    }
}
# SIG # Begin signature block
# MIIoLQYJKoZIhvcNAQcCoIIoHjCCKBoCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCC6ANVVUm2q8Px+
# SlTbvBRlQ/eC883TuSrKYJkRYZL4u6CCDXYwggX0MIID3KADAgECAhMzAAAEBGx0
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
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIG1xQjn/7HehX8oXYyowe5oD
# BdclsTdLNsT9ViCC2J3eMEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEB
# BQAEggEAdkdLRhQ+8XsC+avlPuzZoRj7qqhkHjMH/hsglI+sN98+75YhItg67akp
# eJQEwhSV0Tc8EfsvWoAmPEDst4mCNhjVKn9XGveoUDN6WBVVvnuuBhep5Fu4MzaI
# I3EiYTs6SbcOTSEoZYkwaU5LEm4ld+T0wfNE57uve4RATRNDBVvss//sVUMI8C9R
# IABwMs6OLPkv1Xp7vwy47J98nabEIgkqQ98l6p2LmCHAkYk5nZUPW7kgmQIQb+Fa
# a7qVwGulWcFBMbT7ZGDd+ufcXj9mt2OeaEk68EBDC1XQYO0Bky2h9TBbqHs9MxeE
# kI5YPzavZ6Y6fb01gIIXIOzmWSZ9VaGCF5cwgheTBgorBgEEAYI3AwMBMYIXgzCC
# F38GCSqGSIb3DQEHAqCCF3AwghdsAgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFSBgsq
# hkiG9w0BCRABBKCCAUEEggE9MIIBOQIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCC7Uk+UkJQAT1nQ617qELG8fEUDDGg3XxqqihacLa6yRAIGZ/fty0qf
# GBMyMDI1MDQzMDAyMjkxMi4zNTZaMASAAgH0oIHRpIHOMIHLMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1l
# cmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046ODYwMy0w
# NUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2Wg
# ghHtMIIHIDCCBQigAwIBAgITMwAAAgcsETmJzYX7xQABAAACBzANBgkqhkiG9w0B
# AQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYD
# VQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAeFw0yNTAxMzAxOTQy
# NTJaFw0yNjA0MjIxOTQyNTJaMIHLMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25z
# MScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046ODYwMy0wNUUwLUQ5NDcxJTAjBgNV
# BAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2UwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQDFP/96dPmcfgODe3/nuFveuBst/JmSxSkOn89ZFytH
# Qm344iLoPqkVws+CiUejQabKf+/c7KU1nqwAmmtiPnG8zm4Sl9+RJZaQ4Dx3qtA9
# mdQdS7Chf6YUbP4Z++8laNbTQigJoXCmzlV34vmC4zpFrET4KAATjXSPK0sQuFhK
# r7ltNaMFGclXSnIhcnScj9QUDVLQpAsJtsKHyHN7cN74aEXLpFGc1I+WYFRxaTgq
# SPqGRfEfuQ2yGrAbWjJYOXueeTA1MVKhW8zzSEpfjKeK/t2XuKykpCUaKn5s8sqN
# bI3bHt/rE/pNzwWnAKz+POBRbJxIkmL+n/EMVir5u8uyWPl1t88MK551AGVh+2H4
# ziR14YDxzyCG924gaonKjicYnWUBOtXrnPK6AS/LN6Y+8Kxh26a6vKbFbzaqWXAj
# zEiQ8EY9K9pYI/KCygixjDwHfUgVSWCyT8Kw7mGByUZmRPPxXONluMe/P8CtBJMp
# uh8CBWyjvFfFmOSNRK8ETkUmlTUAR1CIOaeBqLGwscShFfyvDQrbChmhXib4nRMX
# 5U9Yr9d7VcYHn6eZJsgyzh5QKlIbCQC/YvhFK42ceCBDMbc+Ot5R6T/Mwce5jVyV
# CmqXVxWOaQc4rA2nV7onMOZC6UvCG8LGFSZBnj1loDDLWo/I+RuRok2j/Q4zcMnw
# kQIDAQABo4IBSTCCAUUwHQYDVR0OBBYEFHK1UmLCvXrQCvR98JBq18/4zo0eMB8G
# A1UdIwQYMBaAFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMF8GA1UdHwRYMFYwVKBSoFCG
# Tmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUy
# MFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNybDBsBggrBgEFBQcBAQRgMF4w
# XAYIKwYBBQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2Vy
# dHMvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUyMDIwMTAoMSkuY3J0MAwG
# A1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQD
# AgeAMA0GCSqGSIb3DQEBCwUAA4ICAQDju0quPbnix0slEjD7j2224pYOPGTmdDvO
# 0+bNRCNkZqUv07P04nf1If3Y/iJEmUaU7w12Fm582ImpD/Kw2ClXrNKLPTBO6nfx
# vOPGtalpAl4wqoGgZxvpxb2yEunG4yZQ6EQOpg1dE9uOXoze3gD4Hjtcc75kca8y
# ivowEI+rhXuVUWB7vog4TGUxKdnDvpk5GSGXnOhPDhdId+g6hRyXdZiwgEa+q9M9
# Xctz4TGhDgOKFsYxFhXNJZo9KRuGq6evhtyNduYrkzjDtWS6gW8akR59UhuLGsVq
# +4AgqEY8WlXjQGM2OTkyBnlQLpB8qD7x9jRpY2Cq0OWWlK0wfH/1zefrWN5+be87
# Sw2TPcIudIJn39bbDG7awKMVYDHfsPJ8ZvxgWkZuf6ZZAkph0eYGh3IV845taLkd
# LOCvw49Wxqha5Dmi2Ojh8Gja5v9kyY3KTFyX3T4C2scxfgp/6xRd+DGOhNVPvVPa
# /3yRUqY5s5UYpy8DnbppV7nQO2se3HvCSbrb+yPyeob1kUfMYa9fE2bEsoMbOaHR
# gGji8ZPt/Jd2bPfdQoBHcUOqPwjHBUIcSc7xdJZYjRb4m81qxjma3DLjuOFljMZT
# YovRiGvEML9xZj2pHRUyv+s5v7VGwcM6rjNYM4qzZQM6A2RGYJGU780GQG0QO98w
# +sucuTVrfTCCB3EwggVZoAMCAQICEzMAAAAVxedrngKbSZkAAAAAABUwDQYJKoZI
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
# MCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOjg2MDMtMDVFMC1EOTQ3MSUwIwYDVQQD
# ExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloiMKAQEwBwYFKw4DAhoDFQDT
# vVU/Yj9lUSyeDCaiJ2Da5hUiS6CBgzCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFBDQSAyMDEwMA0GCSqGSIb3DQEBCwUAAgUA67t3IjAiGA8yMDI1MDQyOTE2MDQ1
# MFoYDzIwMjUwNDMwMTYwNDUwWjB3MD0GCisGAQQBhFkKBAExLzAtMAoCBQDru3ci
# AgEAMAoCAQACAgQXAgH/MAcCAQACAhGdMAoCBQDrvMiiAgEAMDYGCisGAQQBhFkK
# BAIxKDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMHoSChCjAIAgEAAgMBhqAwDQYJ
# KoZIhvcNAQELBQADggEBADjl+NlyK24PZTINDlD0ZRCa20pEslCWrZvwINhcvA79
# 3l0rxLrsGqqfqLZrK1/HAxPihr3JAgYrq/7lRJFcEjMHio3w9lGMFrAENmpLkPxi
# Bp+7OtzQAJZQvuzXN34xVJuQPFljHiDbI5u0tUO78TlbeGEM4rQ8bo27gv/Pm2At
# gXRJAlKH+jtJqTlirxw6Opufel1IXqBn6Q0eD8yPkt9WcDR+cU2TBWuBIOWD7a9V
# c5BlZCvsL0r85kYc8NHf3Ql3m4PHTLuY5zoAys2H4jeRC6V254Hrny211sDdE+z5
# zgJjkIb08xlCPt1t71dWQ031JfOddEerOeXE3+jnaUsxggQNMIIECQIBATCBkzB8
# MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVk
# bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1N
# aWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAgcsETmJzYX7xQABAAAC
# BzANBglghkgBZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEE
# MC8GCSqGSIb3DQEJBDEiBCB/ncNbmPYCyBQVJwAx2lOyhq7ZEcF05S00Yucq/VZG
# KTCB+gYLKoZIhvcNAQkQAi8xgeowgecwgeQwgb0EIC/31NHQds1IZ5sPnv59p+v6
# BjBDgoDPIwiAmn0PHqezMIGYMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29m
# dCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENB
# IDIwMTACEzMAAAIHLBE5ic2F+8UAAQAAAgcwIgQgePRlBPSH22ebYnjk/KXzbJqP
# hZXx+/8yVWcAMyHNd4AwDQYJKoZIhvcNAQELBQAEggIAt9kCmfLYVYEJnjJoKj44
# WUygg/VTp4jgIOL4Vza3gnN5MniLZDcDo55dtzmGQaItDCDhRoCXmVIxG6CIEy/K
# hG6aDmnBvRN2T/hxlXyXLgtGO3BCaagqqTh7OerJt8vWvOQdBgF6g93eflLlizTw
# 75JWJjz2AFpBQKiwgylzOgMH1ZI6yzrAt8zyyeHcfHdRBK4NWAI1Dgo1EMtBSQIW
# hkSHmvMAJxlDOwODDo8RVe+j4yyvSspn+BnXs+njJqAV8nSSGx8qHxgIEm2u6MWD
# jg5MY7sgweUECzRALdoGjLwW/r8IRSypRn1jcNjwC/Jf4LG7dS8Q52F1DSX4U2+8
# WjJHiHb7T1jItGAvHfp0DkP19VN6+Jk7WIKJ/ujhqjaoPoeJS1UtGIh3zR4hMmzB
# HtNZ944aMQj4lHH40Y0j3UQHPRJ1+MseBESonnzHl6IhiAOcKVdHXeSrURGLSjkw
# CqHBvN+eUOLh7f1fHgkmFBQFAG04Zr1Xu9+5eVdjb9gd8OlX2ed6ME0tCVOLtpzR
# S+cZCumwcCmcvsebf7cHfiNeYzAkDfAR1CYon11JMqkMiX26uVSd9pNn0Oa8SjZG
# OeDnAyjSatJe0aGsYo9GnZhkQahEP/kiHrxwmmJA+rNIO6CmfRMOMHp/AFCUJcOF
# 3Djs6648Aajb+8i3Oqq/NR0=
# SIG # End signature block
