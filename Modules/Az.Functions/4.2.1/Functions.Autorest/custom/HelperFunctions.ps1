# Load Az.Functions module constants
$constants = @{}
$constants["AllowedStorageTypes"] = @('Standard_GRS', 'Standard_RAGRS', 'Standard_LRS', 'Standard_ZRS', 'Premium_LRS', 'Standard_GZRS')
$constants["RequiredStorageEndpoints"] = @('PrimaryEndpointFile', 'PrimaryEndpointQueue', 'PrimaryEndpointTable')
$constants["DefaultFunctionsVersion"] = '4'
$constants["RuntimeToFormattedName"] = @{
    'dotnet' = 'DotNet'
    'dotnet-isolated' = 'DotNet-Isolated'
    'custom' = 'Custom'
    'node' = 'Node'
    'python' = 'Python'
    'java' = 'Java'
    'powershell' = 'PowerShell'
}
$constants["RuntimeToDefaultOSType"] = @{
    'DotNet'= 'Windows'
    'DotNet-Isolated' = 'Windows'
    'Custom' = 'Windows'
    'Node' = 'Windows'
    'Java' = 'Windows'
    'PowerShell' = 'Windows'
    'Python' = 'Linux'
}
$constants["ReservedFunctionAppSettingNames"] = @(
    'FUNCTIONS_WORKER_RUNTIME'
    'DOCKER_CUSTOM_IMAGE_NAME'
    'FUNCTION_APP_EDIT_MODE'
    'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
    'DOCKER_REGISTRY_SERVER_URL'
    'DOCKER_REGISTRY_SERVER_USERNAME'
    'DOCKER_REGISTRY_SERVER_PASSWORD'
    'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
    'WEBSITE_NODE_DEFAULT_VERSION'
    'AzureWebJobsStorage'
    'AzureWebJobsDashboard'
    'FUNCTIONS_EXTENSION_VERSION'
    'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
    'WEBSITE_CONTENTSHARE'
    'APPINSIGHTS_INSTRUMENTATIONKEY'
)
$constants["SetDefaultValueParameterWarningMessage"] = "This default value is subject to change over time. Please set this value explicitly to ensure the behavior is not accidentally impacted by future changes."
$constants["DEBUG_PREFIX"] = '[Stacks API] - '
$constants["DefaultCentauriImage"] = 'mcr.microsoft.com/azure-functions/dotnet8-quickstart-demo:1.0'

foreach ($variableName in $constants.Keys)
{
    if (-not (Get-Variable $variableName -ErrorAction SilentlyContinue))
    {
        Set-Variable $variableName -value $constants[$variableName] -option ReadOnly
    }
}

# These are used to hold the types for the tab completers
$RuntimeToVersionLinux = @{}
$RuntimeToVersionWindows = @{}
$AllRuntimeVersions = @{}
$global:StacksAndTabCompletersInitialized = $false
$AllFunctionsExtensionVersions = New-Object System.Collections.Generic.List[[String]]

function GetConnectionString
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $StorageAccountName,

        $SubscriptionId,
        $HttpPipelineAppend,
        $HttpPipelinePrepend
    )

    if ($PSBoundParameters.ContainsKey("StorageAccountName"))
    {
        $PSBoundParameters.Remove("StorageAccountName") | Out-Null
    }

    $storageAccountInfo = GetStorageAccount -Name $StorageAccountName @PSBoundParameters
    if (-not $storageAccountInfo)
    {
        $errorMessage = "Storage account '$StorageAccountName' does not exist."
        $exception = [System.InvalidOperationException]::New($errorMessage)
        ThrowTerminatingError -ErrorId "StorageAccountNotFound" `
                              -ErrorMessage $errorMessage `
                              -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                              -Exception $exception
    }

    if ($storageAccountInfo.ProvisioningState -ne "Succeeded")
    {
        $errorMessage = "Storage account '$StorageAccountName' is not ready. Please run 'Get-AzStorageAccount' and ensure that the ProvisioningState is 'Succeeded'"
        $exception = [System.InvalidOperationException]::New($errorMessage)
        ThrowTerminatingError -ErrorId "StorageAccountNotFound" `
                              -ErrorMessage $errorMessage `
                              -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                              -Exception $exception
    }
    
    $skuName = $storageAccountInfo.SkuName
    if (-not ($AllowedStorageTypes -contains $skuName))
    {
        $storageOptions = $AllowedStorageTypes -join ", "
        $errorMessage = "Storage type '$skuName' is not allowed'. Currently supported storage options: $storageOptions"
        $exception = [System.InvalidOperationException]::New($errorMessage)
        ThrowTerminatingError -ErrorId "StorageTypeNotSupported" `
                              -ErrorMessage $errorMessage `
                              -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                              -Exception $exception
    }

    foreach ($endpoint in $RequiredStorageEndpoints)
    {
        if ([string]::IsNullOrEmpty($storageAccountInfo.$endpoint))
        {
            $errorMessage = "Storage account '$StorageAccountName' has no '$endpoint' endpoint. It must have table, queue, and blob endpoints all enabled."
            $exception = [System.InvalidOperationException]::New($errorMessage)
            ThrowTerminatingError -ErrorId "StorageAccountRequiredEndpointNotAvailable" `
                                  -ErrorMessage $errorMessage `
                                  -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                                  -Exception $exception
        }
    }

    $resourceGroupName = ($storageAccountInfo.Id -split "/")[4]
    $keys = Az.Functions.internal\Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName -Name $storageAccountInfo.Name @PSBoundParameters -ErrorAction SilentlyContinue

    if (-not $keys)
    {
        $errorMessage = "Failed to get key for storage account '$StorageAccountName'."
        $exception = [System.InvalidOperationException]::New($errorMessage)
        ThrowTerminatingError -ErrorId "FailedToGetStorageAccountKey" `
                              -ErrorMessage $errorMessage `
                              -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                              -Exception $exception
    }

    if ([string]::IsNullOrEmpty($keys[0].Value))
    {
        $errorMessage = "Storage account '$StorageAccountName' has no key value."
        $exception = [System.InvalidOperationException]::New($errorMessage)
        ThrowTerminatingError -ErrorId "StorageAccountHasNoKeyValue" `
                              -ErrorMessage $errorMessage `
                              -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                              -Exception $exception
    }

    $suffix = GetEndpointSuffix
    $accountKey = $keys[0].Value

    $connectionString = "DefaultEndpointsProtocol=https;AccountName=$StorageAccountName;AccountKey=$accountKey" + $suffix

    return $connectionString
}

function GetEndpointSuffix
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param()

    $environmentName = (Get-AzContext).Environment.Name

    switch ($environmentName)
    {
        "AzureUSGovernment" { ';EndpointSuffix=core.usgovcloudapi.net' }
        "AzureChinaCloud"   { ';EndpointSuffix=core.chinacloudapi.cn' }
        "AzureCloud"        { ';EndpointSuffix=core.windows.net' }
        default { '' }
    }
}

function NewAppSetting
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,

        [Parameter(Mandatory=$false)]
        [System.String]
        $Value
    )

    $setting = New-Object -TypeName Microsoft.Azure.PowerShell.Cmdlets.Functions.Models.Api20231201.NameValuePair
    $setting.Name = $Name
    $setting.Value = $Value

    return $setting
}

function GetServicePlan
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,

        $SubscriptionId,
        $HttpPipelineAppend,
        $HttpPipelinePrepend
    )

    if ($PSBoundParameters.ContainsKey("Name"))
    {
        $PSBoundParameters.Remove("Name") | Out-Null
    }

    $plans = @(Az.Functions\Get-AzFunctionAppPlan @PSBoundParameters)

    foreach ($plan in $plans)
    {
        if ($plan.Name -eq $Name)
        {
            return $plan
        }
    }

    # The plan name was not found, error out
    $errorMessage = "Service plan '$Name' does not exist."
    $exception = [System.InvalidOperationException]::New($errorMessage)
    ThrowTerminatingError -ErrorId "ServicePlanDoesNotExist" `
                          -ErrorMessage $errorMessage `
                          -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                          -Exception $exception
}

function GetStorageAccount
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,

        $SubscriptionId,
        $HttpPipelineAppend,
        $HttpPipelinePrepend
    )

    if ($PSBoundParameters.ContainsKey("Name"))
    {
        $PSBoundParameters.Remove("Name") | Out-Null
    }

    $storageAccounts = @(Az.Functions.internal\Get-AzStorageAccount @PSBoundParameters -ErrorAction SilentlyContinue)
    foreach ($account in $storageAccounts)
    {
        if ($account.Name -eq $Name)
        {
            return $account
        }
    }
}

function GetApplicationInsightsProject
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,

        $SubscriptionId,
        $HttpPipelineAppend,
        $HttpPipelinePrepend
    )

    if ($PSBoundParameters.ContainsKey("Name"))
    {
        $PSBoundParameters.Remove("Name") | Out-Null
    }

    $projects = @(Az.Functions.internal\Get-AzAppInsights @PSBoundParameters)
    
    foreach ($project in $projects)
    {
        if ($project.Name -eq $Name)
        {
            return $project
        }
    }
}

function CreateApplicationInsightsProject
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ResourceName,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ResourceGroupName,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Location,

        $SubscriptionId,
        $HttpPipelineAppend,
        $HttpPipelinePrepend
    )

    $paramsToRemove = @(
        "ResourceGroupName",
        "ResourceName",
        "Location"
    )
    foreach ($paramName in $paramsToRemove)
    {
        if ($PSBoundParameters.ContainsKey($paramName))
        {
            $PSBoundParameters.Remove($paramName)  | Out-Null
        }
    }

    # Create a new ApplicationInsights
    $maxNumberOfTries = 3
    $tries = 1

    while ($true)
    {
        try
        {
            $newAppInsightsProject = Az.Functions.internal\New-AzAppInsights -ResourceGroupName $ResourceGroupName `
                                                                             -ResourceName $ResourceName  `
                                                                             -Location $Location `
                                                                             -Kind web `
                                                                             -RequestSource "AzurePowerShell" `
                                                                             -ErrorAction Stop `
                                                                             @PSBoundParameters
            if ($newAppInsightsProject)
            {
                return $newAppInsightsProject
            }
        }
        catch
        {
            # Ignore the failure and continue
        }

        if ($tries -ge $maxNumberOfTries)
        {
            break
        }

        # Wait for 2^(tries-1) seconds between retries. In this case, it would be 1, 2, and 4 seconds, respectively.
        $waitInSeconds = [Math]::Pow(2, $tries - 1)
        Start-Sleep -Seconds $waitInSeconds

        $tries++
    }
}

function ConvertWebAppApplicationSettingToHashtable
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [Object]
        $ApplicationSetting,

        [System.Management.Automation.SwitchParameter]
        $ShowAllAppSettings,

        [System.Management.Automation.SwitchParameter]
        $RedactAppSettings,

        [System.Management.Automation.SwitchParameter]
        $ShowOnlySpecificAppSettings,

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $AppSettingsToShow
    )

    if ($RedactAppSettings.IsPresent)
    {
        Write-Warning "App settings have been redacted. Use the Get-AzFunctionAppSetting cmdlet to view them."
    }

    # Create a key value pair to hold the function app settings
    $applicationSettings = @{}

    foreach ($keyName in $ApplicationSetting.Property.Keys)
    {
        if($ShowAllAppSettings.IsPresent)
        {
            $applicationSettings[$keyName] = $ApplicationSetting.Property[$keyName]
        }
        elseif ($RedactAppSettings.IsPresent)
        {
            # When RedactAppSettings is present, all app settings are set to null
            $applicationSettings[$keyName] = $null
        }
        elseif($ShowOnlySpecificAppSettings.IsPresent)
        {
            # When ShowOnlySpecificAppSettings is present, only show the app settings in this list AppSettingsToShow
            if ($AppSettingsToShow.Contains($keyName))
            {
                $applicationSettings[$keyName] = $ApplicationSetting.Property[$keyName]
            }
        }
    }

    return $applicationSettings
}

function GetRuntime
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [Object]
        $Settings,

        [Parameter(Mandatory=$false)]
        [String]
        $AppKind
    )

    $appSettings = ConvertWebAppApplicationSettingToHashtable -ApplicationSetting $Settings -ShowAllAppSettings
    $runtimeName = $appSettings["FUNCTIONS_WORKER_RUNTIME"]

    $runtime = ""
    if (($null -ne $runtimeName) -and ($RuntimeToFormattedName.ContainsKey($runtimeName)))
    {
        $runtime = $RuntimeToFormattedName[$runtimeName]
    }
    elseif ($appSettings.ContainsKey("DOCKER_CUSTOM_IMAGE_NAME"))
    {
        if ($AppKind -match "azurecontainerapps")
        {
            $runtime = "Container App"
        }
        else
        {
            $runtime = "Custom Image"
        }
    }

    return $runtime
}


function AddFunctionAppSettings
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [Object]
        $App,

        $SubscriptionId,
        $HttpPipelineAppend,
        $HttpPipelinePrepend
    )

    if ($PSBoundParameters.ContainsKey("App"))
    {
        $PSBoundParameters.Remove("App") | Out-Null
    }

    if ($App.kind.ToString() -match "azurecontainerapps")
    {
        if ($App.ManagedEnvironmentId)
        {
            $App.AppServicePlan = ($App.ManagedEnvironmentId -split "/")[-1]
        }
    }
    else
    {
        $App.AppServicePlan = ($App.ServerFarmId -split "/")[-1]
    }

    $App.OSType = if ($App.kind.ToString() -match "linux"){ "Linux" } else { "Windows" }

    if ($App.Type -eq "Microsoft.Web/sites/slots")
    {
        return $App
    }
    
    $currentSubscription = $null
    $resetDefaultSubscription = $false
    
    try
    {
        $settings = Az.Functions.internal\Get-AzWebAppApplicationSetting -Name $App.Name `
                                                                         -ResourceGroupName $App.ResourceGroup `
                                                                         -ErrorAction SilentlyContinue `
                                                                         @PSBoundParameters
        if ($null -eq $settings)
        {
            Write-Warning -Message "Failed to retrieve function app settings. 1st attempt"
            Write-Warning -Message "Setting session context to subscription id '$($App.SubscriptionId)'"

            $resetDefaultSubscription = $true
            $currentSubscription = (Get-AzContext).Subscription.Id
            $null = Select-AzSubscription $App.SubscriptionId

            $settings = Az.Functions.internal\Get-AzWebAppApplicationSetting -Name $App.Name `
                                                                             -ResourceGroupName $App.ResourceGroup `
                                                                             -ErrorAction SilentlyContinue `
                                                                             @PSBoundParameters
            if ($null -eq $settings)
            {
                # We are unable to get the app settings, return the app
                Write-Warning -Message "Failed to retrieve function app settings. 2nd attempt."
                return $App
            }
        }
    }
    finally
    {
        if ($resetDefaultSubscription)
        {
            Write-Warning -Message "Resetting session context to subscription id '$currentSubscription'"
            $null = Select-AzSubscription $currentSubscription
        }
    }

    # Add application settings and runtime
    $App.ApplicationSettings = ConvertWebAppApplicationSettingToHashtable -ApplicationSetting $settings -RedactAppSettings
    $App.Runtime = GetRuntime -Settings $settings -AppKind $App.kind

    # Get the app site config
    $config = GetAzWebAppConfig -Name $App.Name -ResourceGroupName $App.ResourceGroup @PSBoundParameters
    # Add all site config properties as a hash table
    $SiteConfig = @{}
    foreach ($property in $config.PSObject.Properties)
    {
        if ($property.Name)
        {
            $SiteConfig.Add($property.Name, $property.Value)
        }
    }

    $App.SiteConfig = $SiteConfig

    return $App
}

function GetFunctionApps
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$true)]
        [AllowEmptyCollection()]
        [Object[]]
        $Apps,

        [System.String]
        $Location,

        $SubscriptionId,
        $HttpPipelineAppend,
        $HttpPipelinePrepend
    )

    $paramsToRemove = @(
        "Apps",
        "Location"
    )
    foreach ($paramName in $paramsToRemove)
    {
        if ($PSBoundParameters.ContainsKey($paramName))
        {
            $PSBoundParameters.Remove($paramName)  | Out-Null
        }
    }

    if ($Apps.Count -eq 0)
    {
        return
    }

    $activityName = "Getting function apps"

    for ($index = 0; $index -lt $Apps.Count; $index++)
    {
        $app = $Apps[$index]

        $percentageCompleted = [int]((100 * ($index + 1)) / $Apps.Count)
        $status = "Complete: $($index + 1)/$($Apps.Count) function apps processed."
        Write-Progress -Activity "Getting function apps" -Status $status -PercentComplete $percentageCompleted
        
        if ($app.kind -match "functionapp")
        {
            if ($Location)
            {
                if ($app.Location -eq $Location)
                {
                    $app = AddFunctionAppSettings -App $app @PSBoundParameters
                    $app
                }
            }
            else
            {
                $app = AddFunctionAppSettings -App $app @PSBoundParameters
                $app
            }
        }
    }

    Write-Progress -Activity $activityName -Status "Completed" -Completed
}

function AddFunctionAppPlanWorkerType
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $AppPlan,

        $SubscriptionId,
        $HttpPipelineAppend,
        $HttpPipelinePrepend
    )

    if ($PSBoundParameters.ContainsKey("AppPlan"))
    {
        $PSBoundParameters.Remove("AppPlan") | Out-Null
    }

    # The GetList api for service plan that does not set the Reserved property, which is needed to figure out if the OSType is Linux.
    # TODO: Remove this code once  https://msazure.visualstudio.com/Antares/_workitems/edit/5623226 is fixed.
    if ($null -eq $AppPlan.Reserved)
    {
        # Get the service plan by name does set the Reserved property
        $planObject = Az.Functions.internal\Get-AzFunctionAppPlan -Name $AppPlan.Name `
                                                                  -ResourceGroupName $AppPlan.ResourceGroup `
                                                                  -ErrorAction SilentlyContinue `
                                                                  @PSBoundParameters
        $AppPlan = $planObject
    }

    $AppPlan.WorkerType = if ($AppPlan.Reserved){ "Linux" } else { "Windows" }

    return $AppPlan
}

function GetFunctionAppPlans
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$true)]
        [AllowEmptyCollection()]
        [Object[]]
        $Plans,

        [System.String]
        $Location,

        $SubscriptionId,
        $HttpPipelineAppend,
        $HttpPipelinePrepend
    )

    $paramsToRemove = @(
        "Plans",
        "Location"
    )
    foreach ($paramName in $paramsToRemove)
    {
        if ($PSBoundParameters.ContainsKey($paramName))
        {
            $PSBoundParameters.Remove($paramName)  | Out-Null
        }
    }

    if ($Plans.Count -eq 0)
    {
        return
    }

    $activityName = "Getting function app plans"

    for ($index = 0; $index -lt $Plans.Count; $index++)
    {
        $plan = $Plans[$index]
        
        $percentageCompleted = [int]((100 * ($index + 1)) / $Plans.Count)
        $status = "Complete: $($index + 1)/$($Plans.Count) function apps plans processed."
        Write-Progress -Activity $activityName -Status $status -PercentComplete $percentageCompleted

        try {
            if ($Location)
            {
                if ($plan.Location -eq $Location)
                {
                    $plan = AddFunctionAppPlanWorkerType -AppPlan $plan @PSBoundParameters
                    $plan
                }
            }
            else
            {
                $plan = AddFunctionAppPlanWorkerType -AppPlan $plan @PSBoundParameters
                $plan
            }
        }
        catch {
            continue;
        }
    }

    Write-Progress -Activity $activityName -Status "Completed" -Completed
}

function ValidateFunctionName
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,

        $SubscriptionId,
        $HttpPipelineAppend,
        $HttpPipelinePrepend
    )

    $result = Az.Functions.internal\Test-AzNameAvailability -Type Site @PSBoundParameters

    if (-not $result.NameAvailable)
    {
        $errorMessage = "Function name '$Name' is not available.  Please try a different name."
        $exception = [System.InvalidOperationException]::New($errorMessage)
        ThrowTerminatingError -ErrorId "FunctionAppNameIsNotAvailable" `
                              -ErrorMessage $errorMessage `
                              -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                              -Exception $exception
    }
}

function NormalizeSku
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Sku
    )    
    if ($Sku -eq "SHARED")
    {
        return "D1"
    }
    return $Sku
}

function CreateFunctionsIdentity
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $InputObject
    )

    if (-not ($InputObject.Name -and $InputObject.ResourceGroupName -and $InputObject.SubscriptionId))
    {
        $errorMessage = "Input object '$InputObject' is missing one or more of the following properties: Name, ResourceGroupName, SubscriptionId"
        $exception = [System.InvalidOperationException]::New($errorMessage)
        ThrowTerminatingError -ErrorId "FailedToCreateFunctionsIdentity" `
                              -ErrorMessage $errorMessage `
                              -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                              -Exception $exception
    }

    $functionsIdentity = New-Object -TypeName Microsoft.Azure.PowerShell.Cmdlets.Functions.Models.FunctionsIdentity
    $functionsIdentity.Name = $InputObject.Name
    $functionsIdentity.SubscriptionId = $InputObject.SubscriptionId
    $functionsIdentity.ResourceGroupName = $InputObject.ResourceGroupName

    return $functionsIdentity
}

function GetSkuName
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Sku
    )

    if (($Sku -eq "D1") -or ($Sku -eq "SHARED"))
    {
        return "SHARED"
    }
    elseif (($Sku -eq "B1") -or ($Sku -eq "B2") -or ($Sku -eq "B3") -or ($Sku -eq "BASIC"))
    {
        return "BASIC"
    }
    elseif (($Sku -eq "S1") -or ($Sku -eq "S2") -or ($Sku -eq "S3"))
    {
        return "STANDARD"
    }
    elseif (($Sku -eq "P1") -or ($Sku -eq "P2") -or ($Sku -eq "P3"))
    {
        return "PREMIUM"
    }
    elseif (($Sku -eq "P1V2") -or ($Sku -eq "P2V2") -or ($Sku -eq "P3V2"))
    {
        return "PREMIUMV2"
    }
    elseif (($Sku -eq "PC2") -or ($Sku -eq "PC3") -or ($Sku -eq "PC4"))
    {
        return "PremiumContainer"
    }
    elseif (($Sku -eq "EP1") -or ($Sku -eq "EP2") -or ($Sku -eq "EP3"))
    {
        return "ElasticPremium"
    }
    elseif (($Sku -eq "I1") -or ($Sku -eq "I2") -or ($Sku -eq "I3"))
    {
        return "Isolated"
    }

    $guidanceUrl = 'https://learn.microsoft.com/azure/azure-functions/functions-premium-plan#plan-and-sku-settings'

    $errorMessage = "Invalid sku (pricing tier), please refer to '$guidanceUrl' for valid values."
    $exception = [System.InvalidOperationException]::New($errorMessage)
    ThrowTerminatingError -ErrorId "InvalidSkuPricingTier" `
                          -ErrorMessage $errorMessage `
                          -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                          -Exception $exception
}

function ThrowTerminatingError
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param 
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ErrorId,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ErrorMessage,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.ErrorCategory]
        $ErrorCategory,

        [Exception]
        $Exception,

        [object]
        $TargetObject
    )

    if (-not $Exception)
    {
        $Exception = New-Object -TypeName System.Exception -ArgumentList $ErrorMessage
    }

    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord -ArgumentList ($Exception, $ErrorId, $ErrorCategory, $TargetObject)
    #$PSCmdlet.ThrowTerminatingError($errorRecord)
    throw $errorRecord
}

function GetErrorMessage
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        $Response
    )

    if ($Response.Exception.ResponseBody)
    {
        try
        {
            $details = ConvertFrom-Json $Response.Exception.ResponseBody
            if ($details.Message)
            {
                return $details.Message
            }
        }
        catch 
        {
            # Ignore the deserialization error
        }
    }
}

function GetSupportedRuntimes
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $OSType
    )

    if ($OSType -eq "Linux")
    {
        return $RuntimeToVersionLinux
    }
    elseif ($OSType -eq "Windows")
    {
        return $RuntimeToVersionWindows
    }

    throw "Unknown OS type '$OSType'"
}

function ValidateFunctionsVersion
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $FunctionsVersion
    )

    # if ($SupportedFunctionsVersion -notcontains $FunctionsVersion)
    if ($AllFunctionsExtensionVersions -notcontains $FunctionsVersion)
    {
        $currentlySupportedFunctionsVersions = $AllFunctionsExtensionVersions -join ' and '
        $errorMessage = "Functions version not supported. Currently supported version are: $($currentlySupportedFunctionsVersions)."
        $exception = [System.InvalidOperationException]::New($errorMessage)
        ThrowTerminatingError -ErrorId "FunctionsVersionNotSupported" `
                              -ErrorMessage $errorMessage `
                              -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                              -Exception $exception
    }
}

function GetDefaultOSType
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Runtime
    )

    $defaultOSType = $RuntimeToDefaultOSType[$Runtime]

    if (-not $defaultOSType)
    {
        # The specified runtime did not match, error out
        $runtimeOptions = FormatListToString -List @($RuntimeToDefaultOSType.Keys | Sort-Object)
        $errorMessage = "Runtime '$Runtime' is not supported. Currently supported runtimes: " + $runtimeOptions + "."
        ThrowRuntimeNotSupportedException -Message $errorMessage -ErrorId "RuntimeNotSupported"
    }

    return $defaultOSType
}

# Returns the stack definition for the given runtime name
#
function GetStackDefinitionForRuntime
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $FunctionsVersion,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Runtime,

        [Parameter(Mandatory=$false)]
        [System.String]
        $RuntimeVersion,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $OSType
    )

    $supportedRuntimes = GetSupportedRuntimes -OSType $OSType
    $runtimeJsonDefinition = $null

    $functionsExtensionVersion = "~$FunctionsVersion"
    if (-not $supportedRuntimes.ContainsKey($Runtime))
    {
        $runtimeOptions = FormatListToString -List @($supportedRuntimes.Keys | Sort-Object)
        $errorMessage = "Runtime '$Runtime' on '$OSType' is not supported. Currently supported runtimes: " + $runtimeOptions + "."

        ThrowRuntimeNotSupportedException -Message $errorMessage -ErrorId "RuntimeNotSupported"
    }

    # If runtime version is not provided, iterate through the list to find the default version (if available)
    if (($Runtime -ne 'Custom') -and (-not $RuntimeVersion))
    {
        $versionFound = $false
        $version = GetDefaultOrLatestRuntimeVersion -SupportedRuntimes $supportedRuntimes -Runtime $Runtime -FunctionsExtensionVersion $functionsExtensionVersion
        if (-not [string]::IsNullOrWhiteSpace($version))
        {
            $RuntimeVersion = $version
            $versionFound = $true
        }
        # Error out if we could not find a default or latest version for the given runtime (except for 'Custom'), functions extension version, and os type
        if (-not $versionFound -and ($Runtime -ne 'Custom'))
        {
            $errorMessage = "Runtime '$Runtime' in Functions version '$FunctionsVersion' on '$OSType' is not supported."
            ThrowRuntimeNotSupportedException -Message $errorMessage -ErrorId "RuntimeVersionNotSupported"
        }

        Write-Warning "RuntimeVersion not specified. Setting default value to '$RuntimeVersion'. $SetDefaultValueParameterWarningMessage"
    }

    if ($Runtime -eq 'Custom')
    {
        # Custom runtime does not have a version
        $runtimeJsonDefinition = $supportedRuntimes[$Runtime]
    }
    else
    {
        $runtimeJsonDefinition = $supportedRuntimes[$Runtime] |  Where-Object { $_.Version -eq $RuntimeVersion }
    }

    if (-not $runtimeJsonDefinition)
    {
        $errorMessage = "Runtime '$Runtime' version '$RuntimeVersion' in Functions version '$FunctionsVersion' on '$OSType' is not supported."

        $supporedVersions = @($supportedRuntimes[$Runtime] |
                                Sort-Object -Property Version -Descending |
                                Where-Object { $_.SupportedFunctionsExtensionVersions -contains $functionsExtensionVersion } |
                                Select-Object -ExpandProperty Version)

        if ($supporedVersions.Count -gt 0)
        {
            $runtimeVersionOptions = $supporedVersions -join ", "
            $errorMessage += " Currently supported runtime versions for '$($Runtime)' are: $runtimeVersionOptions."
        }

        ThrowRuntimeNotSupportedException -Message $errorMessage -ErrorId "RuntimeVersionNotSupported"
    }
    
    if ($runtimeJsonDefinition.IsPreview)
    {
        # Write a verbose message to the user if the current runtime is in Preview
        Write-Verbose "Runtime '$Runtime' version '$RuntimeVersion' is in Preview for '$OSType'." -Verbose
    }

    if ($runtimeJsonDefinition.EndOfLifeDate)
    {
        $today = Get-Today
        $sixMonthsFromToday = (Get-Today).AddMonths(6)
        $endOfLifeDate = $runtimeJsonDefinition.EndOfLifeDate
        $formattedEOLDate = ([DateTime]$endOfLifeDate).ToString("MMMM dd yyyy")

        $defaultRuntimeVersion = GetDefaultOrLatestRuntimeVersion -SupportedRuntimes $supportedRuntimes `
                                                                  -Runtime $Runtime `
                                                                  -FunctionsExtensionVersion $functionsExtensionVersion

        if ($endOfLifeDate -le $today)
        {
            $errorMsg = "Use $Runtime $defaultRuntimeVersion as $Runtime $RuntimeVersion has reached end-of-life "
            $errorMsg += "on $formattedEOLDate and is no longer supported. Learn more: aka.ms/FunctionsStackUpgrade."

            $exception = [System.InvalidOperationException]::New($errorMsg)
            ThrowTerminatingError -ErrorId "RuntimeVersionEndOfLife" `
                                  -ErrorMessage $errorMsg `
                                  -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                                  -Exception $exception
        }
        elseif ($endOfLifeDate -lt $sixMonthsFromToday)
        {
            $warningMsg = "Use $Runtime $defaultRuntimeVersion as $Runtime $RuntimeVersion will reach end-of-life on $formattedEOLDate"
            $warningMsg += " and will no longer be supported. Learn more: aka.ms/FunctionsStackUpgrade."
            Write-Warning $warningMsg
        }
    }

    return $runtimeJsonDefinition
}

function GetDefaultOrLatestRuntimeVersion {
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$true)]
        [Hashtable]
        $SupportedRuntimes,
        [Parameter(Mandatory=$true)]
        [String]
        $Runtime,
        [Parameter(Mandatory=$true)]
        [String]
        $FunctionsExtensionVersion
    )

    $defaultVersion = $SupportedRuntimes[$Runtime] |
        Where-Object { $_.IsDefault -and ($_.SupportedFunctionsExtensionVersions -contains $FunctionsExtensionVersion) } |
        Select-Object -First 1 -ExpandProperty Version

    if ($defaultVersion) {
        Write-Debug "$DEBUG_PREFIX Runtime '$Runtime' has a default version '$defaultVersion'"
        return $defaultVersion
    }

    Write-Debug "$DEBUG_PREFIX Runtime '$Runtime' does not have a default version. Finding the latest version."

    $latestVersion = $SupportedRuntimes[$Runtime] |
        Sort-Object -Property Version -Descending |
        Where-Object { $_.SupportedFunctionsExtensionVersions -contains $FunctionsExtensionVersion -and (-not $_.IsPreview) } |
        Select-Object -First 1 -ExpandProperty Version

    if ($latestVersion) {
        Write-Debug "$DEBUG_PREFIX Latest version for runtime '$Runtime' is '$latestVersion'"
    }
    else {
        Write-Debug "$DEBUG_PREFIX No latest version found for runtime '$Runtime'"
    }

    return $latestVersion
}

function ThrowRuntimeNotSupportedException
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Message,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ErrorId
    )

    $Message += [System.Environment]::NewLine
    $Message += "For supported languages, please visit 'https://learn.microsoft.com/azure/azure-functions/functions-versions#languages'."

    $exception = [System.InvalidOperationException]::New($Message)
    ThrowTerminatingError -ErrorId $ErrorId `
                          -ErrorMessage $Message `
                          -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                          -Exception $exception
}

function FormatListToString
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$true)]
        [System.String[]]
        $List
    )
    
    if ($List.Count -eq 0)
    {
        return
    }

    $result = ""

    if ($List.Count -eq 1)
    {
        $result = "'" + $List[0] + "'"
    }
    
    else
    {
        for ($index = 0; $index -lt ($List.Count - 1); $index++)
        {
            $item = $List[$index]
            $result += "'" + $item + "', "
        }

        $result += "'" + $List[$List.Count - 1] + "'"
    }
    
    return $result
}

function ValidatePlanLocation
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Location,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        [ValidateSet("Dynamic", "ElasticPremium")]
        $PlanType,

        [Parameter(Mandatory=$false)]
        [System.Management.Automation.SwitchParameter]
        $OSIsLinux,

        $SubscriptionId,
        $HttpPipelineAppend,
        $HttpPipelinePrepend
    )

    $paramsToRemove = @(
        "PlanType",
        "OSIsLinux",
        "Location"
    )
    foreach ($paramName in $paramsToRemove)
    {
        if ($PSBoundParameters.ContainsKey($paramName))
        {
            $PSBoundParameters.Remove($paramName)  | Out-Null
        }
    }

    $Location = $Location.Trim()
    $locationContainsSpace = $Location.Contains(" ")

    $availableLocations = @(Az.Functions.internal\Get-AzFunctionAppAvailableLocation -Sku $PlanType `
                                                                                     -LinuxWorkersEnabled:$OSIsLinux `
                                                                                     @PSBoundParameters | ForEach-Object { $_.Name })

    if (-not $locationContainsSpace)
    {
        $availableLocations = @($availableLocations | ForEach-Object { $_.Replace(" ", "") })
    }

    if (-not ($availableLocations -contains $Location))
    {
        $errorMessage = "Location is invalid. Use 'Get-AzFunctionAppAvailableLocation' to see available locations for running function apps."
        $exception = [System.InvalidOperationException]::New($errorMessage)
        ThrowTerminatingError -ErrorId "LocationIsInvalid" `
                              -ErrorMessage $errorMessage `
                              -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                              -Exception $exception
    }
}

function ValidatePremiumPlanLocation
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Location,

        [Parameter(Mandatory=$false)]
        [System.Management.Automation.SwitchParameter]
        $OSIsLinux,

        $SubscriptionId,
        $HttpPipelineAppend,
        $HttpPipelinePrepend
    )

    ValidatePlanLocation -PlanType ElasticPremium @PSBoundParameters
}

function ValidateConsumptionPlanLocation
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Location,

        [Parameter(Mandatory=$false)]
        [System.Management.Automation.SwitchParameter]
        $OSIsLinux,

        $SubscriptionId,
        $HttpPipelineAppend,
        $HttpPipelinePrepend
    )

    ValidatePlanLocation -PlanType Dynamic @PSBoundParameters
}

function GetParameterKeyValues
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$true)]
        [System.Collections.Generic.Dictionary[string, object]]
        [ValidateNotNull()]
        $PSBoundParametersDictionary,

        [Parameter(Mandatory=$true)]
        [System.String[]]
        [ValidateNotNull()]
        $ParameterList
    )

    $params = @{}
    if ($ParameterList.Count -gt 0)
    {
        foreach ($paramName in $ParameterList)
        {
            if ($PSBoundParametersDictionary.ContainsKey($paramName))
            {
                $params[$paramName] = $PSBoundParametersDictionary[$paramName]
            }
        }
    }
    return $params
}

function NewResourceTag
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [hashtable]
        $Tag
    )

    $resourceTag = [Microsoft.Azure.PowerShell.Cmdlets.Functions.Models.Api20231201.ResourceTags]::new()

    foreach ($tagName in $Tag.Keys)
    {
        $resourceTag.Add($tagName, $Tag[$tagName])
    }
    return $resourceTag
}

function ParseDockerImage
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $DockerImageName
    )

    # Sample urls:
    # myacr.azurecr.io/myimage:tag
    # mcr.microsoft.com/azure-functions/powershell:2.0
    if ($DockerImageName.Contains("/"))
    {
        $index = $DockerImageName.LastIndexOf("/")
        $value = $DockerImageName.Substring(0,$index)
        if ($value.Contains(".") -or $value.Contains(":"))
        {
            return $value
        }
    }
}

function GetFunctionAppServicePlanInfo
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ServerFarmId,

        $SubscriptionId,
        $HttpPipelineAppend,
        $HttpPipelinePrepend
    )

    if ($PSBoundParameters.ContainsKey("ServerFarmId"))
    {
        $PSBoundParameters.Remove("ServerFarmId") | Out-Null
    }

    $planInfo = $null

    if ($ServerFarmId.Contains("/"))
    {
        $parts = $ServerFarmId -split "/"

        $planName = $parts[-1]
        $resourceGroupName = $parts[-5]

        $planInfo = Az.Functions\Get-AzFunctionAppPlan -Name $planName `
                                                       -ResourceGroupName $resourceGroupName `
                                                       @PSBoundParameters
    }

    if (-not $planInfo)
    {
        $errorMessage = "Could not determine the current plan of the functionapp."
        $exception = [System.InvalidOperationException]::New($errorMessage)
        ThrowTerminatingError -ErrorId "CouldNotDetermineFunctionAppPlan" `
                            -ErrorMessage $errorMessage `
                            -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                            -Exception $exception

    }

    return $planInfo
}

function ValidatePlanSwitchCompatibility
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $CurrentServicePlan,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $NewServicePlan
    )

    if (-not (($CurrentServicePlan.SkuTier -eq "ElasticPremium") -or ($CurrentServicePlan.SkuTier -eq "Dynamic") -or
              ($NewServicePlan.SkuTier -eq "ElasticPremium") -or ($NewServicePlan.SkuTier -eq "Dynamic")))
    {
        $errorMessage = "Currently the switch is only allowed between a Consumption or an Elastic Premium plan."
        $exception = [System.InvalidOperationException]::New($errorMessage)
        ThrowTerminatingError -ErrorId "InvalidFunctionAppPlanSwitch" `
                              -ErrorMessage $errorMessage `
                              -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                              -Exception $exception
    }
}

function NewAppSettingObject
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [Hashtable]
        $CurrentAppSetting
    )

    # Create StringDictionaryProperties (hash table) with the app settings
    $properties = New-Object -TypeName Microsoft.Azure.PowerShell.Cmdlets.Functions.Models.Api20231201.StringDictionaryProperties

    foreach ($keyName in $currentAppSettings.Keys)
    {
        $properties.Add($keyName, $currentAppSettings[$keyName])
    }

    $appSettings = New-Object -TypeName Microsoft.Azure.PowerShell.Cmdlets.Functions.Models.Api20231201.StringDictionary
    $appSettings.Property = $properties

    return $appSettings
}

function ContainsReservedFunctionAppSettingName
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $AppSettingName
    )

    foreach ($name in $AppSettingName)
    {
        if ($ReservedFunctionAppSettingNames.Contains($name))
        {
            return $true
        }
    }

    return $false
}

function GetFunctionAppByName
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ResourceGroupName,

        $SubscriptionId,
        $HttpPipelineAppend,
        $HttpPipelinePrepend
    )

    $paramsToRemove = @(
        "Name",
        "ResourceGroupName"
    )
    foreach ($paramName in $paramsToRemove)
    {
        if ($PSBoundParameters.ContainsKey($paramName))
        {
            $PSBoundParameters.Remove($paramName)  | Out-Null
        }
    }

    $existingFunctionApp = Az.Functions\Get-AzFunctionApp -ResourceGroupName $ResourceGroupName `
                                                          -Name $Name `
                                                          -ErrorAction SilentlyContinue `
                                                          @PSBoundParameters

    if (-not $existingFunctionApp)
    {
        $errorMessage = "Function app name '$Name' in resource group name '$ResourceGroupName' does not exist."
        $exception = [System.InvalidOperationException]::New($errorMessage)
        ThrowTerminatingError -ErrorId "FunctionAppDoesNotExist" `
                              -ErrorMessage $errorMessage `
                              -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                              -Exception $exception
    }

    return $existingFunctionApp
}
function GetAzWebAppConfig
{

    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ResourceGroupName,

        [Switch]
        $ErrorIfResultIsNull,

        $SubscriptionId,
        $HttpPipelineAppend,
        $HttpPipelinePrepend
    )

    if ($PSBoundParameters.ContainsKey("ErrorIfResultIsNull"))
    {
        $PSBoundParameters.Remove("ErrorIfResultIsNull") | Out-Null
    }

    $resetDefaultSubscription = $false
    $webAppConfig = $null
    $currentSubscription = $null
    try
    {
        $webAppConfig = Az.Functions.internal\Get-AzWebAppConfiguration -ErrorAction SilentlyContinue `
                                                                        @PSBoundParameters

        if ($null -eq $webAppConfig)
        {
            Write-Warning -Message "Failed to retrieve function app site config. 1st attempt"
            Write-Warning -Message "Setting session context to subscription id '$($SubscriptionId)'"

            $resetDefaultSubscription = $true
            $currentSubscription = (Get-AzContext).Subscription.Id
            $null = Select-AzSubscription $SubscriptionId

            $webAppConfig = Az.Functions.internal\Get-AzWebAppConfiguration -ResourceGroupName $ResourceGroupName `
                                                                            -Name $Name `
                                                                            -ErrorAction SilentlyContinue `
                                                                            @PSBoundParameters
            if ($null -eq $webAppConfig)
            {
                Write-Warning -Message "Failed to retrieve function app site config. 2nd attempt."
            }
        }
    }
    finally
    {
        if ($resetDefaultSubscription)
        {
            Write-Warning -Message "Resetting session context to subscription id '$currentSubscription'"
            $null = Select-AzSubscription $currentSubscription
        }
    }

    if ((-not $webAppConfig) -and $ErrorIfResultIsNull)
    {
        $errorMessage = "Falied to get config for function app name '$Name' in resource group name '$ResourceGroupName'."
        $exception = [System.InvalidOperationException]::New($errorMessage)
        ThrowTerminatingError -ErrorId "FaliedToGetFunctionAppConfig" `
                              -ErrorMessage $errorMessage `
                              -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                              -Exception $exception
    }

    return $webAppConfig
}

function NewIdentityUserAssignedIdentity
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String[]]
        $IdentityID
    )

    # If creating user assigned identities, only alphanumeric characters (0-9, a-z, A-Z), the underscore (_) and the hyphen (-) are supported.
    $msiUserAssignedIdentities = New-Object -TypeName Microsoft.Azure.PowerShell.Cmdlets.Functions.Models.Api20231201.ManagedServiceIdentityUserAssignedIdentities

    foreach ($id in $IdentityID)
    {
        $functionAppUserAssignedIdentitiesValue = New-Object -TypeName Microsoft.Azure.PowerShell.Cmdlets.Functions.Models.Api20231201.ManagedServiceIdentityUserAssignedIdentities
        $msiUserAssignedIdentities.Add($id, $functionAppUserAssignedIdentitiesValue)
    }

    return $msiUserAssignedIdentities
}

function GetShareSuffix
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Int]
        $Length = 8
    )

    # Create char array from 'a' to 'z'
    $letters = 97..122 | ForEach-Object { [char]$_ }
    $numbers = 0..9
    $alphanumericLowerCase = $letters + $numbers

    $suffix = [System.Text.StringBuilder]::new()

    for ($index = 0; $index -lt $Length; $index++)
    {
        $value = $alphanumericLowerCase | Get-Random
        $suffix.Append($value) | Out-Null
    }

    $suffix.ToString()
}

function GetShareName
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $FunctionAppName
    )

    $FunctionAppName = $FunctionAppName.ToLower()

    if ($env:FunctionsTestMode)
    {
        # To support the tests' playback mode, we need to have the same values for each function app creation payload.
        # Adding this test hook will allows us to have a constant share name when creation an app.

        return $FunctionAppName
    }

    <#
    Share name restrictions:
        - A share name must be a valid DNS name.
        - Share names must start with a letter or number, and can contain only letters, numbers, and the dash (-) character.
        - Every dash (-) character must be immediately preceded and followed by a letter or number; consecutive dashes are not permitted in share names.
        - All letters in a share name must be lowercase.
        - Share names must be from 3 through 63 characters long.

    Docs: https://learn.microsoft.com/en-us/rest/api/storageservices/naming-and-referencing-shares--directories--files--and-metadata#share-names
    #>

    # Share name will be function app name + 8 random char suffix with a max length of 60
    $MAXLENGTH = 60
    $SUFFIXLENGTH = 8
    if (($FunctionAppName.Length + $SUFFIXLENGTH) -lt $MAXLENGTH)
    {
        $name = $FunctionAppName
    }
    else
    {
        $endIndex = $MAXLENGTH - $SUFFIXLENGTH - 1
        $name = $FunctionAppName.Substring(0, $endIndex)
    }

    $suffix = GetShareSuffix -Length $SUFFIXLENGTH
    $shareName = $name + $suffix

    return $shareName
}

Class Runtime
{
    [string]$Name
    [string]$FullName
    [string]$Version
    [bool]$IsPreview
    [string[]]$SupportedFunctionsExtensionVersions
    [hashtable]$AppSettingsDictionary
    [hashtable]$SiteConfigPropertiesDictionary
    [bool]$IsHidden
    [bool]$IsDefault
    [string]$PreferredOs
    [hashtable]$AppInsightsSettings
    [Nullable[datetime]]$EndOfLifeDate
}

function GetBuiltInFunctionAppStacksDefinition
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$false)]
        [Switch]
        $DoNotShowWarning
    )

    if (-not $DoNotShowWarning)
    {
        $warmingMessage = "Failed to get Function App Stack definitions from ARM API. "
        $warmingMessage += "Please open an issue at https://github.com/Azure/azure-powershell/issues with the following title: "
        $warmingMessage += "[Az.Functions] Failed to get Function App Stack definitions from ARM API."
        Write-Warning $warmingMessage
    }

    $filePath = "$PSScriptRoot/FunctionsStack/functionAppStacks.json"
    $json = Get-Content -Path $filePath -Raw

    return $json
}

# Get the Function App Stack definition from the ARM API using the current Azure session
#
function GetFunctionAppStackDefinition
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param ()

    if ($env:FunctionsTestMode -or ($null -ne $env:SYSTEM_DEFINITIONID -or $null -ne $env:Release_DefinitionId -or $null -ne $env:AZUREPS_HOST_ENVIRONMENT))
    {
        Write-Debug "$DEBUG_PREFIX Running on test mode. Using built in json file definition."
        $json = GetBuiltInFunctionAppStacksDefinition -DoNotShowWarning
        return $json
    }

    # Make sure there is an active Azure session
    $context = Get-AzContext -ErrorAction SilentlyContinue
    if (-not $context)
    {
        $errorMessage = "There is no active Azure PowerShell session. Please run 'Connect-AzAccount'"
        $exception = [System.InvalidOperationException]::New($errorMessage)
        ThrowTerminatingError -ErrorId "LoginToAzureViaConnectAzAccount" `
                              -ErrorMessage $errorMessage `
                              -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                              -Exception $exception
    }

    # Get the ResourceManagerUrl
    $resourceManagerUrl = $context.Environment.ResourceManagerUrl
    if ([string]::IsNullOrWhiteSpace($resourceManagerUrl))
    {
        Write-Debug "$DEBUG_PREFIX context does not have a ResourceManagerUrl. Using built in json file definition."
        $json = GetBuiltInFunctionAppStacksDefinition
        return $json
    }

    if (-not $resourceManagerUrl.EndsWith('/'))
    {
        $resourceManagerUrl += '/'
    }

    Write-Debug "$DEBUG_PREFIX Get AccessToken."
    $token =  . "$PSScriptRoot/../utils/Unprotect-SecureString.ps1" (Get-AzAccessToken -AsSecureString).Token
    $headers = @{
        Authorization="Bearer $token"
    }

    $params = @{
        stackOsType = 'All'
        removeDeprecatedStacks = 'true'
    }

    $apiEndPoint = $resourceManagerUrl + "providers/Microsoft.Web/functionAppStacks?api-version=2020-10-01"

    $maxNumberOfTries = 3
    $currentCount = 1

    Write-Debug "$DEBUG_PREFIX Set TLS 1.2"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    do
    {
        $result = $null
        try
        {
            Write-Debug "$DEBUG_PREFIX Pull down Function App Stack definitions from ARM API. Attempt $currentCount of $maxNumberOfTries."
            $result = Invoke-WebRequest -Uri $apiEndPoint -Method Get -Headers $headers -body $params -ErrorAction Stop
        }
        catch
        {
            $exception = $_
            Write-Debug "$DEBUG_PREFIX Failed to get Function App Stack definitions from ARM API. Attempt $currentCount of $maxNumberOfTries. Error: $($exception.Message)"
        }

        if ($result)
        {
            # Unauthorized
            if ($result.StatusCode -eq 401)
            {
                # Get a new access token, create new headers and retry
                $token =  . "$PSScriptRoot/../utils/Unprotect-SecureString.ps1" (Get-AzAccessToken -AsSecureString).Token

                $headers = @{
                    Authorization = "Bearer $token"
                }
            }

            if ($result.StatusCode -eq 200)
            {
                $stackDefinition = $result.Content | ConvertFrom-Json

                return $stackDefinition.value | ConvertTo-Json -Depth 100
            }
        }

        $currentCount++

    } while ($currentCount -le $maxNumberOfTries)


    # At this point, we failed to get the stack definition from the ARM API.
    # Return the built in json file definition
    $json = GetBuiltInFunctionAppStacksDefinition
    return $json
}

function ContainsProperty
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.Object]
        $Object,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $PropertyName
    )

    $result = $Object | Get-Member -MemberType Properties | Where-Object { $_.Name -eq $PropertyName }
    return ($null -ne $result)
}

function ParseMinorVersion
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$false)]
        [System.String]
        $StackMinorVersion,

        [Parameter(Mandatory=$false)]
        [System.String]
        $PreferredOs,

        [Parameter(Mandatory=$true)]
        [PSCustomObject]
        $RuntimeSettings,

        [Parameter(Mandatory=$false)]
        [System.String]
        $RuntimeFullName,

        [Parameter(Mandatory=$false)]
        [Bool]
        $StackIsLinux
    )

    # If this FunctionsVersion is not supported, skip it
    if ($RuntimeSettings.supportedFunctionsExtensionVersions -notcontains "~$DefaultFunctionsVersion")
    {
        $supportedFunctionsExtensionVersions = $RuntimeSettings.supportedFunctionsExtensionVersions -join ", "
        Write-Debug "$DEBUG_PREFIX Minimium required Functions version '$DefaultFunctionsVersion' is not supported. Runtime supported Functions versions: $supportedFunctionsExtensionVersions. Skipping..."
        return
    }
    else
    {
        Write-Debug "$DEBUG_PREFIX Minimium required Functions version '$DefaultFunctionsVersion' is supported."
    }

    $runtimeName = GetRuntimeName -AppSettingsDictionary $RuntimeSettings.AppSettingsDictionary

    $version = $null
    if ($RuntimeName -eq "Java" -and $RuntimeSettings.RuntimeVersion -eq "1.8")
    {
        # Java 8 is only supported in Windows. The display value is 8; however, the actual SiteConfig.JavaVersion is 1.8
        $version = $StackMinorVersion
    }
    else
    {
        $version = $RuntimeSettings.RuntimeVersion
    }

    $runtimeVersion = GetRuntimeVersion -Version $version -StackIsLinux $StackIsLinux

    # For Java function app, the version from the Stacks API is 8.0, 11.0, and 17.0. However, this is a breaking change which cannot be supported in the current release.
    # We will convert the version to 8, 11, and 17. This change will be reverted for the May 2024 breaking release.
    if ($RuntimeName -eq "Java")
    {
        $runtimeVersion = [int]$runtimeVersion
        Write-Debug "$DEBUG_PREFIX Runtime version for Java is modified to be compatible with the current release. Current version '$runtimeVersion'"
    }

    # For DotNet function app, the version from the Stacks API is 6.0. 7.0, and 8.0. However, this is a breaking change which cannot be supported in the current release.
    # We will convert the version to 6, 7, and 8. This change will be reverted for the May 2024 breaking release.
    if ($RuntimeName -like "DotNet*")
    {
        if ($runtimeVersion.EndsWith(".0"))
        {
            $runtimeVersion = [int]$runtimeVersion
        }
        Write-Debug "$DEBUG_PREFIX Runtime version for $runtimeName is modified to be compatible with the current release. Current version '$runtimeVersion'"
    }

    $runtime = [Runtime]::new()
    $runtime.Name = $runtimeName
    $runtime.AppSettingsDictionary = GetDictionary -SettingsDictionary $RuntimeSettings.AppSettingsDictionary
    $runtime.SiteConfigPropertiesDictionary = GetDictionary -SettingsDictionary $RuntimeSettings.SiteConfigPropertiesDictionary
    $runtime.AppInsightsSettings = GetDictionary -SettingsDictionary $RuntimeSettings.AppInsightsSettings
    $runtime.SupportedFunctionsExtensionVersions = GetSupportedFunctionsExtensionVersion -SupportedFunctionsExtensionVersions $RuntimeSettings.SupportedFunctionsExtensionVersions
    $runtime.EndOfLifeDate = $null

    if (![string]::IsNullOrWhiteSpace($RuntimeSettings.EndOfLifeDate))
    {
        $runtime.EndOfLifeDate = ParseEndOfLifeDate -Runtime $runtimeName -DateString $RuntimeSettings.EndOfLifeDate
    }

    foreach ($propertyName in @("isPreview", "isHidden", "isDefault"))
    {
        if (ContainsProperty -Object $RuntimeSettings -PropertyName $propertyName)
        {
            Write-Debug "$DEBUG_PREFIX Runtime setting contains '$propertyName'"
            $runtime.$propertyName = $RuntimeSettings.$propertyName
        }
    }

    # When $env:FunctionsDisplayHiddenRuntimes is set to true, we will display all runtimes
    if ($runtime.IsHidden -and (-not $env:FunctionsDisplayHiddenRuntimes))
    {
        Write-Debug "$DEBUG_PREFIX Runtime $runtimeName is hidden. Skipping..."
        return
    }

    if ($runtimeVersion -and ($runtimeName -ne "custom"))
    {
        Write-Debug "$DEBUG_PREFIX Runtime version: $runtimeVersion"
        $runtime.Version = $runtimeVersion
    }
    else
    {
        Write-Debug "$DEBUG_PREFIX Runtime $runtimeName does not have a version."
        $runtime.Version = ""
    }

    if ($RuntimeFullName)
    {
        $runtime.FullName = $RuntimeFullName
    }

    if ($PreferredOs)
    {
        $runtime.PreferredOs = $PreferredOs
    }

    $targetOs = if ($StackIsLinux) { 'Linux' } else { 'Windows' }
    Write-Debug "$DEBUG_PREFIX Runtime '$runtimeName' for '$targetOs' parsed successfully."

    return $runtime
}


function GetRuntimeVersion
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$false)]
        [System.String]
        $Version,

        [Parameter(Mandatory=$false)]
        [Bool]
        $StackIsLinux
    )

    if (-not $Version)
    {
        # Some runtimes do not have a version like custom handler
        return
    }

    if ($StackIsLinux)
    {
        $Version = $Version.Split('|')[1]
    }
    else
    {
        $valuesToReplace = @('v', '~')
        foreach ($value in $valuesToReplace)
        {
            if ($Version.Contains($value))
            {
                $Version = $Version.Replace($value, '')
            }
        }
    }

    $Version =  $Version.Trim()
    return $Version
}

function GetDictionary
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$true)]
        [PSCustomObject]
        $SettingsDictionary
    )

    $dictionary = @{}
    foreach ($property in $SettingsDictionary.PSObject.Properties)
    {
        $dictionary.Add($property.Name, $property.Value)
    }

    return $dictionary
}

function GetRuntimeName
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$true)]
        [PSCustomObject]
        $AppSettingsDictionary
    )

    $settingHashTable = GetDictionary -SettingsDictionary $AppSettingsDictionary

    $name = $settingHashTable['FUNCTIONS_WORKER_RUNTIME']

    if ($RuntimeToFormattedName.ContainsKey($name))
    {
        return $RuntimeToFormattedName[$name]
    }

    return $name
}

function GetSupportedFunctionsExtensionVersion
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String[]]
        $SupportedFunctionsExtensionVersions
    )

    $supportedExtensionsVersions = @()

    foreach ($extensionVersion in $SupportedFunctionsExtensionVersions)
    {
        if ($extensionVersion -ge "~$DefaultFunctionsVersion")
        {
            $supportedExtensionsVersions += $extensionVersion
        }
    }

    return $supportedExtensionsVersions
}

function AddRuntimeToDictionary
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$true)]
        $Runtime,

        [Parameter(Mandatory=$true)]
        [hashtable]
        [Ref]$RuntimeToVersionDictionary
    )

    if ($RuntimeToVersionDictionary.ContainsKey($Runtime.Name))
    {
        $list = $RuntimeToVersionDictionary[$Runtime.Name]
    }
    else
    {
        $list = New-Object System.Collections.Generic.List[[Runtime]]
    }

    $list.Add($Runtime)
    $RuntimeToVersionDictionary[$Runtime.Name] = $list

    # Add the runtime name and version to the all runtimes list. This is used for the tab completers
    if ($AllRuntimeVersions.ContainsKey($runtime.Name))
    {
        $allVersionsList = $AllRuntimeVersions[$Runtime.Name]
    }
    else
    {
        $allVersionsList = @()
    }

    if (-not $allVersionsList.Contains($Runtime.Version))
    {
        $allVersionsList += $Runtime.Version
        $AllRuntimeVersions[$Runtime.name] = $allVersionsList
    }

    # Add Functions extension version to AllFunctionsExtensionVersions. This is used for the tab completers
    foreach ($extensionVersion in $Runtime.SupportedFunctionsExtensionVersions)
    {
        $version = $extensionVersion.Replace("~", "")
        if (-not $AllFunctionsExtensionVersions.Contains($version))
        {
            $AllFunctionsExtensionVersions.Add($version)
        }
    }
}

function SetLinuxandWindowsSupportedRuntimes
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param ()

    Write-Debug "$DEBUG_PREFIX Build function stack definitions."

    # Get Function App Runtime Definitions
    $json = GetFunctionAppStackDefinition
    $functionAppStackDefinition = $json | ConvertFrom-Json

    # Build a map of runtime -> runtime version -> runtime version properties
    foreach ($stackDefinition in $functionAppStackDefinition)
    {
        $preferredOs = $stackDefinition.properties.preferredOs

        $stackName = $stackDefinition.properties.value
        Write-Debug "$DEBUG_PREFIX Parsing stack name: $stackName"

        foreach ($majorVersion in $stackDefinition.properties.majorVersions)
        {
            foreach ($minorVersion in $majorVersion.minorVersions)
            {
                $runtimeFullName = $minorVersion.DisplayText
                Write-Debug "$DEBUG_PREFIX runtime full name: $runtimeFullName"

                $stackMinorVersion = $minorVersion.value
                Write-Debug "$DEBUG_PREFIX stack minor version: $stackMinorVersion"
                $runtime = $null

                if (ContainsProperty -Object $minorVersion.stackSettings -PropertyName "windowsRuntimeSettings")
                {
                    $runtime = ParseMinorVersion -RuntimeSettings $minorVersion.stackSettings.windowsRuntimeSettings `
                                                 -RuntimeFullName $runtimeFullName `
                                                 -PreferredOs $preferredOs `
                                                 -StackMinorVersion $stackMinorVersion

                    if ($runtime)
                    {
                        AddRuntimeToDictionary -Runtime $runtime -RuntimeToVersionDictionary ([Ref]$RuntimeToVersionWindows)
                    }
                }

                if (ContainsProperty -Object $minorVersion.stackSettings -PropertyName "linuxRuntimeSettings")
                {
                    $runtime = ParseMinorVersion -RuntimeSettings $minorVersion.stackSettings.linuxRuntimeSettings `
                                                 -RuntimeFullName $runtimeFullName `
                                                 -PreferredOs $preferredOs `
                                                 -StackIsLinux $true

                    if ($runtime)
                    {
                        AddRuntimeToDictionary -Runtime $runtime -RuntimeToVersionDictionary ([Ref]$RuntimeToVersionLinux)
                    }
                }
            }
        }
    }
}

# This method pulls down the Functions stack definitions from the ARM API and builds a list of supported runtimes and runtime versions.
# This is used to build the tab completers for the New-AzFunctionApp cmdlet.
function RegisterFunctionsTabCompleters
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param ()

    if (-not $global:StacksAndTabCompletersInitialized)
    {
        SetLinuxandWindowsSupportedRuntimes

        # New-AzFunction app ArgumentCompleter for the RuntimeVersion parameter
        # The values of RuntimeVersion depend on the selection of the Runtime parameter
        $GetRuntimeVersionCompleter = {

            param ($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

            if ($fakeBoundParameters.ContainsKey('Runtime'))
            {
                # RuntimeVersions is defined in SetLinuxandWindowsSupportedRuntimes
                $AllRuntimeVersions[$fakeBoundParameters.Runtime] | Where-Object {
                    $_ -like "$wordToComplete*"
                } | ForEach-Object { [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_) }
            }
        }

        # New-AzFunction app ArgumentCompleter for the Runtime parameter
        $GetAllRuntimesCompleter = {

            param ($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

            $runtimeValues = $AllRuntimeVersions.Keys | Sort-Object | ForEach-Object { $_ }

            $runtimeValues | Where-Object { $_ -like "$wordToComplete*" }
        }

        # New-AzFunction app ArgumentCompleter for the Runtime parameter
        $GetAllFunctionsVersionsCompleter = {

            param ($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

            $functionsVersions = $AllFunctionsExtensionVersions | Sort-Object | ForEach-Object { $_ }

            $functionsVersions | Where-Object { $_ -like "$wordToComplete*" }
        }

        # Register tab completers
        Register-ArgumentCompleter -CommandName New-AzFunctionApp -ParameterName FunctionsVersion -ScriptBlock $GetAllFunctionsVersionsCompleter
        Register-ArgumentCompleter -CommandName New-AzFunctionApp -ParameterName Runtime -ScriptBlock $GetAllRuntimesCompleter
        Register-ArgumentCompleter -CommandName New-AzFunctionApp -ParameterName RuntimeVersion -ScriptBlock $GetRuntimeVersionCompleter

        $global:StacksAndTabCompletersInitialized = $true
    }
}

function ValidateCpuAndMemory
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$false)]
        [Double]
        $ResourceCpu,

        [Parameter(Mandatory=$false)]
        [System.String]
        $ResourceMemory
    )

    if (-not $ResourceCpu -and -not $ResourceMemory)
    {
        return
    }

    if ($ResourceCpu -and -not $ResourceMemory)
    {
        $errorMessage = "ResourceMemory must be specified when ResourceCpu is specified."
        $exception = [System.InvalidOperationException]::New($errorMessage)
        ThrowTerminatingError -ErrorId "ResourceMemoryNotSpecified" `
                              -ErrorMessage $errorMessage `
                              -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                              -Exception $exception
    }

    if ($ResourceMemory -and -not $ResourceCpu)
    {
        $errorMessage = "ResourceCpu must be specified when ResourceMemory is specified."
        $exception = [System.InvalidOperationException]::New($errorMessage)
        ThrowTerminatingError -ErrorId "ResourceCpuNotSpecified" `
                              -ErrorMessage $errorMessage `
                              -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                              -Exception $exception
    }

    try
    {
        if (-not $ResourceMemory.ToLower().EndsWith("gi"))
        {
            throw
        }

        # Attempt to parse the numerical part of ResourceMemory to ensure it's a valid format.
        [double]::Parse($ResourceMemory.Substring(0, $ResourceMemory.Length - 2)) | Out-Null
    }
    catch
    {
        $errorMessage = "ResourceMemory must be specified in Gi. Please provide a correct value. e.g., 4.0Gi."
        $exception = [System.InvalidOperationException]::New($errorMessage)
        ThrowTerminatingError -ErrorId "InvalidResourceMemory" `
                              -ErrorMessage $errorMessage `
                              -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                              -Exception $exception
    }
}

function FormatFxVersion
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Image
    )

    $fxVersion = $Image

    # Normalize case and remove HTTP(s) prefixes if present.
    $normalizedImage = $Image -replace '^(https?://)', '' -replace ' ', ''

    # Prepend "DOCKER|" if not already prefixed with "docker|" (case-insensitive).
    if (-not $normalizedImage.StartsWith('docker|', [StringComparison]::OrdinalIgnoreCase))
    {
        $fxVersion = "DOCKER|$Image"
    }

    return $fxVersion
}

function GetManagedEnvironment
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Environment,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ResourceGroupName
    )

    $azAppModuleName = "Az.App"
    if (-not (Get-Module -ListAvailable -Name $azAppModuleName))
    {
        $errorMessage = "The '$azAppModuleName' module is required when creating Function Apps ACA. Please install the module and try again."
        $exception = [System.InvalidOperationException]::New($errorMessage)
        ThrowTerminatingError -ErrorId "RequiredModuleNotAvailable" `
                              -ErrorMessage $errorMessage `
                              -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                              -Exception $exception
    }

    Import-Module -Name $azAppModuleName -Force -ErrorAction Stop

    $managedEnv = Get-AzContainerAppManagedEnv -Name $Environment `
                                               -ResourceGroupName $ResourceGroupName `
                                               -ErrorAction SilentlyContinue

    if (-not $managedEnv)
    {
        $errorMessage = "Failed to get the managed environment '$Environment' in resource group name '$ResourceGroupName'."
        $errorMessage += " Please make sure the managed environment is valid."
        $exception = [System.InvalidOperationException]::New($errorMessage)
        ThrowTerminatingError -ErrorId "FailedToGetEnvironment" `
                              -ErrorMessage $errorMessage `
                              -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                              -Exception $exception
    }

    return $managedEnv
}

function ParseEndOfLifeDate
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Runtime,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $DateString
    )

    try
    {
        $dateTime = [DateTime]::ParseExact($DateString, "ddd MMM dd yyyy HH:mm:ss 'GMT'K '(Coordinated Universal Time)'",
                                           [System.Globalization.CultureInfo]::InvariantCulture)
    }
    catch
    {
        $message = "Failed to parse the EndOfLifeDate '$DateString' for '$Runtime' runtime. Skipping..."
        Write-Warning $message
    }

    return $dateTime
}

function Get-Today {
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param ()

    if ($env:FunctionsTestMode)
    {
        # Test hook to support running the tests in playback mode.
        return [datetime]"2024-01-01"
    }
    return Get-Date
}

# SIG # Begin signature block
# MIIoOQYJKoZIhvcNAQcCoIIoKjCCKCYCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDaaMl4br3GbmJ0
# 8XNvAHW0ALaZmWIsOdUZr/eWZfjF+qCCDYUwggYDMIID66ADAgECAhMzAAAEA73V
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
# cVZOSEXAQsmbdlsKgEhr/Xmfwb1tbWrJUnMTDXpQzTGCGgowghoGAgEBMIGVMH4x
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01p
# Y3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTECEzMAAAQDvdWVXQ87GK0AAAAA
# BAMwDQYJYIZIAWUDBAIBBQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIFX7
# mhxCZciPLVC+5fklzYqwy//IQ3X3ztoGr9bHVpFjMEIGCisGAQQBgjcCAQwxNDAy
# oBSAEgBNAGkAYwByAG8AcwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20wDQYJKoZIhvcNAQEBBQAEggEAjhEwmVXGlUnVUKKSM0Hsce2ws0SrMq63nWEv
# QvE9xLE62cTvwbGFjbga6lKMH5KAGNWrfqqb9qYZ8m+MRKxSvr3UHXc5f5j0gyQk
# mdfRuUB86kBPiTsuNvZddQ0n5mQPh6GJieZxiWX5o0+iGoLfX8O5vi965Ej5qyAg
# BqjMDjmLuv2D6mBntbzPekQpylMvCsPHlVlifq4cwoGANEy7C6SSsvKdtzudOmx0
# TZ3F9fsc0Auwj7Po/7X0noWDAqqlcUUNnmvEkF0EnbpdkP1pTtY0QqTPOiLgibpS
# 8qdCzHqXZFrCaFPeDC0fTMZ+mpz2n7Tn9rd3+PSbvY8ffWibQqGCF5QwgheQBgor
# BgEEAYI3AwMBMYIXgDCCF3wGCSqGSIb3DQEHAqCCF20wghdpAgEDMQ8wDQYJYIZI
# AWUDBAIBBQAwggFSBgsqhkiG9w0BCRABBKCCAUEEggE9MIIBOQIBAQYKKwYBBAGE
# WQoDATAxMA0GCWCGSAFlAwQCAQUABCDIVPbRFnlpcNdnvUijHESU8VpzlIpHcMH8
# 1op+HlH6FgIGaBjB/gjNGBMyMDI1MDUxNDA5MTkwOC44NjdaMASAAgH0oIHRpIHO
# MIHLMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQL
# ExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxk
# IFRTUyBFU046OTIwMC0wNUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1l
# LVN0YW1wIFNlcnZpY2WgghHqMIIHIDCCBQigAwIBAgITMwAAAgkIB+D5XIzmVQAB
# AAACCTANBgkqhkiG9w0BAQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAx
# MDAeFw0yNTAxMzAxOTQyNTVaFw0yNjA0MjIxOTQyNTVaMIHLMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1l
# cmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046OTIwMC0w
# NUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2Uw
# ggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDClEow9y4M3f1S9z1xtNEE
# TwWL1vEiiw0oD7SXEdv4sdP0xsVyidv6I2rmEl8PYs9LcZjzsWOHI7dQkRL28GP3
# CXcvY0Zq6nWsHY2QamCZFLF2IlRH6BHx2RkN7ZRDKms7BOo4IGBRlCMkUv9N9/tw
# OzAkpWNsM3b/BQxcwhVgsQqtQ8NEPUuiR+GV5rdQHUT4pjihZTkJwraliz0ZbYpU
# TH5Oki3d3Bpx9qiPriB6hhNfGPjl0PIp23D579rpW6ZmPqPT8j12KX7ySZwNuxs3
# PYvF/w13GsRXkzIbIyLKEPzj9lzmmrF2wjvvUrx9AZw7GLSXk28Dn1XSf62hbkFu
# UGwPFLp3EbRqIVmBZ42wcz5mSIICy3Qs/hwhEYhUndnABgNpD5avALOV7sUfJrHD
# ZXX6f9ggbjIA6j2nhSASIql8F5LsKBw0RPtDuy3j2CPxtTmZozbLK8TMtxDiMCgx
# Tpfg5iYUvyhV4aqaDLwRBsoBRhO/+hwybKnYwXxKeeOrsOwQLnaOE5BmFJYWBOFz
# 3d88LBK9QRBgdEH5CLVh7wkgMIeh96cH5+H0xEvmg6t7uztlXX2SV7xdUYPxA3vj
# jV3EkV7abSHD5HHQZTrd3FqsD/VOYACUVBPrxF+kUrZGXxYInZTprYMYEq6UIG1D
# T4pCVP9DcaCLGIOYEJ1g0wIDAQABo4IBSTCCAUUwHQYDVR0OBBYEFEmL6NHEXTjl
# vfAvQM21dzMWk8rSMB8GA1UdIwQYMBaAFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMF8G
# A1UdHwRYMFYwVKBSoFCGTmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMv
# Y3JsL01pY3Jvc29mdCUyMFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNybDBs
# BggrBgEFBQcBAQRgMF4wXAYIKwYBBQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0
# LmNvbS9wa2lvcHMvY2VydHMvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUy
# MDIwMTAoMSkuY3J0MAwGA1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUH
# AwgwDgYDVR0PAQH/BAQDAgeAMA0GCSqGSIb3DQEBCwUAA4ICAQBcXnxvODwk4h/j
# bUBsnFlFtrSuBBZb7wSZfa5lKRMTNfNlmaAC4bd7Wo0I5hMxsEJUyupHwh4kD5qk
# RZczIc0jIABQQ1xDUBa+WTxrp/UAqC17ijFCePZKYVjNrHf/Bmjz7FaOI41kxueR
# hwLNIcQ2gmBqDR5W4TS2htRJYyZAs7jfJmbDtTcUOMhEl1OWlx/FnvcQbot5VPza
# UwiT6Nie8l6PZjoQsuxiasuSAmxKIQdsHnJ5QokqwdyqXi1FZDtETVvbXfDsofzT
# ta4en2qf48hzEZwUvbkz5smt890nVAK7kz2crrzN3hpnfFuftp/rXLWTvxPQcfWX
# iEuIUd2Gg7eR8QtyKtJDU8+PDwECkzoaJjbGCKqx9ESgFJzzrXNwhhX6Rc8g2EU/
# +63mmqWeCF/kJOFg2eJw7au/abESgq3EazyD1VlL+HaX+MBHGzQmHtvOm3Ql4wVT
# N3Wq8X8bCR68qiF5rFasm4RxF6zajZeSHC/qS5336/4aMDqsV6O86RlPPCYGJOPt
# f2MbKO7XJJeL/UQN0c3uix5RMTo66dbATxPUFEG5Ph4PHzGjUbEO7D35LuEBiiG8
# YrlMROkGl3fBQl9bWbgw9CIUQbwq5cTaExlfEpMdSoydJolUTQD5ELKGz1TJahTi
# dd20wlwi5Bk36XImzsH4Ys15iXRfAjCCB3EwggVZoAMCAQICEzMAAAAVxedrngKb
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
# ELQdVTNYs6FwZvKhggNNMIICNQIBATCB+aGB0aSBzjCByzELMAkGA1UEBhMCVVMx
# EzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoT
# FU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjElMCMGA1UECxMcTWljcm9zb2Z0IEFtZXJp
# Y2EgT3BlcmF0aW9uczEnMCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOjkyMDAtMDVF
# MC1EOTQ3MSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloiMK
# AQEwBwYFKw4DAhoDFQB8762rPTQd7InDCQdb1kgFKQkCRKCBgzCBgKR+MHwxCzAJ
# BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jv
# c29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwMA0GCSqGSIb3DQEBCwUAAgUA6850kDAi
# GA8yMDI1MDUxNDAxNDY1NloYDzIwMjUwNTE1MDE0NjU2WjB0MDoGCisGAQQBhFkK
# BAExLDAqMAoCBQDrznSQAgEAMAcCAQACAjNSMAcCAQACAhKEMAoCBQDrz8YQAgEA
# MDYGCisGAQQBhFkKBAIxKDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMHoSChCjAI
# AgEAAgMBhqAwDQYJKoZIhvcNAQELBQADggEBAFPlPQBCDdLlCdr/p14GCAcDWqKa
# xgnnFcHOvozv0Xl71i1Hty6H0wxMysi2np0sGXi1N2dOHKT8fgdQFsv6Tr5VzvbR
# LWW0ajto0u7+iq815hjW+fq0P+uCMbGB2B28N4KnbocPWcBIh04p4wCtnMQ698pI
# H4IcqiqDRnWEDzLnGMLYU1F1xsE+ixGP04HmAtfXQmNNd2R6soQfXaN2EQIAU+AX
# g7QIILAk4S3+gNKszrz8j7/wSInxgfPMBfnwmPCbu7oAtsZnX8y2FUWw4KdrRJI+
# Jp2S2kd2G13m8tVZ41UhnERrsRM9cvINbQ+QKLtZsTEQmyOVh9kk6XGzIdkxggQN
# MIIECQIBATCBkzB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQ
# MA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9u
# MSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAgkI
# B+D5XIzmVQABAAACCTANBglghkgBZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkDMQ0G
# CyqGSIb3DQEJEAEEMC8GCSqGSIb3DQEJBDEiBCDb5mhJomlVsW5y7FSy8gxPYOzJ
# ObbmtVXqfKqPCMmDKzCB+gYLKoZIhvcNAQkQAi8xgeowgecwgeQwgb0EIGgbLB7I
# vfQCLmUOUZhjdUqK8bikfB6ZVVdoTjNwhRM+MIGYMIGApH4wfDELMAkGA1UEBhMC
# VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNV
# BAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRp
# bWUtU3RhbXAgUENBIDIwMTACEzMAAAIJCAfg+VyM5lUAAQAAAgkwIgQgbmsgFSOI
# cxiykQgNGN0J/4WscrqPBT4MP20btzoCWYIwDQYJKoZIhvcNAQELBQAEggIAiuZ1
# AB204lLAppn2Lr1thdnt0PyVPIMmQjxp73TdhPwrcz4jK+WqBukI/eRlcYkRvMmo
# SRnq0witiJjjqD8yradaST7AUQH2pVwnSuynEgrfHni0QYdQ2is3deXsmRkW0UjA
# egTQVSMb+jk8IZy+n6nxJ+HLIYcEg1hVlS6jWaqfXfZp7NFPAtLgzzlAYOwSlPp+
# EhssMUh4grTL2rl1L+64e7lhYM09ZBZyiX6Gwem3af4SY0+aAd5SMmJxOigICvRs
# wg28PzXgfaV0+jwyvSiWvnhBfvG2+HFpYHlRVkXHRNt5oYVcb97BneDiqXGLb3ie
# c/rEOtaIr1/wWXA4U5uehqdjaciZKLZwqxpHnWQpnqUbCJ/XSIhR6vO/lUG4RITg
# 3QYDzu651IHAbvqK+aV6BEImQXNwUJg8F/PK7eyR7baALt4ncdeXHTKp+liGeNNS
# gM2uVRUg1pBeGIHG1xN2EEtf7hA1CV+vThhaVSCo/BwfTb4RILYeqGNw1wfFANu/
# jXn8jHVBxG+S3dqXUVbdKGPx8zHINzsWJnGBQMhPbiJeUOQtr/oGpTh6mZ7oQyAM
# JyEyD9PfMRn6V0Q+dx/nVx5EyBLKXVe4h+12KVbaUN+9KWptxkUej3braI1WKdlP
# vkcVszEij7n6lBNmvQY7eAtZFza9x3UoT47ovTg=
# SIG # End signature block
