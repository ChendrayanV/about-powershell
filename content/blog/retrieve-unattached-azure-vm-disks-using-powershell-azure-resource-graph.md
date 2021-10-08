+++
author = "Chendrayan Venkatesan"
categories = ["Azure"]
tags = ["KQL" , "PowerShell", "Azure Resource Graph"]
date = "2020-05-01"
description = "Cost Saving..."
featured = "unattached-disks.jpg"
featuredalt = "unattached-disks"
featuredpath = "date"
linktitle = ""
title = "Retrieve unattached Azure VM disks using PowerShell & Azure Resource Graph"
type = "post"
draft = "false"

+++

# Introduction
As part of the cost saving project task, I developed a PowerShell script to retrieve UNATTACHED disks. I used JOIN operator in this code to get a few tag information from the respective resource group. 

> Replace value for the {TAGNAME}.

```PowerShell
$Query = "Resources
            | where type =~ 'Microsoft.Compute/disks'
            | where properties.diskState =~ 'Unattached'
            | project id, name, subscriptionId, resourceGroup, diskInGB = properties.diskSizeGB, diskState = properties.diskState, timeCreated = properties.timeCreated
            | join kind=inner(
            ResourceContainers
                | where type =~ 'microsoft.resources/subscriptions/resourcegroups'
                | project id, name, subscriptionId, resourceGroup, owner = tags.{TAGNAME}, Administrator = tags.{TAGNAME}, MonitoringAlertContact = tags.{TAGNAME})
            on subscriptionId, resourceGroup
            | project-away id1, name1, subscriptionId1, resourceGroup1"
$pageSize = 5000
$iteration = 0
$searchParams = @{
    Query = $($Query)
    First = $pageSize
}
[System.Collections.ArrayList]$results = @()
do {
    $iteration += 1
    $pageResults = Search-AzGraph @searchParams -Verbose
    $searchParams.Skip += $pageResults.Count
    $results.AddRange($pageResults)
} while ($pageResults.Count -eq $pageSize)
```

## Multi-purpose queries

> Not in current year! 

```PowerShell
($results | ? {$_.timeCreated -lt (Get-Date).AddYears(-1)}) | Select name , timeCreated , diskinGB
```

> Less than a month older

```PowerShell
($results | ? {$_.timeCreated -lt (Get-Date).AddMonths(-1)}) | Select name , timeCreated 
```

> Where disk size is 32 GB

```PowerShell
($results | ? {$_.diskInGB -eq 32})
```