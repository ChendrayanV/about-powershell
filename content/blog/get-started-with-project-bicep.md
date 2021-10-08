+++
author = "Chendrayan Venkatesan"
categories = ["Azure"]
date = "2021-01-03"
linktitle = ""
featured = "bicep-header.jpg"
featuredpath = "date"
featuredalt = ""
title = "Get started with project bicep"
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

As a first step, we need to install the bicep tools on our local computer. If you need to deploy the solution using Az DevOps, follow the steps given in the "Deploy Bicep Solution using Azure DevOps" section.

### Install Bicep

```powershell
$installPath = "$env:USERPROFILE\.bicep"
$installDir = New-Item -ItemType Directory -Path $installPath -Force
$installDir.Attributes += 'Hidden'
(New-Object Net.WebClient).DownloadFile("https://github.com/Azure/bicep/releases/latest/download/bicep-win-x64.exe", "$installPath\bicep.exe")
$currentPath = (Get-Item -path "HKCU:\Environment" ).GetValue('Path', '', 'DoNotExpandEnvironmentNames')
if (-not $currentPath.Contains("%USERPROFILE%\.bicep")) { setx PATH ($currentPath + ";%USERPROFILE%\.bicep") }
if (-not $env:path.Contains($installPath)) { $env:path += ";$installPath" }
bicep build main.bicep
```

Upon the successful installation, try the below-listed commands

```powershell
Bicep –version
Bicep –help
```

### Create project scaffolding

📦src  
┣ 📂scripts  
┣ 📂storage_account  
┃ ┗ 📜storage_account.bicep  
┣ 📜main.bicep  

### (storage_account.bicep) file

```powershell
param storage_account_name string = 'stgbicepdev'

resource storage_account 'Microsoft.Storage/storageAccounts@2020-08-01-preview' = {
  name: 'stgbicepdev'
  location: 'eastus2'
  properties: {
    accessTier: 'Hot'
  }
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  kind: 'BlobStorage'
}
```

### (storage_account.bicep) file

```powershell
targetScope = 'subscription'

param resource_group_name string = 'rg-bicep-dev'

resource rg 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: resource_group_name
  location: 'eastus2'
}

module storage_account './storage_account/storage_account.bicep' = {
  name: 'storage_account'
  scope: resourceGroup(rg.name)
}
```

### Build

Now it's time for us to start with the first build

```powershell
PS C:\repos\Project-Bicep\src> build bicep .\main.bicep
```
If the above command is successful, we should see a main.json file in the ‘SRC’ folder.

### Test and Deploy

```powershell
PS C:\repos\Project-Bicep\src> Test-AzDeployment -Location 'East US 2' -TemplateFile .\main.json -Verbose
PS C:\repos\Project-Bicep\src> New-AzDeployment -Location 'East US 2' -TemplateFile .\main.json -Verbose
```

### How do we show the outputs?

```powershell
# MODULE (storage_account.bicep)
output storage_account_id string = storage_account.id
# MAIN (main.bicep)
output storage_account_id string = storage_account.outputs.storage_account_id
```
![output](img/output.png)

## Deploy project bicep using Azure DevOps

To deploy the bicep solutions using Az DevOps, a minor change is required in the project scaffolding. Below illustrated tree view helps you to get it done.

📦.azure-pipelines  
┗ 📜storage_account.yml 

Add a folder ".azure-pipelines," and underneath it, add a file name "storage_account.yml."

To install the bicep cli in the Az DevOps pipeline, we use the same PowerShell script file (Refer install bicep section in introduction). It's nice to place it inside the script folder as shown below

📦scripts  
┗ 📜BICEP.PS1  

### (storage_account.yml)

**Replace the value of azureResourceManagerConnection and subscriptionId**

```yml
trigger:
  branches:
    include:
      - 'main'

pool:
  vmImage: 'windows-latest'

stages:
  - stage: 'BUILD'
    jobs:
      - job: 
        steps:
          - task: PowerShell@2
            inputs:
              targetType: filePath
              filePath: '\scripts\BICEP.PS1'
          - task: CopyFiles@2
            inputs:
              SourceFolder: '.\SRC\'
              Contents: '*.json'
              TargetFolder: $(Build.ArtifactStagingDirectory)
          - task: PublishBuildArtifacts@1
            inputs:
              PathtoPublish: $(Build.ArtifactStagingDirectory)
              ArtifactName: 'BICEP'
  - stage: 'RELEASE'
    jobs:
      - job: 
        steps:
          - task: DownloadBuildArtifacts@0
            inputs:
              buildType: current
              downloadType: single
              artifactName: BICEP
              downloadPath: $(System.ArtifactsDirectory)
          - task: AzureResourceManagerTemplateDeployment@3
            inputs:
              azureResourceManagerConnection: '{SERVICE CONNECTION NAME}'
              deploymentScope: Subscription
              csmFile: '$(System.ArtifactsDirectory)\src\MAIN.json'
              location: 'eastus2'
              deploymentName: 'AZURE.WVD'
              subscriptionId: '{SUBSCRIPTION ID}'
```