function CheckResourceGraphModuleDependency {
    [Microsoft.Azure.PowerShell.Cmdlets.Migrate.DoNotExportAttribute()]
    param() 

    process {
        $module = Get-Module -ListAvailable | Where-Object { $_.Name -eq "Az.ResourceGraph" }
        if ($null -eq $module) {
            $message = "Az.ResourceGraph Module must be installed to run this command. Please run 'Install-Module -Name Az.ResourceGraph' to install and continue."
            throw $message
        }
    }
}

function CheckResourcesModuleDependency {
    [Microsoft.Azure.PowerShell.Cmdlets.Migrate.DoNotExportAttribute()]
    param() 

    process {
        $module = Get-Module -ListAvailable | Where-Object { $_.Name -eq "Az.Resources" }
        if ($null -eq $module) {
            $message = "Az.Resources Module must be installed to run this command. Please run 'Install-Module -Name Az.Resources' to install and continue."
            throw $message
        }
    }
}

function CheckStorageModuleDependency {
    [Microsoft.Azure.PowerShell.Cmdlets.Migrate.DoNotExportAttribute()]
    param() 

    process {
        $module = Get-Module -ListAvailable | Where-Object { $_.Name -eq "Az.Storage" }
        if ($null -eq $module) {
            $message = "Az.Storage Module must be installed to run this command. Please run 'Install-Module -Name Az.Storage' to install and continue."
            throw $message
        }
    }
}

function GetARGQueryForArcResourceBridge {
    [Microsoft.Azure.PowerShell.Cmdlets.Migrate.DoNotExportAttribute()]
    param(
        [Parameter(Mandatory)]
        [System.String]
        # Specifies HCI Cluster Id.
        ${HCIClusterID}
    )

    process {
        $query = @"
resources | where type == 'microsoft.extendedlocation/customlocations'
| mv-expand ClusterId = properties['clusterExtensionIds']
| extend ClusterId = toupper(tostring(ClusterId))
| extend CustomLocation = toupper(tostring(id))
| extend resourceBridgeID = toupper(tostring(properties['hostResourceId']))
| extend customLocationRegion = location
| join (
    kubernetesconfigurationresources
    | where type == 'microsoft.kubernetesconfiguration/extensions'
    | where properties['ConfigurationSettings']['HCIClusterID'] =~ '$HCIClusterID'
    | project ClusterId = id
    | extend ClusterId = toupper(tostring(ClusterId))
) on ClusterId
| join (
    resources
    | where type == 'microsoft.resourceconnector/appliances'
    | where properties['provisioningState'] == 'Succeeded'
    | extend statusOfTheBridge = properties['status']
    | extend resourceBridgeID = toupper(tostring(id))
) on resourceBridgeID
"@
        return $query
    }
}

function IsReservedOrTrademarked {
    [Microsoft.Azure.PowerShell.Cmdlets.Migrate.DoNotExportAttribute()]
    param(
        [Parameter(Mandatory)]
        [System.String]
        # Specifies VM name.
        ${Value}
    )

    $uppercased = $Value.ToUpper();

    # cannot be exactly one of these, but could be slightly different (e.g. hololens2)
    $reservedWords = @(
        "ACCESS",
        "APP_CODE",
        "APP_THEMES",
        "APP_DATA",
        "APP_GLOBALRESOURCES",
        "APP_LOCALRESOURCES",
        "APP_WEBREFERENCES",
        "APP_BROWSERS",
        "AZURE",
        "BING",
        "BIZSPARK",
        "BIZTALK",
        "CORTANA",
        "DIRECTX",
        "DOTNET",
        "DYNAMICS",
        "EXCEL",
        "EXCHANGE",
        "FOREFRONT",
        "GROOVE",
        "HOLOLENS",
        "HYPERV",
        "KINECT",
        "LYNC",
        "MSDN",
        "O365",
        "OFFICE",
        "OFFICE365",
        "ONEDRIVE",
        "ONENOTE",
        "OUTLOOK",
        "POWERPOINT",
        "SHAREPOINT",
        "SKYPE",
        "VISIO",
        "VISUALSTUDIO"
    )

    # The following words can't be used as either a whole word or a substring in the name:
    $microsoft = "MICROSOFT";
    $windows = "WINDOWS";

    # The following words can't be used at the start of a resource name, but can be used later in the name:
    $startLogin = "LOGIN";
    $startXbox = "XBOX";

    if ($uppercased.startsWith($startLogin) -or $uppercased.startsWith($startXbox)) {
        return $true;
    }

    if ($uppercased.contains($microsoft) -or $uppercased.contains($windows)) {
        return $true;
    }

    foreach ($reservedName in $reservedWords) {
        if ($uppercased -eq $reservedName) {
            return $true;
        }
    }

    return $false;
}

function GenerateHashForArtifact {
    [Microsoft.Azure.PowerShell.Cmdlets.Migrate.DoNotExportAttribute()]
    param(
        [Parameter(Mandatory)]
        [System.String]
        # Specifies resource group name.
        ${Artifact}
    )

    $hashCode = 0
    $artifactLength = $Artifact.Length
    $tempItemLength = 0
    if ($artifactLength -gt 0) {
        while ($tempItemLength -lt $artifactLength) {
            $hashCode = ((($hashCode -shl 5) - $hashCode) + $Artifact[$tempItemLength++] -bor 0)
            
            # Treat as Double, then convert to Bytes, then convert back to Int32 to match JavaScript behavior
            $hashCode = [System.BitConverter]::ToInt32([System.BitConverter]::GetBytes($hashCode), 0)
        }
    }

    if ($hashCode -lt 0) {
        return -1 * $hashCode
    }
    else {
        return $hashCode
    }
}

function InvokeAzMigrateGetCommandWithRetries {
    [Microsoft.Azure.PowerShell.Cmdlets.Migrate.DoNotExportAttribute()]
    param(
        [Parameter(Mandatory)]
        [System.String]
        # Specifies the name of Az.Migrate command.
        ${CommandName},

        [Parameter(Mandatory)]
        [System.Collections.Hashtable]
        # Specifies the parameters for Az.Migrate command.
        ${Parameters},

        [Parameter()]
        [System.Int32]
        # Specifies the maximum number of retries.
        ${MaxRetryCount} = 3,

        [Parameter()]
        [System.Int32]
        # Specifies the delay between retries in seconds.
        ${RetryDelayInSeconds} = 30,

        [Parameter()]
        [System.String]
        # Specifies the error message to throw if command fails.
        ${ErrorMessage} = "Internal Az.Migrate commands failed to execute."
    )

    process {
        # Filter out ErrorAction and ErrorVariable from the parameters
        $params = @{}
        foreach ($key in $Parameters.Keys) {
            if ($key -ne "ErrorAction" -and $key -ne "ErrorVariable") {
                $params[$key] = $Parameters[$key]
            }
        }

        # Extract user-specified ErrorAction and ErrorVariable or defaults
        # but do not include them in $params
        if ($Parameters.ContainsKey("ErrorVariable")) {
            $errorVariable = $Parameters["ErrorVariable"]
        }
        else
        {
            $errorVariable = "notPresent"
        }

        if ($Parameters.ContainsKey("ErrorAction")) {
            $errorAction = $Parameters["ErrorAction"]
        }
        else
        {
            $errorAction = "Continue"
        }

        for ($i = 0; $i -le $MaxRetryCount; $i++) {
            try {
                $result = & $CommandName @params -ErrorVariable $errorVariable -ErrorAction $errorAction

                if ($null -eq $result) {
                    throw $ErrorMessage
                }

                break
            }
            catch {
                if ($i -lt $MaxRetryCount) {
                    Start-Sleep -Seconds $RetryDelayInSeconds
                }
                else {
                    throw "Get command failed after $MaxRetryCount retries. Error: $($_.Exception)"
                }
            }
        }

        return $result
    }
}

function ValidateReplication {
    [Microsoft.Azure.PowerShell.Cmdlets.Migrate.DoNotExportAttribute()]
    param (
        [Parameter(Mandatory)]
        [PSCustomObject]
        ${Machine},

        [Parameter(Mandatory)]
        [System.String]
        ${MigrationType}
    )
    # Check if the VM is already protected
    $protectedItem = Az.Migrate\Get-AzMigrateLocalServerReplication `
        -DiscoveredMachineId $Machine.Id  `
        -ErrorAction SilentlyContinue
    if ($null -ne $protectedItem) {
        throw $VmReplicationValidationMessages.AlreadyInReplication
    }

    # Check the VM power status
    if ($Machine.PowerStatus -eq $PowerStatus.OffVMware -or $Machine.PowerStatus -eq $PowerStatus.OffHyperV) {
        throw $VmReplicationValidationMessages.VmPoweredOff
    }

    # Hyper-V scenario checks
    if ($MigrationType -eq $AzLocalInstanceTypes.HyperVToAzLocal) {
        # Hyper-V VMs with 'otherguestfamily' OS type and missing OS name could also mean Hyper-V Integration Services are not running
        if ([string]::IsNullOrEmpty($Machine.OperatingSystemDetailOSType) -or
            ($Machine.OperatingSystemDetailOSType -eq $OsTypes.OtherGuestFamily -and [string]::IsNullOrEmpty($Machine.GuestOSDetailOsname)))
        {
            throw $VmReplicationValidationMessages.HyperVIntegrationServicesNotRunning
        }

        # Hyper-V VMs should be highly available
        if (![string]::IsNullOrEmpty($Machine.ClusterId) -and $Machine.HighAvailability -eq $HighAvailability.NO) {
            throw $VmReplicationValidationMessages.VmNotHighlyAvailable
        }
    }

    # VMware scenario checks
    if ($MigrationType -eq $AzLocalInstanceTypes.VMwareToAzLocal) {
        # VMware tools should be running to support static ip migration
        if ($Machine.VMwareToolsStatus -eq $VMwareToolsStatus.NotRunning) {
            Write-Warning $VmReplicationValidationMessages.VmWareToolsNotRunning
        }

        if ($Machine.VMwareToolsStatus -eq $VMwareToolsStatus.NotInstalled) {
            Write-Warning $VmReplicationValidationMessages.VmWareToolsNotInstalled
        }
    }

    # Only OS type of windowsguest and linuxguest are supported for Hyper-V and VMware scenarios
    if ($Machine.OperatingSystemDetailOSType -ne $OsTypes.WindowsGuest -and
        $Machine.OperatingSystemDetailOSType -ne $OsTypes.LinuxGuest)
    {
        Write-Warning $VmReplicationValidationMessages.OsTypeNotSupported
    }
}
# SIG # Begin signature block
# MIIoLQYJKoZIhvcNAQcCoIIoHjCCKBoCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCC47LK4OPD6J5/r
# L3VHFaJ9taDU/7yBoNjYaQue8juVpKCCDXYwggX0MIID3KADAgECAhMzAAAEhV6Z
# 7A5ZL83XAAAAAASFMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjUwNjE5MTgyMTM3WhcNMjYwNjE3MTgyMTM3WjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQDASkh1cpvuUqfbqxele7LCSHEamVNBfFE4uY1FkGsAdUF/vnjpE1dnAD9vMOqy
# 5ZO49ILhP4jiP/P2Pn9ao+5TDtKmcQ+pZdzbG7t43yRXJC3nXvTGQroodPi9USQi
# 9rI+0gwuXRKBII7L+k3kMkKLmFrsWUjzgXVCLYa6ZH7BCALAcJWZTwWPoiT4HpqQ
# hJcYLB7pfetAVCeBEVZD8itKQ6QA5/LQR+9X6dlSj4Vxta4JnpxvgSrkjXCz+tlJ
# 67ABZ551lw23RWU1uyfgCfEFhBfiyPR2WSjskPl9ap6qrf8fNQ1sGYun2p4JdXxe
# UAKf1hVa/3TQXjvPTiRXCnJPAgMBAAGjggFzMIIBbzAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQUuCZyGiCuLYE0aU7j5TFqY05kko0w
# RQYDVR0RBD4wPKQ6MDgxHjAcBgNVBAsTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEW
# MBQGA1UEBRMNMjMwMDEyKzUwNTM1OTAfBgNVHSMEGDAWgBRIbmTlUAXTgqoXNzci
# tW2oynUClTBUBgNVHR8ETTBLMEmgR6BFhkNodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpb3BzL2NybC9NaWNDb2RTaWdQQ0EyMDExXzIwMTEtMDctMDguY3JsMGEG
# CCsGAQUFBwEBBFUwUzBRBggrBgEFBQcwAoZFaHR0cDovL3d3dy5taWNyb3NvZnQu
# Y29tL3BraW9wcy9jZXJ0cy9NaWNDb2RTaWdQQ0EyMDExXzIwMTEtMDctMDguY3J0
# MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQADggIBACjmqAp2Ci4sTHZci+qk
# tEAKsFk5HNVGKyWR2rFGXsd7cggZ04H5U4SV0fAL6fOE9dLvt4I7HBHLhpGdE5Uj
# Ly4NxLTG2bDAkeAVmxmd2uKWVGKym1aarDxXfv3GCN4mRX+Pn4c+py3S/6Kkt5eS
# DAIIsrzKw3Kh2SW1hCwXX/k1v4b+NH1Fjl+i/xPJspXCFuZB4aC5FLT5fgbRKqns
# WeAdn8DsrYQhT3QXLt6Nv3/dMzv7G/Cdpbdcoul8FYl+t3dmXM+SIClC3l2ae0wO
# lNrQ42yQEycuPU5OoqLT85jsZ7+4CaScfFINlO7l7Y7r/xauqHbSPQ1r3oIC+e71
# 5s2G3ClZa3y99aYx2lnXYe1srcrIx8NAXTViiypXVn9ZGmEkfNcfDiqGQwkml5z9
# nm3pWiBZ69adaBBbAFEjyJG4y0a76bel/4sDCVvaZzLM3TFbxVO9BQrjZRtbJZbk
# C3XArpLqZSfx53SuYdddxPX8pvcqFuEu8wcUeD05t9xNbJ4TtdAECJlEi0vvBxlm
# M5tzFXy2qZeqPMXHSQYqPgZ9jvScZ6NwznFD0+33kbzyhOSz/WuGbAu4cHZG8gKn
# lQVT4uA2Diex9DMs2WHiokNknYlLoUeWXW1QrJLpqO82TLyKTbBM/oZHAdIc0kzo
# STro9b3+vjn2809D0+SOOCVZMIIHejCCBWKgAwIBAgIKYQ6Q0gAAAAAAAzANBgkq
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
# Z25pbmcgUENBIDIwMTECEzMAAASFXpnsDlkvzdcAAAAABIUwDQYJYIZIAWUDBAIB
# BQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIEOl/EJDCmGWZWEbJinVYkvZ
# Rgdglb3whwwqH65WZFdOMEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEB
# BQAEggEAVCSeHnmhrqH2+i2K6pd4VHE2DUZnA6GF/jzQw067FK6gEAaUpl+xZ2cg
# w9dkoQ7mUSyq5kVH4LOERDPRQ4Eedl8BDY+s10nFTlK+a2XKYUbGDvYy5E0yJO35
# x4ODG9hz7YzFWc6DjzXnp1TXziMo7KmsgV5ZVeyKlkB5vjF4IX8k/jl+cvftmwwK
# ZHGUJn88FSh47DYFk+Vyh+AsV2ok3tkwHMcT+H2xjguMom4ax+JEasJjWjO4W+se
# F+5BbzWikBMLs1k2fWl0/gNSEV1tg8Wl11wlriVg+R31SlC4p+jX2TBDUUE+X3kV
# KphtRd4ETXF6CAqqqY35To+lAJpy7qGCF5cwgheTBgorBgEEAYI3AwMBMYIXgzCC
# F38GCSqGSIb3DQEHAqCCF3AwghdsAgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFSBgsq
# hkiG9w0BCRABBKCCAUEEggE9MIIBOQIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCBsO9pBdcj4C9uCritOe4bZm1dGJ/8eEzVcbBgnh7a3VwIGaEsgBNtV
# GBMyMDI1MDczMDAzNTExOC45MzlaMASAAgH0oIHRpIHOMIHLMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1l
# cmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046ODkwMC0w
# NUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2Wg
# ghHtMIIHIDCCBQigAwIBAgITMwAAAg4syyh9lSB1YwABAAACDjANBgkqhkiG9w0B
# AQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYD
# VQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAeFw0yNTAxMzAxOTQz
# MDNaFw0yNjA0MjIxOTQzMDNaMIHLMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25z
# MScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046ODkwMC0wNUUwLUQ5NDcxJTAjBgNV
# BAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2UwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQCs5t7iRtXt0hbeo9ME78ZYjIo3saQuWMBFQ7X4s9vo
# oYRABTOf2poTHatx+EwnBUGB1V2t/E6MwsQNmY5XpM/75aCrZdxAnrV9o4Tu5sBe
# pbbfehsrOWRBIGoJE6PtWod1CrFehm1diz3jY3H8iFrh7nqefniZ1SnbcWPMyNIx
# uGFzpQiDA+E5YS33meMqaXwhdb01Cluymh/3EKvknj4dIpQZEWOPM3jxbRVAYN5J
# 2tOrYkJcdDx0l02V/NYd1qkvUBgPxrKviq5kz7E6AbOifCDSMBgcn/X7RQw630Qk
# zqhp0kDU2qei/ao9IHmuuReXEjnjpgTsr4Ab33ICAKMYxOQe+n5wqEVcE9OTyhmW
# ZJS5AnWUTniok4mgwONBWQ1DLOGFkZwXT334IPCqd4/3/Ld/ItizistyUZYsml/C
# 4ZhdALbvfYwzv31Oxf8NTmV5IGxWdHnk2Hhh4bnzTKosEaDrJvQMiQ+loojM7f5b
# gdyBBnYQBm5+/iJsxw8k227zF2jbNI+Ows8HLeZGt8t6uJ2eVjND1B0YtgsBP0cs
# BlnnI+4+dvLYRt0cAqw6PiYSz5FSZcbpi0xdAH/jd3dzyGArbyLuo69HugfGEEb/
# sM07rcoP1o3cZ8eWMb4+MIB8euOb5DVPDnEcFi4NDukYM91g1Dt/qIek+rtE88VS
# 8QIDAQABo4IBSTCCAUUwHQYDVR0OBBYEFIVxRGlSEZE+1ESK6UGI7YNcEIjbMB8G
# A1UdIwQYMBaAFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMF8GA1UdHwRYMFYwVKBSoFCG
# Tmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUy
# MFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNybDBsBggrBgEFBQcBAQRgMF4w
# XAYIKwYBBQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2Vy
# dHMvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUyMDIwMTAoMSkuY3J0MAwG
# A1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQD
# AgeAMA0GCSqGSIb3DQEBCwUAA4ICAQB14L2TL+L8OXLxnGSal2h30mZ7FsBFooiY
# kUVOY05F9pnwPTVufEDGWEpNNy2OfaUHWIOoQ/9/rjwO0hS2SpB0BzMAk2gyz92N
# GWOpWbpBdMvrrRDpiWZi/uLS4ZGdRn3P2DccYmlkNP+vaRAXvnv+mp27KgI79mJ9
# hGyCQbvtMIjkbYoLqK7sF7Wahn9rLjX1y5QJL4lvEy3QmA9KRBj56cEv/lAvzDq7
# eSiqRq/pCyqyc8uzmQ8SeKWyWu6DjUA9vi84QsmLjqPGCnH4cPyg+t95RpW+73sn
# hew1iCV+wXu2RxMnWg7EsD5eLkJHLszUIPd+XClD+FTvV03GfrDDfk+45flH/eKR
# Zc3MUZtnhLJjPwv3KoKDScW4iV6SbCRycYPkqoWBrHf7SvDA7GrH2UOtz1Wa1k27
# sdZgpG6/c9CqKI8CX5vgaa+A7oYHb4ZBj7S8u8sgxwWK7HgWDRByOH3CiJu4LJ8h
# 3TiRkRArmHRp0lbNf1iAKuL886IKE912v0yq55t8jMxjBU7uoLsrYVIoKkzh+sAk
# gkpGOoZL14+dlxVM91Bavza4kODTUlwzb+SpXsSqVx8nuB6qhUy7pqpgww1q4SNh
# AxFnFxsxiTlaoL75GNxPR605lJ2WXehtEi7/+YfJqvH+vnqcpqCjyQ9hNaVzuOEH
# X4MyuqcjwjCCB3EwggVZoAMCAQICEzMAAAAVxedrngKbSZkAAAAAABUwDQYJKoZI
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
# MCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOjg5MDAtMDVFMC1EOTQ3MSUwIwYDVQQD
# ExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloiMKAQEwBwYFKw4DAhoDFQBK
# 6HY/ZWLnOcMEQsjkDAoB/JZWCKCBgzCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFBDQSAyMDEwMA0GCSqGSIb3DQEBCwUAAgUA7DOQ0DAiGA8yMDI1MDcyOTE4MjYy
# NFoYDzIwMjUwNzMwMTgyNjI0WjB3MD0GCisGAQQBhFkKBAExLzAtMAoCBQDsM5DQ
# AgEAMAoCAQACAhvFAgH/MAcCAQACAhMMMAoCBQDsNOJQAgEAMDYGCisGAQQBhFkK
# BAIxKDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMHoSChCjAIAgEAAgMBhqAwDQYJ
# KoZIhvcNAQELBQADggEBAKdyT+Z+SxvRG9p9Y9rvwCsYoCA1kCxBPmDD3/V4NMvh
# 0+jhIbVkYLl4EN1nBalfAwckY29o8BUfmt02EDlVBusEoS8dZHevu35gGom/rNjU
# EMg2LYkKV2X7ivOBcVMUQtGlwMc11lLwZ8RVc5VF8mpaR8DpWr4LOmtNxPxyHuN4
# QVhiWEtfEz7x9FEwDIsu4F6/9qWmkj/ngsbx4CCfpxgeFEKVtlvVaFoaQM4vtAhi
# eVwtxz9Mw8HNvmNDbSJLNqLffAMMP2zGEHUssm2ReUhd1EhR+T4d15DKbvGTgeN8
# NPRUM8SnOZ9UVYyeQxso3RqL0ucHQijdWX0JRfGads0xggQNMIIECQIBATCBkzB8
# MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVk
# bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1N
# aWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAg4syyh9lSB1YwABAAAC
# DjANBglghkgBZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEE
# MC8GCSqGSIb3DQEJBDEiBCBTeUQOwDmmScs0Zz7GXdEEiP/Vdqu8GY8K39OHX4aM
# vDCB+gYLKoZIhvcNAQkQAi8xgeowgecwgeQwgb0EIAF0HXMl8OmBkK267mxobKSi
# hwOdP0eUNXQMypPzTxKGMIGYMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29m
# dCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENB
# IDIwMTACEzMAAAIOLMsofZUgdWMAAQAAAg4wIgQgacI9uBQ9Gp4nktT0P9+wTdiP
# L3p8j7BcOmT5ySOJR9gwDQYJKoZIhvcNAQELBQAEggIAfIIZ4+zIjBwMQ8D8SffM
# 9EWB3ZCs378nhbgNpLTHyMcckiChVtBr16omDcS3ATw4KDII054g6ccDhgZgqdTL
# NUbo9xtfWi1z2c9pM9Kz1EtpfoMZiJPUo89fRryroA2NoKOGY00dgUI5OhDMfBAd
# CZ5QY0SHo4eQuTMnwPROdaAlbqlmWTrGVyaZNpT3AaSUtnPqsabWWjtsv8NbN3oZ
# ZzTAyxuQZAl4VjqeVOvv4wYplkUrMFh3qHjkE1vTdgzHJlci0TRN8IR6Zj1CTEkX
# S4lCh2zhs13pICbMnP/Mcadhq6ichw0zMDeUKYXjZs0Uf8nD27fV9Pu0nQ0T41Lt
# v2r8J1+3mUlDLUohf2HUN0b5iEGso+/SKUUjqdeTAUwB9qjq88vc+7ppJrvXVMwW
# zZj7vDkqiXBl2Z7yDF8NTy/momejIyuI60kXN+2dWtaNdSVP8TOmJMJ+ga3mdLrr
# bF8hSAQ4xMQ4IPXhMk8sLMxyHt7Bj8iQDiwuIeEX7eW4KMVpVfmPp2qWYJUw5KGD
# 81A2YE9YmBRlOLVlkzunBnk+pkXLT//ShGTa/qb0iMs/KPLxAgy7FhtC7kgpCqyY
# QjCRoAqcDeTioxbeZpIvsmC+jy4XfPgOQ1jRmUJW/LBg+6YK5plpEwiCQHyyAJLv
# 1zMGV02gX/+b1EyNsg97/wo=
# SIG # End signature block
