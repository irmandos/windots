
function New-AzFunctionApp {
    [OutputType([Microsoft.Azure.PowerShell.Cmdlets.Functions.Models.Api20231201.ISite])]
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.Description('Creates a function app.')]
    [CmdletBinding(SupportsShouldProcess=$true, DefaultParametersetname="Consumption")]
    param(
        [Parameter(ParameterSetName="Consumption", HelpMessage='The Azure subscription ID.')]
        [Parameter(ParameterSetName="ByAppServicePlan")]
        [Parameter(ParameterSetName="CustomDockerImage")]
        [Parameter(ParameterSetName="EnvironmentForContainerApp")]
        [Microsoft.Azure.PowerShell.Cmdlets.Functions.Runtime.DefaultInfo(Script='(Get-AzContext).Subscription.Id')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        ${SubscriptionId},
        
        [Parameter(Mandatory=$true, ParameterSetName="Consumption", HelpMessage='The name of the resource group.')]
        [Parameter(Mandatory=$true, ParameterSetName="ByAppServicePlan")]
        [Parameter(Mandatory=$true, ParameterSetName="CustomDockerImage")]
        [Parameter(Mandatory=$true, ParameterSetName="EnvironmentForContainerApp")]
        [ValidateNotNullOrEmpty()]
        [System.String]
        ${ResourceGroupName},
        
        [Parameter(Mandatory=$true, ParameterSetName="Consumption", HelpMessage='The name of the function app.')]
        [Parameter(Mandatory=$true, ParameterSetName="ByAppServicePlan")]
        [Parameter(Mandatory=$true, ParameterSetName="CustomDockerImage")]
        [Parameter(Mandatory=$true, ParameterSetName="EnvironmentForContainerApp")]
        [ValidateNotNullOrEmpty()]
        [System.String]
        ${Name},
        
        [Parameter(Mandatory=$true, ParameterSetName="Consumption", HelpMessage='The name of the storage account.')]
        [Parameter(Mandatory=$true, ParameterSetName="ByAppServicePlan")]
        [Parameter(Mandatory=$true, ParameterSetName="CustomDockerImage")]
        [Parameter(Mandatory=$true, ParameterSetName="EnvironmentForContainerApp")]
        [ValidateNotNullOrEmpty()]
        [System.String]
        ${StorageAccountName},

        [Parameter(ParameterSetName="Consumption", HelpMessage='Name of the existing App Insights project to be added to the function app.')]
        [Parameter(ParameterSetName="ByAppServicePlan")]
        [Parameter(ParameterSetName="CustomDockerImage")]
        [Parameter(ParameterSetName="EnvironmentForContainerApp")]
        [ValidateNotNullOrEmpty()]
        [System.String]
        [Alias("AppInsightsName")]
        ${ApplicationInsightsName},

        [Parameter(ParameterSetName="Consumption", HelpMessage='Instrumentation key of App Insights to be added.')]
        [Parameter(ParameterSetName="ByAppServicePlan")]
        [Parameter(ParameterSetName="CustomDockerImage")]
        [Parameter(ParameterSetName="EnvironmentForContainerApp")]
        [ValidateNotNullOrEmpty()]
        [System.String]
        [System.String]
        [Alias("AppInsightsKey")]
        ${ApplicationInsightsKey},

        [Parameter(Mandatory=$true, ParameterSetName="Consumption", HelpMessage='The location for the consumption plan.')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        ${Location},

        [Parameter(Mandatory=$true, ParameterSetName="ByAppServicePlan", HelpMessage='The name of the service plan.')]
        [Parameter(Mandatory=$true, ParameterSetName="CustomDockerImage")]
        [ValidateNotNullOrEmpty()]
        [System.String]
        ${PlanName},

        [Parameter(ParameterSetName="ByAppServicePlan", HelpMessage='The OS to host the function app.')]
        [Parameter(ParameterSetName="Consumption")]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.Functions.Support.WorkerType])]
        [ValidateSet("Linux", "Windows")]
        [ValidateNotNullOrEmpty()]
        [System.String]
        # OS type (Linux or Windows)
        ${OSType},
        
        [Parameter(Mandatory=$true, ParameterSetName="ByAppServicePlan", HelpMessage='The function runtime.')]
        [Parameter(Mandatory=$true, ParameterSetName="Consumption")]
        [ValidateNotNullOrEmpty()]
        [System.String]
        # Runtime types are defined in HelperFunctions.ps1
        ${Runtime},

        [Parameter(ParameterSetName="ByAppServicePlan", HelpMessage='The function runtime.')]
        [Parameter(ParameterSetName="Consumption")]
        [ValidateNotNullOrEmpty()]
        [System.String]
        # RuntimeVersion types are defined in HelperFunctions.ps1
        ${RuntimeVersion},

        [Parameter(ParameterSetName="ByAppServicePlan", HelpMessage='The Functions version.')]
        [Parameter(ParameterSetName="Consumption")]
        [ValidateNotNullOrEmpty()]
        [System.String]
        # FunctionsVersion types are defined in HelperFunctions.ps1
        ${FunctionsVersion},

        [Parameter(ParameterSetName="ByAppServicePlan", HelpMessage='Disable creating application insights resource during the function app creation. No logs will be available.')]
        [Parameter(ParameterSetName="Consumption")]
        [Parameter(ParameterSetName="CustomDockerImage")]
        [Parameter(ParameterSetName="EnvironmentForContainerApp")]
        [System.Management.Automation.SwitchParameter]
        [Alias("DisableAppInsights")]
        ${DisableApplicationInsights},
        
        [Parameter(Mandatory=$true, ParameterSetName="CustomDockerImage", HelpMessage='Container image name, e.g., publisher/image-name:tag.')]
        [Parameter(ParameterSetName="EnvironmentForContainerApp")]
        [ValidateNotNullOrEmpty()]
        [System.String]
        [Alias("DockerImageName")]
        ${Image},

        [Parameter(ParameterSetName="CustomDockerImage", HelpMessage='The container registry username and password. Required for private registries.')]
        [Parameter(ParameterSetName="EnvironmentForContainerApp")]
        [ValidateNotNullOrEmpty()]
        [PSCredential]
        [Alias("DockerRegistryCredential")]
        ${RegistryCredential},

        [Parameter(HelpMessage='Returns true when the command succeeds.')]
        [System.Management.Automation.SwitchParameter]
        ${PassThru},

        [Parameter(ParameterSetName="ByAppServicePlan", HelpMessage='Starts the operation and returns immediately, before the operation is completed. In order to determine if the operation has successfully been completed, use some other mechanism.')]
        [Parameter(ParameterSetName="Consumption")]
        [Parameter(ParameterSetName="CustomDockerImage")]
        [Parameter(ParameterSetName="EnvironmentForContainerApp")]
        [Microsoft.Azure.PowerShell.Cmdlets.Functions.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        ${NoWait},
        
        [Parameter(ParameterSetName="ByAppServicePlan", HelpMessage='Runs the cmdlet as a background job.')]
        [Parameter(ParameterSetName="Consumption")]
        [Parameter(ParameterSetName="CustomDockerImage")]
        [Parameter(ParameterSetName="EnvironmentForContainerApp")]
        [Microsoft.Azure.PowerShell.Cmdlets.Functions.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        ${AsJob},

        [Parameter(ParameterSetName="ByAppServicePlan", HelpMessage='Resource tags.')]
        [Parameter(ParameterSetName="Consumption")]
        [Parameter(ParameterSetName="CustomDockerImage")]
        [Parameter(ParameterSetName="EnvironmentForContainerApp")]
        [Microsoft.Azure.PowerShell.Cmdlets.Functions.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.Functions.Runtime.Info(PossibleTypes=([Microsoft.Azure.PowerShell.Cmdlets.Functions.Models.Api20231201.IResourceTags]))]
        [System.Collections.Hashtable]
        [ValidateNotNull()]
        ${Tag},

        [Parameter(ParameterSetName="ByAppServicePlan", HelpMessage='Function app settings.')]
        [Parameter(ParameterSetName="Consumption")]
        [Parameter(ParameterSetName="CustomDockerImage")]
        [Parameter(ParameterSetName="EnvironmentForContainerApp")]
        [ValidateNotNullOrEmpty()]
        [Hashtable]
        ${AppSetting},

        [Parameter(ParameterSetName="ByAppServicePlan", HelpMessage="Specifies the type of identity used for the function app.
            The acceptable values for this parameter are:
            - SystemAssigned
            - UserAssigned
            ")]
        [Parameter(ParameterSetName="Consumption")]
        [Parameter(ParameterSetName="CustomDockerImage")]
        [Parameter(ParameterSetName="EnvironmentForContainerApp")]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.Functions.Support.FunctionAppManagedServiceIdentityCreateType])]
        [Microsoft.Azure.PowerShell.Cmdlets.Functions.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.Functions.Support.ManagedServiceIdentityType]
        ${IdentityType},

        [Parameter(ParameterSetName="ByAppServicePlan", HelpMessage="Specifies the list of user identities associated with the function app.
            The user identity references will be ARM resource ids in the form:
            '/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.ManagedIdentity/identities/{identityName}'")]
        [Parameter(ParameterSetName="Consumption")]
        [Parameter(ParameterSetName="CustomDockerImage")]
        [Parameter(ParameterSetName="EnvironmentForContainerApp")]
        [ValidateNotNull()]
        [System.String[]]
        ${IdentityID},

        [Parameter(Mandatory=$true, ParameterSetName="EnvironmentForContainerApp", HelpMessage='Name of the container app environment.')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        ${Environment},

        [Parameter(Mandatory=$false, ParameterSetName="EnvironmentForContainerApp", HelpMessage='The workload profile name to run the container app on.')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        ${WorkloadProfileName},

        [Parameter(Mandatory=$false, ParameterSetName="EnvironmentForContainerApp", HelpMessage='The CPU in cores of the container app. e.g., 0.75.')]
        [ValidateNotNullOrEmpty()]
        [Double]
        ${ResourceCpu},

        [Parameter(Mandatory=$false, ParameterSetName="EnvironmentForContainerApp", HelpMessage='The memory size of the container app. e.g., 1.0Gi.')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        ${ResourceMemory},

        [Parameter(Mandatory=$false, ParameterSetName="EnvironmentForContainerApp", HelpMessage='The maximum number of replicas when creating a function app on container app.')]
        [ValidateScript({$_ -gt 0})]
        [Int]
        ${ScaleMaxReplica},

        [Parameter(Mandatory=$false, ParameterSetName="EnvironmentForContainerApp", HelpMessage='The minimum number of replicas when create function app on container app.')]
        [ValidateScript({$_ -gt 0})]
        [Int]
        ${ScaleMinReplica},

        [Parameter(Mandatory=$false, ParameterSetName="EnvironmentForContainerApp", HelpMessage='The container registry server hostname, e.g. myregistry.azurecr.io.')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        ${RegistryServer},
        
        [Alias('AzureRMContext', 'AzureCredential')]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Functions.Category('Azure')]
        [System.Management.Automation.PSObject]
        ${DefaultProfile},

        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.Functions.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Wait for .NET debugger to attach
        ${Break},

        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Functions.Category('Runtime')]
        [Microsoft.Azure.PowerShell.Cmdlets.Functions.Runtime.SendAsyncStep[]]
        # SendAsync Pipeline Steps to be appended to the front of the pipeline
        ${HttpPipelineAppend},

        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Functions.Category('Runtime')]
        [Microsoft.Azure.PowerShell.Cmdlets.Functions.Runtime.SendAsyncStep[]]
        # SendAsync Pipeline Steps to be prepended to the front of the pipeline
        ${HttpPipelinePrepend},

        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.Functions.Category('Runtime')]
        [System.Uri]
        # The URI for the proxy server to use
        ${Proxy},

        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Functions.Category('Runtime')]
        [System.Management.Automation.PSCredential]
        # Credentials for a proxy server to use for the remote call
        ${ProxyCredential},

        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.Functions.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Use the default credentials for the proxy
        ${ProxyUseDefaultCredentials}
    )

    process {

        RegisterFunctionsTabCompleters

        # Remove bound parameters from the dictionary that cannot be process by the intenal cmdlets.
        $paramsToRemove = @(
            "StorageAccountName",
            "ApplicationInsightsName",
            "ApplicationInsightsKey",
            "Location",
            "PlanName",
            "OSType",
            "Runtime",
            "DisableApplicationInsights",
            "Image",
            "RegistryCredential",
            "FunctionsVersion",
            "RuntimeVersion",
            "AppSetting",
            "IdentityType",
            "IdentityID",
            "Tag",
            "Environment",
            "RegistryServer",
            "WorkloadProfileName",
            "ResourceCpu",
            "ResourceMemory",
            "ScaleMaxReplica",
            "ScaleMinReplica"
        )
        foreach ($paramName in $paramsToRemove)
        {
            if ($PSBoundParameters.ContainsKey($paramName))
            {
                $PSBoundParameters.Remove($paramName)  | Out-Null
            }
        }

        $functionAppIsCustomDockerImage = $PsCmdlet.ParameterSetName -eq "CustomDockerImage"
        $environmentForContainerApp = $PsCmdlet.ParameterSetName -eq "EnvironmentForContainerApp"

        $appSettings = New-Object -TypeName System.Collections.Generic.List[System.Object]
        $siteConfig = New-Object -TypeName Microsoft.Azure.PowerShell.Cmdlets.Functions.Models.Api20231201.SiteConfig
        $functionAppDef = New-Object -TypeName Microsoft.Azure.PowerShell.Cmdlets.Functions.Models.Api20231201.Site

        $params = GetParameterKeyValues -PSBoundParametersDictionary $PSBoundParameters `
                                        -ParameterList @("SubscriptionId", "HttpPipelineAppend", "HttpPipelinePrepend")

        $runtimeJsonDefinition = $null
        ValidateFunctionName -Name $Name @params

        if (-not ($functionAppIsCustomDockerImage -or $environmentForContainerApp))
        {
            if (-not $FunctionsVersion)
            {
                $FunctionsVersion = $DefaultFunctionsVersion
                Write-Warning "FunctionsVersion not specified. Setting default value to '$FunctionsVersion'. $SetDefaultValueParameterWarningMessage"
            }

            ValidateFunctionsVersion -FunctionsVersion $FunctionsVersion

            if (-not $OSType)
            {
                $OSType = GetDefaultOSType -Runtime $Runtime
                Write-Warning "OSType not specified. Setting default value to '$OSType'. $SetDefaultValueParameterWarningMessage"
            }

            $runtimeJsonDefinition = GetStackDefinitionForRuntime -FunctionsVersion $FunctionsVersion -Runtime $Runtime -RuntimeVersion $RuntimeVersion -OSType $OSType

            if (-not $runtimeJsonDefinition)
            {
                $errorId = "FailedToGetRuntimeDefinition"
                $message += "Failed to get runtime definition for '$Runtime' version '$RuntimeVersion' in Functions version '$FunctionsVersion' on '$OSType'."
                $exception = [System.InvalidOperationException]::New($message)
                ThrowTerminatingError -ErrorId $errorId `
                                      -ErrorMessage $message `
                                      -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                                      -Exception $exception

            }

            # Add app settings
            if ($runtimeJsonDefinition.AppSettingsDictionary.Count -gt 0)
            {
                foreach ($keyName in $runtimeJsonDefinition.AppSettingsDictionary.Keys)
                {
                    $value = $runtimeJsonDefinition.AppSettingsDictionary[$keyName]
                    $appSettings.Add((NewAppSetting -Name $keyName -Value $value))
                }
            }

            # Add site config properties
            if ($runtimeJsonDefinition.SiteConfigPropertiesDictionary.Count -gt 0)
            {
                foreach ($PropertyName in $runtimeJsonDefinition.SiteConfigPropertiesDictionary.Keys)
                {
                    $value = $runtimeJsonDefinition.SiteConfigPropertiesDictionary[$PropertyName]
                    $siteConfig.$PropertyName = $value
                }
            }            
        }

        $servicePlan = $null
        $consumptionPlan = $PsCmdlet.ParameterSetName -eq "Consumption"
        $OSIsLinux = $OSType -eq "Linux"
        $dockerRegistryServerUrl = $null
        
        if ($consumptionPlan)
        {
            ValidateConsumptionPlanLocation -Location $Location -OSIsLinux:$OSIsLinux @params
            $functionAppDef.Location = $Location
        }
        elseif ($environmentForContainerApp)
        {
            $OSIsLinux = $true

            if (-not $Image)
            {
                Write-Warning "Image not specified. Setting default value to '$DefaultCentauriImage'."
                $Image = $DefaultCentauriImage
            }
            if ($RegistryServer)
            {
                $dockerRegistryServerUrl = $RegistryServer
            }

            if ($Environment -and $RegistryCredential)
            {
                # Error out if the user has specified both Environment and RegistryCredential and not provided RegistryServer.
                if (-not $RegistryServer)
                {
                    $errorMessage = "RegistryServer is required when Environment and RegistryCredential is specified."
                    $exception = [System.InvalidOperationException]::New($errorMessage)
                    ThrowTerminatingError -ErrorId "RegistryServerRequired" `
                                          -ErrorMessage $errorMessage `
                                          -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                                          -Exception $exception
                }
            }
        }
        elseif ($PlanName)
        {
            # Host function app in Elastic Premium or app service plan
            $servicePlan = GetServicePlan $PlanName @params

            if ($null -ne $servicePlan.Location)
            {
                $Location = $servicePlan.Location
            }

            if ($null -ne $servicePlan.Reserved)
            {
                $OSIsLinux = $servicePlan.Reserved
            }

            $functionAppDef.ServerFarmId = $servicePlan.Id
            $functionAppDef.Location = $Location
        }

        if ($OSIsLinux)
        {
            # These are the scenarios we currently support when creating a Docker container:
            # 1) In Consumption, we only support images created by Functions with a predefine runtime name and version, e.g., Python 3.7
            # 2) For App Service and Premium plans, a customer can specify a customer container image

            # Linux function app
            $functionAppDef.Kind = 'functionapp,linux'
            $functionAppDef.Reserved = $true

            # Bring your own container is only supported on App Service, Premium plans and Container App
            if ($Image)
            {
                $functionAppDef.Kind = 'functionapp,linux,container'

                $appSettings.Add((NewAppSetting -Name 'DOCKER_CUSTOM_IMAGE_NAME' -Value $Image.Trim().ToLower()))
                $appSettings.Add((NewAppSetting -Name 'FUNCTION_APP_EDIT_MODE' -Value 'readOnly'))
                $appSettings.Add((NewAppSetting -Name 'WEBSITES_ENABLE_APP_SERVICE_STORAGE' -Value 'false'))

                $siteConfig.LinuxFxVersion = FormatFxVersion -Image $Image

                # Parse the docker registry url only for the custom image parameter set (otherwise it will be a breaking change for existing customers).
                # For the container app environment, the registry url must me explicitly provided.
                if (-not $dockerRegistryServerUrl -and -not $environmentForContainerApp)
                {
                    $dockerRegistryServerUrl = ParseDockerImage -DockerImageName $Image
                }

                if ($dockerRegistryServerUrl)
                {
                    $appSettings.Add((NewAppSetting -Name 'DOCKER_REGISTRY_SERVER_URL' -Value $dockerRegistryServerUrl))

                    if ($RegistryCredential)
                    {
                        $appSettings.Add((NewAppSetting -Name 'DOCKER_REGISTRY_SERVER_USERNAME' -Value $RegistryCredential.GetNetworkCredential().UserName))
                        $appSettings.Add((NewAppSetting -Name 'DOCKER_REGISTRY_SERVER_PASSWORD' -Value $RegistryCredential.GetNetworkCredential().Password))
                    }
                }
            }
            else
            {
                $appSettings.Add((NewAppSetting -Name 'WEBSITES_ENABLE_APP_SERVICE_STORAGE' -Value 'true'))
            }
        }
        else 
        {
            # Windows function app
            $functionAppDef.Kind = 'functionapp'
        }

        if ($environmentForContainerApp)
        {
            $functionAppDef.Kind = 'functionapp,linux,container,azurecontainerapps'
            $functionAppDef.Reserved = $null
            $functionAppDef.HttpsOnly = $null
            $functionAppDef.ScmSiteAlsoStopped = $null
            $functionAppDef.HttpsOnly = $null

            ValidateCpuAndMemory -ResourceCpu $ResourceCpu -ResourceMemory $ResourceMemory
            if ($ResourceCpu -and $ResourceMemory)
            {
                $functionAppDef.ResourceConfigCpu = $ResourceCpu
                $functionAppDef.ResourceConfigMemory = $ResourceMemory
            }

            if ($WorkloadProfileName)
            {
                $functionAppDef.WorkloadProfileName = $WorkloadProfileName
            }

            $siteConfig.netFrameworkVersion = $null
            $siteConfig.JavaVersion = $null
            $siteConfig.Use32BitWorkerProcess = $null
            $siteConfig.PowerShellVersion = $null
            $siteConfig.Http20Enabled = $null
            $siteConfig.LocalMySqlEnabled = $null

            if ($ScaleMinReplica)
            {
                $siteConfig.MinimumElasticInstanceCount = $ScaleMinReplica
            }

            if ($ScaleMaxReplica)
            {
                $siteConfig.FunctionAppScaleLimit = $ScaleMaxReplica
            }
            
            $managedEnvironment = GetManagedEnvironment -Environment $Environment -ResourceGroupName $ResourceGroupName
            $functionAppDef.Location = $managedEnvironment.Location
            $functionAppDef.ManagedEnvironmentId = $managedEnvironment.Id
        }

        # Validate storage account and get connection string
        $connectionString = GetConnectionString -StorageAccountName $StorageAccountName @params
        $appSettings.Add((NewAppSetting -Name 'AzureWebJobsStorage' -Value $connectionString))
        $appSettings.Add((NewAppSetting -Name 'AzureWebJobsDashboard' -Value $connectionString))

        if (-not ($functionAppIsCustomDockerImage -or $environmentForContainerApp))
        {
            $appSettings.Add((NewAppSetting -Name 'FUNCTIONS_EXTENSION_VERSION' -Value "~$FunctionsVersion"))
        }

        # If plan is not consumption, elastic premium or a container app environment, set always on
        $planIsElasticPremium = $servicePlan.SkuTier -eq 'ElasticPremium'
        if ((-not $consumptionPlan) -and (-not $planIsElasticPremium) -and (-not $Environment))
        {
            $siteConfig.AlwaysOn = $true
        }

        # If plan is Elastic Premium or Consumption (Windows or Linux), we need these app settings
        if ($planIsElasticPremium -or $consumptionPlan)
        {
            $appSettings.Add((NewAppSetting -Name 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING' -Value $connectionString))

            $shareName = GetShareName -FunctionAppName $Name
            $appSettings.Add((NewAppSetting -Name 'WEBSITE_CONTENTSHARE' -Value $shareName))
        }

        if (-not $DisableApplicationInsights)
        {
            if ($ApplicationInsightsKey)
            {
                $appSettings.Add((NewAppSetting -Name 'APPINSIGHTS_INSTRUMENTATIONKEY' -Value $ApplicationInsightsKey))
            }
            elseif ($ApplicationInsightsName)
            {
                $appInsightsProject = GetApplicationInsightsProject -Name $ApplicationInsightsName @params
                if (-not $appInsightsProject)
                {
                    $errorMessage = "Failed to get application insights key for project name '$ApplicationInsightsName'. Please make sure the project exist."
                    $exception = [System.InvalidOperationException]::New($errorMessage)
                    ThrowTerminatingError -ErrorId "ApplicationInsightsProjectNotFound" `
                                        -ErrorMessage $errorMessage `
                                        -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                                        -Exception $exception
                }

                $appSettings.Add((NewAppSetting -Name 'APPINSIGHTS_INSTRUMENTATIONKEY' -Value $appInsightsProject.InstrumentationKey))
            }
            else
            {
                $newAppInsightsProject = CreateApplicationInsightsProject -ResourceGroupName $resourceGroupName `
                                                                          -ResourceName $Name `
                                                                          -Location $functionAppDef.Location `
                                                                          @params
                if ($newAppInsightsProject)
                {
                    $appSettings.Add((NewAppSetting -Name 'APPINSIGHTS_INSTRUMENTATIONKEY' -Value $newAppInsightsProject.InstrumentationKey))
                }
                else
                {
                    $warningMessage = "Unable to create the Application Insights for the function app. Creation of Application Insights will help you monitor and diagnose your function apps in the Azure Portal. `r`n"
                    $warningMessage += "Use the 'New-AzApplicationInsights' cmdlet or the Azure Portal to create a new Application Insights project. After that, use the 'Update-AzFunctionApp' cmdlet to update Application Insights for your function app."
                    Write-Warning $warningMessage
                }
            }
        }

        if ($Tag.Count -gt 0)
        {
            $resourceTag = NewResourceTag -Tag $Tag
            $functionAppDef.Tag = $resourceTag
        }

        # Add user app settings
        if ($appSetting.Count -gt 0)
        {
            foreach ($keyName in $appSetting.Keys)
            {
                $appSettings.Add((NewAppSetting -Name $keyName -Value $appSetting[$keyName]))
            }
        }

        # Set function app managed identity
        if ($IdentityType)
        {
            $functionAppDef.IdentityType = $IdentityType

            if ($IdentityType -eq "UserAssigned")
            {
                # Set UserAssigned managed identiy
                if (-not $IdentityID)
                {
                    $errorMessage = "IdentityID is required for UserAssigned identity"
                    $exception = [System.InvalidOperationException]::New($errorMessage)
                    ThrowTerminatingError -ErrorId "IdentityIDIsRequiredForUserAssignedIdentity" `
                                            -ErrorMessage $errorMessage `
                                            -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                                            -Exception $exception

                }

                $identityUserAssignedIdentity = NewIdentityUserAssignedIdentity -IdentityID $IdentityID
                $functionAppDef.IdentityUserAssignedIdentity = $identityUserAssignedIdentity
            }
        }

        # Set app settings and site configuration
        $siteConfig.AppSetting = $appSettings
        $functionAppDef.Config = $siteConfig
        $PSBoundParameters.Add("SiteEnvelope", $functionAppDef)  | Out-Null

        if ($PsCmdlet.ShouldProcess($Name, "Creating function app"))
        {
            # Save the ErrorActionPreference
            $currentErrorActionPreference = $ErrorActionPreference
            $ErrorActionPreference = 'Stop'

            $exceptionThrown = $false

            try
            {
                Az.Functions.internal\New-AzFunctionApp @PSBoundParameters
            }
            catch
            {
                $exceptionThrown = $true

                $errorMessage = GetErrorMessage -Response $_

                if ($errorMessage)
                {
                    $exception = [System.InvalidOperationException]::New($errorMessage)
                    ThrowTerminatingError -ErrorId "FailedToCreateFunctionApp" `
                                            -ErrorMessage $errorMessage `
                                            -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                                            -Exception $exception
                }

                throw $_
            }
            finally
            {
                # Reset the ErrorActionPreference
                $ErrorActionPreference = $currentErrorActionPreference
            }

            if (-not $exceptionThrown)
            {
                if ($consumptionPlan -and $OSIsLinux)
                {
                    $message = "Your Linux function app '$Name', that uses a consumption plan has been successfully created but is not active until content is published using Azure Portal or the Functions Core Tools."
                    Write-Verbose $message -Verbose
                }
            }
        }
    }
}

# SIG # Begin signature block
# MIIoKQYJKoZIhvcNAQcCoIIoGjCCKBYCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAysI9JXbowLlbJ
# 4pzs4wTMJ4SfGJVLBz0GjLO89pKXU6CCDXYwggX0MIID3KADAgECAhMzAAADrzBA
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
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIM3LlgImWoUKlOZPNXb3+j+w
# ql9ZlcuZjZ1tj4rOW7fVMEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEB
# BQAEggEAjoF2Mz4YvRRQSx1dKOYTK4v9F8v11NNxsPVbIwDYlCohnPa6V/+uIrlq
# etN/iRCTEfy/VONYZNrJIl4/e7wSLpF0xJBu4KsdJOb9qXdfzC1K1ryyjuDvnIt6
# b+3dn42hSO30woYIQtJq8fMmj0GBBIKP8WraVGnI03a2fNE3GacAh3ammBkjV+13
# rr5WSwucRyuLX8sR276JQVephdKO8BflVBpZGePGIBD+wieA8H1P626o3WA8gt8O
# vCJAGwgPFesbMY18iczlisvPlJryMlXRFhjxHKaN5aO3gqT2EY6JbwBMNbEB/v0O
# AFwwqY+hY3+/vSk+B0OEk6nc1eFpm6GCF5MwghePBgorBgEEAYI3AwMBMYIXfzCC
# F3sGCSqGSIb3DQEHAqCCF2wwghdoAgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFRBgsq
# hkiG9w0BCRABBKCCAUAEggE8MIIBOAIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCCp8Hgu/eo1TpGTti/uDYB5hskT6QYr9fU9+noG6ohf0QIGZkY+WyN3
# GBIyMDI0MDcwNDA4MzA0OS40NFowBIACAfSggdGkgc4wgcsxCzAJBgNVBAYTAlVT
# MRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQK
# ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJTAjBgNVBAsTHE1pY3Jvc29mdCBBbWVy
# aWNhIE9wZXJhdGlvbnMxJzAlBgNVBAsTHm5TaGllbGQgVFNTIEVTTjo5NjAwLTA1
# RTAtRDk0NzElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2VydmljZaCC
# EeowggcgMIIFCKADAgECAhMzAAAB74k/VqFYzKjaAAEAAAHvMA0GCSqGSIb3DQEB
# CwUAMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQH
# EwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNV
# BAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwMB4XDTIzMTIwNjE4NDU0
# OFoXDTI1MDMwNTE4NDU0OFowgcsxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNo
# aW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29y
# cG9yYXRpb24xJTAjBgNVBAsTHE1pY3Jvc29mdCBBbWVyaWNhIE9wZXJhdGlvbnMx
# JzAlBgNVBAsTHm5TaGllbGQgVFNTIEVTTjo5NjAwLTA1RTAtRDk0NzElMCMGA1UE
# AxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2VydmljZTCCAiIwDQYJKoZIhvcNAQEB
# BQADggIPADCCAgoCggIBAKMLWOKfDOAfCE5qRmrLXugTgEgEqybmRfgNSYIFYjSU
# VWkSIrmZnYqHn2ygvieznamEUxBgYbmTKkKKm6eDA/02hvhUZUTpqgyjmFn03K1d
# HllGBv1nw1HoSYsogJGEPiyiM8yD9GcZFNx1/v9Ni/IzXSMuOYvIoR6Awd+8jA+Y
# z4A/uHNAt8TEN2oIna7rgZ3leWesU6S7lT2Ms4qTXLvRz5PC3Tj9Euqu6/V8Y/wu
# Zia0e+sHhNwGwANdKZwWOHRWBCRfjNcXCqcgbyuBj7MOolhA1k/w7VijiRJyQdPj
# dcLSgzjTJ7b72X+tNiIMUzeeVl7aOG06QYI7oaqJOnnTEj0hOkleLS8R6TwB6NPg
# 8owQ7Zs/FTrenre5luN03kv6WAhwI0wI0jRIiilLiBpVHhLL8igO/W8Nal74jbz8
# rLyNZN553Q7cfE8kxmpfhAHcjoOfBmseIqfqgTfy2AFMIIAq8Shg5ODuvaUXQi5u
# 3/f5U+8q1MJRtk8U4byNm32roAWh2W9Ce2KiVghi2pKsvJcBAiVcaFniA1y/h2/V
# gCKWdtYD0KydiH44oQWv/jDgzr2Uj7Jqhncv+39R9elP/7JzuFL8WiVyasYUlMFi
# VLicTVy4puXBn9Q4bbpIuEM41ZcZkMowko3neg4tJKTiV1HQeWxtPiF4uVaU4SUl
# AgMBAAGjggFJMIIBRTAdBgNVHQ4EFgQU7UxaooXCsJu2vD0/wDrdsBVInMswHwYD
# VR0jBBgwFoAUn6cVXQBeYl2D9OXSZacbUzUZ6XIwXwYDVR0fBFgwVjBUoFKgUIZO
# aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jcmwvTWljcm9zb2Z0JTIw
# VGltZS1TdGFtcCUyMFBDQSUyMDIwMTAoMSkuY3JsMGwGCCsGAQUFBwEBBGAwXjBc
# BggrBgEFBQcwAoZQaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jZXJ0
# cy9NaWNyb3NvZnQlMjBUaW1lLVN0YW1wJTIwUENBJTIwMjAxMCgxKS5jcnQwDAYD
# VR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAOBgNVHQ8BAf8EBAMC
# B4AwDQYJKoZIhvcNAQELBQADggIBABgZlrdoIO51uT0RV2Q/zFxAZm4gAg9HH0rU
# IDu5HMG3zR8LRpaS5hiFAy8cclEdShtIzhTDfM3t8cQ3yGFoENv01FoacVZ20fGY
# n14zPommfoqIjKL1Tk6DtAJNkyXXufbDh512rm+2TitFY5W+mIMEYkBEqJdYH27a
# LHRYfYQwUYeqMiGNZReE+BHgLo0oU1ce9a9d5wnZZesme+9AZcB80kYRMlkalHjW
# dQ3eKN+IJKMUPFqYY+zLmJi73Tge/265Jdh3mbQnF/ZY0lJeQ8aU2Gs7buk/GBPX
# XWbIBHrVLdLaFznvbM33KgkQ5sT3xXLkoQzdlfndwt583zUXUL2n9wAqQTq71Xqv
# LKX+pKDG7VSp45kK0b+JodIoyjEzsyrhIwWw9P/yJ453AKVilzDQKNl7koHHbEtr
# gHWd4WJvwnz+BKiyMx0XeceLIfHVh51kO3FJKB6B4myLR9tSB3OxUwli+pXDnZap
# A27QZELv1m5Wt5RUp0ImZQwEcGlOnpUWikvQl/hKuCD7NEP2LBtz25muf7z2h2ki
# dvOdiuc8oeI7bqp7V6Q3CX93uujYi0/+WCHPQOgPuQQZ6KQolYd22jt5UmgmGStR
# xqdO5QfTyD41jAbpL4+MFIH83I0Xpsdr/FH5x4BiFyPHSIGK/3QyfQmIZ+cDb+Eu
# Pl6+FNwCMIIHcTCCBVmgAwIBAgITMwAAABXF52ueAptJmQAAAAAAFTANBgkqhkiG
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
# JQYDVQQLEx5uU2hpZWxkIFRTUyBFU046OTYwMC0wNUUwLUQ5NDcxJTAjBgNVBAMT
# HE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2WiIwoBATAHBgUrDgMCGgMVAEtw
# jzWDFt5rUTHaYVtfHtyT7SD/oIGDMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAg
# UENBIDIwMTAwDQYJKoZIhvcNAQELBQACBQDqMKnFMCIYDzIwMjQwNzA0MDQ1NTMz
# WhgPMjAyNDA3MDUwNDU1MzNaMHQwOgYKKwYBBAGEWQoEATEsMCowCgIFAOowqcUC
# AQAwBwIBAAICJgAwBwIBAAICEmcwCgIFAOox+0UCAQAwNgYKKwYBBAGEWQoEAjEo
# MCYwDAYKKwYBBAGEWQoDAqAKMAgCAQACAwehIKEKMAgCAQACAwGGoDANBgkqhkiG
# 9w0BAQsFAAOCAQEAKte/eBMs4xPqyJ0mCrjbZKYtJjt9LE26pyiHCMWYJuE8YB8H
# lzG1Fnd86at1RXT5C6VsctQGfwowrLlOmNrBLaqFqUMp/qE1g62yfr1hjuHfIUm+
# Gr+DnMWIHI9ExFZv/ChCxl3Ntms7oegfjKevTZ1xltEhe1IhF0O6gw+/3nO5K3vN
# EafJyrCs/k5xACO8dC9RibO0wvAQiwxF+4/9XOpvUdp2867SjzVykr0ObXMJBDdB
# r68G2Q1yI7JRyq9ox7zFJjpq1x3gADXp/+WvtGVOzrXyJV2ABZ3UTXWu5tztdSB1
# cWcYsTkmVTjwvHugWaI8LVEABNR9dJ9Ydz9r5jGCBA0wggQJAgEBMIGTMHwxCzAJ
# BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jv
# c29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAAB74k/VqFYzKjaAAEAAAHvMA0G
# CWCGSAFlAwQCAQUAoIIBSjAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwLwYJ
# KoZIhvcNAQkEMSIEICTD+By1AIVJbERJJxLBqBdHuR2GtwKoflHezlyooHH2MIH6
# BgsqhkiG9w0BCRACLzGB6jCB5zCB5DCBvQQg8GEoRbgWjfBTPT01DHZrQNtx2xfy
# Oi8zkuLMeafJf6MwgZgwgYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAx
# MAITMwAAAe+JP1ahWMyo2gABAAAB7zAiBCCDRH8gUzDmY7UdEaexWEiLOO4Yx8V9
# towkevPKzmj8tDANBgkqhkiG9w0BAQsFAASCAgBiMTqVed0zAMPzF4DS2S2nhUeE
# jRT0Bop46F4JPdhjYZcH95MwMhdLyUIDiP3K4hf+Mr7yy706Ln75ftINMTeZM7di
# +iX6j6HOH5OcRSu1og9Na+HfuTmhn7kieFoDEoY9lGuY/VmJ5eyfArc4jy5Yuhzh
# TusrtNHRpz1bB6npTU/SaU8GrN96cUkBmVJ9I5Y+6tiny5WbSONgV82uyxl+bOrg
# CKaTbqjzXF+ZEd1in1uSTFJ2jXBZEh/NqnhS+7thqdZ8vQgFvcCaKZYNbFCbj+YG
# bIAEGqtphTGsIKXL5EG6tVm3+tlEwtX6x9wn4mtPZzLBxS6ziFmPFSawOkeG2xgH
# f9Y0Whz9SFnu2h41ESje0r+S0YQ7dYsTpXmVuUJA8UGJjXJ+CS3IBnzRl4oFzqD+
# ZQLur542U90TRii2O47M6ttSpAS5tKSqy0rq0sop1zstwBGckzN8Blvl9xRo23rZ
# BEbkDpWVAZjASSyXFJAmK0thG5BAMawYzw90WA9TTbggd+Y5CKV7hSMCrBDMuZYj
# OCyJoztA/aROjNrnrccF/Oc+tjAsNTct15b1UrDO+j62xyjgdEboAdbXd3fkDUbu
# rd3N5FMlBYns8JnEE7JEo7DTQNRoNkw7fSFTqpR5yCAHpFJxSUl5fzTtV0B2+DlO
# rZAJ0/+5DyKlhBovSA==
# SIG # End signature block
