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
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api202501.IBackupInstanceResource]
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
        [Microsoft.Azure.PowerShell.Cmdlets.DataProtection.Models.Api202501.IAzureBackupRestoreRequest]
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
# MIIoLQYJKoZIhvcNAQcCoIIoHjCCKBoCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDkL4Ux7eWL8R71
# OMvIMmKjMBcxg61XrXe8r+ArVsaZN6CCDXYwggX0MIID3KADAgECAhMzAAAEBGx0
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
# /Xmfwb1tbWrJUnMTDXpQzTGCGg0wghoJAgEBMIGVMH4xCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNp
# Z25pbmcgUENBIDIwMTECEzMAAAQEbHQG/1crJ3IAAAAABAQwDQYJYIZIAWUDBAIB
# BQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIM6PRYPvqcZYqXE6SDXbFffn
# 4KW3tvhQHiyMGkaFdmk8MEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEB
# BQAEggEAaBeS6G7pFecP6+vsqR1yhJrhu2T5j5NxQzWO7Vw9V/HBBJIyjJpDTdji
# grUS8UXUtcCoXOr5283dFsnTcEiJIio5+/Uuu0r8oEgadFuaHiTmNrGEubs8cQI5
# WgPna9GQEWezaPQ9f8ZaydrMCTmrzzFu8zbKSZ/2xUcxXr+kVAgSBv4Kzq4LYxM+
# 8bwL+kutCvtdSuprZkkOPCJRoP5jOlbYDmzyAcf7Frh9IAKeWSihp9m64faLI33N
# g0iSvEC5/mH4z/ut3esfv3NzRREPZQCHioWJId1eMg+mIGXZqv36GNsktYiJNQig
# tQKaCvXcPQJeg2GCnFeu5q0rzuzYxqGCF5cwgheTBgorBgEEAYI3AwMBMYIXgzCC
# F38GCSqGSIb3DQEHAqCCF3AwghdsAgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFSBgsq
# hkiG9w0BCRABBKCCAUEEggE9MIIBOQIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCBfBR3wntk7UR8Wa/T0eD01ye8FwNMuPQuAU2P/T48VRwIGZ/fWlH2x
# GBMyMDI1MDQzMDAyMjkwNC43MjFaMASAAgH0oIHRpIHOMIHLMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1l
# cmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046QTAwMC0w
# NUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2Wg
# ghHtMIIHIDCCBQigAwIBAgITMwAAAgh4nVhdksfZUgABAAACCDANBgkqhkiG9w0B
# AQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYD
# VQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAeFw0yNTAxMzAxOTQy
# NTNaFw0yNjA0MjIxOTQyNTNaMIHLMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25z
# MScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046QTAwMC0wNUUwLUQ5NDcxJTAjBgNV
# BAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2UwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQC1y3AI5lIz3Ip1nK5BMUUbGRsjSnCz/VGs33zvY0Ne
# shsPgfld3/Z3/3dS8WKBLlDlosmXJOZlFSiNXUd6DTJxA9ik/ZbCdWJ78LKjbN3t
# FkX2c6RRpRMpA8sq/oBbRryP3c8Q/gxpJAKHHz8cuSn7ewfCLznNmxqliTk3Q5LH
# qz2PjeYKD/dbKMBT2TAAWAvum4z/HXIJ6tFdGoNV4WURZswCSt6ROwaqQ1oAYGvE
# ndH+DXZq1+bHsgvcPNCdTSIpWobQiJS/UKLiR02KNCqB4I9yajFTSlnMIEMz/Ni5
# 38oGI64phcvNpUe2+qaKWHZ8d4T1KghvRmSSF4YF5DNEJbxaCUwsy7nULmsFnTaO
# jVOoTFWWfWXvBuOKkBcQKWGKvrki976j4x+5ezAP36fq3u6dHRJTLZAu4dEuOooU
# 3+kMZr+RBYWjTHQCKV+yZ1ST0eGkbHXoA2lyyRDlNjBQcoeZIxWCZts/d3+nf1ji
# SLN6f6wdHaUz0ADwOTQ/aEo1IC85eFePvyIKaxFJkGU2Mqa6Xzq3qCq5tokIHtjh
# ogsrEgfDKTeFXTtdhl1IPtLcCfMcWOGGAXosVUU7G948F6W96424f2VHD8L3FoyA
# I9+r4zyIQUmqiESzuQWeWpTTjFYwCmgXaGOuSDV8cNOVQB6IPzPneZhVTjwxbAZl
# aQIDAQABo4IBSTCCAUUwHQYDVR0OBBYEFKMx4vfOqcUTgYOVB9f18/mhegFNMB8G
# A1UdIwQYMBaAFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMF8GA1UdHwRYMFYwVKBSoFCG
# Tmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUy
# MFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNybDBsBggrBgEFBQcBAQRgMF4w
# XAYIKwYBBQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2Vy
# dHMvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUyMDIwMTAoMSkuY3J0MAwG
# A1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQD
# AgeAMA0GCSqGSIb3DQEBCwUAA4ICAQBRszKJKwAfswqdaQPFiaYB/ZNAYWDa040X
# TcQsCaCua5nsG1IslYaSpH7miTLr6eQEqXczZoqeOa/xvDnMGifGNda0CHbQwtpn
# IhsutrKO2jhjEaGwlJgOMql21r7Ik6XnBza0e3hBOu4UBkMl/LEX+AURt7i7+RTN
# sGN0cXPwPSbTFE+9z7WagGbY9pwUo/NxkGJseqGCQ/9K2VMU74bw5e7+8IGUhM2x
# spJPqnSeHPhYmcB0WclOxcVIfj/ZuQvworPbTEEYDVCzSN37c0yChPMY7FJ+HGFB
# NJxwd5lKIr7GYfq8a0gOiC2ljGYlc4rt4cCed1XKg83f0l9aUVimWBYXtfNebhpf
# r6Lc3jD8NgsrDhzt0WgnIdnTZCi7jxjsIBilH99pY5/h6bQcLKK/E6KCP9E1YN78
# fLaOXkXMyO6xLrvQZ+uCSi1hdTufFC7oSB/CU5RbfIVHXG0j1o2n1tne4eCbNfKq
# UPTE31tNbWBR23Yiy0r3kQmHeYE1GLbL4pwknqaip1BRn6WIUMJtgncawEN33f8A
# YGZ4a3NnHopzGVV6neffGVag4Tduy+oy1YF+shChoXdMqfhPWFpHe3uJGT4GJEiN
# s4+28a/wHUuF+aRaR0cN5P7XlOwU1360iUCJtQdvKQaNAwGI29KOwS3QGriR9F2j
# OGPUAlpeEzCCB3EwggVZoAMCAQICEzMAAAAVxedrngKbSZkAAAAAABUwDQYJKoZI
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
# MCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOkEwMDAtMDVFMC1EOTQ3MSUwIwYDVQQD
# ExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloiMKAQEwBwYFKw4DAhoDFQCN
# kvu0NKcSjdYKyrhJZcsyXOUTNKCBgzCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFBDQSAyMDEwMA0GCSqGSIb3DQEBCwUAAgUA67wIpjAiGA8yMDI1MDQzMDAyMjU0
# MloYDzIwMjUwNTAxMDIyNTQyWjB3MD0GCisGAQQBhFkKBAExLzAtMAoCBQDrvAim
# AgEAMAoCAQACAgyYAgH/MAcCAQACAhKgMAoCBQDrvVomAgEAMDYGCisGAQQBhFkK
# BAIxKDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMHoSChCjAIAgEAAgMBhqAwDQYJ
# KoZIhvcNAQELBQADggEBAC23ijTu+sJdRA0uvXFZDLtTKwItG2sBTaXBy1NcwHXC
# 2hB5d25PSNc9RYGCYfw+7oX7Emm8QuRTgUIq3KUtsGr3zEU4rFUksgkMzjtEIhx8
# gBZF3pRi/cnRWu0PB1akjY0B6hxW1Trn5xnkwyMj9+teHnKDQmPoz/AF0MHZfnl3
# JyQB/i0TXz/bXcdOjNtU1ttjjJtif0jHsbX9vOlU0LoFuOZYc/769+Dj/8O5wiLE
# yawdSBb7obivdPZdqHmXhkvNFEhggBjSaa/X0M1Cth/Nm8/vlkufstaAvTj6zfiu
# vk9P2Agu0QicaK+YNlswzHCf58dlg1bXTOfJm6x/4DwxggQNMIIECQIBATCBkzB8
# MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVk
# bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1N
# aWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAgh4nVhdksfZUgABAAAC
# CDANBglghkgBZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEE
# MC8GCSqGSIb3DQEJBDEiBCDcbfhqoZFYS5mB58F2aHa0tU7wioOaHiEyYk9jsitG
# rTCB+gYLKoZIhvcNAQkQAi8xgeowgecwgeQwgb0EII//jm8JHa2W1O9778t9+Ft2
# Z5NmKqttPk6Q+9RRpmepMIGYMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29m
# dCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENB
# IDIwMTACEzMAAAIIeJ1YXZLH2VIAAQAAAggwIgQga7qmcJ2Fi2ZrIImQZSuySQln
# lLP/k/rQ0EKgNxaglfQwDQYJKoZIhvcNAQELBQAEggIArcsDBeAtCoso6NYrR6Kv
# XS4JSiZ2c0XwFAzY0meDSn/PlHgn3u+GyTKbvWlLnAVSFSiVMfBmS+U4qOGavUZt
# E1S2wlf4XG8/bnTw57Ty/KjnaoPRVRx1NJ6UHuFyEAq7g0+aXABAd3E9F46ggJfp
# m0t7KYivEN6O24eKSGChjrE54s2MrO677pt6OajL0jDseKLu/gGQaCySpUlIjyjS
# 8p2LsMoPG6OADOSk/hzV/YPsFe9gyqn8HrNjxUcTp9yziEwF+1geerU1Db21/Mot
# Qc3s3yDeMV6EmpFOB+g0BlqQDrOI2nl2oAYXvPm6TS3hrUGqskywCmNGHeEX2gHj
# giEROiTsPCqn6b3/M0ehH1pHDFb/cYoWSJdjTUPuZh5KZsbM7blyOzX+LUjn5TKr
# iHAMc5XQQMkmL9agZC2EX9VehSeL2GN1BNqoMmaVAnYaAC6lLZhgvnFTo8KLQJLa
# bqplFYk3DVMTLHz5sbl+TfWDDIc4egsQfUA1AhIgh14cp1d/ZbTuphTCl0sAIwKW
# +jy2dUoaxMssvc2TW/9l4QM+NdKj80qRCt/Ltb4wSKKCggjkFwDzZ9vgMvTgdz0j
# nEJocpVavcddPVOvKrZP3IQjlrWkp5ijSeThwXRYOMKPBmksiwPALkHq7Bu603+Q
# oQASpECPsKW4oMOJtWM5SAg=
# SIG # End signature block
