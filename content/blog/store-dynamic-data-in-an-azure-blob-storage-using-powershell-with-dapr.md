+++
title = "Store Dynamic Data in an Azure Blob Storage using PowerShell with Dapr"
description = ""
author = "Chendrayan Venkatesan"
draft = "false"
date = "2022-02-22"
tags = ["Dapr", "Output Binding"]
categories = ["Bicep" , "Azure-Container-Apps"]
[[images]]
  src = "img/2022/02/DAPR-OP-BINDING.PNG"
  alt = "DAPR-OP-BINDING"

+++

# Introduction

The detailed documentation on the Azure Blob Storage binding component is super helpful. With that reference, let me walk you through the steps to store dynamic data to Azure blob storage without writing additional code (using blob API) to interact with the blob. Instead, we use the Dapr binding API. 

## Binding Component Format

```YAML
apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: bloboutput
spec:
  type: bindings.azure.blobstorage
  version: v1
  metadata:
  - name: storageAccount
    value: icontoso
  - name: storageAccessKey
    value: {YOUR_STORAGE_ACCOUNT_KEY}
  - name: container
    value: demo
  - name: decodeBase64
    value: true
  - name: getBlobRetryCount
    value: 3
```

## Build a web server (Static Blob Content) - app.ps1

```PowerShell
Start-PodeServer {
    Add-PodeEndpoint -Address * -Port 3000 -Protocol Http 
    Add-PodeRoute -Method Get -Path '/bloboutput' -ScriptBlock {
        $Bytes = [System.Text.Encoding]::Unicode.GetBytes("Hello, World!")
        $EncodedText = [Convert]::ToBase64String($Bytes)
        $body = [PSCustomObject]@{
            operation = 'create'
            data      = $($EncodedText)
            metadata  = [PSCustomObject]@{
                blobName = 'name.txt'
            }
        } | ConvertTo-Json -Compress
        Invoke-RestMethod -Uri 'http://localhost:3500/v1.0/bindings/bloboutput' `
            -Method Post `
            -Body $body `
            -ContentType 'application/json'
    }
} -DisableTermination
```

## Run the Application

```PowerShell
PS C:\> dapr run --app-id outputblob --app-port 3000 --dapr-http-port 3500 --dapr-grpc-port 60002 --components-path .\components\ -- pwsh .\output-binding\app.ps1
```

## Invoke the REST API

```PowerShell
PS C:\> Invoke-RestMethod -Uri 'http://localhost:3000/bloboutput' 
```

> Hey, wait! Data we store in the blob is not dynamic! I see hello, world content in the blob for every execution. Yes, you are right! Let us modify the app.ps1 to store the dynamic content. 

## Build a web server (Static Blob Content) - app.ps1

```PowerShell
Start-PodeServer {
    Add-PodeEndpoint -Address * -Port 3000 -Protocol Http 
    Add-PodeRoute -Method Post -Path '/bloboutput' -ScriptBlock {
        $Bytes = [System.Text.Encoding]::Unicode.GetBytes($($WebEvent.Request.Body))
        $EncodedText = [Convert]::ToBase64String($Bytes)
        $body = [PSCustomObject]@{
            operation = 'create'
            data      = $($EncodedText)
            metadata  = [PSCustomObject]@{
                blobName = 'name.txt'
            }
        } | ConvertTo-Json -Compress
        Invoke-RestMethod -Uri 'http://localhost:3500/v1.0/bindings/bloboutput' `
            -Method Post `
            -Body $body `
            -ContentType 'application/json'
    }
} -DisableTermination
```

***$Bytes = [System.Text.Encoding]::Unicode.GetBytes($($WebEvent.Request.Body))*** is the trick to get dynamic contents. 

```PowerShell 
$Data = [pscustomobject]@{
    Name     = 'Chen'
    Location = 'Bangalore'
} | ConvertTo-Json -Compress
Invoke-RestMethod -Uri 'http://localhost:3000/bloboutput' -Body $($Data) -Method Post -ContentType 'application/json'
```

### Output 

Access the storage blob! You should see the content 😊 