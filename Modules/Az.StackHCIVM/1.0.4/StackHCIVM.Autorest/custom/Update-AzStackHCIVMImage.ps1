<#
.Synopsis
The operation to update an image.

.Description
The operation to update an image.
Please note some properties can be set only during image creation.

.Outputs
Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Models.IGalleryImages
Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Models.IMarketplaceGalleryImages
.Link
https://learn.microsoft.com/powershell/module/az.stackhcivm/update-azstackhcivmimage
#>

function Update-AzStackHCIVMImage{
    [OutputType([Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Models.IMarketplaceGalleryImages],ParameterSetName='Marketplace' )]
    [OutputType([Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Models.IGalleryImages],ParameterSetName='GalleryImage' )]
    [CmdletBinding(DefaultParameterSetName='GalleryImage', PositionalBinding=$false, SupportsShouldProcess, ConfirmImpact='Medium')]
   
  param(
    [Parameter(ParameterSetName='ByName', Mandatory)]
    [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Path')]
    [System.String]
    # Name of the gallery image
    ${Name},

    [Parameter(ParameterSetName='ByName', Mandatory)]
    [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Path')]
    [System.String]
    # The name of the resource group.
    # The name is case insensitive.
    ${ResourceGroupName},

    [Parameter(ParameterSetName='ByName')]
    [Parameter(ParameterSetName='ByResourceId')] 
    [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Path')]
    [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Runtime.DefaultInfo(Script='(Get-AzContext).Subscription.Id')]
    [System.String]
    # The ID of the target subscription.
    ${SubscriptionId},

    [Parameter(ParameterSetName='ByResourceId', Mandatory)]
    [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Path')]
    [System.String]
    # The ARM Resource ID of the image.
    ${ResourceId},

    [Parameter(ParameterSetName='ByName')]
    [Parameter(ParameterSetName='ByResourceId')] 
    [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Body')]
    [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Runtime.Info(PossibleTypes=([Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Models.IGalleryImagesUpdateRequestTags]))]
    [System.Collections.Hashtable]
    # Resource tags
    ${Tag},

    
    [Parameter(DontShow)]
    [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Runtime')]
    [System.Management.Automation.SwitchParameter]
    # Wait for .NET debugger to attach
    ${Break},

    [Parameter(DontShow)]
    [ValidateNotNull()]
    [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Runtime')]
    [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Runtime.SendAsyncStep[]]
    # SendAsync Pipeline Steps to be appended to the front of the pipeline
    ${HttpPipelineAppend},

    [Parameter(DontShow)]
    [ValidateNotNull()]
    [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Runtime')]
    [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Runtime.SendAsyncStep[]]
    # SendAsync Pipeline Steps to be prepended to the front of the pipeline
    ${HttpPipelinePrepend},

    [Parameter()]
    [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Runtime')]
    [System.Management.Automation.SwitchParameter]
    # Run the command asynchronously
    ${NoWait},

    [Parameter(DontShow)]
    [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Runtime')]
    [System.Uri]
    # The URI for the proxy server to use
    ${Proxy},

    [Parameter(DontShow)]
    [ValidateNotNull()]
    [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Runtime')]
    [System.Management.Automation.PSCredential]
    # Credentials for a proxy server to use for the remote call
    ${ProxyCredential},

    [Parameter(DontShow)]
    [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Runtime')]
    [System.Management.Automation.SwitchParameter]
    # Use the default credentials for the proxy
    ${ProxyUseDefaultCredentials}

)

    process {
        if ($PSCmdlet.ParameterSetName -eq "ByName"){

            $isGalleryImage = $false
            $isMarketplaceGalleryImage = $false

            
            $galImage = Az.StackHCIVM.internal\Get-AzStackHCIVMGalleryImage -Name $Name -ResourceGroupName $ResourceGroupName -SubscriptionId $SubscriptionId -ErrorAction SilentlyContinue
            if ($galImage -ne $null){
                $isGalleryImage = $true 
            } else {
                $marketplaceGalImage = Az.StackHCIVM.internal\Get-AzStackHCIVMMarketplaceGalleryImage -Name $Name -ResourceGroupName $ResourceGroupName -SubscriptionId $SubscriptionId -ErrorAction SilentlyContinue
                if ($marketplaceGalImage -ne $null){
                    $isMarketplaceGalleryImage = $true 
                }else{
                    Write-Error "An Image with name: $Name does not exist in Resource Group: $ResourceGroupName" -ErrorAction Stop
                }
            }
        

            if ($isGalleryImage){
                try{
                    Az.StackHCIVM.internal\Update-AzStackHCIVMGalleryImage -ErrorAction Stop @PSBoundParameters 
                } catch {
                    $e = $_
                    if ($e.FullyQualifiedErrorId -match "MissingAzureKubernetesMapping" ){
                        Write-Error "An older version of the Arc VM cluster extension is installed on your cluster. Please downgrade the Az.StackHCIVm version to 1.0.1 to proceed." -ErrorAction Stop
                    } else {
                        Write-Error $e.Exception.Message -ErrorAction Stop
                    }
                }
            } 

            if ($isMarketplaceGalleryImage){
                try{
                    Az.StackHCIVM.internal\Update-AzStackHCIVMMarketplaceGalleryImage -ErrorAction Stop @PSBoundParameters 
                } catch {
                    $e = $_
                    if ($e.FullyQualifiedErrorId -match "MissingAzureKubernetesMapping" ){
                        Write-Error "An older version of the Arc VM cluster extension is installed on your cluster. Please downgrade the Az.StackHCIVm version to 1.0.1 to proceed." -ErrorAction Stop
                    } else {
                        Write-Error $e.Exception.Message -ErrorAction Stop
                    }
                }
                
            }

        }  elseif ($PSCmdlet.ParameterSetName -eq "ByResourceId"){
        
               if ($ResourceId -match $galImageRegex){
                
                    $subscriptionId = $($Matches['subscriptionId'])
                    $resourceGroupName = $($Matches['resourceGroupName'])
                    $resourceName = $($Matches['imageName'])
                    $null = $PSBoundParameters.Remove("ResourceId")
                    $PSBoundParameters.Add("Name", $resourceName)
                    $PSBoundParameters.Add("ResourceGroupName", $resourceGroupName)
                    $null = $PSBoundParameters.Remove("SubscriptionId")
                    $PSBoundParameters.Add("SubscriptionId", $subscriptionId)

                    try{
                        Az.StackHCIVM.internal\Update-AzStackHCIVMGalleryImage -ErrorAction Stop @PSBoundParameters 
                    } catch {
                        $e = $_
                        if ($e.FullyQualifiedErrorId -match "MissingAzureKubernetesMapping" ){
                            Write-Error "An older version of the Arc VM cluster extension is installed on your cluster. Please downgrade the Az.StackHCIVm version to 1.0.1 to proceed." -ErrorAction Stop
                        } else {
                            Write-Error $e.Exception.Message -ErrorAction Stop
                        }
                    }
                    
                } elseif ($ResourceId -match $marketplaceGalImageRegex){
                    $subscriptionId = $($Matches['subscriptionId'])
                    $resourceGroupName = $($Matches['resourceGroupName'])
                    $resourceName = $($Matches['imageName'])
                    $null = $PSBoundParameters.Remove("ResourceId")
                    $PSBoundParameters.Add("Name", $resourceName)
                    $PSBoundParameters.Add("ResourceGroupName", $resourceGroupName)
                    $null = $PSBoundParameters.Remove("SubscriptionId")
                    $PSBoundParameters.Add("SubscriptionId", $subscriptionId)
                    try{
                        Az.StackHCIVM.internal\Update-AzStackHCIVMMarketplaceGalleryImage -ErrorAction Stop @PSBoundParameters 
                    } catch {
                        $e = $_
                        if ($e.FullyQualifiedErrorId -match "MissingAzureKubernetesMapping" ){
                            Write-Error "An older version of the Arc VM cluster extension is installed on your cluster. Please downgrade the Az.StackHCIVm version to 1.0.1 to proceed." -ErrorAction Stop
                        } else {
                            Write-Error $e.Exception.Message -ErrorAction Stop
                        }
                    }

                } else {
                    Write-Error "Resource ID is invalid: $ResourceId"
                }
        }    
    }
} 
# SIG # Begin signature block
# MIInvwYJKoZIhvcNAQcCoIInsDCCJ6wCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAL46oADAS2gBwR
# lJIfBE4mpNq+m9qH2C70Tpe4zti6A6CCDXYwggX0MIID3KADAgECAhMzAAADrzBA
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
# /Xmfwb1tbWrJUnMTDXpQzTGCGZ8wghmbAgEBMIGVMH4xCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNp
# Z25pbmcgUENBIDIwMTECEzMAAAOvMEAOTKNNBUEAAAAAA68wDQYJYIZIAWUDBAIB
# BQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIDFi5WubKxUwmhQgTPSTn34v
# KmLDbiC923/5hrC32RzPMEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEB
# BQAEggEAD4QRvIV7zCCPz2Glw1QaCah7pnYrnHh7QF/+NMZCdtXaFU2H1+PTb3Ag
# JWfV8IAnhlS16Qt1H6VnKd/ePoNYUY1PDVdDV1407YHkFl88t3M4neUtKxEUvpXm
# QT/IsksZeNz2BBl71wrbG1c9WQPF6WE9Gc26DsT1WrX2l5anosydheaYkY70Vq0a
# +IDdc2tvr+re2ulzgFaqhoAdHug0ZwOQnPPfx9LDOEUTiaUPCUYOFCkQew+a8l3R
# HvC7j5yUlqenzmZALk0KpKEfYtOZ4NrgaYJlBZ5HFmOzLcJ262wMOmKnWrqyWNMd
# JHvx01R/rk93nNWvlkjG6J2gqkhdnaGCFykwghclBgorBgEEAYI3AwMBMYIXFTCC
# FxEGCSqGSIb3DQEHAqCCFwIwghb+AgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFZBgsq
# hkiG9w0BCRABBKCCAUgEggFEMIIBQAIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCDW7wMJ0i2p5LOPIHMqDniFXB/8lWeVFk7Mcqk1B1O3VwIGZjOqm5nO
# GBMyMDI0MDUxNjA2NDIxNC4zNjlaMASAAgH0oIHYpIHVMIHSMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQLEyRNaWNyb3NvZnQgSXJl
# bGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJjAkBgNVBAsTHVRoYWxlcyBUU1MgRVNO
# OjNCRDQtNEI4MC02OUMzMSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBT
# ZXJ2aWNloIIReDCCBycwggUPoAMCAQICEzMAAAHlj2rA8z20C6MAAQAAAeUwDQYJ
# KoZIhvcNAQELBQAwfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
# EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
# bjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAwHhcNMjMx
# MDEyMTkwNzM1WhcNMjUwMTEwMTkwNzM1WjCB0jELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjEtMCsGA1UECxMkTWljcm9zb2Z0IElyZWxhbmQgT3Bl
# cmF0aW9ucyBMaW1pdGVkMSYwJAYDVQQLEx1UaGFsZXMgVFNTIEVTTjozQkQ0LTRC
# ODAtNjlDMzElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2VydmljZTCC
# AiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAKl74Drau2O6LLrJO3HyTvO9
# aXai//eNyP5MLWZrmUGNOJMPwMI08V9zBfRPNcucreIYSyJHjkMIUGmuh0rPV5/2
# +UCLGrN1P77n9fq/mdzXMN1FzqaPHdKElKneJQ8R6cP4dru2Gymmt1rrGcNe800C
# cD6d/Ndoommkd196VqOtjZFA1XWu+GsFBeWHiez/PllqcM/eWntkQMs0lK0zmCfH
# +Bu7i1h+FDRR8F7WzUr/7M3jhVdPpAfq2zYCA8ZVLNgEizY+vFmgx+zDuuU/GChD
# K7klDcCw+/gVoEuSOl5clQsydWQjJJX7Z2yV+1KC6G1JVqpP3dpKPAP/4udNqpR5
# HIeb8Ta1JfjRUzSv3qSje5y9RYT/AjWNYQ7gsezuDWM/8cZ11kco1JvUyOQ8x/JD
# kMFqSRwj1v+mc6LKKlj//dWCG/Hw9ppdlWJX6psDesQuQR7FV7eCqV/lfajoLpPN
# x/9zF1dv8yXBdzmWJPeCie2XaQnrAKDqlG3zXux9tNQmz2L96TdxnIO2OGmYxBAA
# ZAWoKbmtYI+Ciz4CYyO0Fm5Z3T40a5d7KJuftF6CToccc/Up/jpFfQitLfjd71cS
# +cLCeoQ+q0n0IALvV+acbENouSOrjv/QtY4FIjHlI5zdJzJnGskVJ5ozhji0YRsc
# v1WwJFAuyyCMQvLdmPddAgMBAAGjggFJMIIBRTAdBgNVHQ4EFgQU3/+fh7tNczEi
# fEXlCQgFOXgMh6owHwYDVR0jBBgwFoAUn6cVXQBeYl2D9OXSZacbUzUZ6XIwXwYD
# VR0fBFgwVjBUoFKgUIZOaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9j
# cmwvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUyMDIwMTAoMSkuY3JsMGwG
# CCsGAQUFBwEBBGAwXjBcBggrBgEFBQcwAoZQaHR0cDovL3d3dy5taWNyb3NvZnQu
# Y29tL3BraW9wcy9jZXJ0cy9NaWNyb3NvZnQlMjBUaW1lLVN0YW1wJTIwUENBJTIw
# MjAxMCgxKS5jcnQwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcD
# CDAOBgNVHQ8BAf8EBAMCB4AwDQYJKoZIhvcNAQELBQADggIBADP6whOFjD1ad8Gk
# EJ9oLBuvfjndMyGQ9R4HgBKSlPt3pa0XVLcimrJlDnKGgFBiWwI6XOgw82hdolDi
# MDBLLWRMTJHWVeUY1gU4XB8OOIxBc9/Q83zb1c0RWEupgC48I+b+2x2VNgGJUsQI
# yPR2PiXQhT5PyerMgag9OSodQjFwpNdGirna2rpV23EUwFeO5+3oSX4JeCNZvgyU
# OzKpyMvqVaubo+Glf/psfW5tIcMjZVt0elswfq0qJNQgoYipbaTvv7xmixUJGTbi
# xYifTwAivPcKNdeisZmtts7OHbAM795ZvKLSEqXiRUjDYZyeHyAysMEALbIhdXgH
# Eh60KoZyzlBXz3VxEirE7nhucNwM2tViOlwI7EkeU5hudctnXCG55JuMw/wb7c71
# RKimZA/KXlWpmBvkJkB0BZES8OCGDd+zY/T9BnTp8si36Tql84VfpYe9iHmy7Pqq
# xqMF2Cn4q2a0mEMnpBruDGE/gR9c8SVJ2ntkARy5SfluuJ/MB61yRvT1mUx3lypp
# O22ePjBjnwoEvVxbDjT1jhdMNdevOuDeJGzRLK9HNmTDC+TdZQlj+VMgIm8ZeEIR
# NF0oaviF+QZcUZLWzWbYq6yDok8EZKFiRR5otBoGLvaYFpxBZUE8mnLKuDlYobjr
# xh7lnwrxV/fMy0F9fSo2JxFmtLgtMIIHcTCCBVmgAwIBAgITMwAAABXF52ueAptJ
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
# tB1VM1izoXBm8qGCAtQwggI9AgEBMIIBAKGB2KSB1TCB0jELMAkGA1UEBhMCVVMx
# EzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoT
# FU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEtMCsGA1UECxMkTWljcm9zb2Z0IElyZWxh
# bmQgT3BlcmF0aW9ucyBMaW1pdGVkMSYwJAYDVQQLEx1UaGFsZXMgVFNTIEVTTjoz
# QkQ0LTRCODAtNjlDMzElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2Vy
# dmljZaIjCgEBMAcGBSsOAwIaAxUA942iGuYFrsE4wzWDd85EpM6RiwqggYMwgYCk
# fjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQD
# Ex1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDANBgkqhkiG9w0BAQUFAAIF
# AOnv800wIhgPMjAyNDA1MTYxMDUxNTdaGA8yMDI0MDUxNzEwNTE1N1owdDA6Bgor
# BgEEAYRZCgQBMSwwKjAKAgUA6e/zTQIBADAHAgEAAgIG2zAHAgEAAgIUMDAKAgUA
# 6fFEzQIBADA2BgorBgEEAYRZCgQCMSgwJjAMBgorBgEEAYRZCgMCoAowCAIBAAID
# B6EgoQowCAIBAAIDAYagMA0GCSqGSIb3DQEBBQUAA4GBAE/ZvDwugy6NnYyIDV7u
# OSLWi/ufyQ+0+8oP/z2EFLWVt1PPV9ckDwOXfMyZUrmeW13sfHNC/IxUxFOo4o6f
# zlnV7jGD2rKF1A4HHzrz25qNAoYIhSmyXWxlEnQSsjafsbqZ4nebWLCpisf9Xvpk
# FD9uxVS2ajQVLxRI4TtSt9PjMYIEDTCCBAkCAQEwgZMwfDELMAkGA1UEBhMCVVMx
# EzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoT
# FU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUt
# U3RhbXAgUENBIDIwMTACEzMAAAHlj2rA8z20C6MAAQAAAeUwDQYJYIZIAWUDBAIB
# BQCgggFKMBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAvBgkqhkiG9w0BCQQx
# IgQgceR+g7i97IDFHkkiqe3SxMinoueKF8Tr3xlWZL2BE/4wgfoGCyqGSIb3DQEJ
# EAIvMYHqMIHnMIHkMIG9BCAVqdP//qjxGFhe2YboEXeb8I/pAof01CwhbxUH9U69
# 7TCBmDCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAw
# DgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24x
# JjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAAB5Y9q
# wPM9tAujAAEAAAHlMCIEIAbnS84eHhUBUYVK4RZHP3oaXBAIVzGN5U0dVtVYzunV
# MA0GCSqGSIb3DQEBCwUABIICAGTLjem33hAdRlWYmj/SUL5L16ReuhhKnISw8jdC
# B4eUsPfhe1Zz+6C/BtmQoDq5ZURocuMGzKdRLzHEeEKMDVwYZqRtsfNecmb+3sih
# Tb6O/r2qJOSWtNn8wnTbE4Rjb7Dmr0KoPb6ICWtvr4F+MDLSy9uNIoAPnHLRpskN
# 3/BqhH2xNh5t268ejlYalj67DkJkoz+iV/Z0UPBJPnph63PIaOxdmRzKNe1Qy0tj
# rRwpI3Ihu8C1m881D8TkQ6HZ+k7fUXaPgnFFx+vvwqdpEd0sQ2H6YmeuMIL1Bdge
# Q9Iyk1cVN7yg7GskT3w/X9k2NCbYY0tOB6Kjvgl8zIrOVSpSzXJ3xb7sizmTJInC
# a5kHz59xzPv/HR+T3Ncb2w+FvWuP+gHNr0Jva1iPhtLsxUgVawNxZilYH3p+RvtR
# 6v21tFzEgc01/ot9KzDzgN0iez5/bE7MGcTME8iNhAPu+Vfg4/f7SFpKGAkLNA7u
# pO9IUFfhRPV7jLoXtvnGBmgRmGm7gReUESMa4zdGBb590A7Ph9GKs2GSy7Otj/un
# KNUdyNvVVkh01FlxH2daeBKpDFKteTi6pqOkBnGVPbRgoiQhTPmG9rSJvmb1QSCx
# 5bbn9IuBKPMIFG1xwPpUVjaKYGL0psV5GBrJGaxIuEnZjW5CaqbHuiNr7KH1aw8/
# MviP
# SIG # End signature block
