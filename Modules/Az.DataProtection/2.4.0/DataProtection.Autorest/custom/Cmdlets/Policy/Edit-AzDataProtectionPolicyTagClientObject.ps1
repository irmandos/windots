function Edit-AzDataProtectionPolicyTagClientObject{
	[OutputType('Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20240401.IBackupPolicy')]
    [CmdletBinding(PositionalBinding=$false)]
    [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Description('Adds or removes schedule tag in an existing backup policy.')]

    param(
        [Parameter(ParameterSetName='updateTag', Mandatory, HelpMessage='Backup Policy Object.')]
        [Parameter(ParameterSetName='RemoveTag', Mandatory, HelpMessage='Backup Policy Object.')]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20240401.IBackupPolicy]
        ${Policy},

        [Parameter(ParameterSetName='updateTag', Mandatory, HelpMessage='Name of the Schedule tag.')]
        [Parameter(ParameterSetName='RemoveTag', Mandatory, HelpMessage='Name of the Schedule tag.')]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Support.TagName]
        ${Name},

        [Parameter(ParameterSetName='RemoveTag', Mandatory, HelpMessage='Specify whether to remove the tag from the given policy object.')]
        [System.Management.Automation.SwitchParameter]
        ${RemoveRule},

        [Parameter(ParameterSetName='updateTag', Mandatory, HelpMessage='Criterias to be associated with the schedule tag.')]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20240401.IScheduleBasedBackupCriteria[]]
        ${Criteria}
    )

    process{
        # Validate the Criteria

        $clientDatasourceType = GetClientDatasourceType -ServiceDatasourceType $Policy.DatasourceType[0]
        $manifest = LoadManifest -DatasourceType $clientDatasourceType

        if($manifest.policySettings.supportedRetentionTags.Contains($Name.ToString()) -eq $false)
        {
            throw "Selected Retention Tag " + $Name  + " is not applicable for Datasource Type " + $clientDatasourceType
        }

        if($manifest.policySettings.disableCustomRetentionTag -eq $true)
        {
            foreach($criterion in $criteria)
            {
                if($criterion.AbsoluteCriterion -eq $null)
                {
                    throw "Only Absolute Criteria is supported for this policy"
                }
            }
        }

        $parameterSetName = $PsCmdlet.ParameterSetName
        $backupRuleIndex = -1
        foreach($index in (0..$Policy.PolicyRule.Length))
        {
            if($Policy.PolicyRule[$index].ObjectType -eq "AzureBackupRule")
            {
                $backupRuleIndex = $index
            }
        }

        if($backupRuleIndex -ne -1)
        {
            if($parameterSetName -eq "RemoveTag")
            {
                $filteredTags = $Policy.PolicyRule[$backupRuleIndex].Trigger.TaggingCriterion | Where-Object { $_.TagInfoTagName –ne $Name }
                $Policy.PolicyRule[$backupRuleIndex].Trigger.TaggingCriterion = $filteredTags
                return $Policy
            }

            if($parameterSetName -eq "updateTag")
            {
                $tagIndex = -1
                foreach($index in (0..$Policy.PolicyRule[$backupRuleIndex].Trigger.TaggingCriterion.Length))
                {
                    if($Policy.PolicyRule[$backupRuleIndex].Trigger.TaggingCriterion[$index].TagInfoTagName -eq $Name)
                    {
                        $tagIndex = $index
                    }
                }

                if($tagIndex -ne -1)
                {
                    $Policy.PolicyRule[$backupRuleIndex].Trigger.TaggingCriterion[$tagIndex].Criterion = $Criteria
                    return $Policy
                }
                
                if($tagIndex -eq -1)
                {
                    $tagCriteria = [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20240401.TaggingCriteria]::new()
                    $tagCriteria.TaggingPriority = GetTaggingPriority -Name $Name
                    $tagCriteria.Criterion = $Criteria
                    $tagCriteria.TagInfoTagName = $Name

                    $Policy.PolicyRule[$backupRuleIndex].Trigger.TaggingCriterion += $tagCriteria
                    return $Policy
                }
            }
        }
        
    }
}
# SIG # Begin signature block
# MIInwQYJKoZIhvcNAQcCoIInsjCCJ64CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCGqYeFhNWbmlX0
# elMtJqY0Zp7PNKWN+Lt3MHZc2zE616CCDXYwggX0MIID3KADAgECAhMzAAADrzBA
# DkyjTQVBAAAAAAOvMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjMxMTE2MTkwOTAwWhcNMjQxMTE0MTkwOTAwWjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQDOS8s1ra6f0YGtg0OhEaQa/t3Q+q1MEHhWJhqQVuO5amYXQpy8MDPNoJYk+FWA
# hePP5LxwcSge5aen+f5Q6WNPd6EDxGzotvVpNi5ve0H97S3F7C/axDfKxyNh21MG
# 0W8Sb0vxi/vorcLHOL9i+t2D6yvvDzLlEefUCbQV/zGCBjXGlYJcUj6RAzXyeNAN
# xSpKXAGd7Fh+ocGHPPphcD9LQTOJgG7Y7aYztHqBLJiQQ4eAgZNU4ac6+8LnEGAL
# go1ydC5BJEuJQjYKbNTy959HrKSu7LO3Ws0w8jw6pYdC1IMpdTkk2puTgY2PDNzB
# tLM4evG7FYer3WX+8t1UMYNTAgMBAAGjggFzMIIBbzAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQURxxxNPIEPGSO8kqz+bgCAQWGXsEw
# RQYDVR0RBD4wPKQ6MDgxHjAcBgNVBAsTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEW
# MBQGA1UEBRMNMjMwMDEyKzUwMTgyNjAfBgNVHSMEGDAWgBRIbmTlUAXTgqoXNzci
# tW2oynUClTBUBgNVHR8ETTBLMEmgR6BFhkNodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpb3BzL2NybC9NaWNDb2RTaWdQQ0EyMDExXzIwMTEtMDctMDguY3JsMGEG
# CCsGAQUFBwEBBFUwUzBRBggrBgEFBQcwAoZFaHR0cDovL3d3dy5taWNyb3NvZnQu
# Y29tL3BraW9wcy9jZXJ0cy9NaWNDb2RTaWdQQ0EyMDExXzIwMTEtMDctMDguY3J0
# MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQADggIBAISxFt/zR2frTFPB45Yd
# mhZpB2nNJoOoi+qlgcTlnO4QwlYN1w/vYwbDy/oFJolD5r6FMJd0RGcgEM8q9TgQ
# 2OC7gQEmhweVJ7yuKJlQBH7P7Pg5RiqgV3cSonJ+OM4kFHbP3gPLiyzssSQdRuPY
# 1mIWoGg9i7Y4ZC8ST7WhpSyc0pns2XsUe1XsIjaUcGu7zd7gg97eCUiLRdVklPmp
# XobH9CEAWakRUGNICYN2AgjhRTC4j3KJfqMkU04R6Toyh4/Toswm1uoDcGr5laYn
# TfcX3u5WnJqJLhuPe8Uj9kGAOcyo0O1mNwDa+LhFEzB6CB32+wfJMumfr6degvLT
# e8x55urQLeTjimBQgS49BSUkhFN7ois3cZyNpnrMca5AZaC7pLI72vuqSsSlLalG
# OcZmPHZGYJqZ0BacN274OZ80Q8B11iNokns9Od348bMb5Z4fihxaBWebl8kWEi2O
# PvQImOAeq3nt7UWJBzJYLAGEpfasaA3ZQgIcEXdD+uwo6ymMzDY6UamFOfYqYWXk
# ntxDGu7ngD2ugKUuccYKJJRiiz+LAUcj90BVcSHRLQop9N8zoALr/1sJuwPrVAtx
# HNEgSW+AKBqIxYWM4Ev32l6agSUAezLMbq5f3d8x9qzT031jMDT+sUAoCw0M5wVt
# CUQcqINPuYjbS1WgJyZIiEkBMIIHejCCBWKgAwIBAgIKYQ6Q0gAAAAAAAzANBgkq
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
# /Xmfwb1tbWrJUnMTDXpQzTGCGaEwghmdAgEBMIGVMH4xCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNp
# Z25pbmcgUENBIDIwMTECEzMAAAOvMEAOTKNNBUEAAAAAA68wDQYJYIZIAWUDBAIB
# BQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIEQok467LUlg/rb5b0ucriKV
# S4N2gIS4soaKQEpIvNsgMEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEB
# BQAEggEAlFT3vlEINXnUrdXQtJKV+/hAsEoxP25RVfmwXkNbbLAwWQnZBPuuMiAO
# 9wo9xjN4yA/dsqpq+YIlHcOCb8dA/T1L49nyc2tjzQ8gV65/uqGyIaW9zf9nvQyM
# X0ZK8XCH65xHJlDaVRn8GyRt7WFFCAlTWVFsMHfT8UV4v3lZQtR3ZeD9ql3EIBWj
# gJIosaM2Hh8uyKzItlxSl+56IPocoeQboBmwv8pofOygao/47xGv/zA5aRS9EKMA
# HqT/WabdHCADNfmdBzsYFgEq42Ua92GAvfQJj15uIE/b9YOYidDHIapxqDpLixvJ
# JQbJO7UnTqeaB2MSBDD5YSjSC/OtLKGCFyswghcnBgorBgEEAYI3AwMBMYIXFzCC
# FxMGCSqGSIb3DQEHAqCCFwQwghcAAgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFYBgsq
# hkiG9w0BCRABBKCCAUcEggFDMIIBPwIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCBCTdtMVOMAd8OKOyqpzeGcGzRpc2seXrinEh701HpvLwIGZh/Gspo9
# GBIyMDI0MDQyMzEzMTUyMi44NlowBIACAfSggdikgdUwgdIxCzAJBgNVBAYTAlVT
# MRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQK
# ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xLTArBgNVBAsTJE1pY3Jvc29mdCBJcmVs
# YW5kIE9wZXJhdGlvbnMgTGltaXRlZDEmMCQGA1UECxMdVGhhbGVzIFRTUyBFU046
# OEQ0MS00QkY3LUIzQjcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNl
# cnZpY2WgghF7MIIHJzCCBQ+gAwIBAgITMwAAAePfvZuaHGiDIgABAAAB4zANBgkq
# hkiG9w0BAQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQ
# MA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9u
# MSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAeFw0yMzEw
# MTIxOTA3MjlaFw0yNTAxMTAxOTA3MjlaMIHSMQswCQYDVQQGEwJVUzETMBEGA1UE
# CBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9z
# b2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQLEyRNaWNyb3NvZnQgSXJlbGFuZCBPcGVy
# YXRpb25zIExpbWl0ZWQxJjAkBgNVBAsTHVRoYWxlcyBUU1MgRVNOOjhENDEtNEJG
# Ny1CM0I3MSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNlMIIC
# IjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAvqQNaB5Gn5/FIFQPo3/K4Qml
# eCDMF40bkoHwz0BshZ4SiQmA6CGUyDwmaqQ2wHhaXU0RdHtwvq+U8KxYYsyHKqax
# xC7fr/yHZvHpNTgzx1VkR3pXhT6X2Cm175UX3WQ4jfl86onp5AMzBIFDlz0SU8VS
# KNMDvNXtjk9FitLgUv2nj3hOJ0KkEQfk3oA7m7zA0D+Mo73hmR+OC7uwsXxJR2tz
# UZE0STYX3UvenFH7fYWy5BNmLyGq2sWkQ5HFvJKCJAE/dwft8+V43U3KeExF/pPt
# cLUvQ9HIrL0xnpMFau7Yd5aK+TEi57WctBv87+fSPZBV3jZl/QCtcH9WrniBDwki
# 9QfRxu/JYzw+iaEWLqrYXuF7jeOGvHK+fVeLWnAc5WxsfbpjEMpNbGXbSF9At3PP
# hFVOjxwVEx1ALGUqRKehw9ap9X/gfkA9I9eTSvwJz9wya9reDgS+6kXgSttI7RQ2
# cJG/tQPGVIaLCIaSafLneaq0Bns0t4+EW3B/GnoBMiiOXwleOvf5udBZQIMJ3k5q
# nnh8Z4ZhTwrE6iGbPrTgGBPXh7exFYAGlb6hdhILIVDdJlDf8s1NVvL0Q2y4SHZQ
# hApZTuW/tyGsGscIPDSMz5bA6NhRLtjEwCFpLI5qGlu50Au9FRelCEQsWg7q07H/
# rqHOqCNJM4Rjem7joEUCAwEAAaOCAUkwggFFMB0GA1UdDgQWBBSxrg1mvjUVt6Fn
# xj56nabZiJipAzAfBgNVHSMEGDAWgBSfpxVdAF5iXYP05dJlpxtTNRnpcjBfBgNV
# HR8EWDBWMFSgUqBQhk5odHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2Ny
# bC9NaWNyb3NvZnQlMjBUaW1lLVN0YW1wJTIwUENBJTIwMjAxMCgxKS5jcmwwbAYI
# KwYBBQUHAQEEYDBeMFwGCCsGAQUFBzAChlBodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMFRpbWUtU3RhbXAlMjBQQ0ElMjAy
# MDEwKDEpLmNydDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMI
# MA4GA1UdDwEB/wQEAwIHgDANBgkqhkiG9w0BAQsFAAOCAgEAt76bLqnU08wRbW3v
# RrxjaEbGPqyINK6UYCzhTGaR/PEwCJziPT4ZM9sfGTX3eZDQVE9r121tFtp7NXQY
# uQSxRZMYXa0/pawN2Xn+UPjBRDvoCsU56dwKkrmy8TSw7QXKGskdnEwsI5yW93q8
# Ag86RkBiKEEf9FdzHNuKWI4Kv//fDtESewu46n/u+VckCwbOYl6wE//QRGrGMq50
# 9a4EbP+p1GUm06Xme/01mTIuKDgPmHL2nYRzXNqi2IuIecn2aWwkRxQOFiPw+dic
# mOOwLG/7InNqjZpQeIhDMxsWr4zTxzy4ER/6zfthtlDtcAXHB7YRUkBTClaOa0nd
# vfNJZMyYVa6cWvZouTq9V5LS7UzIR8S/7RsOT43eOawLBsuQz0VoOLurYe1SffPq
# TsCcRNzbx0C8t/+KipStVhPAGttEfhdUUS9ohD6Lt6wNCJxZbV0IMD8nfE6gIQJX
# rzrXWOuJqN91WDyjRan4UKDkIBS2yWA4W6JhQuBzGerOSY/aLnxkRrSubgtnKYcH
# OwgxTTIya5WYCRjFt0QOLleqVki6k+mqYPr98uMPi5vRIQS206mDSenStr8w0J+/
# +1WEm3PnCCIQgpf6zhqRrAt9j7XrEMHrg2bQegaz8bLzbe6UibgbKtRyk1nGde8T
# o5kyMj9XUCBICDxT+F4xa5lNZVQwggdxMIIFWaADAgECAhMzAAAAFcXna54Cm0mZ
# AAAAAAAVMA0GCSqGSIb3DQEBCwUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNyb3NvZnQgUm9vdCBDZXJ0aWZpY2F0
# ZSBBdXRob3JpdHkgMjAxMDAeFw0yMTA5MzAxODIyMjVaFw0zMDA5MzAxODMyMjVa
# MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdS
# ZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMT
# HU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwMIICIjANBgkqhkiG9w0BAQEF
# AAOCAg8AMIICCgKCAgEA5OGmTOe0ciELeaLL1yR5vQ7VgtP97pwHB9KpbE51yMo1
# V/YBf2xK4OK9uT4XYDP/XE/HZveVU3Fa4n5KWv64NmeFRiMMtY0Tz3cywBAY6GB9
# alKDRLemjkZrBxTzxXb1hlDcwUTIcVxRMTegCjhuje3XD9gmU3w5YQJ6xKr9cmmv
# Haus9ja+NSZk2pg7uhp7M62AW36MEBydUv626GIl3GoPz130/o5Tz9bshVZN7928
# jaTjkY+yOSxRnOlwaQ3KNi1wjjHINSi947SHJMPgyY9+tVSP3PoFVZhtaDuaRr3t
# pK56KTesy+uDRedGbsoy1cCGMFxPLOJiss254o2I5JasAUq7vnGpF1tnYN74kpEe
# HT39IM9zfUGaRnXNxF803RKJ1v2lIH1+/NmeRd+2ci/bfV+AutuqfjbsNkz2K26o
# ElHovwUDo9Fzpk03dJQcNIIP8BDyt0cY7afomXw/TNuvXsLz1dhzPUNOwTM5TI4C
# vEJoLhDqhFFG4tG9ahhaYQFzymeiXtcodgLiMxhy16cg8ML6EgrXY28MyTZki1ug
# poMhXV8wdJGUlNi5UPkLiWHzNgY1GIRH29wb0f2y1BzFa/ZcUlFdEtsluq9QBXps
# xREdcu+N+VLEhReTwDwV2xo3xwgVGD94q0W29R6HXtqPnhZyacaue7e3PmriLq0C
# AwEAAaOCAd0wggHZMBIGCSsGAQQBgjcVAQQFAgMBAAEwIwYJKwYBBAGCNxUCBBYE
# FCqnUv5kxJq+gpE8RjUpzxD/LwTuMB0GA1UdDgQWBBSfpxVdAF5iXYP05dJlpxtT
# NRnpcjBcBgNVHSAEVTBTMFEGDCsGAQQBgjdMg30BATBBMD8GCCsGAQUFBwIBFjNo
# dHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL0RvY3MvUmVwb3NpdG9yeS5o
# dG0wEwYDVR0lBAwwCgYIKwYBBQUHAwgwGQYJKwYBBAGCNxQCBAweCgBTAHUAYgBD
# AEEwCwYDVR0PBAQDAgGGMA8GA1UdEwEB/wQFMAMBAf8wHwYDVR0jBBgwFoAU1fZW
# y4/oolxiaNE9lJBb186aGMQwVgYDVR0fBE8wTTBLoEmgR4ZFaHR0cDovL2NybC5t
# aWNyb3NvZnQuY29tL3BraS9jcmwvcHJvZHVjdHMvTWljUm9vQ2VyQXV0XzIwMTAt
# MDYtMjMuY3JsMFoGCCsGAQUFBwEBBE4wTDBKBggrBgEFBQcwAoY+aHR0cDovL3d3
# dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy9NaWNSb29DZXJBdXRfMjAxMC0wNi0y
# My5jcnQwDQYJKoZIhvcNAQELBQADggIBAJ1VffwqreEsH2cBMSRb4Z5yS/ypb+pc
# FLY+TkdkeLEGk5c9MTO1OdfCcTY/2mRsfNB1OW27DzHkwo/7bNGhlBgi7ulmZzpT
# Td2YurYeeNg2LpypglYAA7AFvonoaeC6Ce5732pvvinLbtg/SHUB2RjebYIM9W0j
# VOR4U3UkV7ndn/OOPcbzaN9l9qRWqveVtihVJ9AkvUCgvxm2EhIRXT0n4ECWOKz3
# +SmJw7wXsFSFQrP8DJ6LGYnn8AtqgcKBGUIZUnWKNsIdw2FzLixre24/LAl4FOmR
# sqlb30mjdAy87JGA0j3mSj5mO0+7hvoyGtmW9I/2kQH2zsZ0/fZMcm8Qq3UwxTSw
# ethQ/gpY3UA8x1RtnWN0SCyxTkctwRQEcb9k+SS+c23Kjgm9swFXSVRk2XPXfx5b
# RAGOWhmRaw2fpCjcZxkoJLo4S5pu+yFUa2pFEUep8beuyOiJXk+d0tBMdrVXVAmx
# aQFEfnyhYWxz/gq77EFmPWn9y8FBSX5+k77L+DvktxW/tM4+pTFRhLy/AsGConsX
# HRWJjXD+57XQKBqJC4822rpM+Zv/Cuk0+CQ1ZyvgDbjmjJnW4SLq8CdCPSWU5nR0
# W2rRnj7tfqAxM328y+l7vzhwRNGQ8cirOoo6CGJ/2XBjU02N7oJtpQUQwXEGahC0
# HVUzWLOhcGbyoYIC1zCCAkACAQEwggEAoYHYpIHVMIHSMQswCQYDVQQGEwJVUzET
# MBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMV
# TWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQLEyRNaWNyb3NvZnQgSXJlbGFu
# ZCBPcGVyYXRpb25zIExpbWl0ZWQxJjAkBgNVBAsTHVRoYWxlcyBUU1MgRVNOOjhE
# NDEtNEJGNy1CM0I3MSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2
# aWNloiMKAQEwBwYFKw4DAhoDFQA9iJe7w5FDiG8py4TsYrQI6DFaeqCBgzCBgKR+
# MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdS
# ZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMT
# HU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwMA0GCSqGSIb3DQEBBQUAAgUA
# 6dItbjAiGA8yMDI0MDQyMzIwNTE1OFoYDzIwMjQwNDI0MjA1MTU4WjB3MD0GCisG
# AQQBhFkKBAExLzAtMAoCBQDp0i1uAgEAMAoCAQACAgLdAgH/MAcCAQACAiSXMAoC
# BQDp037uAgEAMDYGCisGAQQBhFkKBAIxKDAmMAwGCisGAQQBhFkKAwKgCjAIAgEA
# AgMHoSChCjAIAgEAAgMBhqAwDQYJKoZIhvcNAQEFBQADgYEAvmD8fY6wG83uxGxZ
# CmJ9xnfFi4JpAJql96Ej+wjIIywR4W3/YijmRIGI2HCh+j31fGT8oLMIAJwVvIDb
# XpTC/FlBtlaAFxqtcs/tGf1D5TXRTX2YQ28pW4VPNm3f7X0r9bv5BDhjQw5Zphm4
# zY75reUduti6reMCF4n5Ynw4HCsxggQNMIIECQIBATCBkzB8MQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGlt
# ZS1TdGFtcCBQQ0EgMjAxMAITMwAAAePfvZuaHGiDIgABAAAB4zANBglghkgBZQME
# AgEFAKCCAUowGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMC8GCSqGSIb3DQEJ
# BDEiBCBP7cRHiCWbzgYYxiM1DmehRMJMklDcq2n8DNluPXOY3jCB+gYLKoZIhvcN
# AQkQAi8xgeowgecwgeQwgb0EIDPUI6vlsP5k90SBCNa9wha4MlxBt2Crw12PTHIy
# 5iYqMIGYMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
# EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
# bjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTACEzMAAAHj
# 372bmhxogyIAAQAAAeMwIgQgCNtoc2vQwRVLix0goXMMSKygqAow+oDXb4OLAdrX
# hFwwDQYJKoZIhvcNAQELBQAEggIAnvYGK0mEYVOi2qxld8WAt/TW1XJfh+oo/L+Y
# gm1hU2wq8E2fdfgsHMWy+jEJ18m4p/rt7tuwYKZ3e3w4tL8Nj/GrwErapQBGQ4Wu
# 0lMBS33HMM9mATCP2C+6roIB4HYclpAu6I7xoWl72zzdkAuxPTTLmuwjjulVa2G0
# mybxkdc8d3VeZYHRnTx+Pto08bWkMZYle2s5P0cc+Im7eIHx0DTxCnLdQY5tHpmG
# pvVMaV6sTug9ARcWp9UggE/9Ny5sJiL+CZxzA43mRzxnMOkpyz0i0+le/gPaOlRs
# rwv0O/A9BbSTJZoxrJmpkQE/RBhUWWfLxqVyRksuKpx7hsZKR+jD+AAgC2ZTjsiq
# PEHy5lR23IGJNADO4uOs2XKQINqr+RND08ZC+67RQMWWt5kcpekuCL5DNwaPhHxb
# fbCCLIQdcLAViplyy4qXHBnJNDD9rdkT8MEt9g5PDANGVaG/Gn5VF4hL1+SzPPXF
# QhwR7V774P7gJ30f+COmQx4ZR//kdJal9/iiw/mVk2RcP7iR17mfDRJD60YKvskb
# lcH9k+zB4vlpa/MCRSqMAweVviOEr/pW8l0GjXJ3JM6h2GsDFqF6oYoitXBZP9Mc
# d0iG0Dwat80AEd7iio/AqWouyA8PKC6KhKBx4f0lbT0WFjOlHDyLvf65CO3FuhP5
# ZXfmh50=
# SIG # End signature block
