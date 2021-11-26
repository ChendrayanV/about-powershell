+++
title = "Bicep template for Azure Container Apps"
description = ""
author = "Chendrayan Venkatesan"
draft = "false"
date = "2021-11-26"
tags = ["Container Apps","Bicep"]
categories = ["Bicep" , "Azure-Container-Apps"]
[[images]]
  src = "img/2021/11/bicep-container-app.jpg"
  alt = "Container-Apps"

+++

# Introduction

In my previous blog post, we got basic information about the Azure Container Apps! As we all know, the Azure Container Apps service is in preview, and there is a lot more to add to the features list. Now, let us see how to build a Bicep template to deploy an application in container apps. First, I would like to thank [Thorsten Hans](https://github.com/ThorstenHans) for the fantastic blog post [How to deploy Azure Container Apps with Bicep](https://www.thorsten-hans.com/how-to-deploy-azure-container-apps-with-bicep/). 

*While following the steps shared by Thorsten Hans, I see an issue in the listKeys() function. So, I slightly modified the code as illustrated below, and it is modularized for easy readability.*

## Bicep Template 

### Parameters

```PowerShell
param environment string = 'dev'
param owner string = 'Chendrayan Venkatesan'
param costcenter string = 'AZ-0023'
param suffix string = 'dev'
param location string = 'northeurope'
param logAnalyticsName string = 'Law-Containers-App'
param kubeEnvironmentName string = 'Kube-Environment'
param containerAppName string = 'colorsofcuisine'
param registryPassword string = 'REPLACEWITHYOURPASSWORD'
```

### Resource Group

```PowerShell
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'colorsofcuisine-${suffix}'
  location: location
  tags: {
    'env': environment
    'owner': owner
    'costcenter': costcenter
  }
}
```

### Create a Log Analytics Workspace

[Module Code](https://github.com/ChendrayanV/Collabrains.Cloud/blob/main/templates/modules/az-log-analytics/log-analytics.bicep)

```PowerShell
module LogAnalyticsworkSpace 'modules/az-log-analytics/log-analytics.bicep' = {
  name: 'log-analytics-deployment'
  scope: resourceGroup(rg.name)
  params: {
    logAnalyticsName: '${logAnalyticsName}-${suffix}'
  }
}
```

### Create a Kube Environment

[Module Code](https://github.com/ChendrayanV/Collabrains.Cloud/blob/main/templates/modules/az-kube-environment/az-kube-environment.bicep)

```PowerShell
module kubeEnvironment 'modules/az-kube-environment/az-kube-environment.bicep' = {
  name: 'kube-deployment-${suffix}'
  params: {
    customerId: LogAnalyticsworkSpace.outputs.customerId
    primarySharedKey: LogAnalyticsworkSpace.outputs.primarySharedKey
    kubeEnvironmentName: '${kubeEnvironmentName}-${suffix}'
  }
  scope: resourceGroup(rg.name)
}
```

### Create Azure Container App

[Module Code](https://github.com/ChendrayanV/Collabrains.Cloud/blob/main/templates/modules/az-container-app/container-app.bicep)

```PowerShell
module containerApp 'modules/az-container-app/container-app.bicep' = {
  name: '${containerAppName}-${suffix}'
  scope: resourceGroup(rg.name)
  params: {
    kubeEnvironmentId: kubeEnvironment.outputs.kubeEnvironmentId
    registryPassword: registryPassword
    containerAppName: containerAppName
  }
}
```

## Docker Image

```Dockerfile
FROM mcr.microsoft.com/powershell:latest
WORKDIR /usr/src/app/
COPY . .    
RUN pwsh -c "Install-Module 'Pode' , 'PSHTML' -Force -AllowClobber"
CMD [ "pwsh", "-c", "cd /usr/src/app; ./app.ps1" ]
```

> Docker Image is available [here](https://hub.docker.com/repository/docker/chenv/collabrains.cloud) and you can develop and replace app.ps1

📦Collabrains.Cloud
 ┣ 📂application
 ┃ ┣ 📂views
 ┃ ┃ ┗ 📜index.ps1
 ┃ ┣ 📜app.ps1
 ┃ ┗ 📜Dockerfile
 ┗ 📜readme.md

### Application (app.ps1)

```PowerShell
Start-PodeServer {
    Add-PodeEndpoint -Address * -Port 80 -Protocol Http
    Set-PodeViewEngine -Type PSHTML -Extension PS1 -ScriptBlock {
        param($path, $data)
        return (. $path $data)
    }
    Add-PodeRoute -Method Get -Path '/' -ScriptBlock {
        Write-PodeViewResponse -Path "index.ps1"
    }
}
```

### Views (views/index.ps1)

```PowerShell
param($data)

function CustomCard {
    Param (
        $ImageSrc
    )

    Div -Class 'cell-lg-4' -Content {
        Div -Class 'price-item text-center bg-white win-shadow' -Content {
            Div -Class 'price-item-header p-6' -Content {
                Div -Class 'img-container rounded' -Content {
                    img -src $($ImageSrc)
                    Div -Class 'image-overlay op-green' 
                }
            }
        }
    }
}
return html -Content {
    head -Content {
        Title -Content "CoC | Index"
        Link -href "https://cdn.metroui.org.ua/v4.3.2/css/metro-all.min.css" -rel "stylesheet"
        script -src "https://cdn.metroui.org.ua/v4/js/metro.min.js"
    }
    body -Content {
        (1..3).ForEach({ br })
        Div -Class 'container' -Content {
            h3 -Class 'Secondary fg-lightBlue' -Content 'Colors of Cuisine...' -Style 'text-align:center'
            hr
            Div -Class 'row flex-align-center rounded' -Content {
                @(
                    "https://media.istockphoto.com/photos/dabba-masala-picture-id465015726?b=1&k=20&m=465015726&s=170667a&w=0&h=IsNYymgb7aX2qZcZ-IdBVZ7xC1m6JNJ9ZFOcEvF_PiM=",
                    "https://media.istockphoto.com/photos/idly-or-idli-picture-id1306083224?b=1&k=20&m=1306083224&s=170667a&w=0&h=USIy9AUuJVA2dboZOHdAc8EUl_1QHWbivvRJUEYQfWk=",
                    "https://media.istockphoto.com/photos/frying-egg-in-a-cooking-pan-in-domestic-kitchen-picture-id1129381764?b=1&k=20&m=1129381764&s=170667a&w=0&h=P3Gw15Zps0Mu_NF7wNwVkfpVqGV3LC7Pg1YbZXBMcnc="
                ).ForEach(
                    {
                        CustomCard -ImageSrc $($_)  
                    }
                )
            }
            hr 
        }
    }
}
```

## Summary

Congratulations on running your Azure Container Apps using PowerShell, Pode and PSHML. There are a lot more coming up in the future, and please feel free to subscribe to my YouTube channel - [iAutomate](https://www.youtube.com/channel/UC22S6qPibfs1xa3MIII0JNw) and follow me on Twitter [ChendrayanV](https://twitter.com/chendrayanv) 