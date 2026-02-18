
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
The operation to create an image.
Please note some properties can be set only during  image creation.
.Description
The operation to create an image.
Please note some properties can be set only during image creation.
.Example
PS C:\> {{ Add code here }}

{{ Add output here }}
.Example
PS C:\> {{ Add code here }}

{{ Add output here }}


.Outputs
Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Models.IGalleryImages
Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Models.IMarketplaceGalleryImages
.Notes
COMPLEX PARAMETER PROPERTIES

.Link
https://learn.microsoft.com/powershell/module/az.stackhcivm/new-azstackhcivmimage
#>
function New-AzStackHCIVMImage{
    [OutputType([Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Models.IMarketplaceGalleryImages],ParameterSetName='Marketplace' )]
    [OutputType([Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Models.IMarketplaceGalleryImages],ParameterSetName='MarketplaceURN' )]
    [OutputType([Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Models.IGalleryImages],ParameterSetName='GalleryImage' )]
    [CmdletBinding(PositionalBinding=$false, SupportsShouldProcess, ConfirmImpact='Medium')]
    param(

    [Parameter(ParameterSetName='Marketplace', Mandatory)]
    [Parameter(ParameterSetName='GalleryImage', Mandatory)]
    [Parameter(ParameterSetName='MarketplaceURN',Mandatory)]
    [Alias('ImageName')]
    [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Path')]
    [System.String]
    # Name of the Image
    #The name must start and end with an alphanumeric character and must contain all alphanumeric characters or ‘-‘, ‘.’, or ‘_’. The max length can be 80 characters and the minimum length is 1 character.
    ${Name},

    [Parameter(ParameterSetName='Marketplace', Mandatory)]
    [Parameter(ParameterSetName='GalleryImage', Mandatory)]
    [Parameter(ParameterSetName='MarketplaceURN', Mandatory)]
    [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Path')]
    [System.String]
    # The name of the resource group.
    # The name is case insensitive.
    ${ResourceGroupName},

    [Parameter(ParameterSetName='Marketplace')]
    [Parameter(ParameterSetName='GalleryImage')]
    [Parameter(ParameterSetName='MarketplaceURN')]
    [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Path')]
    [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Runtime.DefaultInfo(Script='(Get-AzContext).Subscription.Id')]
    [System.String]
    # The ID of the target subscription.
    ${SubscriptionId},

    [Parameter(ParameterSetName='Marketplace', Mandatory)]
    [Parameter(ParameterSetName='GalleryImage', Mandatory)]
    [Parameter(ParameterSetName='MarketplaceURN', Mandatory)]
    [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Body')]
    [System.String]
    # The geo-location where the resource lives
    ${Location},

    [Parameter(ParameterSetName='Marketplace')]
    [Parameter(ParameterSetName='GalleryImage')]
    [Parameter(ParameterSetName='MarketplaceURN')]
    [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.PSArgumentCompleterAttribute("NoCloud", "Azure")]
    [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Body')]
    [System.String]
    # Datasource for the gallery image when provisioning with cloud-init [NoCloud, Azure]
    ${CloudInitDataSource},


    [Parameter(ParameterSetName='Marketplace', Mandatory)]
    [Parameter(ParameterSetName='GalleryImage', Mandatory)]
    [Parameter(ParameterSetName='MarketplaceURN', Mandatory)]
    [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Body')]
    [System.String]
    # The ARM Id of the extended location to create image resource in.
    ${CustomLocationId},

    [Parameter(ParameterSetName='GalleryImage', Mandatory)]
    [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Body')]
    [System.String]
    # Local path of image that the image should be created from. 
    # This parameter is required for non marketplace images. 
    ${ImagePath},

    [Parameter(ParameterSetName='GalleryImage', Mandatory)]
    [Parameter(ParameterSetName='Marketplace', Mandatory)]
    [Parameter(ParameterSetName='MarketplaceURN', Mandatory)]
    [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.PSArgumentCompleterAttribute("Windows", "Linux")]
    [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Body')] 
    # Operating system type that the gallery image uses [Windows, Linux]
    ${OSType},

    [Parameter(ParameterSetName='Marketplace', Mandatory)]
    [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Body')]
    [System.String]
    # The name of the marketplae gallery image definition offer.
    ${Offer},

    [Parameter(ParameterSetName='Marketplace', Mandatory)]
    [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Body')]
    [System.String]
    # The name of the marketplace gallery image definition publisher.
    ${Publisher},

    [Parameter(ParameterSetName='Marketplace', Mandatory)]
    [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Body')]
    [System.String]
    # The name of the marketplace gallery image definition SKU.
    ${Sku},

    [Parameter(ParameterSetName='Marketplace')]
    [Parameter(ParameterSetName='GalleryImage')]
    [Parameter(ParameterSetName='MarketplaceURN')]
    [AllowEmptyCollection()]
    [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Body')]
    [System.String]
    # Storage Container Name of the storage container to be used for gallery image
    ${StoragePathName},

    [Parameter(ParameterSetName='Marketplace')]
    [Parameter(ParameterSetName='GalleryImage')]
    [Parameter(ParameterSetName='MarketplaceURN')]
    [AllowEmptyCollection()]
    [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Body')]
    [System.String]
    # Resource Group of the Storage Path. The Default value is the Resource Group of the Image. 
    ${StoragePathResourceGroup},

    [Parameter()]
    [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Body')]
    [System.String]
    # Storage ContainerID of the storage container to be used for gallery image
    ${StoragePathId},

    [Parameter(ParameterSetName='GalleryImage')]
    [Parameter(ParameterSetName='Marketplace')]
    [Parameter(ParameterSetName='MarketplaceURN')]
    [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Body')]
    [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Runtime.Info(PossibleTypes=([Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Models.ITrackedResourceTags]))]
    [System.Collections.Hashtable]
    # Resource tags.
    ${Tag},

    [Parameter(ParameterSetName='MarketplaceURN', Mandatory)]
    [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Body')]
    [System.String]
    # The URN of the marketplace gallery image.
    ${URN},

    [Parameter(ParameterSetName='Marketplace', Mandatory)]
    [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Body')]
    [System.String]
    # The version of the marketplace gallery image.
    ${Version},
    
    [Parameter()]
    [Alias('AzureRMContext', 'AzureCredential')]
    [ValidateNotNull()]
    [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Azure')]
    [System.Management.Automation.PSObject]
    # The credentials, account, tenant, and subscription used for communication with Azure.
    ${DefaultProfile},

    [Parameter()]
    [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Runtime')]
    [System.Management.Automation.SwitchParameter]
    # Run the command as a job
    ${AsJob},

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

        if (-Not ($name -match $imageNameRegex )) {
            Write-Error "Invalid Name for image provided: $name" -ErrorAction Stop
        }

        if ($CustomLocationId -notmatch $customLocationRegex){
            Write-Error "Invalid CustomLocationId: $CustomLocationId" -ErrorAction Stop
        }
        if ($OSType){
            if ($OSType.ToString().ToLower() -eq "windows"){
                $PSBoundParameters['OSType'] = 'Windows'

            }
            elseif ($OSType.ToString().ToLower() -eq "linux"){
                $PSBoundParameters['OSType'] = 'Linux'
            }
            else {
                Write-Error "Invalid OSType provided:  $OSType. Expected values are 'Windows' or 'Linux'." -ErrorAction Stop
            }
        }

        #cloudinitdatassouce 
        if ($CloudInitDataSource){
            if ($CloudInitDataSource.ToString().ToLower() -eq "nocloud"){
            $PSBoundParameters['CloudInitDataSource'] = 'NoCloud'

            }
            elseif ($CloudInitDataSource.ToString().ToLower() -eq "azure"){
                $PSBoundParameters['CloudInitDataSource'] = 'Azure'
            }
            else {
                Write-Error "Invalid CloudInitDataSource provided: $CloudInitDataSource. Expected values are 'NoCloud' or 'Azure'." -ErrorAction Stop
            }

        }
        
        if ($HyperVGeneration){
            if ($HyperVGeneration.ToString().ToLower() -eq "v1"){
                $PSBoundParameters['HyperVGeneration'] = 'V1'

            }
            elseif ($HyperVGeneration.ToString().ToLower() -eq "v2"){
                $PSBoundParameters['HyperVGeneration'] = 'V2'
            }
            else {
                Write-Error "Invalid HyperVGeneration provided: $HyperVGeneration. Expected values are 'V1' or 'V2'." -ErrorAction Stop
            }

        }
        
        if ($StoragePathName){
            if ($StoragePathResourceGroup){
                $StoragePathId = "/subscriptions/$SubscriptionId/resourceGroups/$StoragePathResourceGroup/providers/Microsoft.AzureStackHCI/storagecontainers/$StoragePathName"
            } else {
                $StoragePathId = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.AzureStackHCI/storagecontainers/$StoragePathName"
            }

            $PSBoundParameters.Add('StoragePathId', $StoragePathId)
            $null = $PSBoundParameters.Remove("StoragePathName")
            $null = $PSBoundParameters.Remove("StoragePathResourceGroup")
        }
        

        if ($PSCmdlet.ParameterSetName -eq "Marketplace")
        {
            $PSBoundParameters['NoWait'] = $true
            $PSBoundParameters['ErrorAction'] = 'Stop'
            try {
                Az.StackHCIVM.internal\New-AzStackHCIVMMarketplaceGalleryImage @PSBoundParameters
                Start-Sleep -Seconds 60
                $PercentCompleted = 0 
                Write-Progress -Activity "Download Percentage: " -Status "$PercentCompleted % Complete:" -PercentComplete $PercentCompleted
                $null = $PSBoundParameters.Remove("Version")
                $null = $PSBoundParameters.Remove("URN")
                $null = $PSBoundParameters.Remove("Tag")
                $null = $PSBoundParameters.Remove("StoragePathId")
                $null = $PSBoundParameters.Remove("Sku")
                $null = $PSBoundParameters.Remove("Publisher")
                $null = $PSBoundParameters.Remove("Offer")
                $null = $PSBoundParameters.Remove("OSType")
                $null = $PSBoundParameters.Remove("ImagePath")
                $null = $PSBoundParameters.Remove("CustomLocationId")
                $null = $PSBoundParameters.Remove("CloudInitDataSource")
                $null = $PSBoundParameters.Remove("Location")
                $null = $PSBoundParameters.Remove("NoWait")
                while ($PercentCompleted -ne 100 ) {                  
                    $image = Az.StackHCIVM.internal\Get-AzStackHCIVMMarketplaceGalleryImage @PSBoundParameters
                    $PercentCompleted = $image.StatusProgressPercentage
                    if ($PercentCompleted -eq $null){
                        $PercentCompleted = 0
                    } 
                    Write-Progress -Activity "Download Percentage: " -Status "$PercentCompleted % Complete" -PercentComplete $PercentCompleted
                    Start-Sleep -Seconds 5    
                    if ($image.ProvisioningStatus -eq "Failed") {
                        Break
                    }           
                }
                if ($image.ProvisioningStatus -eq "Failed"){
                    Write-Error $image.StatusErrorMessage -ErrorAction Stop
                }
               
            } catch {
                $e = $_
                if ($e.FullyQualifiedErrorId -match "MissingAzureKubernetesMapping" ){
                    Write-Error "An older version of the Arc VM cluster extension is installed on your cluster. Please downgrade the Az.StackHCIVm version to 1.0.1 to proceed." -ErrorAction Stop
                } else {
                    Write-Error $e.Exception.Message -ErrorAction Stop
                }
            }

        
        } elseif ($PSCmdlet.ParameterSetName -eq "MarketplaceURN") {
            if ($URN -match $urnRegex){
                $publisher = $Matches.publisher.ToLower()
                $offer = $Matches.offer.ToLower()
                $sku = $Matches.sku.ToLower()
                $version = $Matches.version.ToLower()

                $null = $PSBoundParameters.Remove("URN")           
                $PSBoundParameters.Add('Publisher', $publisher)
                $PSBoundParameters.Add('Offer', $offer)
                $PSBoundParameters.Add('Sku', $sku)
                $PSBoundParameters.Add('Version', $version)
            } else {
                Write-Error "Invalid URN provided: $URN. Valid URN format is Publisher:Offer:Sku:Version ." -ErrorAction Stop
            }
            
            $PSBoundParameters['NoWait'] = $true
            $PSBoundParameters['ErrorAction'] = 'Stop'
            try {
                Az.StackHCIVM.internal\New-AzStackHCIVMMarketplaceGalleryImage @PSBoundParameters
                Start-Sleep -Seconds 60
                $PercentCompleted = 0 
                Write-Progress -Activity "Download Percentage: " -Status "$PercentCompleted % Complete:" -PercentComplete $PercentCompleted
                $null = $PSBoundParameters.Remove("Version")
                $null = $PSBoundParameters.Remove("URN")
                $null = $PSBoundParameters.Remove("Tag")
                $null = $PSBoundParameters.Remove("StoragePathId")
                $null = $PSBoundParameters.Remove("Sku")
                $null = $PSBoundParameters.Remove("Publisher")
                $null = $PSBoundParameters.Remove("Offer")
                $null = $PSBoundParameters.Remove("OSType")
                $null = $PSBoundParameters.Remove("ImagePath")
                $null = $PSBoundParameters.Remove("CustomLocationId")
                $null = $PSBoundParameters.Remove("CloudInitDataSource")
                $null = $PSBoundParameters.Remove("Location")
                $null = $PSBoundParameters.Remove("NoWait")
                while ($PercentCompleted -ne 100 ) {                  
                    $image = Az.StackHCIVM.internal\Get-AzStackHCIVMMarketplaceGalleryImage @PSBoundParameters
                    $PercentCompleted = $image.StatusProgressPercentage
                    if ($PercentCompleted -eq $null){
                        $PercentCompleted = 0
                    } 
                    Write-Progress -Activity "Download Percentage: " -Status "$PercentCompleted % Complete" -PercentComplete $PercentCompleted
                    Start-Sleep -Seconds 5    
                    if ($image.ProvisioningStatus -eq "Failed") {
                        Break
                    }           
                }
                if ($image.ProvisioningStatus -eq "Failed"){
                    Write-Error $image.StatusErrorMessage -ErrorAction Stop
                }
               
            } catch {
                $e = $_
                if ($e.FullyQualifiedErrorId -match "MissingAzureKubernetesMapping" ){
                    Write-Error "An older version of the Arc VM cluster extension is installed on your cluster. Please downgrade the Az.StackHCIVm version to 1.0.1 to proceed." -ErrorAction Stop
                } else {
                    Write-Error $e.Exception.Message -ErrorAction Stop
                }
            }


        }

        if ($PSCmdlet.ParameterSetName -eq "GalleryImage")
        {
            try{
                Az.StackHCIVM.internal\New-AzStackHCIVMGalleryImage -ErrorAction Stop @PSBoundParameters 
            } catch {
                $e = $_
                if ($e.FullyQualifiedErrorId -match "MissingAzureKubernetesMapping" ){
                    Write-Error "An older version of the Arc VM cluster extension is installed on your cluster. Please downgrade the Az.StackHCIVm version to 1.0.1 to proceed." -ErrorAction Stop
                } else {
                    Write-Error $e.Exception.Message -ErrorAction Stop
                }
            }
        }

       
    
}
# SIG # Begin signature block
# MIIoKgYJKoZIhvcNAQcCoIIoGzCCKBcCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCATfLMnnlGHSd+m
# QSvyDjdjA4AkUkNcEWyiiq8aZS2EyKCCDXYwggX0MIID3KADAgECAhMzAAAEBGx0
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
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIG+8GsYTynp/PTpL9ehS09yl
# KoS2kdrUSttdqU37IXpkMEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEB
# BQAEggEAq6UUVDA1GfYUoeuN0FwnZyIyhmfnQu3kvwW0gwZZPXs8UsHHN/Yv9pZ/
# ZKtrBLldLWVfWn+eqAe/m8/1OxkM/oXQYjdBFdWxPKFUpdGKAAE5Cae63ojlxT2x
# DLSV9YD2uE1Pejusw3BTnvorWNp6jg+nJcjyGhlJqrkwEvAVESBM7J/r6vuc/FyU
# 9PUbrDw8icQKR9Uc3fvXvBT7RY8gl+Qd4zKmMxr/Cf4F08p83BFxkBMGaU5qrn0Q
# pnr0si5jxEcsK3mYJjHgLU9V4sDJlosdAyPtEcQOz/B0DYJqxo2kIg3tP6XOTAp5
# wGD8GhZTRc06Gg6AAtwrZaC2tjRUkaGCF5QwgheQBgorBgEEAYI3AwMBMYIXgDCC
# F3wGCSqGSIb3DQEHAqCCF20wghdpAgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFSBgsq
# hkiG9w0BCRABBKCCAUEEggE9MIIBOQIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCDDn4Inh/edBJWgHyJsax+AjOSRIunSaNPChSGcdWyO2QIGZ1rYDqld
# GBMyMDI1MDEwOTA2Mzc0Mi42NTRaMASAAgH0oIHRpIHOMIHLMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1l
# cmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046QTAwMC0w
# NUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2Wg
# ghHqMIIHIDCCBQigAwIBAgITMwAAAevgGGy1tu847QABAAAB6zANBgkqhkiG9w0B
# AQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYD
# VQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAeFw0yMzEyMDYxODQ1
# MzRaFw0yNTAzMDUxODQ1MzRaMIHLMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25z
# MScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046QTAwMC0wNUUwLUQ5NDcxJTAjBgNV
# BAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2UwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQDBFWgh2lbgV3eJp01oqiaFBuYbNc7hSKmktvJ15NrB
# /DBboUow8WPOTPxbn7gcmIOGmwJkd+TyFx7KOnzrxnoB3huvv91fZuUugIsKTnAv
# g2BU/nfN7Zzn9Kk1mpuJ27S6xUDH4odFiX51ICcKl6EG4cxKgcDAinihT8xroJWV
# ATL7p8bbfnwsc1pihZmcvIuYGnb1TY9tnpdChWr9EARuCo3TiRGjM2Lp4piT2lD5
# hnd3VaGTepNqyakpkCGV0+cK8Vu/HkIZdvy+z5EL3ojTdFLL5vJ9IAogWf3XAu3d
# 7SpFaaoeix0e1q55AD94ZwDP+izqLadsBR3tzjq2RfrCNL+Tmi/jalRto/J6bh4f
# PhHETnDC78T1yfXUQdGtmJ/utI/ANxi7HV8gAPzid9TYjMPbYqG8y5xz+gI/SFyj
# +aKtHHWmKzEXPttXzAcexJ1EH7wbuiVk3sErPK9MLg1Xb6hM5HIWA0jEAZhKEyd5
# hH2XMibzakbp2s2EJQWasQc4DMaF1EsQ1CzgClDYIYG6rUhudfI7k8L9KKCEufRb
# K5ldRYNAqddr/ySJfuZv3PS3+vtD6X6q1H4UOmjDKdjoW3qs7JRMZmH9fkFkMzb6
# YSzr6eX1LoYm3PrO1Jea43SYzlB3Tz84OvuVSV7NcidVtNqiZeWWpVjfavR+Jj/J
# OQIDAQABo4IBSTCCAUUwHQYDVR0OBBYEFHSeBazWVcxu4qT9O5jT2B+qAerhMB8G
# A1UdIwQYMBaAFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMF8GA1UdHwRYMFYwVKBSoFCG
# Tmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUy
# MFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNybDBsBggrBgEFBQcBAQRgMF4w
# XAYIKwYBBQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2Vy
# dHMvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUyMDIwMTAoMSkuY3J0MAwG
# A1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQD
# AgeAMA0GCSqGSIb3DQEBCwUAA4ICAQCDdN8voPd8C+VWZP3+W87c/QbdbWK0sOt9
# Z4kEOWng7Kmh+WD2LnPJTJKIEaxniOct9wMgJ8yQywR8WHgDOvbwqdqsLUaM4Nre
# rtI6FI9rhjheaKxNNnBZzHZLDwlkL9vCEDe9Rc0dGSVd5Bg3CWknV3uvVau14F55
# ESTWIBNaQS9Cpo2Opz3cRgAYVfaLFGbArNcRvSWvSUbeI2IDqRxC4xBbRiNQ+1qH
# XDCPn0hGsXfL+ynDZncCfszNrlgZT24XghvTzYMHcXioLVYo/2Hkyow6dI7uULJb
# KxLX8wHhsiwriXIDCnjLVsG0E5bR82QgcseEhxbU2d1RVHcQtkUE7W9zxZqZ6/jP
# maojZgXQO33XjxOHYYVa/BXcIuu8SMzPjjAAbujwTawpazLBv997LRB0ZObNckJY
# yQQpETSflN36jW+z7R/nGyJqRZ3HtZ1lXW1f6zECAeP+9dy6nmcCrVcOqbQHX7Zr
# 8WPcghHJAADlm5ExPh5xi1tNRk+i6F2a9SpTeQnZXP50w+JoTxISQq7vBij2nitA
# sSLaVeMqoPi+NXlTUNZ2NdtbFr6Iir9ZK9ufaz3FxfvDZo365vLOozmQOe/Z+pu4
# vY5zPmtNiVIcQnFy7JZOiZVDI5bIdwQRai2quHKJ6ltUdsi3HjNnieuE72fT4eWh
# xtmnN5HYCDCCB3EwggVZoAMCAQICEzMAAAAVxedrngKbSZkAAAAAABUwDQYJKoZI
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
# MCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOkEwMDAtMDVFMC1EOTQ3MSUwIwYDVQQD
# ExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloiMKAQEwBwYFKw4DAhoDFQCA
# Bol1u1wwwYgUtUowMnqYvbul3qCBgzCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFBDQSAyMDEwMA0GCSqGSIb3DQEBCwUAAgUA6ymWNTAiGA8yMDI1MDEwOTAwMjYy
# OVoYDzIwMjUwMTEwMDAyNjI5WjB0MDoGCisGAQQBhFkKBAExLDAqMAoCBQDrKZY1
# AgEAMAcCAQACAhUpMAcCAQACAhMJMAoCBQDrKue1AgEAMDYGCisGAQQBhFkKBAIx
# KDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMHoSChCjAIAgEAAgMBhqAwDQYJKoZI
# hvcNAQELBQADggEBAIHAmhLTSl+tqfMPnHFg24foG1zMFnOXn0DIotbJRVZDtlhF
# nPqSqCYuWMG+vt5lcw61eK9qKCrEL1Z3DME2BYjzUw4pvqj9S4ij9UXBcY7EsuZF
# xKynfZfrdMCTOQx8920OBKrkMuEZQIyhTbNOGFKIbVqAF1ZuNWC3k3d938tCrz6k
# O5nVvlHq0eMKKt0dmLBFNI5t6CmeGfb0gGg5/DxT5b7DLoU2WO/iX3YhbPO8FNpc
# g+onP0f7LP1tI4/67GHNCchp1IYsV2KHZ7V50TN63bGfo1U4AWWahgpxKX44Wl5K
# RAfCFw4sMxpUmJCvGkkLX92WpRPfW0D8+81HOZQxggQNMIIECQIBATCBkzB8MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNy
# b3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAevgGGy1tu847QABAAAB6zAN
# BglghkgBZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMC8G
# CSqGSIb3DQEJBDEiBCAqdUc+RwFC4HnyJ3nX8or7VLK8Auf9ugSyZoyyGcIgYTCB
# +gYLKoZIhvcNAQkQAi8xgeowgecwgeQwgb0EIM63a75faQPhf8SBDTtk2DSUgIbd
# izXsz76h1JdhLCz4MIGYMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldh
# c2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBD
# b3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIw
# MTACEzMAAAHr4BhstbbvOO0AAQAAAeswIgQg3a/qZy5c5u5kLf4EWs4lzDywFVJR
# 2BigcuxSIs4sgoQwDQYJKoZIhvcNAQELBQAEggIATfJYGIpJj85Bu6OZh1TgjL5n
# B2I7CA3f7D1SVs1EI+aHIWCF7XOV1sPueZiTKH8MpQMWSiI5ZNm27+hUrnn/bI+U
# BFVdjnA70fN0f91Ru++bz6rwGlYF7BsoJSkVFZFDX4k02IpkDH2pmF+ep1yt/zaD
# faum/Vj9WN6wHn/TxATQJnvibY3fN6I5AR3Zx7NuHTQnb9BBEeEWwAfW46Nvo9U6
# HG4FXMO0VxIiFJeTjbfAjJrEoiBMDu3/UWszJuF6Q5YPmNEHL8WxyI9KR292pksr
# i83gbQtw8Xt2xZJfl+m7qTMZiXVlotNqF6FghQkpFCpTGNRJZ+G7xJdH86N7vWho
# JgJYboER8E37tcd/ppG/xpqLXnm4ie9MfCOyuDoUYsQS5iV9A4Rf+yc4ADEYb2+j
# SSl6p+cybkh1qKk4AgX0KkwJw3+SVpXQSVk/OFRve/MKcVqgKEbjK+8cKcbnZFS+
# hTAlOThw531fs/cCJPDuyNuUYv2ZLD1a6DPvck5TZCJv17VrNrisZSDKriqXSw5E
# awJZIa2SY0i5HxLDWjxTxbxp7psp+wf3DXmDmVuKyWOp1bx0X6qXVPnNhkPz4wDZ
# IySwe+0oGvHiPBOYxLx3EuAKz5IlAOu++CW8Cyl3kyzmQsIjvPbNG/aJ+pp0vJdE
# NF3hNm7YDT7AecXn7Xs=
# SIG # End signature block
