+++
author = "Chendrayan Venkatesan"
categories = ["Azure" , "PowerShell" , "JIT"]
date = "2021-01-04"
linktitle = ""
featured = "security.jpg"
featuredpath = "date"
featuredalt = "security"
title = "Retrieve a list of Azure VM which aren't protected with just-in-time network access control"
description = "PowerShell script to list VM's with no JIT enabled"
type = "post"
draft = "false"

+++

# Introduction

I was asked to build a PowerShell script to retrieve Azure virtual machines with no Just In Time (JIT) access enabled. Yes, it’s for the security auditing team. I searched in PowerShell Gallery, TechNet Gallery, and other sources and didn’t find one. So, I developed a script that may help you!

## Solution

First, I thought of retrieving virtual machines and query against the JIT Access Policy REST API endpoint. But it's not required! Using Azure Advisor recommendation API is super fast and easy.

```powershell
# Connect-AzAccount -UseDeviceAuthentication
$azureRmProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
$currentAzureContext = Get-AzContext
$profileClient = New-Object Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient($azureRmProfile)
$header = "Bearer {0}" -f ($profileClient.AcquireAccessToken($currentAzureContext.Subscription.TenantId).AccessToken)
$Subscriptions = Get-AzSubscription | Where-Object { $_.State -eq 'Enabled' }
[System.Collections.ArrayList]$Results = @()
foreach ($Subscription in $Subscriptions) {
    # $Subscription
    $Uri = "https://management.azure.com/subscriptions/$($Subscription.Id)/providers/Microsoft.Advisor/recommendations?api-version=2017-04-19&`$filter=RecommendationTypeGuid eq '805651bc-6ecd-4c73-9b55-97a19d0582d0'"
    do {
        $Result = Invoke-RestMethod -Uri $Uri -Headers @{Authorization = $header } -Verbose
        $Results.AddRange($Result.value)
        $Uri = $Result.nextLink
    } until ($null -eq $Uri)
}
$Results.properties | Select-Object impactedValue , lastUpdated
```

> Result (Secure the VM)

![JIT](img/JIT.png)