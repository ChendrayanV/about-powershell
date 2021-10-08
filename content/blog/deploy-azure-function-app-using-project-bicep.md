+++
author = "Chendrayan Venkatesan"
categories = ["Azure", "Project Bicep", "ARM", "Azure Functions"]
date = "2021-01-07"
linktitle = ""
featured = "az-function-app.jpg"
featuredpath = "date"
featuredalt = ""
title = "Deploy Azure Function App using Project Bicep"
description = "project bicep ... an arm dsl"
type = "post"
draft = "false"

+++

# References

Refer to the below links to know more about the project bicep

1. GitHub
    1. [Repository](https://github.com/Azure/bicep)
    2. [Docs](https://github.com/Azure/bicep/tree/main/docs)
    3. [Examples](https://github.com/Azure/bicep/tree/main/docs/examples)
    4. [Tutorials](https://github.com/Azure/bicep/tree/main/docs/tutorial)
    5. [Specifications](https://github.com/Azure/bicep/tree/main/docs/spec)
    
2. YouTube
    1. [Intro to Azure's Project Bicep with Brendan Burns and team](https://www.youtube.com/watch?v=GHLUVwDkRrQ)
    2. [Project Bicep Demo at Ignite 2020 by Mark Russinovich](https://www.youtube.com/watch?v=ykHA5QTYlDc)
    3. [Project Bicep and ARM Templates November 2020 Update](https://www.youtube.com/watch?v=9Vfw5IhwT84) 

## Introduction 

Project Bicep is growing well, and I am using it at my workplace to build proof of concepts environments. In my last [blog post](http://about-powershell.com/blog/get-started-with-project-bicep/), I showed how to use bicep in Azure DevOps. Now, let me show the steps to deploy the Azure Function app using project bicep.     

### Prerequisites:

1. Azure Account.
2. Contributor Permission on Azure subscriptions. 
3. Resource Group
    1. rg-azeusfunctionappdev01

> Note: *The first time I made a mistake – I ignored kind=’Function App'. So, it created a web app. Redeploying by adding kind ended up with the below error.*

```powershell
Status Message: Consumption pricing tier cannot be used for regular web apps. (Code: Conflict)
 - Consumption pricing tier cannot be used for regular web apps. (Code:)
 -  (Code:Conflict)
 -  (Code:)
```

> Solution: *Clear the resource group and redeploy it!*

## Bicep Code

```powershell
var location = resourceGroup().location
var suffix = 'azeusfunctionappdev01'

resource storage_account 'Microsoft.Storage/storageAccounts@2020-08-01-preview' = {
  name: 'stg${suffix}'
  location: location
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
  }
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
}

resource hosting_plan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: 'asp-${suffix}'
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
}

resource function_app 'Microsoft.Web/sites@2020-06-01' = {
  name: 'functionapp-${suffix}'
  location: location
  kind: 'functionapp'
  properties: {
    httpsOnly: true
    serverFarmId: hosting_plan.id
    clientAffinityEnabled: true
    siteConfig: {
      appSettings: [
        {
          'name': 'FUNCTIONS_EXTENSION_VERSION'
          'value': '~3'
        }
        {
          'name': 'FUNCTIONS_WORKER_RUNTIME'
          'value': 'powershell'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storage_account.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storage_account.id, storage_account.apiVersion).keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: '${substring(uniqueString(resourceGroup().id), 3)}-azeus-functionapp-dev01'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storage_account.name};AccountKey=${listKeys(storage_account.id, storage_account.apiVersion)};EndpointSuffix=core.windows.net'
        }
      ]
    }
  }

  dependsOn: [
    hosting_plan
    storage_account
  ]
}
```

### Build Bicep

```powershell
PS C:\> build bicep .\main.bicep
```

### Deploy 

```powershell
PS C:\> New-AzResourceGroupDeployment -ResourceGroupName "rg-azeusfunctionappdev01" -TemplateFile .\Main.json -Debug
```

### Result

![AzFunctionApp](img/AzFuncApp.PNG)