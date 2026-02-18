@{
RootModule = if($PSEdition -eq 'Core')
{
    '.\netCore\ExchangeOnlineManagement.psm1'
}
else # Desktop
{
    '.\netFramework\ExchangeOnlineManagement.psm1'
}
FunctionsToExport = @('Connect-ExchangeOnline', 'Connect-IPPSSession', 'Disconnect-ExchangeOnline')
ModuleVersion = '3.5.0'
GUID = 'B5ECED50-AFA4-455B-847A-D8FB64140A22'
Author = 'Microsoft Corporation'
CompanyName = 'Microsoft Corporation'
Copyright = '(c) 2021 Microsoft. All rights reserved.'
Description = 'This is a General Availability (GA) release of the Exchange Online PowerShell V3 module. Exchange Online cmdlets in this module are REST-backed and do not require Basic Authentication to be enabled in WinRM. REST-based connections in Windows require the PowerShellGet module, and by dependency, the PackageManagement module.
Please check the documentation here - https://aka.ms/exov3-module.
For issues related to the module, contact Microsoft support.'
PowerShellVersion = '3.0'
CmdletsToExport = @('Add-VivaModuleFeaturePolicy','Get-ConnectionInformation','Get-DefaultTenantBriefingConfig','Get-DefaultTenantMyAnalyticsFeatureConfig','Get-EXOCasMailbox','Get-EXOMailbox','Get-EXOMailboxFolderPermission','Get-EXOMailboxFolderStatistics','Get-EXOMailboxPermission','Get-EXOMailboxStatistics','Get-EXOMobileDeviceStatistics','Get-EXORecipient','Get-EXORecipientPermission','Get-MyAnalyticsFeatureConfig','Get-UserBriefingConfig','Get-VivaFeatureCategory','Get-VivaInsightsSettings','Get-VivaModuleFeature','Get-VivaModuleFeatureEnablement','Get-VivaModuleFeaturePolicy','Remove-VivaModuleFeaturePolicy','Set-DefaultTenantBriefingConfig','Set-DefaultTenantMyAnalyticsFeatureConfig','Set-MyAnalyticsFeatureConfig','Set-UserBriefingConfig','Set-VivaInsightsSettings','Update-VivaModuleFeaturePolicy')

# Add modules on which ExchangeOnlineManagement depend
RequiredModules = @(
    @{
        ModuleName     = 'PackageManagement'
        ModuleVersion  = '1.0.0.1'
    },
    @{
        ModuleName     = 'PowerShellGet'
        ModuleVersion  = '1.0.0.1'
    }
)

FileList = if($PSEdition -eq 'Core')
{
    @('.\netCore\Azure.Core.dll',
        '.\netCore\Microsoft.Bcl.AsyncInterfaces.dll',
        '.\netCore\Microsoft.Bcl.HashCode.dll',
        '.\netCore\Microsoft.Exchange.Management.AdminApiProvider.dll',
        '.\netCore\Microsoft.Exchange.Management.ExoPowershellGalleryModule.dll',
        '.\netCore\Microsoft.Exchange.Management.RestApiClient.dll',
        '.\netCore\Microsoft.Identity.Client.dll',
        '.\netCore\Microsoft.IdentityModel.Abstractions.dll',
        '.\netCore\Microsoft.IdentityModel.JsonWebTokens.dll',
        '.\netCore\Microsoft.IdentityModel.Logging.dll',
        '.\netCore\Microsoft.IdentityModel.Tokens.dll',
        '.\netCore\Microsoft.OData.Client.dll',
        '.\netCore\Microsoft.OData.Core.dll',
        '.\netCore\Microsoft.OData.Edm.dll',
        '.\netCore\Microsoft.Online.CSE.RestApiPowerShellModule.Instrumentation.dll',
        '.\netCore\Microsoft.Spatial.dll',
        '.\netCore\Microsoft.Win32.Registry.AccessControl.dll',
        '.\netCore\Microsoft.Win32.SystemEvents.dll',
        '.\netCore\msvcp140.dll',
        '.\netCore\Newtonsoft.Json.dll',
        '.\netCore\System.CodeDom.dll',
        '.\netCore\System.Configuration.ConfigurationManager.dll',
        '.\netCore\System.Diagnostics.PerformanceCounter.dll',
        '.\netCore\System.DirectoryServices.dll',
        '.\netCore\System.Drawing.Common.dll',
        '.\netCore\System.IdentityModel.Tokens.Jwt.dll',
        '.\netCore\System.Management.Automation.dll',
        '.\netCore\System.Management.dll',
        '.\netCore\System.Memory.Data.dll',
        '.\netCore\System.Security.Cryptography.Pkcs.dll',
        '.\netCore\System.Security.Cryptography.ProtectedData.dll',
        '.\netCore\System.Security.Permissions.dll',
        '.\netCore\System.Windows.Extensions.dll',
        '.\netCore\vcruntime140_1.dll',
        '.\netCore\vcruntime140.dll',
        '.\license.txt')
}
else # Desktop
{
    @('.\netFramework\Microsoft.Bcl.AsyncInterfaces.dll',
        '.\netFramework\Microsoft.Exchange.Management.AdminApiProvider.dll',
        '.\netFramework\Microsoft.Exchange.Management.ExoPowershellGalleryModule.dll',
        '.\netFramework\Microsoft.Exchange.Management.RestApiClient.dll',
        '.\netFramework\Microsoft.Identity.Client.dll',
        '.\netFramework\Microsoft.IdentityModel.Abstractions.dll',
        '.\netFramework\Microsoft.IdentityModel.JsonWebTokens.dll',
        '.\netFramework\Microsoft.IdentityModel.Logging.dll',
        '.\netFramework\Microsoft.IdentityModel.Tokens.dll',
        '.\netFramework\Microsoft.OData.Client.dll',
        '.\netFramework\Microsoft.OData.Core.dll',
        '.\netFramework\Microsoft.OData.Edm.dll',
        '.\netFramework\Microsoft.Online.CSE.RestApiPowerShellModule.Instrumentation.dll',
        '.\netFramework\Microsoft.Spatial.dll',
        '.\netFramework\Newtonsoft.Json.dll',
        '.\netFramework\System.Buffers.dll',
        '.\netFramework\System.IdentityModel.Tokens.Jwt.dll',
        '.\netFramework\System.Management.Automation.dll',
        '.\netFramework\System.Memory.dll',
        '.\netFramework\System.Numerics.Vectors.dll',
        '.\netFramework\System.Runtime.CompilerServices.Unsafe.dll',
        '.\netFramework\System.Text.Json.dll',
        '.\netFramework\System.Threading.Tasks.Extensions.dll',
        '.\license.txt')
}

PrivateData = @{
    PSData = @{
    # Tags applied to this module. These help with module discovery in online galleries.
    Tags = 'Exchange', 'ExchangeOnline', 'EXO', 'EXOV2', 'EXOV3', 'Mailbox', 'Management'
    ReleaseNotes = '
---------------------------------------------------------------------------------------------
What is new in this release:

v3.5.0 :
    1. Added new cmdlet Get-VivaFeatureCategory
    2. Added support for policy operations at a category level for Viva GFAC (aka. VFAM - Viva Feature Access Management).
    3. Added a new return value IsFeatureEnabledByDefault in cmdlet Get-VivaModuleFeaturePolicy. This value informs of the default enablement state for users in the tenant when no tenant or user/group policies have been created.

---------------------------------------------------------------------------------------------
Previous Releases:

v3.4.0 :
    1.  Bug fixes in Connect-ExchangeOnline, Get-EXORecipientPermission and Get-EXOMailboxFolderPermission.
    2.  Support to use Constrained Language Mode(CLM) using SigningCertificate parameter.

v3.3.0 :
    1.  Support to skip loading cmdlet help files with Connect-ExchangeOnline.
    2.  Global variable EXO_LastExecutionStatus can now be used to check the status of the last cmdlet that was executed.
    3.  Bug fixes in Connect-ExchangeOnline and Connect-IPPSSession.
    4.  Support of user controls enablement by policy for features that are onboarded to Viva feature access management.

v3.2.0 :
    1.  General Availability of new cmdlets:
        -  Updating Briefing Email Settings of a tenant (Get-DefaultTenantBriefingConfig and Set-DefaultTenantBriefingConfig)
        -  Updating Viva Insights Feature Settings of a tenant (Get-DefaultTenantMyAnalyticsFeatureConfig and Set-DefaultTenantMyAnalyticsFeatureConfig)
        -  View the features in Viva that support setting access management policies (Get-VivaModuleFeature)
        -  Create and manage Viva app feature policies
           -  Get-VivaModuleFeaturePolicy
           -  Add-VivaModuleFeaturePolicy
           -  Remove-VivaModuleFeaturePolicy
           -  Update-VivaModuleFeaturePolicy
        -  View whether or not a Viva feature is enabled for a specific user/group (Get-VivaModuleFeatureEnablement)

    2.  General Availability of REST based cmdlets for Security and Compliance PowerShell.
    3.  Support to get REST connection informations from Get-ConnectionInformation cmdlet and disconnect REST connections using Disconnect-ExchangeOnline cmdlet for specific connection(s).
    4.  Support to sign the temporary generated module with a client certificate to use the module in all PowerShell execution policies.
    5.  Bug fixes in Connect-ExchangeOnline.

v3.1.0 :
    1.  Support for providing an Access Token with Connect-ExchangeOnline.
    2.  Bug fixes in Connect-ExchangeOnline and Get-ConnectionInformation.
    3.  Bug fix in Connect-IPPSSession for connecting to Security and Compliance PowerShell using Certificate Thumbprint.

v3.0.0 :
    1.  General Availability of REST-backed cmdlets for Exchange Online which do not require WinRM Basic Authentication to be enabled.
    2.  General Availability of Certificate Based Authentication for Security and Compliance PowerShell cmdlets.
    3.  Support for System-Assigned and User-Assigned ManagedIdentities to connect to ExchangeOnline from Azure VMs, Azure Virtual Machine Scale Sets and Azure Functions.
    4.  Breaking changes
        -   Get-PSSession cannot be used to get information about the sessions created as PowerShell Remoting is no longer being used. The Get-ConnectionInformation cmdlet has been introduced instead, to get information about the existing connections to ExchangeOnline. Refer https://docs.microsoft.com/en-us/powershell/module/exchange/get-connectioninformation?view=exchange-ps for more information.
        -   Certain cmdlets that used to prompt for confirmation in specific scenarios will no longer have this prompt and the cmdlet will run to completion by default.
        -   The format of the error returned from a failed cmdlet execution has been slightly modified. The Exception contains some additional data such as the exception type, and the FullyQualifiedErrorId does not contain the FailureCategory. The format of the error is subject to further modifications.
        -   Deprecation of the Get-OwnerlessGroupPolicy and Set-OwnerlessGroupPolicy cmdlets.

v2.0.5 :
    1. Manage ownerless Microsoft 365 groups through newly added cmdlets Get-OwnerlessGroupPolicy and Set-OwnerlessGroupPolicy.
    2. Add new cmdlets Get-VivaInsightsSettings and Set-VivaInsightsSettings for Global/ExchangeOnline/Teams administrators to control user access of Headspace features in Viva Insights.

v2.0.4 :
    1. Manage EXO using Linux devices along with Browser based SSO Authentication for enhanced interactive management experience. No need to enter UserName and password everytime you run the PowerShell script.
    2. Manage EXO using Apple Macintosh devices. Supported versions of Apple MAC OS are Mojave, Catalina & Big Sur. Steps for installing PowerShell on MAC OS is documented here - https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-macos?view=powershell-7.1
    3. Real time policy & security enforcement in all user based authentication. Continuous Access Evaluation (CAE) has been enabled in EXO V2 Module. Read more about CAE here - https://techcommunity.microsoft.com/t5/azure-active-directory-identity/moving-towards-real-time-policy-and-security-enforcement/ba-p/1276933
    4. Use parameter InlineCredential to pass credentials of Non-MFA accounts on the go without the need of storing credentials in a variable
    5. More secure method to fetch access token using safe Reply URLs.
    6. Breaking change :- Change in cmdlet signature to configure MyAnalytics access for users in your tenant. Get/Set-UserAnalyticsConfig has been replaced by Get/Set-MyAnalyticsFeatureConfig Additionally, you can have more granular controls and configure access at feature level. For more steps read here - https://docs.microsoft.com/en-us/workplace-analytics/myanalytics/setup/configure-myanalytics

v2.0.3 :
    1. General availability of Certificate Based Authentication feature which enables using Modern Authentication in Unattended Scripting or background automation scenarios.
    2. Certificate Based Authentication accepts Certificate File directly from terminal thus enabling certificate files to be stored in Azure Key Vault and being fetched Just-In-Time for enhanced security. See parameter Certificate in Connect-ExchangeOnline.
    3. Connect with Exchange Online and Security Compliance Center simultaneously in a single PowerShell window.
    4. Ability to restrict the PowerShell cmdlets imported in a session using CommandName parameter, thus reducing memory footprint in case of high usage PowerShell applications.
    5. Get-ExoMailboxFolderPermission now supports ExternalDirectoryObjectID in the Identity parameter.
    6. Optimized latency of first V2 Cmdlet call. (Lab results show first call latency has been reduced from 8 seconds to ~1 seconds. Actual results will depend on result size and Tenant environment.)
 
v1.0.1 :
    1. This is the General Availability (GA) version of EXO PowerShell V2 Module. It is stable and ready for being used in production environments.
    2. Get-ExoMobileDeviceStatistics cmdlet now supports Identity parameter.
    3. Improved reliability of session auto-connect in certain cases where script was executing for ~50minutes and threw "Cmdlet not found" error due to a bug in auto-reconnect logic.
    4. Fixed data-type issues of two commonly used attributed "User" and "MailboxFolderUser" for easy migration of scripts.
    5. Enhanced support for filters as it now supports 4 more operators - endswith, contains, not and notlike support. Please check online documentation for attributes which are not supported in filter string.
 
---------------------------------------------------------------------------------------------
'
    LicenseUri='http://aka.ms/azps-license'
    }
}
}
# SIG # Begin signature block
# MIIoKQYJKoZIhvcNAQcCoIIoGjCCKBYCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCdKOpkglJnBFDP
# XcM1VigdXDsRVT0aAIBZS2K2C03Sc6CCDXYwggX0MIID3KADAgECAhMzAAADrzBA
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
# /Xmfwb1tbWrJUnMTDXpQzTGCGgkwghoFAgEBMIGVMH4xCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNp
# Z25pbmcgUENBIDIwMTECEzMAAAOvMEAOTKNNBUEAAAAAA68wDQYJYIZIAWUDBAIB
# BQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIFD/IL2dyh+iTzn82n5v9Zjt
# BCGmW5hcUU3RewFvHL4vMEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEB
# BQAEggEAsUM062ioT0i7VG4aWeex8eAzO+PL3OTjG3PuY4y70FijWQoOGfi2Uxmq
# wFPA2tHFcQ4Ger9sKYl9DJzIe2qC4bvY4pPJ1GfzdFYtOUXaKJM/bL0QZhnMqo64
# sQO6sY3alTGbRaubZvZEE3mOnexn5or3n89F4RGSxzGyWGll4IN8DYt0+OClWt65
# vPmvuxz3zd6+NQpD6HdkS0Imxrayh51rEgg6GWT49pX9PhwLa61x+KxoDTP1uyUI
# WaijBtUrDLI9MBf+pouR5OEkWleYaFdRAtp2Ft4VAE9SEywurDwCrqrtWxzislOo
# 2O9Syh1Kbm7qk0LAn+ejIPqoGNETVKGCF5MwghePBgorBgEEAYI3AwMBMYIXfzCC
# F3sGCSqGSIb3DQEHAqCCF2wwghdoAgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFRBgsq
# hkiG9w0BCRABBKCCAUAEggE8MIIBOAIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCBLga79DzJlhjdLg9G3QZM0RQ7zTqM727nbpiPQpORtAAIGZjOTHvPT
# GBIyMDI0MDUxNjAxMzIxOS4wMlowBIACAfSggdGkgc4wgcsxCzAJBgNVBAYTAlVT
# MRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQK
# ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJTAjBgNVBAsTHE1pY3Jvc29mdCBBbWVy
# aWNhIE9wZXJhdGlvbnMxJzAlBgNVBAsTHm5TaGllbGQgVFNTIEVTTjo4OTAwLTA1
# RTAtRDk0NzElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2VydmljZaCC
# EeowggcgMIIFCKADAgECAhMzAAAB7eFfy9X3pV1zAAEAAAHtMA0GCSqGSIb3DQEB
# CwUAMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQH
# EwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNV
# BAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwMB4XDTIzMTIwNjE4NDU0
# MVoXDTI1MDMwNTE4NDU0MVowgcsxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNo
# aW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29y
# cG9yYXRpb24xJTAjBgNVBAsTHE1pY3Jvc29mdCBBbWVyaWNhIE9wZXJhdGlvbnMx
# JzAlBgNVBAsTHm5TaGllbGQgVFNTIEVTTjo4OTAwLTA1RTAtRDk0NzElMCMGA1UE
# AxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2VydmljZTCCAiIwDQYJKoZIhvcNAQEB
# BQADggIPADCCAgoCggIBAKgwwmySuupqnJwvE8LUfvMPuDzw2lsRpDpKNxMhFvMJ
# XJhA2zPxNovWmoVMQA8vVfuiMvj8RoRb5SM2pmz9rIzJbhgikU9k/bHgUExUJ12x
# 4XaL5owyMMeLQtxNBnEzazeYUysJkBZJ8thdgMiKYUHPyPSgtYbLdWAuYFMozjEu
# q/sNlTPwHZKgCZsS2nraeBKXSE6g3vdIXAT5jbhK8ZAxaHKSkb69cPByla/AN75O
# CestHsBNEVc3klLbp2bbLLpJgUxFicwTd0wcJD9RAhBA0LycuYi90qQChYQxe0mw
# YSjdCszZLZIG/g+kdHNG6TNO0/5QBx4bEz0nKvBRA/k4ISZbphyETJENLA/iFT1/
# sHQDKHXg/D28mjuN7A2N4w8iSad7ItKLSu6/ajH/FEa1wn3IE0LkFpGS2PPuy09q
# iNH48MDZ+4G0KjzEqWS3neZRvsBj4JkceqEubvql0wXoEe/ZO/CVUF5BE3bZeNpV
# VHAKCOAmc17C3s96NyulSfSocuAur7UE3UPNi6RaROvvBPTOXSJev422pSRZI6dZ
# F97w3bW0Hq6/dWRbycV0KG1ttlnPbil4u0kRm42s3xd/09M8zNlcMkEjURyJH/3V
# BwahkWZVsVVvatQgCzTX5mR7C9uGYZUN59f2hkbj8riAZSxO9Nb6vUlkzFRPYzCp
# AgMBAAGjggFJMIIBRTAdBgNVHQ4EFgQUzhvw7PfeECoER8qUBl/Q0qHgIhkwHwYD
# VR0jBBgwFoAUn6cVXQBeYl2D9OXSZacbUzUZ6XIwXwYDVR0fBFgwVjBUoFKgUIZO
# aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jcmwvTWljcm9zb2Z0JTIw
# VGltZS1TdGFtcCUyMFBDQSUyMDIwMTAoMSkuY3JsMGwGCCsGAQUFBwEBBGAwXjBc
# BggrBgEFBQcwAoZQaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jZXJ0
# cy9NaWNyb3NvZnQlMjBUaW1lLVN0YW1wJTIwUENBJTIwMjAxMCgxKS5jcnQwDAYD
# VR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAOBgNVHQ8BAf8EBAMC
# B4AwDQYJKoZIhvcNAQELBQADggIBAJ3WArZF354YvR4eL6ITr+oNjyxtuw7h6Zqd
# ynoo837GrlkBq2IFHiOZFGGb71WKTQWjQMtaL83bxsUjt1djDT2ne8KKluPLgSiJ
# +bQ253v/hTfSL37tG9btc5DevHfv5Tu+r2WTrJikYI2nSOUnXzz8K5E+Comd+rkR
# 15p8fYCgbjqEpZN4HsO5dqwa3qykk56cZ51Kt7fgxZmp5MhDSto4i1mcW4YPLj7G
# gPWpHPZBb67aAIdobwBCOFhQzi5OL23qS22PpztdqavbOta5x4OHPuwou20tMnvC
# zlisDYjxxOVswB/YpbQZWMptgZ34tkZ24Qrv/t+zgZSQypznUWw10bWf7OBzvMe7
# agYZ4IGDizxlHRkXLHuOyCb2xIUIpDkKxsC+Wv/rQ12TlN4xHwmzaQ1SJy7YKpnT
# fzfdOy9OCTuIPUouB9LXocS+M3qbhUokqCMns4knNpu1LglCBScmshl/KiyTgPXy
# tmeL2lTA3TdaBOZ3XRZPCJk67iDxSfqIpw8xj+IWpO7ie2TMVTEEGlsUbqTUIg1m
# aiKsRaYK0beXJnYh12aO0h59OQi8ZZvgnHPPuXab8TaQY6LEMkexqFlWbCyg2+HL
# mS7+KdT751cfPD6GW+pNIVPz2sgVWFyaxY8Mk81FJKkyGgnfdXZlr+WQpxuRQzRJ
# tCBL2qx3MIIHcTCCBVmgAwIBAgITMwAAABXF52ueAptJmQAAAAAAFTANBgkqhkiG
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
# e784cETRkPHIqzqKOghif9lwY1NNje6CbaUFEMFxBmoQtB1VM1izoXBm8qGCA00w
# ggI1AgEBMIH5oYHRpIHOMIHLMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
# Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBv
# cmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25zMScw
# JQYDVQQLEx5uU2hpZWxkIFRTUyBFU046ODkwMC0wNUUwLUQ5NDcxJTAjBgNVBAMT
# HE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2WiIwoBATAHBgUrDgMCGgMVAO4d
# rIpMJpixjEmH6hZPHq5U8XD5oIGDMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAg
# UENBIDIwMTAwDQYJKoZIhvcNAQELBQACBQDp790YMCIYDzIwMjQwNTE2MDExNzEy
# WhgPMjAyNDA1MTcwMTE3MTJaMHQwOgYKKwYBBAGEWQoEATEsMCowCgIFAOnv3RgC
# AQAwBwIBAAICBT0wBwIBAAICEnowCgIFAOnxLpgCAQAwNgYKKwYBBAGEWQoEAjEo
# MCYwDAYKKwYBBAGEWQoDAqAKMAgCAQACAwehIKEKMAgCAQACAwGGoDANBgkqhkiG
# 9w0BAQsFAAOCAQEAcoPsqRfgCRFRcChfMQfB5XgZ3Gd5jWO7aLLIYDOFRx99cDUI
# vTo/XVW3K/nhW1dJZmPWrxEEm8aUXMmCd2vOvz+mXv341+2DFPc+uKneRWr3NN0L
# V3FLlbvKPDR6HqnrcSFWp2rvGMix48r5aHWBhAB5WSMHffLUc0l2N4m13ZTo6jnN
# tHoCrvbyDC586odOIYZWwTMMpzodxkQ61IQvA5D6Smpp1oGVEjVV8PS/BazPznrA
# z4pRAnEUnDqTQFTQ1o4CbH31yJUeniUd5DV1s0nyzlPlYjylo8Yu3I1NfRFs4kUn
# CrxqdZqY7P77hLPQpL+USflHskxQlVmAzIlYMTGCBA0wggQJAgEBMIGTMHwxCzAJ
# BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jv
# c29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAAB7eFfy9X3pV1zAAEAAAHtMA0G
# CWCGSAFlAwQCAQUAoIIBSjAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwLwYJ
# KoZIhvcNAQkEMSIEIHFxYNC/jHUtltZaC6stjw/bemKR3emiVrGfQl/QGSpYMIH6
# BgsqhkiG9w0BCRACLzGB6jCB5zCB5DCBvQQgjS4NaDQIWx4rErcDXqXXCsjCuxIO
# tdnrFJ/QXjFsyjkwgZgwgYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAx
# MAITMwAAAe3hX8vV96VdcwABAAAB7TAiBCBhXakyx6xyxDfOqSF14qbMpvysJw4E
# kpnqO6spD356MzANBgkqhkiG9w0BAQsFAASCAgB9bnMGhrAhCEaWg6K54LWOPpkT
# 3mTDMPTDMGPx3oAR3BOXUVMGgRbLJy+Nw4bUZDmE2TRYNql7Xoe3H1l3tXdMYeg/
# BwEB9FYhvKau/e30RI/4lJgeGHttcypBOR3roxG9AbUcu9X0fd4a7CoAbVOCeWIX
# gngOwvEenD/X9X/wE5efNTCIZ6n9cG1bbITmADdn26zVLH08H2rIcoAiM71+nGNj
# hwiQmIIaqYWnC4iOSPA5/iec+VsjSpavTaGP4eXj+5v2s1zQQ1NmeydgxVbJwQ4E
# yluUYj/BCTVkBoW2TiYBiJnheMBt31JJktmpokArS9ZcZSjRfcRWaQtAmcesVT7c
# kmLu4sJd7n86DmeoOoQB9SvwHnbxYHQ3juLdV79iZ7JN7tNvc7aVUl6chYmXPCji
# 9djV1TWKNNj8TN0rOGWvfqte9gjWBaW315IQqIRldgJKDi/43Ix34k74RyhFXDAr
# Fr0uRim+WEboQ7m5CqTd62Gpl8evk3AksJ1HXEsTEJLY6qda7HCo8lPN4SGogAvF
# 0jwfJbasIhoF5ol37tdfyktARtuWpmwUumF8sxKoyBUdf5fpNsXgSSOrl/oSdk2e
# xywRRbcOhSnSghCj4/MIa4QmT88pqBysqbaz45Tta3oUVey1KVrN4Snwk6o1YXCz
# SkCOIvDG+YbVSUdzvw==
# SIG # End signature block
