+++
author = "Chendrayan Venkatesan"
categories = ["Azure Resource Graph"]
tags = ["Azure Resource Graph" , "PowerShell"]
date = "2021-02-07"
description = "Azure Resource Graph | PowerShell"
featured = "ARG-PS-Collection.jpg"
featuredalt = "ARG-PS-Collection"
featuredpath = "date"
linktitle = ""
title = "Collection of Azure Resource Graph Query"
type = "post"

+++

# Introduction

This blog post is to share the Azure Resource Graph query I developed at my workplace. I have used this with PowerShell and Azure Monitor. 

## Azure Virtual Machines PowerState Report

```powershell
$Query = "Resources
| where type =~ 'microsoft.compute/virtualMachines'
| project id, VMName = tostring(name), Location = tostring(location), 
    ResourceGroup = tostring(resourceGroup), 
    SubscriptionId = tostring(subscriptionId), 
    OSType = tostring(properties.storageProfile.osDisk.osType),
    PowerState = iff(
    tostring(
    split(
    properties.extended.instanceView.powerState.code, '/'
    )[1]
    ) != '', tostring(split(properties.extended.instanceView.powerState.code, '/')[1]), 'transitioning'
    )"
$PageSize = 1000
$Iteration = 0
$SearchParams = @{
    Query = $($Query)
    First = $PageSize
}
[System.Collections.ArrayList]$Results = @()
do {
    $Iteration += 1
    $PageResults = Search-AzGraph @searchParams -Verbose
    $SearchParams.Skip += $pageResults.Count
    $Results.AddRange($pageResults)
} while ($PageResults.Count -eq $PageSize)
$Results
```
### Azure Virtual Machines (Summarized Reports)

### Count By Location
```powershell
Search-AzGraph -Query "where type =~ 'Microsoft.Compute/virtualMachines' | summarize count() by location"
```

### Count By OS Type 
```powershell
Search-AzGraph -Query "where type =~ 'Microsoft.Compute/virtualMachines' | project id, osType= tostring(properties.storageProfile.osDisk.osType) |summarize count() by osType"
```

### Count By Resource Group
```powershell
Search-AzGraph -Query "where type =~ 'Microsoft.Compute/virtualMachines' | summarize count() by resourceGroup"
```
### Count By Power State
```powershell
Search-AzGraph -Query "where type =~ 'Microsoft.Compute/virtualMachines' 
| project id, powerState = tostring(split(properties.extended.instanceView.powerState.code, '/')[1]) 
| summarize count() by powerState"
```

## Azure Virtual Machines Backup Report

```powershell
$Query = "RecoveryServicesResources
| where type =~ 'microsoft.recoveryservices/vaults/backupfabrics/protectioncontainers/protecteditems'
| where properties.backupManagementType =~ 'AzureIaasVM'
| project id, SubscriptionId = subscriptionId, VMName = tostring(properties.friendlyName), 
    LastRecoveryPoint = tostring(properties.lastRecoveryPoint), 
    PolicyName = tostring(properties.policyName), 
    ProtectionStatus = tostring(properties.protectionStatus), 
    CurrentProtectionState = tostring(properties.currentProtectionState),
    BackupId = tostring(properties.id),
    IsBackedUp = isnotempty(id),
    recoveryServiceVault = split(id, '/')[8]"
$PageSize = 1000
$Iteration = 0
$SearchParams = @{
    Query = $($Query)
    First = $PageSize
}
[System.Collections.ArrayList]$RecoveryServicesResources = @()
do {
    $Iteration += 1
    $PageResults = Search-AzGraph @SearchParams -Verbose
    $SearchParams.Skip += $PageResults.Count
    $RecoveryServicesResources.AddRange($PageResults)
} while ($PageResults.Count -eq $PageSize)
$RecoveryServicesResources
```