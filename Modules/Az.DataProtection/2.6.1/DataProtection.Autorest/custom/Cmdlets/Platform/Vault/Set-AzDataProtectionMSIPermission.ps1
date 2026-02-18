function Get-VaultIdentity {
    
    [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.DoNotExportAttribute()]
    param (
        [Parameter(Mandatory=$true)]
        [System.Object] $vault,

        [Parameter(Mandatory=$false)]
        [System.String] $UserAssignedIdentityARMId
    )

    #Determine the vault MSI to be used
    $vaultIdentity = $null
    if ($UserAssignedIdentityARMId) {        
        $vaultIdentity = $vault.Identity.UserAssignedIdentity[$UserAssignedIdentityARMId].PrincipalID
        Write-Host "Using Vault UAMI with ARMId: $UserAssignedIdentityARMId with Principal ID: $vaultIdentity"
    } else {
        $vaultIdentity = $vault.Identity.PrincipalId
        Write-Host "Using system-assigned identity with Principal ID: $vaultIdentity"
    }

    if (-not $vaultIdentity) {
        throw "Vault identity could not be determined. Please check the UserAssignedIdentityARMId or the vault configuration."
    }

    return $vaultIdentity
}

function Set-AzDataProtectionMSIPermission {
    [OutputType('System.Object')]
    [CmdletBinding(PositionalBinding=$false, SupportsShouldProcess, ConfirmImpact = 'High')]
    [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Description('Grants required permissions to the backup vault and other resources for configure backup and restore scenarios')]

    param(
        [Parameter(ParameterSetName="SetPermissionsForBackup", Mandatory, HelpMessage='Backup instance request object which will be used to configure backup')]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20240401.IBackupInstanceResource]
        ${BackupInstance},
        
        [Parameter(ParameterSetName="SetPermissionsForBackup", Mandatory=$false, HelpMessage='ID of the keyvault')]
        [ValidatePattern("/subscriptions/([A-z0-9\-]+)/resourceGroups/(?<rg>.+)/(?<id>.+)")]
        [System.String]
        ${KeyVaultId},

        [Parameter(ParameterSetName="SetPermissionsForRestore", Mandatory=$false, HelpMessage='Subscription Id of the backup vault')]
        [System.String]
        ${SubscriptionId},

        [Parameter(Mandatory, HelpMessage='Resource group of the backup vault')]
        [Alias('ResourceGroupName')]
        [System.String]
        ${VaultResourceGroup},
        
        [Parameter(Mandatory, HelpMessage='Name of the backup vault')]
        [System.String]
        ${VaultName},

        [Parameter(Mandatory, HelpMessage='Scope at which the permissions need to be granted')]
        [System.String]
        [ValidateSet("Resource","ResourceGroup","Subscription")]
        ${PermissionsScope},

        [Parameter(ParameterSetName="SetPermissionsForRestore", Mandatory=$false, HelpMessage='Datasource Type')]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Support.DatasourceTypes]
        ${DatasourceType},

        [Parameter(ParameterSetName="SetPermissionsForRestore", Mandatory, HelpMessage='Restore request object which will be used for restore')]
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api20240401.IAzureBackupRestoreRequest]
        ${RestoreRequest},

        [Parameter(ParameterSetName="SetPermissionsForRestore", Mandatory=$false, HelpMessage='Sanpshot Resource Group')]
        [System.String]
        [ValidatePattern("/subscriptions/([A-z0-9\-]+)/resourceGroups/(?<rg>.+)")]
        ${SnapshotResourceGroupId},

        [Parameter(ParameterSetName="SetPermissionsForRestore", Mandatory=$false, HelpMessage='Target storage account ARM Id. Use this parameter for DatasourceType AzureDatabaseForMySQL, AzureDatabaseForPGFlexServer.')]
        [System.String]
        ${StorageAccountARMId},

        [Parameter(Mandatory=$false, HelpMessage='User Assigned Identity ARM ID of the backup vault to be used for assigning permissions')]
        [Alias('AssignUserIdentity')]
        [System.String]
        ${UserAssignedIdentityARMId}
    )

    process {
          CheckResourcesModuleDependency
          
          $OriginalWarningPreference = $WarningPreference
          $WarningPreference = 'SilentlyContinue'
          
          $MissingRolesInitially = $false

          if($PsCmdlet.ParameterSetName -eq "SetPermissionsForRestore"){
                            
              $DatasourceId = $RestoreRequest.RestoreTargetInfo.DatasourceInfo.ResourceId

              $DatasourceTypeInternal = ""
              $subscriptionIdInternal = ""
              if($DataSourceId -ne $null){
                  $DatasourceTypeInternal =  GetClientDatasourceType -ServiceDatasourceType $RestoreRequest.RestoreTargetInfo.DatasourceInfo.Type
                  
                  $ResourceArray = $DataSourceId.Split("/")
                  $ResourceRG = GetResourceGroupIdFromArmId -Id $DataSourceId
                  $SubscriptionName = GetSubscriptionNameFromArmId -Id $DataSourceId
                  $subscriptionIdInternal = $ResourceArray[2]

                  if($DatasourceType -ne $null -and $DatasourceTypeInternal -ne $DatasourceType){
                      throw "DatasourceType is not compatible with the RestoreRequest"
                  }
              }
              elseif($DatasourceType -ne $null){
                  $DatasourceTypeInternal = $DatasourceType

                  if($SubscriptionId -eq ""){
                      
                      $err = "SubscriptionId can't be identified. Please provide the value for parameter SubscriptionId"
                      throw $err
                  }
                  else{
                      $subscriptionIdInternal = $SubscriptionId
                  }
              }
              else{
                  $err = "DatasourceType can't be identified since DataSourceInfo is null. Please provide the value for parameter DatasourceType"
                  throw $err
              }

              $manifest = LoadManifest -DatasourceType $DatasourceTypeInternal.ToString()              
              
              $vault = Az.DataProtection\Get-AzDataProtectionBackupVault -VaultName $VaultName -ResourceGroupName $VaultResourceGroup -SubscriptionId $subscriptionIdInternal
              $vaultIdentity = Get-VaultIdentity -vault $vault -UserAssignedIdentityARMId $UserAssignedIdentityARMId
                            
              if(-not $manifest.supportRestoreGrantPermission){
                  $err = "Set permissions for restore is currently not supported for given DataSourceType"
                  throw $err
              }
                            
              if(($manifest.dataSourceOverSnapshotRGPermissions.Length -gt 0 -or $manifest.snapshotRGPermissions.Length -gt 0) -and $SnapshotResourceGroupId -eq ""){
                  $warning = "SnapshotResourceGroupId parameter is required to assign permissions over snapshot resource group, skipping"
                  Write-Warning $warning
              }
              else{
                  foreach($Permission in $manifest.dataSourceOverSnapshotRGPermissions)
                  {
                      if($DatasourceTypeInternal -eq "AzureKubernetesService"){
                          CheckAksModuleDependency
                                    
                          $aksCluster = Get-AzAksCluster -Id $RestoreRequest.RestoreTargetInfo.DataSourceInfo.ResourceId -SubscriptionId $subscriptionIdInternal

                          $dataSourceMSI = ""
                          if($aksCluster.Identity.Type -match "UserAssigned"){
                              $UAMIKey = $aksCluster.Identity.UserAssignedIdentities.Keys[0]

                              if($UAMIKey -eq "" -or $UAMIKey -eq $null){
                                  Write-Error "User assigned identity not found for AKS cluster."
                              }
                              $dataSourceMSI = $aksCluster.Identity.UserAssignedIdentities[$UAMIKey].PrincipalId
                          }
                          else{
                              $dataSourceMSI = $aksCluster.Identity.PrincipalId
                          }

                          $dataSourceMSIRoles = Az.Resources\Get-AzRoleAssignment -ObjectId $dataSourceMSI
                      }

                      # CSR: $SubscriptionName might be different when we add cross subscription restore
                      $CheckPermission = $dataSourceMSIRoles | Where-Object { ($_.Scope -eq $SnapshotResourceGroupId -or $_.Scope -eq $SubscriptionName)  -and $_.RoleDefinitionName -eq $Permission}

                      if($CheckPermission -ne $null)
                      {
                          Write-Host "Required permission $($Permission) is already assigned to target resource with Id $($RestoreRequest.RestoreTargetInfo.DataSourceInfo.ResourceId) over snapshot resource group with Id $($SnapshotResourceGroupId)"
                      }
                      else
                      {
                          # can add snapshot resource group name in allow statement
                          if ($PSCmdlet.ShouldProcess("$($RestoreRequest.RestoreTargetInfo.DataSourceInfo.ResourceId)","Allow $($Permission) permission over snapshot resource group"))
                          {
                              $MissingRolesInitially = $true
                              
                              AssignMissingRoles -ObjectId $dataSourceMSI -Permission $Permission -PermissionsScope $PermissionsScope -Resource $SnapshotResourceGroupId -ResourceGroup $SnapshotResourceGroupId -Subscription $SubscriptionName
  
                              Write-Host "Assigned $($Permission) permission to target resource with Id $($RestoreRequest.RestoreTargetInfo.DataSourceInfo.ResourceId) over snapshot resource group with Id $($SnapshotResourceGroupId)"
                          }
                      }
                  }

                  foreach($Permission in $manifest.snapshotRGPermissions)
                  {
                      $AllRoles = Az.Resources\Get-AzRoleAssignment -ObjectId $vaultIdentity

                      # CSR: $SubscriptionName might be different when we add cross subscription restore
                      $CheckPermission = $AllRoles | Where-Object { ($_.Scope -eq $SnapshotResourceGroupId -or $_.Scope -eq $SubscriptionName) -and $_.RoleDefinitionName -eq $Permission}

                      if($CheckPermission -ne $null)
                      {
                          Write-Host "Required permission $($Permission) is already assigned to backup vault over snapshot resource group with Id $($SnapshotResourceGroupId)"
                      }

                      else
                      {
                          $MissingRolesInitially = $true

                          AssignMissingRoles -ObjectId $vaultIdentity -Permission $Permission -PermissionsScope $PermissionsScope -Resource $SnapshotResourceGroupId -ResourceGroup $SnapshotResourceGroupId -Subscription $SubscriptionName
  
                          Write-Host "Assigned $($Permission) permission to the backup vault over snapshot resource group with Id $($SnapshotResourceGroupId)"
                      }
                  }
              }

              foreach($Permission in $manifest.datasourcePermissionsForRestore)
              {
                  # set context to the subscription where ObjectId is present
                  $AllRoles = Az.Resources\Get-AzRoleAssignment -ObjectId $vaultIdentity

                  $CheckPermission = $AllRoles | Where-Object { ($_.Scope -eq $DataSourceId -or $_.Scope -eq $ResourceRG -or  $_.Scope -eq $SubscriptionName) -and $_.RoleDefinitionName -eq $Permission}

                  if($CheckPermission -ne $null)
                  {   
                      Write-Host "Required permission $($Permission) is already assigned to backup vault over DataSource with Id $($DataSourceId)"
                  }

                  else
                  {
                      $MissingRolesInitially = $true
                   
                      AssignMissingRoles -ObjectId $vaultIdentity -Permission $Permission -PermissionsScope $PermissionsScope -Resource $DataSourceId -ResourceGroup $ResourceRG -Subscription $SubscriptionName

                      Write-Host "Assigned $($Permission) permission to the backup vault over DataSource with Id $($DataSourceId)"
                  }
              }

              foreach($Permission in $manifest.storageAccountPermissionsForRestore)
              {
                  # set context to the subscription where ObjectId is present
                  $AllRoles = Az.Resources\Get-AzRoleAssignment -ObjectId $vaultIdentity

                  $targetResourceArmId = $restoreRequest.RestoreTargetInfo.TargetDetail.TargetResourceArmId

                  if($targetResourceArmId -ne $null -and $targetResourceArmId -ne ""){
                      if(-not $targetResourceArmId.Contains("/blobServices/")){
                          $err = "restoreRequest.RestoreTargetInfo.TargetDetail.TargetResourceArmId is not in the correct format"
                          throw $err
                      }

                      $storageAccId = ($targetResourceArmId -split "/blobServices/")[0]
                      $storageAccResourceGroupId = ($targetResourceArmId -split "/providers/")[0]
                      $storageAccountSubId = ($targetResourceArmId -split "/resourceGroups/")[0]
                  }
                  else{
                      if($StorageAccountARMId -eq ""){
                          $err = "Permissions can't be assigned to target storage account. Please input parameter StorageAccountARMId"
                          throw $err
                      }

                      # storage Account subscription and resource group
                      $storageAccountSubId = ($StorageAccountARMId -split "/resourceGroups/")[0]
                      $storageAccResourceGroupId = ($StorageAccountARMId -split "/providers/")[0]

                      # storage Account ID
                      $storageAccId = $StorageAccountARMId                      
                  }
                                    
                  $CheckPermission = $AllRoles | Where-Object { ($_.Scope -eq $storageAccId -or $_.Scope -eq $storageAccResourceGroupId -or  $_.Scope -eq $storageAccountSubId) -and $_.RoleDefinitionName -eq $Permission}

                  if($CheckPermission -ne $null)
                  {   
                      Write-Host "Required permission $($Permission) is already assigned to backup vault over storage account with Id $($storageAccId)"
                  }

                  else
                  {
                      $MissingRolesInitially = $true
                   
                      AssignMissingRoles -ObjectId $vaultIdentity -Permission $Permission -PermissionsScope $PermissionsScope -Resource $storageAccId -ResourceGroup $storageAccResourceGroupId -Subscription $storageAccountSubId

                      Write-Host "Assigned $($Permission) permission to the backup vault over  storage account with Id $($storageAccId)"
                  }
              }
          }

          elseif($PsCmdlet.ParameterSetName -eq "SetPermissionsForBackup"){
              $DatasourceId = $BackupInstance.Property.DataSourceInfo.ResourceId
              $DatasourceType =  GetClientDatasourceType -ServiceDatasourceType $BackupInstance.Property.DataSourceInfo.Type 
              $manifest = LoadManifest -DatasourceType $DatasourceType.ToString()

              $ResourceArray = $DataSourceId.Split("/")
              $ResourceRG = GetResourceGroupIdFromArmId -Id $DataSourceId
              $SubscriptionName = GetSubscriptionNameFromArmId -Id $DataSourceId
              $subscriptionId = $ResourceArray[2]

              $vault = Az.DataProtection\Get-AzDataProtectionBackupVault -VaultName $VaultName -ResourceGroupName $VaultResourceGroup -SubscriptionId $ResourceArray[2]
              $vaultIdentity = Get-VaultIdentity -vault $vault -UserAssignedIdentityARMId $UserAssignedIdentityARMId
              
              $AllRoles = Az.Resources\Get-AzRoleAssignment -ObjectId $vaultIdentity

              # If more DataSourceTypes support this then we can make it manifest driven
              if($DatasourceType -eq "AzureDatabaseForPostgreSQL")
              {
                  CheckPostgreSqlModuleDependency
                  CheckKeyVaultModuleDependency

                  if($KeyVaultId -eq "" -or $KeyVaultId -eq $null)
                  {
                      Write-Error "KeyVaultId not provided. Please provide the KeyVaultId parameter to successfully assign the permissions on the keyvault"
                  }

                  $KeyvaultName = GetResourceNameFromArmId -Id $KeyVaultId
                  $KeyvaultRGName = GetResourceGroupNameFromArmId -Id $KeyVaultId
                  $ServerName = GetResourceNameFromArmId -Id $DataSourceId
                  $ServerRG = GetResourceGroupNameFromArmId -Id $DataSourceId
                
                  $KeyvaultArray = $KeyVaultId.Split("/")
                  $KeyvaultRG = GetResourceGroupIdFromArmId -Id $KeyVaultId
                  $KeyvaultSubscriptionName = GetSubscriptionNameFromArmId -Id $KeyVaultId

                  if ($PSCmdlet.ShouldProcess("KeyVault: $($KeyvaultName) and PostgreSQLServer: $($ServerName)","
                              1.'Allow All Azure services' under network connectivity in the Postgres Server
                              2.'Allow Trusted Azure services' under network connectivity in the Key vault")) 
                  {                    
                      Update-AzPostgreSqlServer -ResourceGroupName $ServerRG -ServerName $ServerName -PublicNetworkAccess Enabled| Out-Null
                      New-AzPostgreSqlFirewallRule -Name AllowAllAzureIps -ResourceGroupName $ServerRG -ServerName $ServerName -EndIPAddress 0.0.0.0 -StartIPAddress 0.0.0.0 | Out-Null
                     
                      $SecretsList = ""
                      try{$SecretsList =  Get-AzKeyVaultSecret -VaultName $KeyvaultName}
                      catch{
                          $err = $_
                          throw $err
                      }
              
                      $SecretValid = $false
                      $GivenSecretUri = $BackupInstance.Property.DatasourceAuthCredentials.SecretStoreResource.Uri
              
                      foreach($Secret in $SecretsList)
                      {
                          $SecretArray = $Secret.Id.Split("/")
                          $SecretArray[2] = $SecretArray[2] -replace "....$"
                          $SecretUri = $SecretArray[0] + "/" + $SecretArray[1] + "/"+  $SecretArray[2] + "/" +  $SecretArray[3] + "/" + $SecretArray[4] 
                              
                          if($Secret.Enabled -eq "true" -and $SecretUri -eq $GivenSecretUri)
                          {
                              $SecretValid = $true
                          }
                      }

                      if($SecretValid -eq $false)
                      {
                          $err = "The Secret URI provided in the backup instance is not associated with the keyvault Id provided. Please provide a valid combination of Secret URI and keyvault Id"
                          throw $err
                      }

                      if($KeyVault.PublicNetworkAccess -eq "Disabled")
                      {
                          $err = "Keyvault needs to have public network access enabled"
                          throw $err
                      }
            
                      try{$KeyVault = Get-AzKeyVault -VaultName $KeyvaultName}
                      catch{
                          $err = $_
                          throw $err
                      }    
            
                      try{Update-AzKeyVaultNetworkRuleSet -VaultName $KeyvaultName -Bypass AzureServices -Confirm:$False}
                      catch{
                          $err = $_
                          throw $err
                      }
                  }
              }

              foreach($Permission in $manifest.keyVaultPermissions)
              {
                  if($KeyVault.EnableRbacAuthorization -eq $false )
                  {
                     try{                    
                          $KeyVault = Get-AzKeyVault -VaultName $KeyvaultName 
                          $KeyVaultAccessPolicies = $KeyVault.AccessPolicies

                          $KeyVaultAccessPolicy =  $KeyVaultAccessPolicies | Where-Object {$_.ObjectID -eq $vaultIdentity}

                          if($KeyVaultAccessPolicy -eq $null)
                          {                         
                            Set-AzKeyVaultAccessPolicy -VaultName $KeyvaultName -ObjectId $vaultIdentity -PermissionsToSecrets Get,List -Confirm:$False 
                            break
                          }

                          $KeyvaultAccessPolicyPermissions = $KeyVaultAccessPolicy."PermissionsToSecrets"
                          $KeyvaultAccessPolicyPermissions+="Get"
                          $KeyvaultAccessPolicyPermissions+="List"
                          [String[]]$FinalKeyvaultAccessPolicyPermissions = $KeyvaultAccessPolicyPermissions
                          $FinalKeyvaultAccessPolicyPermissions = $FinalKeyvaultAccessPolicyPermissions | select -uniq                      
                      
                          Set-AzKeyVaultAccessPolicy -VaultName $KeyvaultName -ObjectId $vaultIdentity -PermissionsToSecrets $FinalKeyvaultAccessPolicyPermissions -Confirm:$False 
                     }
                     catch{
                         $err = $_
                         throw $err
                     }
                  }

                  else
                  {
                      $CheckPermission = $AllRoles | Where-Object { ($_.Scope -eq $KeyVaultId -or $_.Scope -eq $KeyvaultRG -or  $_.Scope -eq $KeyvaultSubscription) -and $_.RoleDefinitionName -eq $Permission}

                      if($CheckPermission -ne $null)
                      {
                          Write-Host "Required permission $($Permission) is already assigned to backup vault over KeyVault with Id $($KeyVaultId)"
                      }

                      else
                      {
                          $MissingRolesInitially = $true
                                                    
                          AssignMissingRoles -ObjectId $vaultIdentity -Permission $Permission -PermissionsScope $PermissionsScope -Resource $KeyVaultId -ResourceGroup $KeyvaultRG -Subscription $KeyvaultSubscriptionName

                          Write-Host "Assigned $($Permission) permission to the backup vault over key vault with Id $($KeyVaultId)"
                      }
                  }
              }
              
              foreach($Permission in $manifest.dataSourceOverSnapshotRGPermissions)
              {
                  $SnapshotResourceGroupId = $BackupInstance.Property.PolicyInfo.PolicyParameter.DataStoreParametersList[0].ResourceGroupId              
              
                  if($DatasourceType -eq "AzureKubernetesService"){                  
                      CheckAksModuleDependency
                                    
                      $aksCluster = Get-AzAksCluster -Id $BackupInstance.Property.DataSourceInfo.ResourceId -SubscriptionId $subscriptionId

                      $dataSourceMSI = ""
                      if($aksCluster.Identity.Type -match "UserAssigned"){
                          $UAMIKey = $aksCluster.Identity.UserAssignedIdentities.Keys[0]

                          if($UAMIKey -eq "" -or $UAMIKey -eq $null){
                              Write-Error "User assigned identity not found for AKS cluster."
                          }
                          $dataSourceMSI = $aksCluster.Identity.UserAssignedIdentities[$UAMIKey].PrincipalId
                      }
                      else{
                          $dataSourceMSI = $aksCluster.Identity.PrincipalId
                      }
                      
                      $dataSourceMSIRoles = Az.Resources\Get-AzRoleAssignment -ObjectId $dataSourceMSI
                  }

                  # CSR: $SubscriptionName might be different when we add cross subscription restore
                  $CheckPermission = $dataSourceMSIRoles | Where-Object { ($_.Scope -eq $SnapshotResourceGroupId -or $_.Scope -eq $SubscriptionName) -and $_.RoleDefinitionName -eq $Permission}

                  if($CheckPermission -ne $null)
                  {
                      Write-Host "Required permission $($Permission) is already assigned to DataSource with Id $($BackupInstance.Property.DataSourceInfo.ResourceId) over snapshot resource group with Id $($SnapshotResourceGroupId)"
                  }

                  else
                  {   
                      # can add snapshot resource group name in allow statement
                      if ($PSCmdlet.ShouldProcess("$($BackupInstance.Property.DataSourceInfo.ResourceId)","Allow $($Permission) permission over snapshot resource group"))
                      {
                          $MissingRolesInitially = $true
                          
                          AssignMissingRoles -ObjectId $dataSourceMSI -Permission $Permission -PermissionsScope $PermissionsScope -Resource $SnapshotResourceGroupId -ResourceGroup $SnapshotResourceGroupId -Subscription $SubscriptionName
  
                          Write-Host "Assigned $($Permission) permission to DataSource with Id $($BackupInstance.Property.DataSourceInfo.ResourceId) over snapshot resource group with Id $($SnapshotResourceGroupId)"
                      }                  
                  }
              }

              foreach($Permission in $manifest.snapshotRGPermissions)
              {
                  $SnapshotResourceGroupId = $BackupInstance.Property.PolicyInfo.PolicyParameter.DataStoreParametersList[0].ResourceGroupId
              
                  # CSR: $SubscriptionName might be different when we add cross subscription restore
                  $AllRoles = Az.Resources\Get-AzRoleAssignment -ObjectId $vaultIdentity
                  $CheckPermission = $AllRoles | Where-Object { ($_.Scope -eq $SnapshotResourceGroupId -or $_.Scope -eq $SubscriptionName)  -and $_.RoleDefinitionName -eq $Permission}

                  if($CheckPermission -ne $null)
                  {
                      Write-Host "Required permission $($Permission) is already assigned to backup vault over snapshot resource group with Id $($SnapshotResourceGroupId)"
                  }

                  else
                  {
                      $MissingRolesInitially = $true

                      AssignMissingRoles -ObjectId $vaultIdentity -Permission $Permission -PermissionsScope $PermissionsScope -Resource $SnapshotResourceGroupId -ResourceGroup $SnapshotResourceGroupId -Subscription $SubscriptionName
  
                      Write-Host "Assigned $($Permission) permission to the backup vault over snapshot resource group with Id $($SnapshotResourceGroupId)"
                  }
              }

              foreach($Permission in $manifest.datasourcePermissions)
              {
                  $AllRoles = Az.Resources\Get-AzRoleAssignment -ObjectId $vaultIdentity
                  $CheckPermission = $AllRoles | Where-Object { ($_.Scope -eq $DataSourceId -or $_.Scope -eq $ResourceRG -or  $_.Scope -eq $SubscriptionName) -and $_.RoleDefinitionName -eq $Permission}
              
                  if($CheckPermission -ne $null)
                  {
                      Write-Host "Required permission $($Permission) is already assigned to backup vault over DataSource with Id $($DataSourceId)"
                  }

                  else
                  {
                      $MissingRolesInitially = $true
                                            
                      AssignMissingRoles -ObjectId $vaultIdentity -Permission $Permission -PermissionsScope $PermissionsScope -Resource $DataSourceId -ResourceGroup $ResourceRG -Subscription $SubscriptionName

                      Write-Host "Assigned $($Permission) permission to the backup vault over DataSource with Id $($DataSourceId)"
                  }
              }

              foreach($Permission in $manifest.datasourceRGPermissions)
              {
                  $AllRoles = Az.Resources\Get-AzRoleAssignment -ObjectId $vaultIdentity
                  $CheckPermission = $AllRoles | Where-Object { ($_.Scope -eq $ResourceRG -or  $_.Scope -eq $SubscriptionName) -and $_.RoleDefinitionName -eq $Permission}
              
                  if($CheckPermission -ne $null)
                  {
                      Write-Host "Required permission $($Permission) is already assigned to backup vault over DataSource resource group with name $($ResourceRG)"
                  }

                  else
                  {
                      $MissingRolesInitially = $true
                      
                      # "Resource","ResourceGroup","Subscription"
                      $DatasourceRGScope = $PermissionsScope
                      if($PermissionsScope -eq "Resource"){
                          $DatasourceRGScope = "ResourceGroup"
                      }

                      AssignMissingRoles -ObjectId $vaultIdentity -Permission $Permission -PermissionsScope $DatasourceRGScope -Resource $DataSourceId -ResourceGroup $ResourceRG -Subscription $SubscriptionName

                      Write-Host "Assigned $($Permission) permission to the backup vault over DataSource resource group with name $($ResourceRG)"
                  }
              }
          }

          if($MissingRolesInitially -eq $true)
          {
              Write-Host "Waiting for 60 seconds for roles to propagate"
              Start-Sleep -Seconds 60
          }
          
          $WarningPreference = $OriginalWarningPreference          
    }
}
# SIG # Begin signature block
# MIIoUgYJKoZIhvcNAQcCoIIoQzCCKD8CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBKWiw/Pj+wLsms
# fvyBnB8tVNFbQTZJtQtPOlLpF6FcBaCCDYUwggYDMIID66ADAgECAhMzAAAEA73V
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
# cVZOSEXAQsmbdlsKgEhr/Xmfwb1tbWrJUnMTDXpQzTGCGiMwghofAgEBMIGVMH4x
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01p
# Y3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTECEzMAAAQDvdWVXQ87GK0AAAAA
# BAMwDQYJYIZIAWUDBAIBBQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIHwp
# RKlQQRmi4mzSKS5m1PQ32hCyzFEzB+2EOzkkvsX4MEIGCisGAQQBgjcCAQwxNDAy
# oBSAEgBNAGkAYwByAG8AcwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20wDQYJKoZIhvcNAQEBBQAEggEAOQJOXCFkNRYar1k0o+DAnIuzVZOFYLw+AkGr
# 7On7jc+MZtYslyXH5m5FzweZWzkysmEYRksMc7Rl7DQsfawq0ubukVppedXYnNfY
# /v+RFV7Ha/RxYfCkYG5ZSMkciR8ibYtx2r0ICvdsW83lYYmT8KOTvEGEe7b+KYdA
# ULj+BGYkLzRkzeUq89TqqImatBENQ4KBG2k/Cz+UFf4BXexWcf0ABjbbzF5miI6S
# DP7vxpcD9h0dLiAieSzJQRqcJ0XToIur9Jiukt1lqZzZumiscDHsL08hHAzjEeUd
# anAflQqpMJNEg5tQF9aZiBCbMyqTFaHvY8JfVjUyc4aDBnZ9aaGCF60wghepBgor
# BgEEAYI3AwMBMYIXmTCCF5UGCSqGSIb3DQEHAqCCF4YwgheCAgEDMQ8wDQYJYIZI
# AWUDBAIBBQAwggFaBgsqhkiG9w0BCRABBKCCAUkEggFFMIIBQQIBAQYKKwYBBAGE
# WQoDATAxMA0GCWCGSAFlAwQCAQUABCA0BJlO3g6hS6Ma7fhEeOxp6En8fBjD0WSy
# fGQGBzJUDgIGZ5q2KO0/GBMyMDI1MDIwNjAzMTkwNy4yOTFaMASAAgH0oIHZpIHW
# MIHTMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQL
# EyRNaWNyb3NvZnQgSXJlbGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJzAlBgNVBAsT
# Hm5TaGllbGQgVFNTIEVTTjo2RjFBLTA1RTAtRDk0NzElMCMGA1UEAxMcTWljcm9z
# b2Z0IFRpbWUtU3RhbXAgU2VydmljZaCCEfswggcoMIIFEKADAgECAhMzAAAB/Big
# r8xpWoc6AAEAAAH8MA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFBDQSAyMDEwMB4XDTI0MDcyNTE4MzExNFoXDTI1MTAyMjE4MzExNFowgdMxCzAJ
# BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xLTArBgNVBAsTJE1pY3Jv
# c29mdCBJcmVsYW5kIE9wZXJhdGlvbnMgTGltaXRlZDEnMCUGA1UECxMeblNoaWVs
# ZCBUU1MgRVNOOjZGMUEtMDVFMC1EOTQ3MSUwIwYDVQQDExxNaWNyb3NvZnQgVGlt
# ZS1TdGFtcCBTZXJ2aWNlMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA
# p1DAKLxpbQcPVYPHlJHyW7W5lBZjJWWDjMfl5WyhuAylP/LDm2hb4ymUmSymV0EF
# RQcmM8BypwjhWP8F7x4iO88d+9GZ9MQmNh3jSDohhXXgf8rONEAyfCPVmJzM7yts
# urZ9xocbuEL7+P7EkIwoOuMFlTF2G/zuqx1E+wANslpPqPpb8PC56BQxgJCI1LOF
# 5lk3AePJ78OL3aw/NdlkvdVl3VgBSPX4Nawt3UgUofuPn/cp9vwKKBwuIWQEFZ83
# 7GXXITshd2Mfs6oYfxXEtmj2SBGEhxVs7xERuWGb0cK6afy7naKkbZI2v1UqsxuZ
# t94rn/ey2ynvunlx0R6/b6nNkC1rOTAfWlpsAj/QlzyM6uYTSxYZC2YWzLbbRl0l
# RtSz+4TdpUU/oAZSB+Y+s12Rqmgzi7RVxNcI2lm//sCEm6A63nCJCgYtM+LLe9pT
# shl/Wf8OOuPQRiA+stTsg89BOG9tblaz2kfeOkYf5hdH8phAbuOuDQfr6s5Ya6W+
# vZz6E0Zsenzi0OtMf5RCa2hADYVgUxD+grC8EptfWeVAWgYCaQFheNN/ZGNQMkk7
# 8V63yoPBffJEAu+B5xlTPYoijUdo9NXovJmoGXj6R8Tgso+QPaAGHKxCbHa1QL9A
# SMF3Os1jrogCHGiykfp1dKGnmA5wJT6Nx7BedlSDsAkCAwEAAaOCAUkwggFFMB0G
# A1UdDgQWBBSY8aUrsUazhxByH79dhiQCL/7QdjAfBgNVHSMEGDAWgBSfpxVdAF5i
# XYP05dJlpxtTNRnpcjBfBgNVHR8EWDBWMFSgUqBQhk5odHRwOi8vd3d3Lm1pY3Jv
# c29mdC5jb20vcGtpb3BzL2NybC9NaWNyb3NvZnQlMjBUaW1lLVN0YW1wJTIwUENB
# JTIwMjAxMCgxKS5jcmwwbAYIKwYBBQUHAQEEYDBeMFwGCCsGAQUFBzAChlBodHRw
# Oi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMFRp
# bWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNydDAMBgNVHRMBAf8EAjAAMBYGA1Ud
# JQEB/wQMMAoGCCsGAQUFBwMIMA4GA1UdDwEB/wQEAwIHgDANBgkqhkiG9w0BAQsF
# AAOCAgEAT7ss/ZAZ0bTaFsrsiJYd//LQ6ImKb9JZSKiRw9xs8hwk5Y/7zign9gGt
# weRChC2lJ8GVRHgrFkBxACjuuPprSz/UYX7n522JKcudnWuIeE1p30BZrqPTOnsc
# D98DZi6WNTAymnaS7it5qAgNInreAJbTU2cAosJoeXAHr50YgSGlmJM+cN6mYLAL
# 6TTFMtFYJrpK9TM5Ryh5eZmm6UTJnGg0jt1pF/2u8PSdz3dDy7DF7KDJad2qHxZO
# RvM3k9V8Yn3JI5YLPuLso2J5s3fpXyCVgR/hq86g5zjd9bRRyyiC8iLIm/N95q6H
# WVsCeySetrqfsDyYWStwL96hy7DIyLL5ih8YFMd0AdmvTRoylmADuKwE2TQCTvPn
# jnLk7ypJW29t17Yya4V+Jlz54sBnPU7kIeYZsvUT+YKgykP1QB+p+uUdRH6e79Va
# iz+iewWrIJZ4tXkDMmL21nh0j+58E1ecAYDvT6B4yFIeonxA/6Gl9Xs7JLciPCIC
# 6hGdliiEBpyYeUF0ohZFn7NKQu80IZ0jd511WA2bq6x9aUq/zFyf8Egw+dunUj1K
# tNoWpq7VuJqapckYsmvmmYHZXCjK1Eus7V1I+aXjrBYuqyM9QpeFZU4U01YG15uW
# wUCaj0uZlah/RGSYMd84y9DCqOpfeKE6PLMk7hLnhvcOQrnxP6kwggdxMIIFWaAD
# AgECAhMzAAAAFcXna54Cm0mZAAAAAAAVMA0GCSqGSIb3DQEBCwUAMIGIMQswCQYD
# VQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEe
# MBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNyb3Nv
# ZnQgUm9vdCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkgMjAxMDAeFw0yMTA5MzAxODIy
# MjVaFw0zMDA5MzAxODMyMjVaMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNo
# aW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29y
# cG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEw
# MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA5OGmTOe0ciELeaLL1yR5
# vQ7VgtP97pwHB9KpbE51yMo1V/YBf2xK4OK9uT4XYDP/XE/HZveVU3Fa4n5KWv64
# NmeFRiMMtY0Tz3cywBAY6GB9alKDRLemjkZrBxTzxXb1hlDcwUTIcVxRMTegCjhu
# je3XD9gmU3w5YQJ6xKr9cmmvHaus9ja+NSZk2pg7uhp7M62AW36MEBydUv626GIl
# 3GoPz130/o5Tz9bshVZN7928jaTjkY+yOSxRnOlwaQ3KNi1wjjHINSi947SHJMPg
# yY9+tVSP3PoFVZhtaDuaRr3tpK56KTesy+uDRedGbsoy1cCGMFxPLOJiss254o2I
# 5JasAUq7vnGpF1tnYN74kpEeHT39IM9zfUGaRnXNxF803RKJ1v2lIH1+/NmeRd+2
# ci/bfV+AutuqfjbsNkz2K26oElHovwUDo9Fzpk03dJQcNIIP8BDyt0cY7afomXw/
# TNuvXsLz1dhzPUNOwTM5TI4CvEJoLhDqhFFG4tG9ahhaYQFzymeiXtcodgLiMxhy
# 16cg8ML6EgrXY28MyTZki1ugpoMhXV8wdJGUlNi5UPkLiWHzNgY1GIRH29wb0f2y
# 1BzFa/ZcUlFdEtsluq9QBXpsxREdcu+N+VLEhReTwDwV2xo3xwgVGD94q0W29R6H
# XtqPnhZyacaue7e3PmriLq0CAwEAAaOCAd0wggHZMBIGCSsGAQQBgjcVAQQFAgMB
# AAEwIwYJKwYBBAGCNxUCBBYEFCqnUv5kxJq+gpE8RjUpzxD/LwTuMB0GA1UdDgQW
# BBSfpxVdAF5iXYP05dJlpxtTNRnpcjBcBgNVHSAEVTBTMFEGDCsGAQQBgjdMg30B
# ATBBMD8GCCsGAQUFBwIBFjNodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3Bz
# L0RvY3MvUmVwb3NpdG9yeS5odG0wEwYDVR0lBAwwCgYIKwYBBQUHAwgwGQYJKwYB
# BAGCNxQCBAweCgBTAHUAYgBDAEEwCwYDVR0PBAQDAgGGMA8GA1UdEwEB/wQFMAMB
# Af8wHwYDVR0jBBgwFoAU1fZWy4/oolxiaNE9lJBb186aGMQwVgYDVR0fBE8wTTBL
# oEmgR4ZFaHR0cDovL2NybC5taWNyb3NvZnQuY29tL3BraS9jcmwvcHJvZHVjdHMv
# TWljUm9vQ2VyQXV0XzIwMTAtMDYtMjMuY3JsMFoGCCsGAQUFBwEBBE4wTDBKBggr
# BgEFBQcwAoY+aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy9NaWNS
# b29DZXJBdXRfMjAxMC0wNi0yMy5jcnQwDQYJKoZIhvcNAQELBQADggIBAJ1Vffwq
# reEsH2cBMSRb4Z5yS/ypb+pcFLY+TkdkeLEGk5c9MTO1OdfCcTY/2mRsfNB1OW27
# DzHkwo/7bNGhlBgi7ulmZzpTTd2YurYeeNg2LpypglYAA7AFvonoaeC6Ce5732pv
# vinLbtg/SHUB2RjebYIM9W0jVOR4U3UkV7ndn/OOPcbzaN9l9qRWqveVtihVJ9Ak
# vUCgvxm2EhIRXT0n4ECWOKz3+SmJw7wXsFSFQrP8DJ6LGYnn8AtqgcKBGUIZUnWK
# NsIdw2FzLixre24/LAl4FOmRsqlb30mjdAy87JGA0j3mSj5mO0+7hvoyGtmW9I/2
# kQH2zsZ0/fZMcm8Qq3UwxTSwethQ/gpY3UA8x1RtnWN0SCyxTkctwRQEcb9k+SS+
# c23Kjgm9swFXSVRk2XPXfx5bRAGOWhmRaw2fpCjcZxkoJLo4S5pu+yFUa2pFEUep
# 8beuyOiJXk+d0tBMdrVXVAmxaQFEfnyhYWxz/gq77EFmPWn9y8FBSX5+k77L+Dvk
# txW/tM4+pTFRhLy/AsGConsXHRWJjXD+57XQKBqJC4822rpM+Zv/Cuk0+CQ1Zyvg
# DbjmjJnW4SLq8CdCPSWU5nR0W2rRnj7tfqAxM328y+l7vzhwRNGQ8cirOoo6CGJ/
# 2XBjU02N7oJtpQUQwXEGahC0HVUzWLOhcGbyoYIDVjCCAj4CAQEwggEBoYHZpIHW
# MIHTMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQL
# EyRNaWNyb3NvZnQgSXJlbGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJzAlBgNVBAsT
# Hm5TaGllbGQgVFNTIEVTTjo2RjFBLTA1RTAtRDk0NzElMCMGA1UEAxMcTWljcm9z
# b2Z0IFRpbWUtU3RhbXAgU2VydmljZaIjCgEBMAcGBSsOAwIaAxUATkEpJXOaqI2w
# fqBsw4NLVwqYqqqggYMwgYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAx
# MDANBgkqhkiG9w0BAQsFAAIFAOtObpYwIhgPMjAyNTAyMDUyMzExMThaGA8yMDI1
# MDIwNjIzMTExOFowdDA6BgorBgEEAYRZCgQBMSwwKjAKAgUA605ulgIBADAHAgEA
# AgII+jAHAgEAAgITPjAKAgUA60/AFgIBADA2BgorBgEEAYRZCgQCMSgwJjAMBgor
# BgEEAYRZCgMCoAowCAIBAAIDB6EgoQowCAIBAAIDAYagMA0GCSqGSIb3DQEBCwUA
# A4IBAQAl0HQ0Uiux9GUUi9Y8mvM2Lf5sG0/b1i/zFZdDhEPDnAMI7GpEMmhm7ZOG
# Z+YN82Hky4hyv5AcrgOSCKxP39nr/C0JOGe3ITJ5lDMjIKDHUOUeb1tltDctTdl8
# 46qc2i9tAMKf3yWf0xhhAvL7VsoqpSmUUHp3kkIVi+cFLOMhBu1hLj4CgSdVcCDH
# vuEdOYnq3pXkFBLvR30X/ovJqQ9eYb54OcXFp95/dGRDAjpC7RXSSbcya3rCRiYD
# H4FSLSslWwQWLhjlZsuE06052hsw2FvI+plfvKZW2eKH/tLoVHvD3xb4Ecx0x0lG
# kVPUhJqiMGBLK3TqR28oJ8eOAw7KMYIEDTCCBAkCAQEwgZMwfDELMAkGA1UEBhMC
# VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNV
# BAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRp
# bWUtU3RhbXAgUENBIDIwMTACEzMAAAH8GKCvzGlahzoAAQAAAfwwDQYJYIZIAWUD
# BAIBBQCgggFKMBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAvBgkqhkiG9w0B
# CQQxIgQg7iNyg+hT9b/9l2HYlYJsYKuSg3YOCgeOXYz0fs0n0AIwgfoGCyqGSIb3
# DQEJEAIvMYHqMIHnMIHkMIG9BCCVQq+Qu+/h/BOVP4wweUwbHuCUhh+T7hq3d5MC
# aNEtYjCBmDCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9u
# MRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRp
# b24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAAB
# /Bigr8xpWoc6AAEAAAH8MCIEIMWA4P7PYUqGdeUFgpwqhCQBiYBM5X0lv2XaRdtu
# 16q1MA0GCSqGSIb3DQEBCwUABIICAJnMDaRTEAj16gAZ1hxxJLv3AblnmhTxHvY6
# HAn2JliCzpfIQkClp5Lqaj/rA9cdw0Osbz6CUcVuYX/M+tTrelMt6tBqT75/3Mh+
# kE4dLwt8MdDZu5bm2GpYo9oJjsala2NvvDeSWxteTEQW+Q0h1DTNH5luEGLS0Tiy
# 6ZnjxXbe7YcqrPO+CvHjyPl70Qiczlgqm0LFJkV4WzZAFwUSSsdX78KVYHnfhktx
# 6jO0DgqRMPhYdbw68dwUFMH/x8iG63wVCRUaH+gogw101dSHV21YXgZYOJSwvyoe
# 3AEhD0++Mzz0bavZC4bOjrH2+Zfj/+9ESl9o5o/l1419cQTHIs/Tym6DlBKxhK7y
# Fg+5HM/X1Zf3HHgWSPsgm7ll/5SrvpswHa4APljAUNGFXzPDTUFq6vO9EG07qH4X
# NpGSgcWxphVCd33xTl+uo3BUtlWdDT43+dQguPYxKzdEPisd0TaSG7Vt63Ri/x1X
# /Eayihz0ViwLZEhCClAjSkbbRMqqpLNi5qSEHAE3M5UZhUFe+WyfRfChlfgSfgj5
# TqawZujyhFoT8p9+GPlX5u5DPkm1WXZLMrWL3NRy9hE4sWLMTZNOhGbrB5H7CrGJ
# pRCZZPVxy2SO4IUK1eHKEdwdcP/ld/k7QJppcOzI2KIeHWX3+I2ROfKWhDmBIlGJ
# 8ISONx1M
# SIG # End signature block
