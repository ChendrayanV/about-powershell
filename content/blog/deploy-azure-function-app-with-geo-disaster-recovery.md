+++
title = "Deploy Azure Function App with Geo Disaster Recovery"
description = "take diversion..."
author = "Chendrayan Venkatesan"
draft = "false"
date = "2022-03-10"
tags = ["Azure Front Door", "Serverless Compute" , "Azure Function"]
categories = ["Azure-Functions"]
[[images]]
  src = "img/2022/03/Diversion.jpg"
  alt = "Take-Diversion"

+++

# Introduction

A colleague of mine wasn’t happy with the manual solution that probes the Azure Function endpoints and diverts them to the secondary instance in case of failures. So, he came up with the Microsoft [document](https://docs.microsoft.com/en-us/azure/azure-functions/functions-geo-disaster-recovery) and asked me to help him with the DevOps approach. For now, hold tight. I don’t have a template for the Front Door. So, I gave him an interim solution. 

***I promise to share the 100% production-ready DevOps steps to deploy Azure Functions in my upcoming blogs and vlogs. If you aren’t aware of my youtube channel, [here](https://www.youtube.com/c/iAutomate) it is!*** 

## Project Structure (Foundation)

📦automata
 ┣ 📂scripts
 ┃ ┣ 📜createfrontdoor.ps1
 ┃ ┗ 📜deploy.ps1
 ┣ 📂template
 ┃ ┣ 📂modules
 ┃ ┃ ┣ 📂appinsight
 ┃ ┃ ┃ ┗ 📜appinsight.bicep
 ┃ ┃ ┣ 📂appserviceplan
 ┃ ┃ ┃ ┗ 📜appserviceplan.bicep
 ┃ ┃ ┣ 📂functionapp
 ┃ ┃ ┃ ┗ 📜functionapp.bicep
 ┃ ┃ ┗ 📂storageaccount
 ┃ ┃ ┃ ┗ 📜storageaccount.bicep
 ┃ ┗ 📜main.bicep
 ┗ 📜README.md

{{< youtube BrEgBBBCLGA >}}

## Bicep Template

### Application Insight 

```Bicep
param appinsightname string
param location string

resource appinsightscomponents 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: appinsightname
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Bluefield'
    Request_Source: 'rest'
  }
}
output instrumentationkey string = reference(appinsightscomponents.id, appinsightscomponents.apiVersion).InstrumentationKey
```

### App Service Plan

```Bicep
param appserviceplanname string
param location string

resource appserviceplan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: appserviceplanname
  location: location
  sku: {
    tier: 'ElasticPremium'
    name: 'EP1'
    family: 'EP'
  }
}

output appserviceplanid string = appserviceplan.id
```

### Storage Account

```Bicep
param storageaccountname string
param location string

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageaccountname
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
  }
}

output storageaccountid string = storageaccount.id
output storageaccountapiversion string = storageaccount.apiVersion
output storageaccountname string = storageaccount.name
output connstring string = 'DefaultEndpointsProtocol=https;AccountName=${storageaccountname};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageaccount.id, storageaccount.apiVersion).keys[0].value}'
```

### Function App

```Bicep
param functionappname string
param location string
param serverfarmid string
param appinsightkey string
param connstring string
resource azureFunction 'Microsoft.Web/sites@2020-12-01' = {
  name: functionappname
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: serverfarmid
    siteConfig: {
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appinsightkey
        }
        {
          name: 'AzureWebJobsStorage'
          value: connstring
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: connstring
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(functionappname)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'powershell'
        }
      ]
      use32BitWorkerProcess: false
    }
  }
}
```

### Main Bicep File 

```Bicep
targetScope = 'subscription'

@description('Name of the resource group')
param resourceGroupname string

@description('Location of the resource group')
param location string

@description('Name of the storage account')
param storageaccountname string

@description('Application Insight Name')
param appinsightname string

@description('App Service Plan (Hosting Plan)')
param appserviceplanname string

@description('Name of the function')
param functionappname string

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupname
  location: location
}

module storageaccount './modules/storageaccount/storageaccount.bicep' = {
  name: 'stg-account-deploy'
  params: {
    storageaccountname: storageaccountname
    location: resourceGroup.location
  }
  scope: resourceGroup
}

module appinsight 'modules/appinsight/appinsight.bicep' = {
  name: 'app-insight-deploy'
  params: {
    appinsightname: appinsightname
    location: resourceGroup.location
  }
  scope: resourceGroup
}

module appserviceplan './modules/appserviceplan/appserviceplan.bicep' = {
  name: 'app-service-plan-deploy'
  params: {
    appserviceplanname: appserviceplanname
    location: resourceGroup.location
  }
  scope: resourceGroup
}

module functionapp './modules/functionapp/functionapp.bicep' = {
  name: 'function-app-deploy'
  params: {
    functionappname: functionappname
    appinsightkey: appinsight.outputs.instrumentationkey
    location: resourceGroup.location
    serverfarmid: appserviceplan.outputs.appserviceplanid
    connstring: storageaccount.outputs.connstring
  }
  scope: resourceGroup
  dependsOn: [
    storageaccount
    appinsight
    appserviceplan
  ]
}

output InstrumentationKey string = appinsight.outputs.instrumentationkey
output appserviceplan string = appserviceplan.outputs.appserviceplanid
output storageaccountname string = storageaccount.name
```

## Script to Deploy

```PowerShell
bicep build .\template\main.bicep
Start-Sleep -Seconds 5 -Verbose
$regions = @('northeurope' , 'westus')
foreach ($region in $regions) {
    switch ($region) {
        'northeurope' {
            $Params = @{  
                Name                    = $([string]::Concat('az-deploy-', $($region)))
                TemplateFile            = 'template\main.json'
                Location                = 'northeurope'
                TemplateParameterObject = @{
                    resourcegroupname  = 'rgp-func-prim-dev-en'; 
                    location           = 'northeurope'; 
                    storageaccountname = 'stgfuncprimdeven'
                    appinsightname     = 'ai-prim-automata-en-dev'
                    appserviceplanname = 'asp-prim-automata-en-dev'
                    functionappname    = 'func-prim-automata-en-dev' 
                }
                verbose                 = $true
            }
            New-AzDeployment @Params
        }
        'westus' {
            $Params = @{  
                Name                    = $([string]::Concat('az-deploy-', $($region)))
                TemplateFile            = 'template\main.json'
                Location                = 'westus'
                TemplateParameterObject = @{
                    resourcegroupname  = 'rgp-func-prim-dev-uw'; 
                    location           = 'westus'; 
                    storageaccountname = 'stgfuncprimdevuw'
                    appinsightname     = 'ai-prim-automata-uw-dev'
                    appserviceplanname = 'asp-prim-automata-uw-dev'
                    functionappname    = 'func-prim-automata-uw-dev' 
                }
                verbose                 = $true
            }
            New-AzDeployment @Params
        }
    }
}
```

## Create Azure Front Door

```PowerShell
# Create a resource group
New-AzResourceGroup -Name 'rgp-frontdoor-global-dev' -Location 'northeurope'

# Create a unique name
$fdname = "automata-frontend"

#Create the frontend object
$FrontendEndObject = New-AzFrontDoorFrontendEndpointObject -Name "automata-frontend" -HostName $fdname".azurefd.net" -Verbose

$AppEN = Get-AzWebApp -Name 'func-prim-automata-en-dev'
$AppUW = Get-AzWebApp -Name 'func-prim-automata-uw-dev'

# Create backend objects that points to the hostname of the web apps
$backendObject1 = New-AzFrontDoorBackendObject -Address $AppEN.DefaultHostName
$backendObject2 = New-AzFrontDoorBackendObject -Address $AppUW.DefaultHostName

# Create a health probe object
$HealthProbeObject = New-AzFrontDoorHealthProbeSettingObject -Name "HealthProbeSetting" -Verbose

# Create the load balancing setting object
$LoadBalancingSettingObject = New-AzFrontDoorLoadBalancingSettingObject `
    -Name "Loadbalancingsetting"  `
    -SampleSize "4" `
    -SuccessfulSamplesRequired "2" `
    -AdditionalLatencyInMilliseconds "0" -Verbose

# Create a backend pool using the backend objects, health probe, and load balancing settings
$BackendPoolObject = New-AzFrontDoorBackendPoolObject `
    -Name "automata-backend" `
    -FrontDoorName $fdname `
    -ResourceGroupName 'rgp-frontdoor-global-dev' `
    -Backend $backendObject1, $backendObject2 `
    -HealthProbeSettingsName "HealthProbeSetting" `
    -LoadBalancingSettingsName "Loadbalancingsetting"

# Create a routing rule mapping the frontend host to the backend pool
$RoutingRuleObject = New-AzFrontDoorRoutingRuleObject `
    -Name LocationRule `
    -FrontDoorName $fdname `
    -ResourceGroupName 'rgp-frontdoor-global-dev' `
    -FrontendEndpointName "automata-frontend" `
    -BackendPoolName "automata-backend" `
    -PatternToMatch "/*"


# Creates the Front Door
New-AzFrontDoor `
    -Name $fdname `
    -ResourceGroupName 'rgp-frontdoor-global-dev' `
    -RoutingRule $RoutingRuleObject `
    -BackendPool $BackendPoolObject `
    -FrontendEndpoint $FrontendEndObject `
    -LoadBalancingSetting $LoadBalancingSettingObject `
    -HealthProbeSetting $HealthProbeObject -Verbose
```

## Output 

{{< youtube TEkMhZn1WiU >}}