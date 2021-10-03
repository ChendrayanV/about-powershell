---
title: "Hello World"
date: 2021-10-03T09:51:01+05:30
draft: false
image_webp: ""
image: images/blog/Hello-World.jpg
author: Chendrayan Venkatesan
description : "Hello, World"
---

# Introduction

I have no access to my organization DevOps due to unfortunate technical issues, but that didn’t stop me from working. This morning I was on a call with a business owner who asked me to show the steps to create service connections with the certificate.   Yes, I have to use the OPEN SSL tool to convert the PFX to PEM, and it was a bit difficult for me to walk him through the steps remotely. So, I got the PAT and certificate from the user and started my experiment in the REST API. After a few struggles, I managed to set up the service connection. Here is the PowerShell script.

> Replace the value for certificate, PAT, subscriptionid & name , service principal and tenant id.

```PowerShell
$Certificate = @"
{YOUR CERTIFICATE}
"@
$PAT = "PAT TOKEN"
$PATGetBytes = [System.Text.Encoding]::ASCII.GetBytes(":$PAT")
$Authentication = [System.Convert]::ToBase64String($PATGetBytes)
$Headers = @{Authorization = ("Basic {0}" -f $Authentication) }
$Uri = "https://dev.azure.com/about-powershell/iShell/_apis/serviceendpoint/endpoints?api-version=5.1-preview.2"
$Body = [pscustomobject]@{
    administratorsGroup = "null"
    data = [pscustomobject]@{
        subscriptionId = ''
        subscriptionName = ''
        CreationMode = 'Manual'
        scopeLevel = 'Subscription'
    }
    authorization = [pscustomobject]@{
            scheme = 'ServicePrincipal'
            parameters = [pscustomobject]@{
            authenticationType = 'spnCertificate'
            servicePrincipalCertificate = $certificate
            serviceprincipalid = ''
            tenantid = ''
        }
    }
    name = 'DEVEPLOPMENT'
    type = 'azurerm'
    url = 'https://management.azure.com/'
} | ConvertTo-Json -Depth 10
Invoke-RestMethod -Uri $Uri -Method Post -Body $Body -Headers $Headers -ContentType 'application/json'
```

Upon successful execution of the script, you can see the result on the service connection page. The point is, no information about subscription,scope, and tenant information is visible. The update of the service connection is possible via REST API in this case, and no UI is supported.
