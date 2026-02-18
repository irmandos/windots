
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
Swaps VIPs between two cloud service (extended support) load balancers.
.Description
Swaps VIPs between two cloud service (extended support) load balancers.

.Link
https://learn.microsoft.com/powershell/module/az.cloudservice/Switch-AzCloudService

#>
function Switch-AzCloudService {
    [OutputType([System.Boolean])]
    [CmdletBinding(DefaultParameterSetName='CloudServiceName', PositionalBinding=$false, SupportsShouldProcess, ConfirmImpact='High')]
    param(
    
        [Parameter(ParameterSetName='CloudService')]
        [Parameter(ParameterSetName='CloudServiceName')]
        [Microsoft.Azure.PowerShell.Cmdlets.CloudService.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.CloudService.Runtime.DefaultInfo(Script='(Get-AzContext).Subscription.Id')]
        [System.String]
        # Subscription credentials which uniquely identify Microsoft Azure subscription.
        # The subscription ID forms part of the URI for every service call.
        ${SubscriptionId},
    
        [Parameter(Mandatory=$true, ParameterSetName="CloudService")]
        [Microsoft.Azure.PowerShell.Cmdlets.CloudService.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.CloudService.Models.Api20220904.CloudService]
        ${CloudService},
    
        [Parameter(Mandatory=$true, ParameterSetName="CloudServiceName")]
        [Microsoft.Azure.PowerShell.Cmdlets.CloudService.Category('Path')]
        [System.String]
        ${ResourceGroupName},
        
        [Parameter(Mandatory=$true, ParameterSetName="CloudServiceName")]
        [Microsoft.Azure.PowerShell.Cmdlets.CloudService.Category('Path')]
        [System.String] 
        ${CloudServiceName},

        [Parameter()]
        [switch] 
        ${Async},

        [Parameter()]
        [Alias('AzureRMContext', 'AzureCredential')]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.CloudService.Category('Azure')]
        [System.Management.Automation.PSObject]
        # The credentials, account, tenant, and subscription used for communication with Azure.
        ${DefaultProfile},
    
        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.CloudService.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Run the command as a job
        ${AsJob},
    
        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.CloudService.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Wait for .NET debugger to attach
        ${Break}
    )
    
    process {
        $ApiVersion = "2020-06-01"
        if (-not $PSBoundParameters.ContainsKey("SubscriptionId")) {
            $SubscriptionId = (Get-AzContext).Subscription.Id
        }

        # Fetch the services to ensure that we have the latest information
        if ($PSBoundParameters.ContainsKey("CloudService")) {
            $CloudServiceName = $CloudService.Name
            $ResourceGroupName = $CloudService.ResourceGroupName
        }

        $SourceCloudService = Get-AzCloudService -SubscriptionId $SubscriptionId -Name $CloudServiceName -ResourceGroupName $ResourceGroupName

        # Check that both have swappable property set.
        if ([string]::IsNullOrEmpty($SourceCloudService.NetworkProfile.SwappableCloudService.Id)) {
            throw "SwappableCloudServiceId is not set on the source cloud service $($SourceCloudService.Name)"
        }

        # Check that Public IPs counts are correct for source
        $validSourceIP = ValidateCloudServicePublicIPAddress($SourceCloudService)
        if ($validSourceIP -eq $false) {
            throw "Specified source cloud service must have a single public IP address specified in its FrontendIpConfigurations." 
        }
  
        # Parse target cloud service fields
        $elements = $SourceCloudService.NetworkProfile.SwappableCloudService.Id.Split("/")
        if (($elements.Count -lt 9) -or ("subscriptions" -ne $elements[1]) -or ("resourceGroups" -ne $elements[3]) -or ("cloudServices" -ne $elements[7]))
        {
            throw "SourceCloudService.NetworkProfile.SwappableCloudService.Id should match the format: /subscriptions/(?<TargetSubscriptionId>[^/]+)/resourceGroups/(?<TargetResourceGroupName>[^/]+/providers/Microsoft.Compute/cloudServices/(?<TargetCloudServiceName>[^/]+))"
        }
        $TargetSubscriptionId = $elements[2]
        $TargetResourceGroupName = $elements[4]
        $TargetCloudServiceName = $elements[8]
 
        # Fetch the target cloud service 
        $TargetCloudService = Get-AzCloudService -SubscriptionId $TargetSubscriptionId -Name $TargetCloudServiceName -ResourceGroupName $TargetResourceGroupName

        # Check that Public IPs counts are correct for target
        $validTargetIP = ValidateCloudServicePublicIPAddress($TargetCloudService)
        if ($validTargetIP -eq $false) {
            throw "Specified target cloud service must have a single public IP address specified in its FrontendIpConfigurations." 
        }

        # Get the LBs and FrontEndIpConfigs to create the request body
        $sourceLB = GetCloudServiceLoadBalancer($SubscriptionId, $ResourceGroupName, $SourceCloudService.NetworkProfile.LoadBalancerConfiguration[0].Name, $ApiVersion)
        $validSourceLB = ValidateLoadBalancerFrontEndIPConfiguration($sourceLB)
        if ($validSourceLB -eq $false) {
            throw "Source loadbBalancer must have a single value in its FrontendIpConfigurations." 
        }

        $targetLB =  GetCloudServiceLoadBalancer($TargetSubscriptionId, $TargetResourceGroupName, $TargetCloudService.NetworkProfile.LoadBalancerConfiguration[0].Name, $ApiVersion)      
        $validTargetLB = ValidateLoadBalancerFrontEndIPConfiguration($targetLB)
        if ($validTargetLB -eq $false) {
            throw "Target loadbBalancer must have a single value in its FrontendIpConfigurations." 
        }

        # Construct the request body
        $requestBody = GetVIPSwapRequestBody
        $requestBody = $requestBody -replace "#LBFE1#", $sourceLB.properties.frontendIPConfigurations[0].Id
        $requestBody = $requestBody -replace "#PIP2#", $TargetCloudService.NetworkProfile.LoadBalancerConfiguration[0].FrontendIPConfiguration[0].PublicIPAddressId
        $requestBody = $requestBody -replace "#LBFE2#", $targetLB.properties.frontendIPConfigurations[0].Id
        $requestBody = $requestBody -replace "#PIP1#", $SourceCloudService.NetworkProfile.LoadBalancerConfiguration[0].FrontendIPConfiguration[0].PublicIPAddressId

        # Set up API URI and Headers
        $uriToInvoke = "/subscriptions/$SubscriptionId/providers/Microsoft.Network/locations/$($SourceCloudService.Location)/setLoadBalancerFrontendPublicIpAddresses?api-version=$ApiVersion"

        # Display the information about the VIP swap being made
        Write-Host "Performing switch cloud service (VIP swap) action between $($SourceCloudService.Name) and $($TargetCloudService.Name)

Request URI : $uriToInvoke
POST

Request Body :
$requestBody"

        # Invoke the VIP swap API
        if ($PSCmdlet.ShouldProcess($SourceCloudService.Name + " <=> " + $TargetCloudService.Name,'VIP swap')) {
            $result = Invoke-AzRestMethod -Method POST -Path $uriToInvoke -Payload $requestBody 

            if ($Async.IsPresent) {
                Write-Host "Query the Azure-AsyncOperation URI from the response for operation progress"
                return $result
            }
            else {
               if ($result.StatusCode -eq 202) {
                   QueryVipSwapOperation($result)
               }
               else {
                   return $result
               }
            }
        }
    }
}

function QueryVipSwapOperation($result) {

    $uri = [System.Uri]($result.Headers.GetValues('Azure-AsyncOperation')[0]);
    $uriToInvoke = $uri.PathAndQuery
    $retryLimit = 100
    $retry = 0

    while ($retry -lt $retryLimit) {
        $statusResult = Invoke-AzRestMethod -Method GET -Path $uriToInvoke  
        if ($statusResult.StatusCode -eq 200) {
            $status = $statusResult.Content | ConvertFrom-Json
            if (-not $status.status.Equals("InProgress",[System.StringComparison]::OrdinalIgnoreCase)) {
                return $statusResult
            }

            $retry++
            Write-Progress -Activity "Performing VIP swap" -PercentComplete $retry -CurrentOperation "Status : InProgress"

            Start-Sleep -Seconds 10
        }
    }
}

function ValidateLoadBalancerFrontEndIPConfiguration($lb) {

    if ($lb.properties.frontendIPConfigurations.Count -eq 1) {   
        if (-not [string]::IsNullOrEmpty($lb.properties.frontendIPConfigurations[0].Id)) {
            return $true;
        }
    }

    return $false;
}

function ValidateCloudServicePublicIPAddress($cs) {

    if ($cs.NetworkProfile.LoadBalancerConfiguration.Count -eq 1) {
        if ($cs.NetworkProfile.LoadBalancerConfiguration[0].FrontendIPConfiguration.Count -eq 1) {
            if (-not [string]::IsNullOrEmpty($cs.NetworkProfile.LoadBalancerConfiguration[0].FrontendIPConfiguration[0].PublicIPAddressId)) {
                return $true;
            }
        }
    }

    return $false;
}

function GetCloudServiceLoadBalancer($parameters) {

    # Set up API URI and Headers
    $uriToInvoke = "/subscriptions/" + $parameters[0] + "/resourceGroups/" + $parameters[1] + "/providers/Microsoft.Network/loadBalancers/" + $parameters[2] + "?api-version=" + $parameters[3]
    $lbResponse = Invoke-AzRestMethod -Method GET -Path $uriToInvoke
    if ($lbResponse.StatusCode -ne 200) {
       throw $lbResponse.Content
    }

    $lb = $lbResponse.Content | ConvertFrom-Json
    return $lb
}

function GetVIPSwapRequestBody() {

    return @"
{
	"frontendIPConfigurations": [
		{
			"id": "#LBFE1#",
			"properties": {
				"publicIPAddress": {
					"id": "#PIP2#"
				}
			}
		},
		{
			"id": "#LBFE2#",
			"properties": {
				"publicIPAddress": {
					"id": "#PIP1#"
				}
			}
		}
	]
}
"@
}


# SIG # Begin signature block
# MIIoPAYJKoZIhvcNAQcCoIIoLTCCKCkCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAaBsrRoLlC6zLE
# 83jv5Mv3uhcpn+Lp30tH21BryBttLqCCDYUwggYDMIID66ADAgECAhMzAAAEA73V
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
# cVZOSEXAQsmbdlsKgEhr/Xmfwb1tbWrJUnMTDXpQzTGCGg0wghoJAgEBMIGVMH4x
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01p
# Y3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTECEzMAAAQDvdWVXQ87GK0AAAAA
# BAMwDQYJYIZIAWUDBAIBBQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIJGw
# 2mMGCS8aLNl/ZyG14lRAQuRNZlzNRtxoV6nYFg4OMEIGCisGAQQBgjcCAQwxNDAy
# oBSAEgBNAGkAYwByAG8AcwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20wDQYJKoZIhvcNAQEBBQAEggEAnT71uOnX3ruio6+fqUrKQQRJOJbLbcxwXBSb
# aAI1IEdGZO8PvUGdavPcbbb3mz0yG9xTzXkaSHx1uAYM0gorykNZsdSqVDIRJ2gN
# qqOAgUCmXEEDqxcTxQlM3l6iF0r1u5LiGKUC9P//nZBw49Fo+eK6mHjuPpl0uYIw
# CReCTgtJzLD8ZaWhO1HWB+zYH1mBRD7XbqCPbcU6npn2MS094VvYhLinYyr1WI+3
# 0xZKeZnWJFnOqaBmO//7yFBOJ7xOX6OFVVS+vXfXGzJnL7EiFUwj+tZegtP1loHi
# JGJX6ezKV6uUgcQsqKOBdH8juigmoCQkq7+mr7EYl6b41Vif56GCF5cwgheTBgor
# BgEEAYI3AwMBMYIXgzCCF38GCSqGSIb3DQEHAqCCF3AwghdsAgEDMQ8wDQYJYIZI
# AWUDBAIBBQAwggFSBgsqhkiG9w0BCRABBKCCAUEEggE9MIIBOQIBAQYKKwYBBAGE
# WQoDATAxMA0GCWCGSAFlAwQCAQUABCCTO+y3926MgzQHU3640YgBArF3ic/6OFqb
# I4d6guqZ+gIGZ1rjbLuIGBMyMDI1MDEwOTA2MzY0OS40OTNaMASAAgH0oIHRpIHO
# MIHLMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQL
# ExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxk
# IFRTUyBFU046ODYwMy0wNUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1l
# LVN0YW1wIFNlcnZpY2WgghHtMIIHIDCCBQigAwIBAgITMwAAAfGzRfUn6MAW1gAB
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
# ELQdVTNYs6FwZvKhggNQMIICOAIBATCB+aGB0aSBzjCByzELMAkGA1UEBhMCVVMx
# EzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoT
# FU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjElMCMGA1UECxMcTWljcm9zb2Z0IEFtZXJp
# Y2EgT3BlcmF0aW9uczEnMCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOjg2MDMtMDVF
# MC1EOTQ3MSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloiMK
# AQEwBwYFKw4DAhoDFQD7n7Bk4gsM2tbU/i+M3BtRnLj096CBgzCBgKR+MHwxCzAJ
# BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jv
# c29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwMA0GCSqGSIb3DQEBCwUAAgUA6ymhlzAi
# GA8yMDI1MDEwOTAxMTUwM1oYDzIwMjUwMTEwMDExNTAzWjB3MD0GCisGAQQBhFkK
# BAExLzAtMAoCBQDrKaGXAgEAMAoCAQACAgnWAgH/MAcCAQACAhLZMAoCBQDrKvMX
# AgEAMDYGCisGAQQBhFkKBAIxKDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMHoSCh
# CjAIAgEAAgMBhqAwDQYJKoZIhvcNAQELBQADggEBABWHux9xbYY4I0L4XVQj97eT
# 2StJ8YAHfLn+PZEx9HdgA8+ONymStatVt+SnyQ9nyV1lIGMKljTA95AUUN3xG9Eo
# 2QioQUCRBmnqjp//gHsXPiv0u7m3VgnLsr/TnTo17aLOc0bOyYlS1BTthbz2XeyB
# 646/F8ochBd1OqoCvluIEvv6Bx9hcodVtCm3pxAv4YDX8sXb0cFRNWz+Vq9JOKr4
# ankiYyp0INmV5C8cAHJb4+PKlCzqdqx+GV4RdLaDvK7pcF6qcaO3J5Gl0I5OoeTF
# 6KN1ifx90T0ps6q5LgV16lzWULKJA/BVAnUF9Q+ybg+yEa3UGrkVPMsX8vGN7sQx
# ggQNMIIECQIBATCBkzB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3Rv
# bjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0
# aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAA
# AfGzRfUn6MAW1gABAAAB8TANBglghkgBZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkD
# MQ0GCyqGSIb3DQEJEAEEMC8GCSqGSIb3DQEJBDEiBCC5eqXVJ2eiMSf9TaUms6G/
# vDo8SOWFPcTyMBNmZTpm4jCB+gYLKoZIhvcNAQkQAi8xgeowgecwgeQwgb0EINV3
# /T5hS7ijwao466RosB7wwEibt0a1P5EqIwEj9hF4MIGYMIGApH4wfDELMAkGA1UE
# BhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc
# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0
# IFRpbWUtU3RhbXAgUENBIDIwMTACEzMAAAHxs0X1J+jAFtYAAQAAAfEwIgQgZv4Q
# Ec5hgS9BsS74vtux+Rzxz6O0XI7Iv02NK7Hl7vIwDQYJKoZIhvcNAQELBQAEggIA
# jEP2Sz5dEFi1FxBOk8TwsaGWeeUnGK7Sn6ni3Ex9rBaR4mBUYbYEejvCdAQSlDSa
# Aq4lD7ybp/+G2Lig/dPPHh9NCfP0UzRS1c06L72EJYw28S710EBNHRGnuhAHlK5d
# jyCPAeCxUVGoAb+yhAXOsLSA0eOzKK5DXoaOqdgoJ7hO3xKQZDU+wcGA9Jjz9zEs
# 5vh7vL7CfmYVGUhQdzHBYPbxUaYira6o/jacURV1sTO3xkiD3ZG1BzU2cWIFIgFq
# 75yCK4X7coO+Zingw0Ku3qYLssIHRvc7UWnXfCMjudW8Bh6zjvmF+bhinv42asN2
# kNnbXFRDjs0dZhNQKNsfxIYKJQRlVf+GZwMfPSaVu6Z5hln67EDz/vpr5qd5K6W0
# I3LNIlWK7U6RyKDDK+XqQEJ7B7g63zjGg3BKH8Fdwo4O4eItaz/ia74pQmSaEd3t
# uqAB/PiNiGYQ7S3bLq2y9eylAvaIST+/pLaJY5B+aIecfsXw2gpuimtKhxO/rf0M
# /n45psaVxteFuw9J1XxezH7eLseT6vWMlS6K/e+2qL0xDBZgy1poWNnMlIv52x42
# cWh9cabGaZ5PXz7jwF0MrfW5qrqsdviGzhoVvNZ96CheEC0RZjY8CODp62zWQitA
# Gc1k8F0sWwhmwTD/BrGtOtO1eDeA+wDktcKHI+OtV5w=
# SIG # End signature block
