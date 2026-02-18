
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
The operation to create or update a logical network.
Please note some properties can be set only during logical network creation.
.Description
The operation to create or update a logical network.
Please note some properties can be set only during logical network creation.

.Outputs
Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Models.ILogicalNetworks
.Notes
COMPLEX PARAMETER PROPERTIES

To create the parameters described below, construct a hash table containing the appropriate properties. For information on hash tables, run Get-Help about_Hash_Tables.

SUBNET <ISubnet[]>: Subnet - list of subnets under the logical network
  [AddressPrefix <String>]: The address prefix for the subnet: Cidr for this subnet - IPv4, IPv6.
  [IPAllocationMethod <IPAllocationMethodEnum?>]: IPAllocationMethod - The IP address allocation method. Possible values include: 'Static', 'Dynamic'
  [IPConfigurationReference <ISubnetPropertiesFormatIPConfigurationReferencesItem[]>]: IPConfigurationReferences - list of IPConfigurationReferences
    [Id <String>]: IPConfigurationID
  [IPPool <IIPPool[]>]: network associated pool of IP Addresses
    [End <String>]: End of the IP address pool
    [Name <String>]: Name of the IP-Pool
    [Start <String>]: Start of the IP address pool
    [Type <IPPoolTypeEnum?>]: Type of the IP Pool [vm, vippool]
  [Name <String>]: Name - The name of the resource that is unique within a resource group. This name can be used to access the resource.
  [PropertiesAddressPrefixes <String[]>]: List of address prefixes for the subnet.
  [Route <IRoute[]>]: Collection of routes contained within a route table.
    [AddressPrefix <String>]: The destination CIDR to which the route applies.
    [Name <String>]: Name - name of the subnet
    [NextHopIPAddress <String>]: The IP address packets should be forwarded to. Next hop values are only allowed in routes where the next hop type is VirtualAppliance.
  [Vlan <Int32?>]: Vlan to use for the subnet
.Link
https://learn.microsoft.com/powershell/module/az.stackhcivm/new-azstackhcivmlogicalnetwork
#>

function New-AzStackHCIVMLogicalNetwork {
  [OutputType([Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Models.ILogicalNetworks])]
  [CmdletBinding( PositionalBinding=$false, SupportsShouldProcess, ConfirmImpact='Medium')]
  param(
      [Parameter(Mandatory)]
      [Alias('LogicalNetworkName')]
      [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Path')]
      [System.String]
      # Name of the virtual network
      ${Name},
  
      [Parameter(Mandatory)]
      [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Path')]
      [System.String]
      # The name of the resource group.
      # The name is case insensitive.
      ${ResourceGroupName},

      [Parameter()]
      [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Path')]
      [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Runtime.DefaultInfo(Script='(Get-AzContext).Subscription.Id')]
      [System.String]
      # The ID of the target subscription.
      ${SubscriptionId},
  
      [Parameter(Mandatory)]
      [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Body')]
      [System.String]
      # The geo-location where the resource lives
      ${Location},
  
      [Parameter(Mandatory)]
      [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Body')]
      [System.String]
      # The name of the extended location.
      ${CustomLocationId},
   
      [Parameter()]
      [AllowEmptyCollection()]
      [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Body')]
      [System.String[]]
      # The list of DNS servers IP addresses.
      ${DnsServer},
  
      [Parameter()]
      [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Body')]
      [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Runtime.Info(PossibleTypes=([Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Models.ITrackedResourceTags]))]
      [System.Collections.Hashtable]
      # Resource tags.
      ${Tag},
  
      [Parameter()]
      [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Body')]
      [System.String]
      # Name of the network switch to be used for VMs
      ${VMSwitchName},
  
  
      [Parameter()]
      [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Body')]
      [System.String[]]
      # List of address prefixes for the subnet.
      $AddressPrefix,
  
      [Parameter()]
      [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.PSArgumentCompleterAttribute("Static", "Dynamic")]
      [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Body')]
      [System.String]
      # The IP address allocation method. Possible values include: 'Static', 'Dynamic'
      $IpAllocationMethod, 
  
      [Parameter()]
      [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Body')]
      [System.String]
      # End of the ip address pool
      $IpPoolEnd, 
  
      [Parameter()]
      [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Body')]
      [System.String]
      # Start of the ip address pool
      $IpPoolStart, 
  
      [Parameter()]
      [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.PSArgumentCompleterAttribute("vm", "vippool")]
      [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Body')]
      [System.String]
      # Ip pool type
      $IpPoolType, 
  
      [Parameter()]
      [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Body')]
      [System.Collections.Hashtable[]]
      # Network associated pool of IP Addresses
      $IpPool,
  
      [Parameter()]
      [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Body')]
      [System.Collections.Hashtable[]]
      # Collection of routes contained within a route table.
      $Route, 
  
      [Parameter()]
      [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Body')]
      [System.String]
      # Name of the subnet
      $SubnetName, 
  
      [Parameter()]
      [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Body')]
      [System.Collections.Hashtable[]]
      # List of subnets under the virtual network
      $Subnet, 
  
      [Parameter()]
      [Microsoft.Azure.PowerShell.Cmdlets.StackHCIVM.Category('Body')]
      [System.Int32]
      # Vlan to use for the subnet
      $Vlan ,

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
  
      if ($Name -notmatch $vnetNameRegex){
        Write-Error "Invalid Name:  $Name. The name must start with an alphanumeric character, contain all alphanumeric characters or '-' or '_' or '.' and end with an alphanumeric character or '_'. The max length is 64 characters." -ErrorAction Stop
      }
  
      if ($CustomLocationId -notmatch $customLocationRegex){
        Write-Error "Invalid CustomLocationId: $CustomLocationId" -ErrorAction Stop
      } 
  
      if ($DnsServer){
        foreach ($DnsServ in $DnsServer){
          if ($DnsServ -notmatch $ipv4Regex){
              Write-Error "Invalid ipaddress provided for Dns Servers : $DnsServ." -ErrorAction Stop
          }
        }
      }
  
      if ($Subnet){
        Confirm-Subnets -Subnets $Subnet
  
      } else{
          $SubnetNew = @{}
          if ($IpAllocationMethod){
            if ($IpAllocationMethod.ToLower() -ne "dynamic" -and $IpAllocationMethod.ToLower() -ne "static"){
              Write-Error "Invalid Ip Allocation method provided: $IpAllocationMethod. Accepted values are 'dynamic' or 'static'" -ErrorAction Stop
            }
            $IpAllocationMethod = $IpAllocationMethod.ToLower()
            
            if ($IpAllocationMethod -eq "static"){
              $SubnetNew["IPAllocationMethod"] = 'Static'
              if (-Not $AddressPrefix){
                Write-Error "Invalid Configuration for Static IpAllocationMethod. AddressPrefix are required for Static IpAllocationMethod." -ErrorAction Stop
              }
            }
          } else {
            $SubnetNew["IPAllocationMethod"] = 'Dynamic'
          }
  
          if ($IpPoolStart -and $IpPoolEnd){
            if($IpPoolStart -notmatch $ipv4Regex){
              Write-Error "Invalid Ip Address provided : $IpPoolStart" -ErrorAction Stop
            }
  
            if($IpPoolEnd -notmatch $ipv4Regex){
              Write-Error "Invalid Ip Address provided : $IpPoolEnd" -ErrorAction Stop
            }
            $IpPoolNew = @{End = $IpPoolEnd; Start = $IpPoolStart}
            if ($IpPoolType){
              $IpPoolType = $IpPoolType.ToLower()
              if ($IpPoolType -ne "vm" -and $IpPoolType -ne "vippool"){
                Write-Error "Invalid IpPoolType provided: $IpPoolType. Accepted values are 'vm' and 'vippool'." -ErrorAction Stop
              }
              $IpPoolNew['Type'] = $IpPoolType
            }
            $SubnetNew["IPPool"] = @($IpPoolNew)
          } elseif ($IpPoolStart -or $IpPoolEnd){
              Write-Error "Both IpPoolStart and IpPoolEnd must be specified together." -ErrorAction Stop
          }
  
          if ($IpPool){
            Confirm-IpPools -IpPools $IpPool
            $SubnetNew["IPPool"] = $IpPool
          }
  
          if($Vlan){
            if ($Vlan -gt 4094 -or $Vlan -lt 1){
              Write-Error "Invalid value for Vlan : $Vlan. Valid range is 1-4094" -ErrorAction Stop
            }
            $SubnetNew["Vlan"] = $Vlan
          }
  
          if ($SubnetName){
            if ($SubnetName -notmatch $subnetNameRegex){
               Write-Error "Invalid SubnetName: $SubnetName. The name must start with an alphanumeric character, contain all alphanumeric characters or '-' or '_' or '.' and end with an alphanumeric character or '_'. The max length is 80 characters." -ErrorAction Stop
            }
            $SubnetNew["Name"] = $SubnetName
          }
  
          if ($AddressPrefix){
            foreach ($addPrefix in $AddressPrefix){
              if ($addPrefix -notmatch $cidrRegex){
                Write-Error "Invalid AddressPrefix: $addPrefix. Please use valid CIDR format." -ErrorAction Stop
              }
            }
  
            if ($AddressPrefix.length -eq 1){
              $SubnetNew["AddressPrefix"] = $AddressPrefix[0]
            } else {
              $SubnetNew["AddressPrefixes"] = $AddressPrefix
            }
  
          }
  
          if ($Route){
            Confirm-Routes -Routes $Route
            $SubnetNew["Route"] = $Route
  
          }
        
          $null = $PSBoundParameters.Remove("IpAllocationMethod")
          $null = $PSBoundParameters.Remove("IpPoolStart")
          $null = $PSBoundParameters.Remove("IpPoolEnd")
          $null = $PSBoundParameters.Remove("IpPoolType")
          $null = $PSBoundParameters.Remove("AddressPrefix")
          $null = $PSBoundParameters.Remove("Vlan")
          $null = $PSBoundParameters.Remove("SubnetName")
          $null = $PSBoundParameters.Remove("IpPool")
          $null = $PSBoundParameters.Remove("Route")
          $PSBoundParameters.Add("Subnet", $SubnetNew)
  
      } 

      try{
        Az.StackHCIVM.internal\New-AzStackHCIVMLogicalNetwork -ErrorAction Stop @PSBoundParameters 
      } catch {
        $e = $_
        if ($e.FullyQualifiedErrorId -match "MissingAzureKubernetesMapping" ){
            Write-Error "An older version of the Arc VM cluster extension is installed on your cluster. Please downgrade the Az.StackHCIVm version to 1.0.1 to proceed." -ErrorAction Stop
        } else {
            Write-Error $e.Exception.Message -ErrorAction Stop
        }
      }
     
  }
  
# SIG # Begin signature block
# MIInvwYJKoZIhvcNAQcCoIInsDCCJ6wCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCA7K8barCnHh0II
# oGIl53Xv5fVootrnBor1nOtkf54jaqCCDXYwggX0MIID3KADAgECAhMzAAADrzBA
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
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIOzp+f3N3rkXdvPafG6OKpw9
# 5QRIa2SXvv0rhS84X/4bMEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEB
# BQAEggEATd0IV8NnQwxvKvFBm8P/G3m/3+xNwV71EUCD6ZGg6+ubOc2gZKOyJ+lH
# kMtkon+F/uuWxZs6sow4XzbgSw7ZtcfQGP1BccJvbYDBpambxf88ru6R+Hv0DkNZ
# eswiFX6ytW4FbykIiryeukX9O3AmDmi92swk74NuDQo24M87fR61v0BXNf/Rqeh9
# bHQewYaq3wa4T/WhYL4KLkVNcQAnKFc6WB0QImtfr8dWdMaDnLEmEeoDl6SvXg17
# AI3bZuBYn1qBlbVIvHxOfa0nU+DfakmEVNMnIjYuj0e+9SSfDLwYR2PlZboBG02k
# 8NAYmzqM7gXgPy5vG2y7WMXtvmiU76GCFykwghclBgorBgEEAYI3AwMBMYIXFTCC
# FxEGCSqGSIb3DQEHAqCCFwIwghb+AgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFZBgsq
# hkiG9w0BCRABBKCCAUgEggFEMIIBQAIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCCkIEQMSsKMQ9YAGujKqz/KBIVumCZ+ne/KdhKkjp62qAIGZjOtMlA5
# GBMyMDI0MDUxNjA2NDIxMy42NzRaMASAAgH0oIHYpIHVMIHSMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQLEyRNaWNyb3NvZnQgSXJl
# bGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJjAkBgNVBAsTHVRoYWxlcyBUU1MgRVNO
# OkQwODItNEJGRC1FRUJBMSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBT
# ZXJ2aWNloIIReDCCBycwggUPoAMCAQICEzMAAAHcweCMwl9YXo4AAQAAAdwwDQYJ
# KoZIhvcNAQELBQAwfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
# EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
# bjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAwHhcNMjMx
# MDEyMTkwNzA2WhcNMjUwMTEwMTkwNzA2WjCB0jELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjEtMCsGA1UECxMkTWljcm9zb2Z0IElyZWxhbmQgT3Bl
# cmF0aW9ucyBMaW1pdGVkMSYwJAYDVQQLEx1UaGFsZXMgVFNTIEVTTjpEMDgyLTRC
# RkQtRUVCQTElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2VydmljZTCC
# AiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAIvIsyA1sjg9kSKJzelrUWF5
# ShqYWL83amn3SE5JyIVPUC7F6qTcLphhHZ9idf21f0RaGrU8EHydF8NxPMR2KVNi
# AtCGPJa8kV1CGvn3beGB2m2ltmqJanG71mAywrkKATYniwKLPQLJ00EkXw5TSwfm
# JXbdgQLFlHyfA5Kg+pUsJXzqumkIvEr0DXPvptAGqkdFLKwo4BTlEgnvzeTfXukz
# X8vQtTALfVJuTUgRU7zoP/RFWt3WagahZ6UloI0FC8XlBQDVDX5JeMEsx7jgJDdE
# nK44Y8gHuEWRDq+SG9Xo0GIOjiuTWD5uv3vlEmIAyR/7rSFvcLnwAqMdqcy/iqQP
# MlDOcd0AbniP8ia1BQEUnfZT3UxyK9rLB/SRiKPyHDlg8oWwXyiv3+bGB6dmdM61
# ur6nUtfDf51lPcKhK4Vo83pOE1/niWlVnEHQV9NJ5/DbUSqW2RqTUa2O2KuvsyRG
# MEgjGJA12/SqrRqlvE2fiN5ZmZVtqSPWaIasx7a0GB+fdTw+geRn6Mo2S6+/bZEw
# S/0IJ5gcKGinNbfyQ1xrvWXPtXzKOfjkh75iRuXourGVPRqkmz5UYz+R5ybMJWj+
# mfcGqz2hXV8iZnCZDBrrnZivnErCMh5Flfg8496pT0phjUTH2GChHIvE4SDSk2hw
# WP/uHB9gEs8p/9Pe/mt9AgMBAAGjggFJMIIBRTAdBgNVHQ4EFgQU6HPSBd0OfEX3
# uNWsdkSraUGe3dswHwYDVR0jBBgwFoAUn6cVXQBeYl2D9OXSZacbUzUZ6XIwXwYD
# VR0fBFgwVjBUoFKgUIZOaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9j
# cmwvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUyMDIwMTAoMSkuY3JsMGwG
# CCsGAQUFBwEBBGAwXjBcBggrBgEFBQcwAoZQaHR0cDovL3d3dy5taWNyb3NvZnQu
# Y29tL3BraW9wcy9jZXJ0cy9NaWNyb3NvZnQlMjBUaW1lLVN0YW1wJTIwUENBJTIw
# MjAxMCgxKS5jcnQwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcD
# CDAOBgNVHQ8BAf8EBAMCB4AwDQYJKoZIhvcNAQELBQADggIBANnrb8Ewr8eX/H1s
# Kt3rnwTDx4AqgHbkMNQo+kUGwCINXS3y1GUcdqsK/R1g6Tf7tNx1q0NpKk1JTupU
# JfHdExKtkuhHA+82lT7yISp/Y74dqJ03RCT4Q+8ooQXTMzxiewfErVLt8Wefebnc
# ST0i6ypKv87pCYkxM24bbqbM/V+M5VBppCUs7R+cETiz/zEA1AbZL/viXtHmryA0
# CGd+Pt9c+adsYfm7qe5UMnS0f/YJmEEMkEqGXCzyLK+dh+UsFi0d4lkdcE+Zq5JN
# jIHesX1wztGVAtvX0DYDZdN2WZ1kk+hOMblUV/L8n1YWzhP/5XQnYl03AfXErn+1
# Eatylifzd3ChJ1xuGG76YbWgiRXnDvCiwDqvUJevVRY1qy4y4vlVKaShtbdfgPyG
# eeJ/YcSBONOc0DNTWbjMbL50qeIEC0lHSpL2rRYNVu3hsHzG8n5u5CQajPwx9Pzp
# sZIeFTNHyVF6kujI4Vo9NvO/zF8Ot44IMj4M7UX9Za4QwGf5B71x57OjaX53gxT4
# vzoHvEBXF9qCmHRgXBLbRomJfDn60alzv7dpCVQIuQ062nyIZKnsXxzuKFb0TjXW
# w6OFpG1bsjXpOo5DMHkysribxHor4Yz5dZjVyHANyKo0bSrAlVeihcaG5F74SZT8
# FtyHAW6IgLc5w/3D+R1obDhKZ21WMIIHcTCCBVmgAwIBAgITMwAAABXF52ueAptJ
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
# bmQgT3BlcmF0aW9ucyBMaW1pdGVkMSYwJAYDVQQLEx1UaGFsZXMgVFNTIEVTTjpE
# MDgyLTRCRkQtRUVCQTElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2Vy
# dmljZaIjCgEBMAcGBSsOAwIaAxUAHDn/cz+3yRkIUCJfSbL3djnQEqaggYMwgYCk
# fjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQD
# Ex1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDANBgkqhkiG9w0BAQUFAAIF
# AOnv9qkwIhgPMjAyNDA1MTYxMTA2MTdaGA8yMDI0MDUxNzExMDYxN1owdDA6Bgor
# BgEEAYRZCgQBMSwwKjAKAgUA6e/2qQIBADAHAgEAAgIOHDAHAgEAAgISLDAKAgUA
# 6fFIKQIBADA2BgorBgEEAYRZCgQCMSgwJjAMBgorBgEEAYRZCgMCoAowCAIBAAID
# B6EgoQowCAIBAAIDAYagMA0GCSqGSIb3DQEBBQUAA4GBAErLMvBkHb4KezZvNtsk
# 484+j510LWTKQwXtcK8L8YqA0+wlWlY7QubH2hmdTAmD/ECPcxbNI1pTKKJ4hlXU
# U56grdz+Bh5jaW5Z6Xh0chi9pHJ7x1cNFeF0Ldzlvj4DxBkInT30K6T+mEyrcU3r
# 8/mf0Pmg3tX/NXqVmouWStmRMYIEDTCCBAkCAQEwgZMwfDELMAkGA1UEBhMCVVMx
# EzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoT
# FU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUt
# U3RhbXAgUENBIDIwMTACEzMAAAHcweCMwl9YXo4AAQAAAdwwDQYJYIZIAWUDBAIB
# BQCgggFKMBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAvBgkqhkiG9w0BCQQx
# IgQgj64UbMb5gFkKtx9h2d6pbaAa4nD2pcG/9Z0V9x5Qx1gwgfoGCyqGSIb3DQEJ
# EAIvMYHqMIHnMIHkMIG9BCBTpxeKatlEP4y8qZzjuWL0Ou0IqxELDhX2TLylxIIN
# NzCBmDCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAw
# DgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24x
# JjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAAB3MHg
# jMJfWF6OAAEAAAHcMCIEIMTvbH6kIHUreuUD/Hq60uvVE0Mtqj5sSIGrAkEVk1NF
# MA0GCSqGSIb3DQEBCwUABIICAIW1a8izRDxS8eWCya5Kidj3J0rvBV5Chobt3mrG
# JN6x/pw3YuIOq7kZIwXIx2FHuGON0NljtFXKQgAhOkNvOQIQlP6ca1JdxEvyDals
# TdEEiojxDErsdiG+McxsJQ99LaI5Rp2Uptf1ubKOgbTFEJtsqt/I7SkX6jI7MPSV
# zG36Cv2JT99/u2/AjfUXJFbu/UB9CWdybytk3mA5ZUvEr4OnOhME4GF4VUDA5ZQ7
# 1GEjSH1sZ1/0dAUpKjBCM9iwLvex6L4So42SP2TNtOnGzZduPd/FJD0rHyK2setT
# rsMltpCdT+boANtQBhakmDQ23nUb4EeHv/tSZe9GedrBphcFlxaQ1am9D9vsUZFc
# tytUn8DIAhkdUXix2mkBqQoawVVfuf5dURvxmkRYN7rF3kNwmIOYyMVOfVQ7o4Cf
# D9qwpSe8i8deQAIQNlBhwQJtFCznTYk+uIcH11hQnk343HFo5sW25BG1QEIYKSfz
# F5HJcoF1wMJSe8wNKl7hbELks2HjstrxgPf9f2VauCHjAPUlQ0E+xB/Qely/kLBS
# tnTy00goB6NKACpuEQeCutASDWYuQEcFL7sYOq1LQrAhsE0R1oYFP0/uLWasFnsN
# EQUOLPTjxeo5ANKfq3lM3np1F98it4mxGPq+AXjr3Lg0fRdpe1xLdT6aYjrvVhPo
# ZFLE
# SIG # End signature block
