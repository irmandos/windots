function Search-AzDataProtectionJobInAzGraph
{
	[OutputType('PSObject')]
    [CmdletBinding(PositionalBinding=$false)]
    [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Description('Searches for Backup Jobs in Azure Resource Graph and retrieves the expected entries')]
    
    param (
        [Parameter(Mandatory, HelpMessage='Subscription of Vault')]
        [System.String[]]
        ${Subscription},

        [Parameter(Mandatory=$false, HelpMessage='Resource Group of Vault')]
        [System.String[]]
        ${ResourceGroup},

        [Parameter(Mandatory=$false, HelpMessage='Name of the vault')]
        [System.String[]]
        ${Vault},

        [Parameter(Mandatory=$false, HelpMessage='Start Time filter for the backup Job')]
        [System.DateTime]
        ${StartTime},

        [Parameter(Mandatory=$false, HelpMessage='End Time filter for the Backup Job')]
        [System.DateTime]
        ${EndTime},

        [Parameter(Mandatory=$false, HelpMessage='Operation filter for the backup job')]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Support.JobOperation[]]
        ${Operation},

        [Parameter(Mandatory=$false, HelpMessage='Status filter for the backup job')]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Support.JobStatus[]]
        ${Status},

        [Parameter(Mandatory, HelpMessage='Datasource Type')]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Support.DatasourceTypes]
        ${DatasourceType},
                
        [Parameter()]
        [Alias('AzureRMContext', 'AzureCredential')]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        # The credentials, account, tenant, and subscription used for communication with Azure.
        ${DefaultProfile},
    
        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Wait for .NET debugger to attach
        ${Break},
    
        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Category('Runtime')]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Runtime.SendAsyncStep[]]
        # SendAsync Pipeline Steps to be appended to the front of the pipeline
        ${HttpPipelineAppend},
    
        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Category('Runtime')]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Runtime.SendAsyncStep[]]
        # SendAsync Pipeline Steps to be prepended to the front of the pipeline
        ${HttpPipelinePrepend},
    
        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Category('Runtime')]
        [System.Uri]
        # The URI for the proxy server to use
        ${Proxy},
    
        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Category('Runtime')]
        [System.Management.Automation.PSCredential]
        # Credentials for a proxy server to use for the remote call
        ${ProxyCredential},
    
        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Use the default credentials for the proxy
        ${ProxyUseDefaultCredentials}
    )

    process 
    {
        CheckResourceGraphModuleDependency

        $manifest = LoadManifest -DatasourceType $DatasourceType
        $query = GetBackupJobARGQuery
        $query = AddFilterToQuery -Query $query -FilterKey "properties.dataSourceType" -FilterValues $manifest.datasourceType

        if($PSBoundParameters.ContainsKey("ResourceGroup")) { $query = AddFilterToQuery -Query $query -FilterKey "resourceGroup" -FilterValues  $resourceGroup }
        if($PSBoundParameters.ContainsKey("Vault")) { $query = AddFilterToQuery -Query $query -FilterKey "vaultName" -FilterValues  $Vault }
        if($PSBoundParameters.ContainsKey("Operation")) { $query = AddFilterToQuery -Query $query -FilterKey "operation" -FilterValues $Operation }
        if($PSBoundParameters.ContainsKey("Status")) { $query = AddFilterToQuery -Query $query -FilterKey "status" -FilterValues $Status }

        if($StartTime -ne $null)
        {   
            $utcStartTime = $StartTime.ToUniversalTime()
            $startTimeFilter = $utcStartTime.ToString("yyyy-MM-ddTHH:mm:ssZ")
            $query += "| where properties.startTime > datetime(" + $startTimeFilter + ")"
        }

        if($EndTime -ne $null)
        {   
            $utcEndTime = $EndTime.ToUniversalTime()
            $endTimeFilter = $utcEndTime.ToString("yyyy-MM-ddTHH:mm:ssZ")
            $query += "| where properties.endTime < datetime(" + $endTimeFilter + ")"
        }

        foreach($param in @("Subscription", "ResourceGroup", "Vault", "StartTime", "EndTime", "Operation", "DatasourceType", "Status"))
        {
            if($PSBoundParameters.ContainsKey($param))
            {
                $null = $PSBoundParameters.Remove($param)
            }
        }

        $null = $PSBoundParameters.Add("Subscription", $Subscription)
        $null = $PSBoundParameters.Add("query", $query)
        $null = $PSBoundParameters.Add("First", 1000)
        $null = $PSBoundParameters.Remove("HttpPipelinePrepend")

        $argJobResponse = Az.ResourceGraph\Search-AzGraph @PSBoundParameters

        $backupJobs = @()
        foreach($jobresponse in $argJobResponse)
        {
            $jsonStringResponse = $jobresponse | ConvertTo-Json -Depth 100
            $backupJobs += [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20240401.AzureBackupJobResource]::FromJsonString($jsonStringResponse)
        }
        return $backupJobs
    }
}
# SIG # Begin signature block
# MIIoKgYJKoZIhvcNAQcCoIIoGzCCKBcCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDj3INHyscD6PCS
# aciLpstTb3xjG/BCLht9j4SgiotKAqCCDXYwggX0MIID3KADAgECAhMzAAAEBGx0
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
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIEDBzvf5Alo/EhfLe9BEPa7r
# NvgQVTmcWV8VZ+kDS4LJMEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEB
# BQAEggEAW0EW0vxdPyURH6nL98mEF6BWM+U3q4aCVInKuBb79ntHBYGie5b3hSj5
# sQLuhSqBCDTfoM0BZmSD0ZqxSHjqq41pcARTJe7aKR1ZP6y5/QRL2YUFZ5dgATOH
# QJPM/gCd7UtMN94z44wV7hia6yLSTgsJqSRpRsmr2UCWSIqp4wn4888J/M6kpTcv
# Q+XyeTCJ3Bpx6Iwce29zMDEarrd3gReYqPJIg5JJ+QhtukJCUwX35qVSqND1mkTg
# eamXEfTce7dyHHM7jnt8GaSlRCygqTdmHHMUE2xn4f/m9booMcYinmB5h3KNdQml
# On8H8uy4jxhqM5nJhzX5bDyELv1S1qGCF5QwgheQBgorBgEEAYI3AwMBMYIXgDCC
# F3wGCSqGSIb3DQEHAqCCF20wghdpAgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFSBgsq
# hkiG9w0BCRABBKCCAUEEggE9MIIBOQIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCBMVy6T3ivdcnpPEtSlXMgCL0ZTWjoiK2ydFwkR0wjJdgIGZ4j9VJGY
# GBMyMDI1MDIwNjAzMTkwOC43NzZaMASAAgH0oIHRpIHOMIHLMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1l
# cmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046OTIwMC0w
# NUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2Wg
# ghHqMIIHIDCCBQigAwIBAgITMwAAAecujy+TC08b6QABAAAB5zANBgkqhkiG9w0B
# AQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYD
# VQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAeFw0yMzEyMDYxODQ1
# MTlaFw0yNTAzMDUxODQ1MTlaMIHLMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25z
# MScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046OTIwMC0wNUUwLUQ5NDcxJTAjBgNV
# BAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2UwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQDCV58v4IuQ659XPM1DtaWMv9/HRUC5kdiEF89YBP6/
# Rn7kjqMkZ5ESemf5Eli4CLtQVSefRpF1j7S5LLKisMWOGRaLcaVbGTfcmI1vMRJ1
# tzMwCNIoCq/vy8WH8QdV1B/Ab5sK+Q9yIvzGw47TfXPE8RlrauwK/e+nWnwMt060
# akEZiJJz1Vh1LhSYKaiP9Z23EZmGETCWigkKbcuAnhvh3yrMa89uBfaeHQZEHGQq
# dskM48EBcWSWdpiSSBiAxyhHUkbknl9PPztB/SUxzRZjUzWHg9bf1mqZ0cIiAWC0
# EjK7ONhlQfKSRHVLKLNPpl3/+UL4Xjc0Yvdqc88gOLUr/84T9/xK5r82ulvRp2A8
# /ar9cG4W7650uKaAxRAmgL4hKgIX5/0aIAsbyqJOa6OIGSF9a+DfXl1LpQPNKR79
# 2scF7tjD5WqwIuifS9YUiHMvRLjjKk0SSCV/mpXC0BoPkk5asfxrrJbCsJePHSOE
# blpJzRmzaP6OMXwRcrb7TXFQOsTkKuqkWvvYIPvVzC68UM+MskLPld1eqdOOMK7S
# bbf2tGSZf3+iOwWQMcWXB9gw5gK3AIYK08WkJJuyzPqfitgubdRCmYr9CVsNOuW+
# wHDYGhciJDF2LkrjkFUjUcXSIJd9f2ssYitZ9CurGV74BQcfrxjvk1L8jvtN7mul
# IwIDAQABo4IBSTCCAUUwHQYDVR0OBBYEFM/+4JiAnzY4dpEf/Zlrh1K73o9YMB8G
# A1UdIwQYMBaAFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMF8GA1UdHwRYMFYwVKBSoFCG
# Tmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUy
# MFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNybDBsBggrBgEFBQcBAQRgMF4w
# XAYIKwYBBQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2Vy
# dHMvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUyMDIwMTAoMSkuY3J0MAwG
# A1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQD
# AgeAMA0GCSqGSIb3DQEBCwUAA4ICAQB0ofDbk+llWi1cC6nsfie5Jtp09o6b6ARC
# pvtDPq2KFP+hi+UNNP7LGciKuckqXCmBTFIhfBeGSxvk6ycokdQr3815pEOaYWTn
# HvQ0+8hKy86r1F4rfBu4oHB5cTy08T4ohrG/OYG/B/gNnz0Ol6v7u/qEjz48zXZ6
# ZlxKGyZwKmKZWaBd2DYEwzKpdLkBxs6A6enWZR0jY+q5FdbV45ghGTKgSr5ECAOn
# LD4njJwfjIq0mRZWwDZQoXtJSaVHSu2lHQL3YHEFikunbUTJfNfBDLL7Gv+sTmRi
# DZky5OAxoLG2gaTfuiFbfpmSfPcgl5COUzfMQnzpKfX6+FkI0QQNvuPpWsDU8sR+
# uni2VmDo7rmqJrom4ihgVNdLaMfNUqvBL5ZiSK1zmaELBJ9a+YOjE5pmSarW5sGb
# n7iVkF2W9JQIOH6tGWLFJS5Hs36zahkoHh8iD963LeGjZqkFusKaUW72yMj/yxTe
# GEDOoIr35kwXxr1Uu+zkur2y+FuNY0oZjppzp95AW1lehP0xaO+oBV1XfvaCur/B
# 5PVAp2xzrosMEUcAwpJpio+VYfIufGj7meXcGQYWA8Umr8K6Auo+Jlj8IeFS6lSv
# KhqQpmdBzAMGqPOQKt1Ow3ZXxehK7vAiim3ZiALlM0K546k0sZrxdZPgpmz7O8w9
# gHLuyZAQezCCB3EwggVZoAMCAQICEzMAAAAVxedrngKbSZkAAAAAABUwDQYJKoZI
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
# MCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOjkyMDAtMDVFMC1EOTQ3MSUwIwYDVQQD
# ExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloiMKAQEwBwYFKw4DAhoDFQCz
# cgTnGasSwe/dru+cPe1NF/vwQ6CBgzCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFBDQSAyMDEwMA0GCSqGSIb3DQEBCwUAAgUA606AwTAiGA8yMDI1MDIwNjAwMjg0
# OVoYDzIwMjUwMjA3MDAyODQ5WjB0MDoGCisGAQQBhFkKBAExLDAqMAoCBQDrToDB
# AgEAMAcCAQACAjitMAcCAQACAhRKMAoCBQDrT9JBAgEAMDYGCisGAQQBhFkKBAIx
# KDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMHoSChCjAIAgEAAgMBhqAwDQYJKoZI
# hvcNAQELBQADggEBAGT0o/g7YjkumIDRSzGG9f4FJRe+AZkqmrep9hbeCRViadwi
# 2DRuzd2Flxzfxd6ZJ+tcRDrgdUSKl/9H1l2Wsy/1xR5K8SUFASGm11eKrPvIxWc8
# EBpOA/OAPdZdqoVQm23qdxWczOjp3qiJOy7xk1kbwjtAQfOtlBFSRpIyWj+kWxZQ
# Z/+GPv/zRss0mbtOw9yYFl7aB2ZU4NR4dsHE/TXZSKO7ZEexndgDv0K1+ReZ9TXU
# o3P1bDwyebGNCtRdkR5ILcHPt7KAxdtSA/j0emNHp0JHVhNpctdcUjzAYvvt7brT
# HV7/dTJfqlv4rmrfutpqkLY/cAJXoHREop6ida4xggQNMIIECQIBATCBkzB8MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNy
# b3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAecujy+TC08b6QABAAAB5zAN
# BglghkgBZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMC8G
# CSqGSIb3DQEJBDEiBCDeI8ZM9KGlMxOlj7kOsUKXrx7TxCMIVEyEeqWzbvRrVzCB
# +gYLKoZIhvcNAQkQAi8xgeowgecwgeQwgb0EIOU2XQ12aob9DeDFXM9UFHeEX74F
# v0ABvQMG7qC51nOtMIGYMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldh
# c2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBD
# b3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIw
# MTACEzMAAAHnLo8vkwtPG+kAAQAAAecwIgQgxPTOA3ra8QtLS/MGt8XbMzGrLg0p
# o1tjSwX1YF/qG0gwDQYJKoZIhvcNAQELBQAEggIALe69r18p/edrMuc4CiqunmRQ
# UxOqeV2NCXe1/4nt5MuIir7xSHAaxLO+wyQ8JcWjox3WrWpTMUA7r1Qs/R1mT7zI
# AEt7XbyHH8ElbdzgRyfVCUjPdmJQ+IQ0MAEEp72tj0QSZVsxJLx08WM3MXT0pN5H
# 7co1XFgPCBDGVJ2UksuBpOiZ9WRR7jB6Lj6gkgu46QRBme9kZj1Ox8mBZP4kFRKH
# fy28Fn15dE448oZfXCssfoOaK7fVIfFnHOT0sc79DLmf+bnDr269H/WSKVUHn6zr
# xLiBbhRMrC3HEMCcFTma2glFAAbBJc0F0IZpMq8FugnUS0DwRFwGLfobhgMNel6a
# D90G6F5dF/qESDi4yFQXLPEzL38Z4AZEPvvfChmOAMxMSxguCjMRe9d9O+io1RUk
# +7N+4rItNBtp1iMsAXIL7BvPPOkhXROJRjIp5ipTFHABTIabf8ycA7ts8uBo5HI6
# jEMQ4D67QHa/nWTG6TPG9a0yVeSfnrm8w7iZGBlOYRPlsSDny3Ybwm+c70z7KMk0
# PMvaBhJ5y8fe2w1uo/o7D5ZSOROB2QDDK/ACBT7OWnEPLyC2EkkxnrZUsFVdSZqR
# p83+l/98SRkrV6+npwIMCfJAZRFGAnaspODjM0Ry9MxwbmO4gjTZ7X+GZSaaiMOL
# q+zcDtIjVwKbjzuksn8=
# SIG # End signature block
