function Initialize-AzDataProtectionRestoreRequest
{
	[OutputType('Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20240401.IAzureBackupRestoreRequest')]
    [CmdletBinding(PositionalBinding=$false, DefaultParameterSetName='AlternateLocationFullRecovery')]
    [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Description('Initializes Restore Request object for triggering restore on a protected backup instance.')]

    param(
        [Parameter(ParameterSetName="OriginalLocationFullRecovery", Mandatory, HelpMessage='Datasource Type')]
        [Parameter(ParameterSetName="AlternateLocationFullRecovery", Mandatory, HelpMessage='Datasource Type')]
        [Parameter(ParameterSetName="OriginalLocationILR", Mandatory, HelpMessage='Datasource Type')]
        [Parameter(ParameterSetName="RestoreAsFiles", Mandatory, HelpMessage='Datasource Type')]
        [Parameter(ParameterSetName="AlternateLocationILR", Mandatory, HelpMessage='Datasource Type')]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Support.DatasourceTypes]
        ${DatasourceType},

        [Parameter(ParameterSetName="OriginalLocationFullRecovery", Mandatory, HelpMessage='DataStore Type of the Recovery point')]
        [Parameter(ParameterSetName="AlternateLocationFullRecovery", Mandatory, HelpMessage='DataStore Type of the Recovery point')]
        [Parameter(ParameterSetName="OriginalLocationILR", Mandatory, HelpMessage='DataStore Type of the Recovery point')]
        [Parameter(ParameterSetName="RestoreAsFiles", Mandatory, HelpMessage='DataStore Type of the Recovery point')]
        [Parameter(ParameterSetName="AlternateLocationILR", Mandatory, HelpMessage='DataStore Type of the Recovery point')]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Support.DataStoreType]
        ${SourceDataStore},

        [Parameter(ParameterSetName="OriginalLocationFullRecovery", Mandatory=$false, HelpMessage='Id of the recovery point to be restored.')]
        [Parameter(ParameterSetName="AlternateLocationFullRecovery", Mandatory=$false, HelpMessage='Id of the recovery point to be restored.')]
        [Parameter(ParameterSetName="OriginalLocationILR", Mandatory=$false, HelpMessage='Id of the recovery point to be restored.')]
        [Parameter(ParameterSetName="RestoreAsFiles", Mandatory=$false, HelpMessage='Id of the recovery point to be restored.')]
        [Parameter(ParameterSetName="AlternateLocationILR", Mandatory=$false, HelpMessage='Id of the recovery point to be restored.')]
        [System.String]
        ${RecoveryPoint},
        
        [Parameter(ParameterSetName="OriginalLocationFullRecovery", Mandatory=$false, HelpMessage='Point In Time for restore.')]
        [Parameter(ParameterSetName="AlternateLocationFullRecovery", Mandatory=$false, HelpMessage='Point In Time for restore.')]
        [Parameter(ParameterSetName="OriginalLocationILR", Mandatory=$false, HelpMessage='Point In Time for restore.')]
        # [Parameter(ParameterSetName="AlternateLocationILR", Mandatory=$false, HelpMessage='Point In Time for restore.')]
        [System.DateTime]
        ${PointInTime},

        [Parameter(ParameterSetName="OriginalLocationFullRecovery", Mandatory=$false, HelpMessage='Rehydration duration for the archived recovery point to stay rehydrated, default value for rehydration duration is 15.')]
        [Parameter(ParameterSetName="AlternateLocationFullRecovery", Mandatory=$false, HelpMessage='Rehydration duration for the archived recovery point to stay rehydrated, default value for rehydration duration is 15.')]
        [Parameter(ParameterSetName="OriginalLocationILR", Mandatory=$false, HelpMessage='Rehydration duration for the archived recovery point to stay rehydrated, default value for rehydration duration is 15.')]
        [Parameter(ParameterSetName="RestoreAsFiles", Mandatory=$false, HelpMessage='Rehydration duration for the archived recovery point to stay rehydrated, default value for rehydration duration is 15.')]
        # [Parameter(ParameterSetName="AlternateLocationILR", Mandatory=$false, HelpMessage='Rehydration duration for the archived recovery point to stay rehydrated, default value for rehydration duration is 15.')]
        [System.String]
        ${RehydrationDuration},

        [Parameter(ParameterSetName="OriginalLocationFullRecovery", Mandatory=$false, HelpMessage='Rehydration priority for archived recovery point. This parameter is mandatory for rehydrate restore of archived points.')]
        [Parameter(ParameterSetName="AlternateLocationFullRecovery", Mandatory=$false, HelpMessage='Rehydration priority for archived recovery point. This parameter is mandatory for rehydrate restore of archived points.')]
        [Parameter(ParameterSetName="OriginalLocationILR", Mandatory=$false, HelpMessage='Rehydration priority for archived recovery point. This parameter is mandatory for rehydrate restore of archived points.')]
        [Parameter(ParameterSetName="RestoreAsFiles", Mandatory=$false, HelpMessage='Rehydration priority for archived recovery point. This parameter is mandatory for rehydrate restore of archived points.')]
        # [Parameter(ParameterSetName="AlternateLocationILR", Mandatory=$false, HelpMessage='Rehydration priority for archived recovery point. This parameter is mandatory for rehydrate restore of archived points.')]
        [ValidateSet("Standard")]
        [System.String]
        ${RehydrationPriority},

        [Parameter(ParameterSetName="OriginalLocationFullRecovery", Mandatory, HelpMessage='Target Restore Location')]
        [Parameter(ParameterSetName="AlternateLocationFullRecovery", Mandatory, HelpMessage='Target Restore Location')]
        [Parameter(ParameterSetName="OriginalLocationILR", Mandatory, HelpMessage='Target Restore Location')]
        [Parameter(ParameterSetName="RestoreAsFiles", Mandatory, HelpMessage='Target Restore Location')]
        [Parameter(ParameterSetName="AlternateLocationILR", Mandatory, HelpMessage='Target Restore Location')]
        [System.String]
        ${RestoreLocation},

        [Parameter(ParameterSetName="OriginalLocationFullRecovery", Mandatory, HelpMessage='Restore Target Type')]
        [Parameter(ParameterSetName="AlternateLocationFullRecovery", Mandatory, HelpMessage='Restore Target Type')]
        [Parameter(ParameterSetName="OriginalLocationILR", Mandatory, HelpMessage='Restore Target Type')]
        [Parameter(ParameterSetName="RestoreAsFiles", Mandatory, HelpMessage='Restore Target Type')]
        [Parameter(ParameterSetName="AlternateLocationILR", Mandatory, HelpMessage='Restore Target Type')]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Support.RestoreTargetType]
        ${RestoreType},

        [Parameter(ParameterSetName="OriginalLocationFullRecovery", Mandatory, HelpMessage='Backup Instance object to trigger original localtion restore.')]
        [Parameter(ParameterSetName="OriginalLocationILR", Mandatory, HelpMessage='Backup Instance object to trigger original localtion restore.')]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20240401.BackupInstanceResource]
        ${BackupInstance},

        # this is applicable to all workloads wherever ALR supported.
        [Parameter(ParameterSetName="AlternateLocationFullRecovery", Mandatory, HelpMessage='Specify the target resource ID for restoring backup data in an alternate location. For instance, provide the target database ARM ID that you want to restore to, for workloadType AzureDatabaseForPostgreSQL.')]
        [Parameter(ParameterSetName="AlternateLocationILR", Mandatory, HelpMessage='Specify the target resource ID for restoring backup data in an alternate location. For instance, provide the target database ARM ID that you want to restore to, for workloadType AzureDatabaseForPostgreSQL.')]
        [System.String]
        ${TargetResourceId},

        # this parameter is being used in OSS cross subscription restore as files
        [Parameter(ParameterSetName="RestoreAsFiles", Mandatory=$false, HelpMessage='Target storage account container ARM Id to which backup data will be restored as files. This parameter is required for restoring as files when cross subscription restore is disabled on the backup vault.')]
        [System.String]
        ${TargetResourceIdForRestoreAsFile},

        [Parameter(ParameterSetName="RestoreAsFiles", Mandatory, HelpMessage='Target storage account container Id to which backup data will be restored as files.')]
        [System.String]
        ${TargetContainerURI},

        [Parameter(ParameterSetName="RestoreAsFiles", Mandatory=$false, HelpMessage='File name to be prefixed to the restored backup data.')]
        [System.String]
        ${FileNamePrefix},

        [Parameter(ParameterSetName="OriginalLocationILR", Mandatory, HelpMessage='Switch parameter to enable item level recovery.')]
        [Parameter(ParameterSetName="AlternateLocationILR", Mandatory, HelpMessage='Switch parameter to enable item level recovery.')]
        [Switch]
        ${ItemLevelRecovery},
                
        [Parameter(ParameterSetName="OriginalLocationILR", Mandatory=$false, HelpMessage='Container names for Item Level Recovery.')]
        [Parameter(ParameterSetName="AlternateLocationILR", Mandatory=$false, HelpMessage='Container names for Item Level Recovery.')]
        [System.String[]]
        ${ContainersList},
                
        [Parameter(ParameterSetName="AlternateLocationILR", Mandatory=$false, HelpMessage='Use this parameter to filter block blobs by prefix in a container for alternate location ILR. When you specify a prefix, only blobs matching that prefix in the container will be restored. Input for this parameter is a hashtable where each key is a container name and each value is an array of string prefixes for that container.')]
        [Hashtable]
        ${PrefixMatch},

        [Parameter(ParameterSetName="OriginalLocationILR", Mandatory=$false, HelpMessage='Specify the blob restore start range for PITR. You can use this option to specify the starting range for a subset of blobs in each container to restore. use a forward slash (/) to separate the container name from the blob prefix pattern.')]
        # [Parameter(ParameterSetName="AlternateLocationILR", Mandatory=$false, HelpMessage='Minimum matching value for Item Level Recovery.')]
        [System.String[]]
        ${FromPrefixPattern},

        [Parameter(ParameterSetName="OriginalLocationILR", Mandatory=$false, HelpMessage='Specify the blob restore end range for PITR. You can use this option to specify the ending range for a subset of blobs in each container to restore. use a forward slash (/) to separate the container name from the blob prefix pattern.')]
        # [Parameter(ParameterSetName="AlternateLocationILR", Mandatory=$false, HelpMessage='Maximum matching value for Item Level Recovery.')]
        [System.String[]]
        ${ToPrefixPattern},

        [Parameter(ParameterSetName="OriginalLocationILR", Mandatory=$false, HelpMessage='Restore configuration for restore. Use this parameter to restore with AzureKubernetesService.')]
        [Parameter(ParameterSetName="AlternateLocationILR", Mandatory=$false, HelpMessage='Restore configuration for restore. Use this parameter to restore with AzureKubernetesService.')]
        [Parameter(ParameterSetName="OriginalLocationFullRecovery", Mandatory=$false, HelpMessage='Restore configuration for restore. Use this parameter to restore with AzureKubernetesService.')]
        [Parameter(ParameterSetName="AlternateLocationFullRecovery", Mandatory=$false, HelpMessage='Restore configuration for restore. Use this parameter to restore with AzureKubernetesService.')]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20240401.KubernetesClusterRestoreCriteria]
        ${RestoreConfiguration},

        [Parameter(ParameterSetName="OriginalLocationFullRecovery", Mandatory=$false, HelpMessage='Secret uri for secret store authentication of data source. This parameter is only supported for AzureDatabaseForPostgreSQL currently.')]
        [Parameter(ParameterSetName="AlternateLocationFullRecovery", Mandatory=$false, HelpMessage='Secret uri for secret store authentication of data source. This parameter is only supported for AzureDatabaseForPostgreSQL currently.')]
        [Parameter(ParameterSetName="OriginalLocationILR", Mandatory=$false, HelpMessage='Secret uri for secret store authentication of data source. This parameter is only supported for AzureDatabaseForPostgreSQL currently.')]
        [Parameter(ParameterSetName="RestoreAsFiles", Mandatory=$false, HelpMessage='Secret uri for secret store authentication of data source. This parameter is only supported for AzureDatabaseForPostgreSQL currently.')]
        [System.String]
        ${SecretStoreURI},

        [Parameter(ParameterSetName="OriginalLocationFullRecovery", Mandatory=$false, HelpMessage='Secret store type for secret store authentication of data source. This parameter is only supported for AzureDatabaseForPostgreSQL currently.')]
        [Parameter(ParameterSetName="AlternateLocationFullRecovery", Mandatory=$false, HelpMessage='Secret store type for secret store authentication of data source. This parameter is only supported for AzureDatabaseForPostgreSQL currently.')]
        [Parameter(ParameterSetName="OriginalLocationILR", Mandatory=$false, HelpMessage='Secret store type for secret store authentication of data source. This parameter is only supported for AzureDatabaseForPostgreSQL currently.')]
        [Parameter(ParameterSetName="RestoreAsFiles", Mandatory=$false, HelpMessage='Secret store type for secret store authentication of data source. This parameter is only supported for AzureDatabaseForPostgreSQL currently.')]
        [ValidateSet("AzureKeyVault")]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Support.SecretStoreTypes]
        ${SecretStoreType}    
    )

    process
    {         
        # Validations
        $parameterSetName = $PsCmdlet.ParameterSetName

        $restoreRequest = $null
        $restoreMode = $null
        $manifest = LoadManifest -DatasourceType $DatasourceType.ToString()

        # Choose Restore Request Type Based on Recovery Point ID/ Time
        if(($RecoveryPoint -ne $null) -and ($RecoveryPoint -ne ""))
        {               
            Write-Debug -Message $RecoveryPoint
            
            if($PSBoundParameters.ContainsKey("RehydrationPriority")){
                $restoreRequest = [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20240401.AzureBackupRestoreWithRehydrationRequest]::new()
                $restoreRequest.ObjectType = "AzureBackupRestoreWithRehydrationRequest"   
                $restoreRequest.RehydrationPriority = $RehydrationPriority
                if($PSBoundParameters.ContainsKey("RehydrationDuration")){
                    $restoreRequest.RehydrationRetentionDuration = "P" + $RehydrationDuration + "D"
                }
                else{
                    $restoreRequest.RehydrationRetentionDuration = "P15D"
                }                
            }
            else{
                $restoreRequest = [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20240401.AzureBackupRecoveryPointBasedRestoreRequest]::new()
                $restoreRequest.ObjectType = "AzureBackupRecoveryPointBasedRestoreRequest"            
            }            
            $restoreRequest.RecoveryPointId = $RecoveryPoint
            $restoreMode = "RecoveryPointBased"
        }
        elseif(($PointInTime -ne $null)  -and ($PointInTime -ne "")) # RecoveryPointInTimeBasedRestore
        {
            $utcTime = $PointInTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.0000000Z")
            Write-Debug -Message $utcTime
            $restoreRequest = [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20240401.AzureBackupRecoveryTimeBasedRestoreRequest]::new()
            $restoreRequest.ObjectType = "AzureBackupRecoveryTimeBasedRestoreRequest"
            $restoreRequest.RecoveryPointTime = $utcTime
            $restoreMode = "PointInTimeBased"
        }
        else{
            $errormsg = "Please input either RecoveryPoint or PointInTime parameter"
    		throw $errormsg
        }
        
        #Validate Restore Options = recoverypoint, ALR, OLR, ILR
        ValidateRestoreOptions -DatasourceType $DatasourceType -RestoreMode $restoreMode -RestoreTargetType $RestoreType -ItemLevelRecovery $ItemLevelRecovery -SecretStoreURI $SecretStoreURI

        # Initialize Restore Target Info based on Type provided

        if($RestoreType -eq "RestoreAsFiles") 
        {
           $restoreRequest.RestoreTargetInfo = [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20240401.RestoreFilesTargetInfo]::new()
           $restoreRequest.RestoreTargetInfo.ObjectType = "RestoreFilesTargetInfo"

           if($manifest.fileNamePrefixDisabled -and $PSBoundParameters.ContainsKey("FileNamePrefix")){
               $errormsg = "FileNamePrefix can't be set for given DatasourceType. Please try again after removing FileNamePrefix parameter"
    		   throw $errormsg
           }
           elseif($manifest.fileNamePrefixDisabled -and !($PSBoundParameters.ContainsKey("TargetContainerURI"))){
               $errormsg = "TargetContainerURI parameter is required for RestoreAsFiles for given DatasourceType"
    		   throw $errormsg
           }
           elseif( !$manifest.fileNamePrefixDisabled -and (!($PSBoundParameters.ContainsKey("FileNamePrefix")) -or !($PSBoundParameters.ContainsKey("TargetContainerURI"))) ){
                $errormsg = "FileNamePrefix and TargetContainerURI parameters are required for RestoreAsFiles for given DatasourceType"
    		    throw $errormsg
           }

           if($manifest.fileNamePrefixDisabled){
               $restoreRequest.RestoreTargetInfo.TargetDetail.FilePrefix = "dummyprefix"
           }
           else{
               $restoreRequest.RestoreTargetInfo.TargetDetail.FilePrefix = $FileNamePrefix
           }
           
           $restoreRequest.RestoreTargetInfo.TargetDetail.RestoreTargetLocationType = "AzureBlobs"
           $restoreRequest.RestoreTargetInfo.TargetDetail.Url = $TargetContainerURI

           # mandatory for Cross Subscription restore scenario for OSS
           if(($PSBoundParameters.ContainsKey("TargetResourceIdForRestoreAsFile"))){
               $restoreRequest.RestoreTargetInfo.TargetDetail.TargetResourceArmId = $TargetResourceIdForRestoreAsFile                
           }
        }
        elseif(!($ItemLevelRecovery))
        {   
            # RestoreTargetInfo for OLR ALR Full recovery
            if($DatasourceType -ne "AzureKubernetesService"){
                $restoreRequest.RestoreTargetInfo = [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20240401.RestoreTargetInfo]::new()
                $restoreRequest.RestoreTargetInfo.ObjectType = "restoreTargetInfo"
            }
            else{
                $restoreRequest.RestoreTargetInfo = [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20240401.ItemLevelRestoreTargetInfo]::new()
                $restoreRequest.RestoreTargetInfo.ObjectType = "itemLevelRestoreTargetInfo"
                $restoreCriteriaList = @()

                # ItemLevelRecovery for AzureKubernetesService
                if($RestoreConfiguration -ne $null){
                    $restoreCriteria = $RestoreConfiguration
                }
                else{
                    $errormsg = "Please input parameter RestoreConfiguration for AKS cluster restore. Use command New-AzDataProtectionRestoreConfigurationClientObject for creating the RestoreConfiguration"
    		        throw $errormsg
                }                
                
                $restoreCriteriaList += ($restoreCriteria)
                $restoreRequest.RestoreTargetInfo.RestoreCriterion = $restoreCriteriaList
            }
        }        
        else 
        {
            # ILR: ItemLevelRestoreTargetInfo
            $restoreRequest.RestoreTargetInfo = [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20240401.ItemLevelRestoreTargetInfo]::new()
            $restoreRequest.RestoreTargetInfo.ObjectType = "itemLevelRestoreTargetInfo"

            $restoreCriteriaList = @()
            
            # can generalise this condition to manifest level if needed
            if($DatasourceType -ne "AzureKubernetesService"){ # TODO: remove Datasource dependency
                
                if(($RecoveryPoint -ne $null) -and ($RecoveryPoint -ne "") -and $ContainersList.length -gt 0){
                    $hasPrefixMatch = $PSBoundParameters.Remove("PrefixMatch")
                    for($i = 0; $i -lt $ContainersList.length; $i++){
                                
                        $restoreCriteria = [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20240401.ItemPathBasedRestoreCriteria]::new()

                        $restoreCriteria.ObjectType = "ItemPathBasedRestoreCriteria"
                        $restoreCriteria.ItemPath = $ContainersList[$i]
                        $restoreCriteria.IsPathRelativeToBackupItem = $true

                        if($hasPrefixMatch){
                            $pathPrefix = $PrefixMatch[$ContainersList[$i]]
                            if($pathPrefix -ne $null -and !($pathPrefix -is [Array])){
                                throw "values for PrefixMatch must be string array for each container"
                            }
                            $restoreCriteria.SubItemPathPrefix = $pathPrefix
                        }

                        # adding a criteria for each container given
                        $restoreCriteriaList += ($restoreCriteria)
                    }
                }
                elseif($ContainersList.length -gt 0){
                    for($i = 0; $i -lt $ContainersList.length; $i++){
                                
                        $restoreCriteria = [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20240401.RangeBasedItemLevelRestoreCriteria]::new()

                        $restoreCriteria.ObjectType = "RangeBasedItemLevelRestoreCriteria"
                        $restoreCriteria.MinMatchingValue = $ContainersList[$i]
                        $restoreCriteria.MaxMatchingValue = $ContainersList[$i] + "-0"

                        # adding a criteria for each container given
                        $restoreCriteriaList += ($restoreCriteria)
                    }
                }
                elseif($FromPrefixPattern.length -gt 0){
                
                    if(($FromPrefixPattern.length -ne $ToPrefixPattern.length) -or ($FromPrefixPattern.length -gt 10) -or ($ToPrefixPattern.length -gt 10)){
                        $errormsg = "FromPrefixPattern and ToPrefixPattern parameters maximum length can be 10 and must be equal "
    			        throw $errormsg
                    }
                
                    for($i = 0; $i -lt $FromPrefixPattern.length; $i++){
                                
                        $restoreCriteria =  [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20240401.RangeBasedItemLevelRestoreCriteria]::new()

                        $restoreCriteria.ObjectType = "RangeBasedItemLevelRestoreCriteria"
                        $restoreCriteria.MinMatchingValue = $FromPrefixPattern[$i]
                        $restoreCriteria.MaxMatchingValue = $ToPrefixPattern[$i]

                        # adding a criteria for each container given
                        $restoreCriteriaList += ($restoreCriteria)
                    }                
                }    
                else{
                     $errormsg = "Provide ContainersList or Prefixes for Item Level Recovery"
    			     throw $errormsg            
                }
            }
            else{
                # ItemLevelRecovery for AzureKubernetesService
                if($RestoreConfiguration -ne $null){
                    $restoreCriteria = $RestoreConfiguration
                }
                else{
                    $errormsg = "Please input parameter RestoreConfiguration for AKS cluster restore. Use command New-AzDataProtectionRestoreConfigurationClientObject for creating the RestoreConfiguration"
    		        throw $errormsg
                }                
                
                $restoreCriteriaList += ($restoreCriteria)
            }

            $restoreRequest.RestoreTargetInfo.RestoreCriterion = $restoreCriteriaList
        }

        # Fill other fields of Restore Object based on inputs given        
        $restoreRequest.SourceDataStoreType = $SourceDataStore
        $restoreRequest.RestoreTargetInfo.RestoreLocation = $RestoreLocation

        
        if($RestoreType -eq "AlternateLocation"){

            if(($TargetResourceId -eq $null) -or ($TargetResourceId -eq ""))
            {
                $errormsg = "Please input TargetResourceId for alternate location recovery"
    		    throw $errormsg
            }
            $resourceId = $TargetResourceId
        }
        elseif($RestoreType -eq "OriginalLocation"){

            if(($BackupInstance -eq $null) -or ($BackupInstance -eq ""))
            {                
                $errormsg = "Please input BackupInstance for original location recovery"
    		    throw $errormsg
            }
            $resourceId = $BackupInstance.Property.DataSourceInfo.ResourceId
        }

        if( ($resourceId -ne $null) -and ($resourceId -ne "") )
        {            
            # set DatasourceInfo for OLR, ALR, OriginalLocationILR
            $restoreRequest.RestoreTargetInfo.DatasourceInfo = GetDatasourceInfo -ResourceId $resourceId -ResourceLocation $RestoreLocation -DatasourceType $DatasourceType
            
            if($manifest.isProxyResource -eq $true)  
            {
                $restoreRequest.RestoreTargetInfo.DatasourceSetInfo = GetDatasourceSetInfo -DatasourceInfo $restoreRequest.RestoreTargetInfo.DatasourceInfo -DatasourceType $DatasourceType
            }
        } 
        
        # secret store authentication
        if($PSBoundParameters.ContainsKey("SecretStoreURI"))
        {
            if($manifest.supportSecretStoreAuthentication -eq $true){
                if(!($PSBoundParameters.ContainsKey("SecretStoreType")))
                {        
                    $errormsg = "Please input SecretStoreType"
        		    throw $errormsg                    
                }
                $restoreRequest.RestoreTargetInfo.DatasourceAuthCredentials = [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20240401.SecretStoreBasedAuthCredentials]::new()
                $restoreRequest.RestoreTargetInfo.DatasourceAuthCredentials.ObjectType = "SecretStoreBasedAuthCredentials"
                $restoreRequest.RestoreTargetInfo.DatasourceAuthCredentials.SecretStoreResource =  [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20240401.SecretStoreResource]::new()
                $restoreRequest.RestoreTargetInfo.DatasourceAuthCredentials.SecretStoreResource.SecretStoreType = $SecretStoreType
                $restoreRequest.RestoreTargetInfo.DatasourceAuthCredentials.SecretStoreResource.Uri = $SecretStoreURI
            }
            else{
                $errormsg = "Please ensure that secret store based authentication is supported for given data source"
        		throw $errormsg
            }            
        }

        return $restoreRequest
    }
}
# SIG # Begin signature block
# MIIn0QYJKoZIhvcNAQcCoIInwjCCJ74CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCGO9YAL8ayswwE
# h1T6urRZtqrAgYgPn01Qr7+IkqDd7aCCDYUwggYDMIID66ADAgECAhMzAAADri01
# UchTj1UdAAAAAAOuMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjMxMTE2MTkwODU5WhcNMjQxMTE0MTkwODU5WjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQD0IPymNjfDEKg+YyE6SjDvJwKW1+pieqTjAY0CnOHZ1Nj5irGjNZPMlQ4HfxXG
# yAVCZcEWE4x2sZgam872R1s0+TAelOtbqFmoW4suJHAYoTHhkznNVKpscm5fZ899
# QnReZv5WtWwbD8HAFXbPPStW2JKCqPcZ54Y6wbuWV9bKtKPImqbkMcTejTgEAj82
# 6GQc6/Th66Koka8cUIvz59e/IP04DGrh9wkq2jIFvQ8EDegw1B4KyJTIs76+hmpV
# M5SwBZjRs3liOQrierkNVo11WuujB3kBf2CbPoP9MlOyyezqkMIbTRj4OHeKlamd
# WaSFhwHLJRIQpfc8sLwOSIBBAgMBAAGjggGCMIIBfjAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQUhx/vdKmXhwc4WiWXbsf0I53h8T8w
# VAYDVR0RBE0wS6RJMEcxLTArBgNVBAsTJE1pY3Jvc29mdCBJcmVsYW5kIE9wZXJh
# dGlvbnMgTGltaXRlZDEWMBQGA1UEBRMNMjMwMDEyKzUwMTgzNjAfBgNVHSMEGDAW
# gBRIbmTlUAXTgqoXNzcitW2oynUClTBUBgNVHR8ETTBLMEmgR6BFhkNodHRwOi8v
# d3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NybC9NaWNDb2RTaWdQQ0EyMDExXzIw
# MTEtMDctMDguY3JsMGEGCCsGAQUFBwEBBFUwUzBRBggrBgEFBQcwAoZFaHR0cDov
# L3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jZXJ0cy9NaWNDb2RTaWdQQ0EyMDEx
# XzIwMTEtMDctMDguY3J0MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQADggIB
# AGrJYDUS7s8o0yNprGXRXuAnRcHKxSjFmW4wclcUTYsQZkhnbMwthWM6cAYb/h2W
# 5GNKtlmj/y/CThe3y/o0EH2h+jwfU/9eJ0fK1ZO/2WD0xi777qU+a7l8KjMPdwjY
# 0tk9bYEGEZfYPRHy1AGPQVuZlG4i5ymJDsMrcIcqV8pxzsw/yk/O4y/nlOjHz4oV
# APU0br5t9tgD8E08GSDi3I6H57Ftod9w26h0MlQiOr10Xqhr5iPLS7SlQwj8HW37
# ybqsmjQpKhmWul6xiXSNGGm36GarHy4Q1egYlxhlUnk3ZKSr3QtWIo1GGL03hT57
# xzjL25fKiZQX/q+II8nuG5M0Qmjvl6Egltr4hZ3e3FQRzRHfLoNPq3ELpxbWdH8t
# Nuj0j/x9Crnfwbki8n57mJKI5JVWRWTSLmbTcDDLkTZlJLg9V1BIJwXGY3i2kR9i
# 5HsADL8YlW0gMWVSlKB1eiSlK6LmFi0rVH16dde+j5T/EaQtFz6qngN7d1lvO7uk
# 6rtX+MLKG4LDRsQgBTi6sIYiKntMjoYFHMPvI/OMUip5ljtLitVbkFGfagSqmbxK
# 7rJMhC8wiTzHanBg1Rrbff1niBbnFbbV4UDmYumjs1FIpFCazk6AADXxoKCo5TsO
# zSHqr9gHgGYQC2hMyX9MGLIpowYCURx3L7kUiGbOiMwaMIIHejCCBWKgAwIBAgIK
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
# cVZOSEXAQsmbdlsKgEhr/Xmfwb1tbWrJUnMTDXpQzTGCGaIwghmeAgEBMIGVMH4x
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01p
# Y3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTECEzMAAAOuLTVRyFOPVR0AAAAA
# A64wDQYJYIZIAWUDBAIBBQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIEPV
# i+gKO9X94A6QdoQPw1+2p5Eqs6i6+aYw7pncJAU/MEIGCisGAQQBgjcCAQwxNDAy
# oBSAEgBNAGkAYwByAG8AcwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20wDQYJKoZIhvcNAQEBBQAEggEAyT8V3RK8NXWt4UIIumaFNTRbiYiSYBl2OG5O
# Dw0PT1cdnz1iTkjGOCWx1k342uMF1HMsS77ncP5mveoFTy9Vxjiy2PkbdiVZPK5s
# V/RTNu7kP8ONEmpks/fo+l/uHN2m3eP9hETqhm3cZ6dvpYWjA5ksUdelNqgDwtM2
# 6xgNG1pseEk4A/D7ryjWOW1d7BciIcmmTO0QDSNWf3c67VV/TowSZgIPLfao/JJG
# AQXh7mEKwBQHB534HwwVjP1gYna5gIPTg1jkt8JzJK1hozphAMGo3GInhwWAySxI
# +OaUzaPIqLNEeHL48yETO1S/DH0+3kE6MULJIOcDb4tsYcBtJ6GCFywwghcoBgor
# BgEEAYI3AwMBMYIXGDCCFxQGCSqGSIb3DQEHAqCCFwUwghcBAgEDMQ8wDQYJYIZI
# AWUDBAIBBQAwggFZBgsqhkiG9w0BCRABBKCCAUgEggFEMIIBQAIBAQYKKwYBBAGE
# WQoDATAxMA0GCWCGSAFlAwQCAQUABCDEBuK32vXe71hT72gVvaBO06A3xh+ptuD4
# RfI5pw4uygIGZh/GsphRGBMyMDI0MDQyMzEzMTUxNC4xNzlaMASAAgH0oIHYpIHV
# MIHSMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQL
# EyRNaWNyb3NvZnQgSXJlbGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJjAkBgNVBAsT
# HVRoYWxlcyBUU1MgRVNOOjhENDEtNEJGNy1CM0I3MSUwIwYDVQQDExxNaWNyb3Nv
# ZnQgVGltZS1TdGFtcCBTZXJ2aWNloIIRezCCBycwggUPoAMCAQICEzMAAAHj372b
# mhxogyIAAQAAAeMwDQYJKoZIhvcNAQELBQAwfDELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAg
# UENBIDIwMTAwHhcNMjMxMDEyMTkwNzI5WhcNMjUwMTEwMTkwNzI5WjCB0jELMAkG
# A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
# HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEtMCsGA1UECxMkTWljcm9z
# b2Z0IElyZWxhbmQgT3BlcmF0aW9ucyBMaW1pdGVkMSYwJAYDVQQLEx1UaGFsZXMg
# VFNTIEVTTjo4RDQxLTRCRjctQjNCNzElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUt
# U3RhbXAgU2VydmljZTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAL6k
# DWgeRp+fxSBUD6N/yuEJpXggzBeNG5KB8M9AbIWeEokJgOghlMg8JmqkNsB4Wl1N
# EXR7cL6vlPCsWGLMhyqmscQu36/8h2bx6TU4M8dVZEd6V4U+l9gpte+VF91kOI35
# fOqJ6eQDMwSBQ5c9ElPFUijTA7zV7Y5PRYrS4FL9p494TidCpBEH5N6AO5u8wNA/
# jKO94Zkfjgu7sLF8SUdrc1GRNEk2F91L3pxR+32FsuQTZi8hqtrFpEORxbySgiQB
# P3cH7fPleN1NynhMRf6T7XC1L0PRyKy9MZ6TBWru2HeWivkxIue1nLQb/O/n0j2Q
# Vd42Zf0ArXB/Vq54gQ8JIvUH0cbvyWM8PomhFi6q2F7he43jhrxyvn1Xi1pwHOVs
# bH26YxDKTWxl20hfQLdzz4RVTo8cFRMdQCxlKkSnocPWqfV/4H5APSPXk0r8Cc/c
# Mmva3g4EvupF4ErbSO0UNnCRv7UDxlSGiwiGkmny53mqtAZ7NLePhFtwfxp6ATIo
# jl8JXjr3+bnQWUCDCd5Oap54fGeGYU8KxOohmz604BgT14e3sRWABpW+oXYSCyFQ
# 3SZQ3/LNTVby9ENsuEh2UIQKWU7lv7chrBrHCDw0jM+WwOjYUS7YxMAhaSyOahpb
# udALvRUXpQhELFoO6tOx/66hzqgjSTOEY3pu46BFAgMBAAGjggFJMIIBRTAdBgNV
# HQ4EFgQUsa4NZr41FbehZ8Y+ep2m2YiYqQMwHwYDVR0jBBgwFoAUn6cVXQBeYl2D
# 9OXSZacbUzUZ6XIwXwYDVR0fBFgwVjBUoFKgUIZOaHR0cDovL3d3dy5taWNyb3Nv
# ZnQuY29tL3BraW9wcy9jcmwvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUy
# MDIwMTAoMSkuY3JsMGwGCCsGAQUFBwEBBGAwXjBcBggrBgEFBQcwAoZQaHR0cDov
# L3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jZXJ0cy9NaWNyb3NvZnQlMjBUaW1l
# LVN0YW1wJTIwUENBJTIwMjAxMCgxKS5jcnQwDAYDVR0TAQH/BAIwADAWBgNVHSUB
# Af8EDDAKBggrBgEFBQcDCDAOBgNVHQ8BAf8EBAMCB4AwDQYJKoZIhvcNAQELBQAD
# ggIBALe+my6p1NPMEW1t70a8Y2hGxj6siDSulGAs4UxmkfzxMAic4j0+GTPbHxk1
# 93mQ0FRPa9dtbRbaezV0GLkEsUWTGF2tP6WsDdl5/lD4wUQ76ArFOencCpK5svE0
# sO0FyhrJHZxMLCOclvd6vAIPOkZAYihBH/RXcxzbiliOCr//3w7REnsLuOp/7vlX
# JAsGzmJesBP/0ERqxjKudPWuBGz/qdRlJtOl5nv9NZkyLig4D5hy9p2Ec1zaotiL
# iHnJ9mlsJEcUDhYj8PnYnJjjsCxv+yJzao2aUHiIQzMbFq+M08c8uBEf+s37YbZQ
# 7XAFxwe2EVJAUwpWjmtJ3b3zSWTMmFWunFr2aLk6vVeS0u1MyEfEv+0bDk+N3jms
# CwbLkM9FaDi7q2HtUn3z6k7AnETc28dAvLf/ioqUrVYTwBrbRH4XVFEvaIQ+i7es
# DQicWW1dCDA/J3xOoCECV68611jriajfdVg8o0Wp+FCg5CAUtslgOFuiYULgcxnq
# zkmP2i58ZEa0rm4LZymHBzsIMU0yMmuVmAkYxbdEDi5XqlZIupPpqmD6/fLjD4ub
# 0SEEttOpg0np0ra/MNCfv/tVhJtz5wgiEIKX+s4akawLfY+16xDB64Nm0HoGs/Gy
# 823ulIm4GyrUcpNZxnXvE6OZMjI/V1AgSAg8U/heMWuZTWVUMIIHcTCCBVmgAwIB
# AgITMwAAABXF52ueAptJmQAAAAAAFTANBgkqhkiG9w0BAQsFADCBiDELMAkGA1UE
# BhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc
# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0
# IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5IDIwMTAwHhcNMjEwOTMwMTgyMjI1
# WhcNMzAwOTMwMTgzMjI1WjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
# Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBv
# cmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDCC
# AiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAOThpkzntHIhC3miy9ckeb0O
# 1YLT/e6cBwfSqWxOdcjKNVf2AX9sSuDivbk+F2Az/1xPx2b3lVNxWuJ+Slr+uDZn
# hUYjDLWNE893MsAQGOhgfWpSg0S3po5GawcU88V29YZQ3MFEyHFcUTE3oAo4bo3t
# 1w/YJlN8OWECesSq/XJprx2rrPY2vjUmZNqYO7oaezOtgFt+jBAcnVL+tuhiJdxq
# D89d9P6OU8/W7IVWTe/dvI2k45GPsjksUZzpcGkNyjYtcI4xyDUoveO0hyTD4MmP
# frVUj9z6BVWYbWg7mka97aSueik3rMvrg0XnRm7KMtXAhjBcTyziYrLNueKNiOSW
# rAFKu75xqRdbZ2De+JKRHh09/SDPc31BmkZ1zcRfNN0Sidb9pSB9fvzZnkXftnIv
# 231fgLrbqn427DZM9ituqBJR6L8FA6PRc6ZNN3SUHDSCD/AQ8rdHGO2n6Jl8P0zb
# r17C89XYcz1DTsEzOUyOArxCaC4Q6oRRRuLRvWoYWmEBc8pnol7XKHYC4jMYcten
# IPDC+hIK12NvDMk2ZItboKaDIV1fMHSRlJTYuVD5C4lh8zYGNRiER9vcG9H9stQc
# xWv2XFJRXRLbJbqvUAV6bMURHXLvjflSxIUXk8A8FdsaN8cIFRg/eKtFtvUeh17a
# j54WcmnGrnu3tz5q4i6tAgMBAAGjggHdMIIB2TASBgkrBgEEAYI3FQEEBQIDAQAB
# MCMGCSsGAQQBgjcVAgQWBBQqp1L+ZMSavoKRPEY1Kc8Q/y8E7jAdBgNVHQ4EFgQU
# n6cVXQBeYl2D9OXSZacbUzUZ6XIwXAYDVR0gBFUwUzBRBgwrBgEEAYI3TIN9AQEw
# QTA/BggrBgEFBQcCARYzaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9E
# b2NzL1JlcG9zaXRvcnkuaHRtMBMGA1UdJQQMMAoGCCsGAQUFBwMIMBkGCSsGAQQB
# gjcUAgQMHgoAUwB1AGIAQwBBMAsGA1UdDwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/
# MB8GA1UdIwQYMBaAFNX2VsuP6KJcYmjRPZSQW9fOmhjEMFYGA1UdHwRPME0wS6BJ
# oEeGRWh0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01p
# Y1Jvb0NlckF1dF8yMDEwLTA2LTIzLmNybDBaBggrBgEFBQcBAQROMEwwSgYIKwYB
# BQUHMAKGPmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2kvY2VydHMvTWljUm9v
# Q2VyQXV0XzIwMTAtMDYtMjMuY3J0MA0GCSqGSIb3DQEBCwUAA4ICAQCdVX38Kq3h
# LB9nATEkW+Geckv8qW/qXBS2Pk5HZHixBpOXPTEztTnXwnE2P9pkbHzQdTltuw8x
# 5MKP+2zRoZQYIu7pZmc6U03dmLq2HnjYNi6cqYJWAAOwBb6J6Gngugnue99qb74p
# y27YP0h1AdkY3m2CDPVtI1TkeFN1JFe53Z/zjj3G82jfZfakVqr3lbYoVSfQJL1A
# oL8ZthISEV09J+BAljis9/kpicO8F7BUhUKz/AyeixmJ5/ALaoHCgRlCGVJ1ijbC
# HcNhcy4sa3tuPywJeBTpkbKpW99Jo3QMvOyRgNI95ko+ZjtPu4b6MhrZlvSP9pEB
# 9s7GdP32THJvEKt1MMU0sHrYUP4KWN1APMdUbZ1jdEgssU5HLcEUBHG/ZPkkvnNt
# yo4JvbMBV0lUZNlz138eW0QBjloZkWsNn6Qo3GcZKCS6OEuabvshVGtqRRFHqfG3
# rsjoiV5PndLQTHa1V1QJsWkBRH58oWFsc/4Ku+xBZj1p/cvBQUl+fpO+y/g75LcV
# v7TOPqUxUYS8vwLBgqJ7Fx0ViY1w/ue10CgaiQuPNtq6TPmb/wrpNPgkNWcr4A24
# 5oyZ1uEi6vAnQj0llOZ0dFtq0Z4+7X6gMTN9vMvpe784cETRkPHIqzqKOghif9lw
# Y1NNje6CbaUFEMFxBmoQtB1VM1izoXBm8qGCAtcwggJAAgEBMIIBAKGB2KSB1TCB
# 0jELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1Jl
# ZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEtMCsGA1UECxMk
# TWljcm9zb2Z0IElyZWxhbmQgT3BlcmF0aW9ucyBMaW1pdGVkMSYwJAYDVQQLEx1U
# aGFsZXMgVFNTIEVTTjo4RDQxLTRCRjctQjNCNzElMCMGA1UEAxMcTWljcm9zb2Z0
# IFRpbWUtU3RhbXAgU2VydmljZaIjCgEBMAcGBSsOAwIaAxUAPYiXu8ORQ4hvKcuE
# 7GK0COgxWnqggYMwgYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
# Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBv
# cmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAN
# BgkqhkiG9w0BAQUFAAIFAOnSLW4wIhgPMjAyNDA0MjMyMDUxNThaGA8yMDI0MDQy
# NDIwNTE1OFowdzA9BgorBgEEAYRZCgQBMS8wLTAKAgUA6dItbgIBADAKAgEAAgIC
# 3QIB/zAHAgEAAgIklzAKAgUA6dN+7gIBADA2BgorBgEEAYRZCgQCMSgwJjAMBgor
# BgEEAYRZCgMCoAowCAIBAAIDB6EgoQowCAIBAAIDAYagMA0GCSqGSIb3DQEBBQUA
# A4GBAL5g/H2OsBvN7sRsWQpifcZ3xYuCaQCapfehI/sIyCMsEeFt/2Io5kSBiNhw
# ofo99Xxk/KCzCACcFbyA216UwvxZQbZWgBcarXLP7Rn9Q+U10U19mENvKVuFTzZt
# 3+19K/W7+QQ4Y0MOWaYZuM2O+a3lHbrYuq3jAheJ+WJ8OBwrMYIEDTCCBAkCAQEw
# gZMwfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcT
# B1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UE
# AxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTACEzMAAAHj372bmhxogyIA
# AQAAAeMwDQYJYIZIAWUDBAIBBQCgggFKMBoGCSqGSIb3DQEJAzENBgsqhkiG9w0B
# CRABBDAvBgkqhkiG9w0BCQQxIgQg67xuOqgc182305aNbabdC/qI9FryIm8ZODMP
# Qv18iYgwgfoGCyqGSIb3DQEJEAIvMYHqMIHnMIHkMIG9BCAz1COr5bD+ZPdEgQjW
# vcIWuDJcQbdgq8Ndj0xyMuYmKjCBmDCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFBDQSAyMDEwAhMzAAAB49+9m5ocaIMiAAEAAAHjMCIEIAjbaHNr0MEVS4sdIKFz
# DEisoKgKMPqA12+DiwHa14RcMA0GCSqGSIb3DQEBCwUABIICABL3xzDbG7k+ymf5
# 1JUzac8mDHZGJnTPQWNwzuY3xwoTrYtDgDljntz5aguUoRIRchMAeufIyONHjwrR
# VFifHmeh5ciDrQEPQUKzOw2BkeQlMd4BgKdUCwP3Kbgl9CDIkoSWqCydl8nCTMGV
# ki9QhIGuv3Jnr5wQDrjVMpLEx9vWOWQ1RJeaTlpcd7IIQ+0c5ws5wPqAicivqDiq
# QM1mARjt3LmatrTyscdX6ipzD+up3ROVUAsg7nosOLs93VRFKnGm+Oqjte2z03XC
# nXz7ANpcMb40JQyeEBv/bcBeYLbYdYpzOxL3MB/TIlm6hxjOLdSc5Br0GNXljCeO
# nhxHEDwp4ptirEdR+NdfRjfNNPEA0de4b7cJn7ySDIPvIjoVcnHkBPo2LST9TN8V
# gdUwRqHmkLOG0W99pDorI7UKD/+OYjC7eSZ8NxHW9YhTMczuP+9IGAMIWxBZ3hGy
# 4WMPrmUZJr93XPuyXA9SVJiDytsf+tAlGAZldyfcvinJqrkFqFO6lQ98Xh42KaEw
# rA++kCq86gWrWHO4ek2depVocdUtRU9f3GepwUDXBT+VdaU9YyqkYyTdNlmYaGdv
# +HemKj2ET0q3jyxEb2Sr4lxZFjMl4Xxc/ls20w6wHMzrWh14xLVY2V0IX1+pBgxT
# 4pbUoXFiutN0x7+0S59RkpUpf/IR
# SIG # End signature block
