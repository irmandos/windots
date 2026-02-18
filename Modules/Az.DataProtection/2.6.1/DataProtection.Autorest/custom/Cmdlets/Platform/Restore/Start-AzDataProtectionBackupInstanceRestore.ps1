

function Start-AzDataProtectionBackupInstanceRestore
{   
	[OutputType('Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20240401.IOperationJobExtendedInfo')]
    [CmdletBinding(PositionalBinding=$false, SupportsShouldProcess)]
    [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Description('Triggers restore for a BackupInstance')]

    param(
        # Trigger, TriggerExpanded
        [Parameter(Mandatory=$false, HelpMessage='Subscription Id of the backup vault')]
        [System.String]
        ${SubscriptionId},

        [Parameter(Mandatory, HelpMessage='The name of the resource group where the backup vault is present')]
        [System.String]
        ${ResourceGroupName},

        [Parameter(Mandatory, HelpMessage='The name of the backup instance')]
        [System.String]
        ${BackupInstanceName},

        [Parameter(Mandatory, HelpMessage='The name of the backup vault')]
        [System.String]
        ${VaultName},

        [Parameter(ParameterSetName="Trigger", Mandatory, HelpMessage='Restore request object to be initialized using Initialize-AzDataProtectionRestoreRequest cmdlet', ValueFromPipeline=$true)]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20240401.IAzureBackupRestoreRequest]
        ${Parameter},

        [Parameter(Mandatory=$false, HelpMessage='Resource guard operation request in the format similar to <resourceguard-ARMID>/dppTriggerRestoreRequests/default. Use this parameter when the operation is MUA protected.')]
        [System.String[]]
        ${ResourceGuardOperationRequest},

        [Parameter(Mandatory=$false, HelpMessage='Parameter deprecate. Please use SecureToken instead.')]
        [System.String]
        ${Token},

        [Parameter(Mandatory=$false, HelpMessage='Parameter to authorize operations protected by cross tenant resource guard. Use command (Get-AzAccessToken -TenantId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx -AsSecureString").Token to fetch authorization token for different tenant.')]
        [System.Security.SecureString]
        ${SecureToken},

        [Parameter(ParameterSetName="TriggerExpanded", Mandatory, HelpMessage='Object type of the restore request')]
        [System.String]
        ${ObjectType},

        [Parameter(ParameterSetName="TriggerExpanded", Mandatory, HelpMessage='Gets or sets the restore target information')]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20240401.IRestoreTargetInfoBase]
        ${RestoreTargetInfo},

        [Parameter(ParameterSetName="TriggerExpanded", Mandatory, HelpMessage='Type of the source data store')]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Support.SourceDataStoreType]
        ${SourceDataStoreType},

        [Parameter(ParameterSetName="TriggerExpanded", Mandatory=$false, HelpMessage='ARM URL for User Assigned Identity')]
        [System.String]
        ${IdentityDetailUserAssignedIdentityArmUrl}, # TODO: add parameter alias to this and below

        [Parameter(ParameterSetName="TriggerExpanded", Mandatory=$false, HelpMessage='Specifies if the BI is protected by System Identity')]
        [System.Management.Automation.SwitchParameter]
        ${IdentityDetailUseSystemAssignedIdentity},

        [Parameter(ParameterSetName="TriggerExpanded", Mandatory=$false, HelpMessage='Fully qualified Azure Resource Manager ID of the datasource which is being recovered')]
        [System.String]
        ${SourceResourceId},

        [Parameter(Mandatory=$false, HelpMessage='Switch parameter to trigger restore to secondary region (Cross region restore)')]
        [Switch]
        ${RestoreToSecondaryRegion},

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
                
        [Parameter(HelpMessage='Run the command as a job')]
        [System.Management.Automation.SwitchParameter]
        # Run the command as a job
        ${AsJob},

        [Parameter(HelpMessage='Run the command asynchronously')]
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
        $hasRestoreToSecondaryRegion = $PSBoundParameters.Remove("RestoreToSecondaryRegion")        
        
        # MUA
        if($PsCmdlet.ParameterSetName -eq "Trigger" -and $PSBoundParameters.ContainsKey("ResourceGuardOperationRequest")){
            $PSBoundParameters.Remove("ResourceGuardOperationRequest")            
            $Parameter.ResourceGuardOperationRequest = $ResourceGuardOperationRequest            
        }

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
                
        if($hasRestoreToSecondaryRegion){
            
            $hasParameter = $PSBoundParameters.Remove("Parameter")
            $hasObjectType = $PSBoundParameters.Remove("ObjectType")
            $hasRestoreTargetInfo = $PSBoundParameters.Remove("RestoreTargetInfo")
            $hasSourceDataStoreType = $PSBoundParameters.Remove("SourceDataStoreType")
            $hasSourceResourceId = $PSBoundParameters.Remove("SourceResourceId")
            $hasIdentityDetailUserAssignedIdentityArmUrl = $PSBoundParameters.Remove("IdentityDetailUserAssignedIdentityArmUrl")
            $hasIdentityDetailUseSystemAssignedIdentity = $PSBoundParameters.Remove("IdentityDetailUseSystemAssignedIdentity")
                        
            # fetch vault from ARG            
            $hasSubscriptionId = $PSBoundParameters.Remove("SubscriptionId")
            $null = $PSBoundParameters.Remove("ResourceGroupName")
            $null = $PSBoundParameters.Remove("VaultName")
            $null = $PSBoundParameters.Remove("BackupInstanceName")

            $PSBoundParameters.Add('ResourceGroup', $ResourceGroupName)
            $PSBoundParameters.Add('Vault', $VaultName)
            if($hasSubscriptionId) { $PSBoundParameters.Add('Subscription', $SubscriptionId) }
            
            $vault = Search-AzDataProtectionBackupVaultInAzGraph @PSBoundParameters

            $null = $PSBoundParameters.Remove("Subscription")
            $null = $PSBoundParameters.Remove("ResourceGroup")
            $null = $PSBoundParameters.Remove("Vault")
            $PSBoundParameters.Add('ResourceGroupName', $ResourceGroupName)
            if($hasSubscriptionId) { $PSBoundParameters.Add('SubscriptionId', $SubscriptionId) }
            
            $backupInstanceId = "/subscriptions/" + $SubscriptionId + "/resourceGroups/" + $ResourceGroupName + "/providers/Microsoft.DataProtection/backupVaults/" + $VaultName + "/backupInstances/" + $BackupInstanceName

            $crossRegionRestoreDetail = [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20240401.CrossRegionRestoreDetails]::new()
            $crossRegionRestoreDetail.SourceBackupInstanceId = $backupInstanceId
            $crossRegionRestoreDetail.SourceRegion = $vault.Location
            
            $PSBoundParameters.Add('Location', $vault.ReplicatedRegion[0])
            $PSBoundParameters.Add("CrossRegionRestoreDetail", $crossRegionRestoreDetail)

            if($hasParameter){                
                $PSBoundParameters.Add("RestoreRequestObject", $Parameter)
            }
            else{
                $restoreRequestObject = [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20240401.AzureBackupRestoreRequest]::new()
                if($hasObjectType) { $restoreRequestObject.ObjectType = $ObjectType }
                if($hasRestoreTargetInfo) { $restoreRequestObject.RestoreTargetInfo = $RestoreTargetInfo }
                if($hasSourceDataStoreType) { $restoreRequestObject.SourceDataStoreType = $SourceDataStoreType }
                if($hasSourceResourceId) { $restoreRequestObject.SourceResourceId = $SourceResourceId }
                if($hasIdentityDetailUseSystemAssignedIdentity) { $restoreRequestObject.IdentityDetailUseSystemAssignedIdentity = $IdentityDetailUseSystemAssignedIdentity }
                if($hasIdentityDetailUserAssignedIdentityArmUrl) { $restoreRequestObject.IdentityDetailUserAssignedIdentityArmUrl = $IdentityDetailUserAssignedIdentityArmUrl }

                $PSBoundParameters.Add("RestoreRequestObject", $restoreRequestObject)
            }           

            Az.DataProtection.Internal\Start-AzDataProtectionBackupInstanceCrossRegionRestore @PSBoundParameters
        }
        else{        
            Az.DataProtection.Internal\Start-AzDataProtectionBackupInstanceRestore @PSBoundParameters
        }
    }
}
# SIG # Begin signature block
# MIIoOQYJKoZIhvcNAQcCoIIoKjCCKCYCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBRo73ppL3Ounj2
# nbgE79RKlpmEYG5DkJcH6bidcgM2g6CCDYUwggYDMIID66ADAgECAhMzAAAEA73V
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
# cVZOSEXAQsmbdlsKgEhr/Xmfwb1tbWrJUnMTDXpQzTGCGgowghoGAgEBMIGVMH4x
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01p
# Y3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTECEzMAAAQDvdWVXQ87GK0AAAAA
# BAMwDQYJYIZIAWUDBAIBBQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIOYh
# WbvQnur9HN3Ud9E2uTEwI7CMWW49H4UJsw5HMmMJMEIGCisGAQQBgjcCAQwxNDAy
# oBSAEgBNAGkAYwByAG8AcwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20wDQYJKoZIhvcNAQEBBQAEggEAPKRx5Bze/srMf46yHC6GGhbyBvaOVyDxexPs
# x4ThLCcERmDJOKXIMrwijXXmk9iybID41LzLuYdB3+MjJp/h0jQpJcDhN8bRMqIl
# HCz7uV/xwoQ74biBUER0M7t9EuZa/78gkzWw5JDFYmP/3eqdlb9hFepfQZFKgphx
# Ivx4cjkH14YmsafBDaPXrPjmeWQydsnMEONJHIioRQZGOUtwSYueL5VSx2nSQZkc
# xiX6RgAEGu+L3u+C3oycabt9fjdqZNj+HLJJ7LEGxxSeRZTtumEvhjYheGE5FQRc
# Hulz5PJUA7zKrzeIeHjYZkUKT8uALZvEahbT2L7kvh4BgEbzg6GCF5QwgheQBgor
# BgEEAYI3AwMBMYIXgDCCF3wGCSqGSIb3DQEHAqCCF20wghdpAgEDMQ8wDQYJYIZI
# AWUDBAIBBQAwggFSBgsqhkiG9w0BCRABBKCCAUEEggE9MIIBOQIBAQYKKwYBBAGE
# WQoDATAxMA0GCWCGSAFlAwQCAQUABCCJOp6DitqVrY/k558KwQdE6L9000adIqTl
# pVx4Sm2jMwIGZ5I2MJRpGBMyMDI1MDIwNjAzMTkwOC40NTVaMASAAgH0oIHRpIHO
# MIHLMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQL
# ExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxk
# IFRTUyBFU046ODYwMy0wNUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1l
# LVN0YW1wIFNlcnZpY2WgghHqMIIHIDCCBQigAwIBAgITMwAAAfGzRfUn6MAW1gAB
# AAAB8TANBgkqhkiG9w0BAQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAx
# MDAeFw0yMzEyMDYxODQ1NTVaFw0yNTAzMDUxODQ1NTVaMIHLMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1l
# cmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046ODYwMy0w
# NUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2Uw
# ggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCxulCZttIf8X97rW9/J+Q4
# Vg9PiugB1ya1/DRxxLW2hwy4QgtU3j5fV75ZKa6XTTQhW5ClkGl6gp1nd5VBsx4J
# b+oU4PsMA2foe8gP9bQNPVxIHMJu6TYcrrn39Hddet2xkdqUhzzySXaPFqFMk2Vi
# fEfj+HR6JheNs2LLzm8FDJm+pBddPDLag/R+APIWHyftq9itwM0WP5Z0dfQyI4Wl
# VeUS+votsPbWm+RKsH4FQNhzb0t/D4iutcfCK3/LK+xLmS6dmAh7AMKuEUl8i2kd
# WBDRcc+JWa21SCefx5SPhJEFgYhdGPAop3G1l8T33cqrbLtcFJqww4TQiYiCkdys
# CcnIF0ZqSNAHcfI9SAv3gfkyxqQNJJ3sTsg5GPRF95mqgbfQbkFnU17iYbRIPJqw
# gSLhyB833ZDgmzxbKmJmdDabbzS0yGhngHa6+gwVaOUqcHf9w6kwxMo+OqG3QZIc
# wd5wHECs5rAJZ6PIyFM7Ad2hRUFHRTi353I7V4xEgYGuZb6qFx6Pf44i7AjXbptU
# olDcVzYEdgLQSWiuFajS6Xg3k7Cy8TiM5HPUK9LZInloTxuULSxJmJ7nTjUjOj5x
# wRmC7x2S/mxql8nvHSCN1OED2/wECOot6MEe9bL3nzoKwO8TNlEStq5scd25GA0g
# MQO+qNXV/xTDOBTJ8zBcGQIDAQABo4IBSTCCAUUwHQYDVR0OBBYEFLy2xe59sCE0
# SjycqE5Erb4YrS1gMB8GA1UdIwQYMBaAFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMF8G
# A1UdHwRYMFYwVKBSoFCGTmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMv
# Y3JsL01pY3Jvc29mdCUyMFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNybDBs
# BggrBgEFBQcBAQRgMF4wXAYIKwYBBQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0
# LmNvbS9wa2lvcHMvY2VydHMvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUy
# MDIwMTAoMSkuY3J0MAwGA1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUH
# AwgwDgYDVR0PAQH/BAQDAgeAMA0GCSqGSIb3DQEBCwUAA4ICAQDhSEjSBFSCbJyl
# 3U/QmFMW2eLPBknnlsfID/7gTMvANEnhq08I9HHbbqiwqDEHSvARvKtL7j0znICY
# BbMrVSmvgDxU8jAGqMyiLoM80788So3+T6IZV//UZRJqBl4oM3bCIQgFGo0VTeQ6
# RzYL+t1zCUXmmpPmM4xcScVFATXj5Tx7By4ShWUC7Vhm7picDiU5igGjuivRhxPv
# bpflbh/bsiE5tx5cuOJEJSG+uWcqByR7TC4cGvuavHSjk1iRXT/QjaOEeJoOnfes
# bOdvJrJdbm+leYLRI67N3cd8B/suU21tRdgwOnTk2hOuZKs/kLwaX6NsAbUy9pKs
# DmTyoWnGmyTWBPiTb2rp5ogo8Y8hMU1YQs7rHR5hqilEq88jF+9H8Kccb/1ismJT
# GnBnRMv68Ud2l5LFhOZ4nRtl4lHri+N1L8EBg7aE8EvPe8Ca9gz8sh2F4COTYd1P
# Hce1ugLvvWW1+aOSpd8NnwEid4zgD79ZQxisJqyO4lMWMzAgEeFhUm40FshtzXud
# AsX5LoCil4rLbHfwYtGOpw9DVX3jXAV90tG9iRbcqjtt3vhW9T+L3fAZlMeraWfh
# 7eUmPltMU8lEQOMelo/1ehkIGO7YZOHxUqeKpmF9QaW8LXTT090AHZ4k6g+tdpZF
# fCMotyG+E4XqN6ZWtKEBQiE3xL27BDCCB3EwggVZoAMCAQICEzMAAAAVxedrngKb
# SZkAAAAAABUwDQYJKoZIhvcNAQELBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQI
# EwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3Nv
# ZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBSb290IENlcnRpZmlj
# YXRlIEF1dGhvcml0eSAyMDEwMB4XDTIxMDkzMDE4MjIyNVoXDTMwMDkzMDE4MzIy
# NVowfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcT
# B1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UE
# AxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQDk4aZM57RyIQt5osvXJHm9DtWC0/3unAcH0qlsTnXI
# yjVX9gF/bErg4r25PhdgM/9cT8dm95VTcVrifkpa/rg2Z4VGIwy1jRPPdzLAEBjo
# YH1qUoNEt6aORmsHFPPFdvWGUNzBRMhxXFExN6AKOG6N7dcP2CZTfDlhAnrEqv1y
# aa8dq6z2Nr41JmTamDu6GnszrYBbfowQHJ1S/rboYiXcag/PXfT+jlPP1uyFVk3v
# 3byNpOORj7I5LFGc6XBpDco2LXCOMcg1KL3jtIckw+DJj361VI/c+gVVmG1oO5pG
# ve2krnopN6zL64NF50ZuyjLVwIYwXE8s4mKyzbnijYjklqwBSru+cakXW2dg3viS
# kR4dPf0gz3N9QZpGdc3EXzTdEonW/aUgfX782Z5F37ZyL9t9X4C626p+Nuw2TPYr
# bqgSUei/BQOj0XOmTTd0lBw0gg/wEPK3Rxjtp+iZfD9M269ewvPV2HM9Q07BMzlM
# jgK8QmguEOqEUUbi0b1qGFphAXPKZ6Je1yh2AuIzGHLXpyDwwvoSCtdjbwzJNmSL
# W6CmgyFdXzB0kZSU2LlQ+QuJYfM2BjUYhEfb3BvR/bLUHMVr9lxSUV0S2yW6r1AF
# emzFER1y7435UsSFF5PAPBXbGjfHCBUYP3irRbb1Hode2o+eFnJpxq57t7c+auIu
# rQIDAQABo4IB3TCCAdkwEgYJKwYBBAGCNxUBBAUCAwEAATAjBgkrBgEEAYI3FQIE
# FgQUKqdS/mTEmr6CkTxGNSnPEP8vBO4wHQYDVR0OBBYEFJ+nFV0AXmJdg/Tl0mWn
# G1M1GelyMFwGA1UdIARVMFMwUQYMKwYBBAGCN0yDfQEBMEEwPwYIKwYBBQUHAgEW
# M2h0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvRG9jcy9SZXBvc2l0b3J5
# Lmh0bTATBgNVHSUEDDAKBggrBgEFBQcDCDAZBgkrBgEEAYI3FAIEDB4KAFMAdQBi
# AEMAQTALBgNVHQ8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBTV
# 9lbLj+iiXGJo0T2UkFvXzpoYxDBWBgNVHR8ETzBNMEugSaBHhkVodHRwOi8vY3Js
# Lm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNSb29DZXJBdXRfMjAx
# MC0wNi0yMy5jcmwwWgYIKwYBBQUHAQEETjBMMEoGCCsGAQUFBzAChj5odHRwOi8v
# d3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1Jvb0NlckF1dF8yMDEwLTA2
# LTIzLmNydDANBgkqhkiG9w0BAQsFAAOCAgEAnVV9/Cqt4SwfZwExJFvhnnJL/Klv
# 6lwUtj5OR2R4sQaTlz0xM7U518JxNj/aZGx80HU5bbsPMeTCj/ts0aGUGCLu6WZn
# OlNN3Zi6th542DYunKmCVgADsAW+iehp4LoJ7nvfam++Kctu2D9IdQHZGN5tggz1
# bSNU5HhTdSRXud2f8449xvNo32X2pFaq95W2KFUn0CS9QKC/GbYSEhFdPSfgQJY4
# rPf5KYnDvBewVIVCs/wMnosZiefwC2qBwoEZQhlSdYo2wh3DYXMuLGt7bj8sCXgU
# 6ZGyqVvfSaN0DLzskYDSPeZKPmY7T7uG+jIa2Zb0j/aRAfbOxnT99kxybxCrdTDF
# NLB62FD+CljdQDzHVG2dY3RILLFORy3BFARxv2T5JL5zbcqOCb2zAVdJVGTZc9d/
# HltEAY5aGZFrDZ+kKNxnGSgkujhLmm77IVRrakURR6nxt67I6IleT53S0Ex2tVdU
# CbFpAUR+fKFhbHP+CrvsQWY9af3LwUFJfn6Tvsv4O+S3Fb+0zj6lMVGEvL8CwYKi
# excdFYmNcP7ntdAoGokLjzbaukz5m/8K6TT4JDVnK+ANuOaMmdbhIurwJ0I9JZTm
# dHRbatGePu1+oDEzfbzL6Xu/OHBE0ZDxyKs6ijoIYn/ZcGNTTY3ugm2lBRDBcQZq
# ELQdVTNYs6FwZvKhggNNMIICNQIBATCB+aGB0aSBzjCByzELMAkGA1UEBhMCVVMx
# EzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoT
# FU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjElMCMGA1UECxMcTWljcm9zb2Z0IEFtZXJp
# Y2EgT3BlcmF0aW9uczEnMCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOjg2MDMtMDVF
# MC1EOTQ3MSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloiMK
# AQEwBwYFKw4DAhoDFQD7n7Bk4gsM2tbU/i+M3BtRnLj096CBgzCBgKR+MHwxCzAJ
# BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jv
# c29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwMA0GCSqGSIb3DQEBCwUAAgUA605/wjAi
# GA8yMDI1MDIwNjAwMjQzNFoYDzIwMjUwMjA3MDAyNDM0WjB0MDoGCisGAQQBhFkK
# BAExLDAqMAoCBQDrTn/CAgEAMAcCAQACAha5MAcCAQACAhMkMAoCBQDrT9FCAgEA
# MDYGCisGAQQBhFkKBAIxKDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMHoSChCjAI
# AgEAAgMBhqAwDQYJKoZIhvcNAQELBQADggEBAIvZXo6WHnbF+tzopPMUm06EFXyl
# kOcCIqJ3Mmi89NMUYOxvt+g06OkcdUIAaGJl97K8adSnDmz+S9XzlLQaiuWPiI7/
# OTuuN2DwqCXb9KxCmpDI/AYlgVyOfa1flV0ObPyBS72wclJBEkMOl38425rG0KHs
# 8jr3WOE6yhVV0BzWVCrac2LrvKEJlq/JBGRJH2nG/x9z9M57ZALRU7YotdbcnsUI
# KsiKKXIB+3ZAMujfUmBSr0krrZtRAb4aWqtSUGgSiJpuNDEMAXmGCeEwIWiND1Ee
# XmDjMq2aHz+JJ5r40PeDrnGNBQU/iCcsSWS0uqDtnlhdej1UbjSjEiUDe94xggQN
# MIIECQIBATCBkzB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQ
# MA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9u
# MSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAfGz
# RfUn6MAW1gABAAAB8TANBglghkgBZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkDMQ0G
# CyqGSIb3DQEJEAEEMC8GCSqGSIb3DQEJBDEiBCBL3hIeSiFHWhT98zCCSyT9AWFq
# +sVu3TsxFsOM779uLDCB+gYLKoZIhvcNAQkQAi8xgeowgecwgeQwgb0EINV3/T5h
# S7ijwao466RosB7wwEibt0a1P5EqIwEj9hF4MIGYMIGApH4wfDELMAkGA1UEBhMC
# VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNV
# BAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRp
# bWUtU3RhbXAgUENBIDIwMTACEzMAAAHxs0X1J+jAFtYAAQAAAfEwIgQgwlqOzV2E
# rRIl+KifFfMkp1BOigV3Z1eTyzS4xV5LUvEwDQYJKoZIhvcNAQELBQAEggIANd4E
# FZ2dq/BOn6xSOkU+OaF0Ell1aLxq226+ONjYPowqGP1y3GgMithbaQxKsg5rwojU
# ImJzmRVAPoYx4CbVVNQmFHaUR8SaweaG9a2VCqwBpUb3vPQD32ySjJenlyeioqwn
# RHq2APBaHYzv5Un4OmKy4Euy2+8Gsuk3qc+bKJJ2efM7C0UcYNIlP0Mgg8C8KxZx
# D90hRoGFI1+e+XmOrePCxHor7DPurq6dL7xlDbBb5mIAeKROFUnrMzztimWEc4IN
# s9ja/W8ApzimTXnNYQg7vZ1lvn4mpYIloA8ZfQi7lXTq5DNK+rfn1K/5VnpAlsi6
# 0CclLAl50CqLJKU8E+VSJlJMI8qMBXSGtgxooHdStlztsu4g2V+umZ8R6psT6Qux
# 9t3osE/sYWmsB/wh9HnEAj9vhdo4gfSNBsEPf/JZlIqPy8DcYByP8XtpCwWFRey8
# oRVebhkiEAcsL9KDWDqI37OW0bf5M+K3PwuRqVm8sOPh+8YSnZD+bihuUzEqdrQb
# zbfLmDF1PdQUCzxaerO1TiM8G6HAi7pXvTZriteWtmo7el7gUr6EGiK7hncxBY9m
# XKflthwhCsc5LgrlcQJgtfbH+Hld1OltqWeQIVwVGfH29GIPgXx3Az0BwxGG6Ypq
# g//TucnO3C4E3X1AoD8aReQptDMtDnCSbItxLcI=
# SIG # End signature block
