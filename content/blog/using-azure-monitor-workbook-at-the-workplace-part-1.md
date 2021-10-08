+++
author = "Chendrayan Venkatesan"
categories = ["Azure" , "Azure DevOps" , "Azure Workbook", "Azure Monitor"]
date = "2021-01-11"
linktitle = ""
featured = "azure-workbook.jpg"
featuredpath = "date"
featuredalt = ""
title = "Using Azure Monitor Workbook at the workplace - Part 1"
description = "Part 1 .... | Azure Monitor Workbook"
type = "post"
draft = "false"

+++

# Introduction

Azure Monitor Workbook is one of my favorite services in Azure Cloud. Why? I use to share scripts/queries with the operations team for reportings. During audits, I get more development works. So, I thought of using the Azure Monitor workbooks to serve the purpose. Indeed, the queries I built is tailor-made for my environment. However, through this blog post, I can share the nuances and some ready to use solutions. 

> Disclaimer: For some reason, below snippet failed. So, I managed to get it done using the joins. 

```powershell
Search-AzGraph -Query "Resources | limit 1" -Include DisplayNames
# ERROR
Search-AzGraph : Object reference not set to an instance of an object.
```

## Azure VM Inventory
    
> For example, ORG-MGMT-TEANT-PROJECT-OPERATINGENVIRONMENT-SOMETEXT. We require to manipulate texts for the reports.

```powershell
Resources
| where type =~ 'Microsoft.Compute/virtualMachines'
| project id, subscriptionId, resourceGroup, powerState = split(tostring(properties.extended.instanceView.powerState.code), '/').[1], osType = properties.storageProfile.osDisk.osType 
| join kind=inner(
    ResourceContainers
    | where type =~ 'microsoft.resources/subscriptions'
    | extend managementGroup = parse_json(tostring(tags['hidden-link-ArgMgTag']))[0]
    | extend serviceType = split(managementGroup, 'COLLABRAINS-AZMGMT-TENANT-TEAM-TECHNICAL-ROOT-')[1]
    | project id, subscriptionName = name, subscriptionId, serviceType, operatingEnvironment = case (
        tostring(split(serviceType, '-')[1]) startswith_cs 'DEV', 'DEVELOPMENT',
        tostring(split(serviceType, '-')[1]) startswith_cs 'PRD', 'PRODUCTION',
        'Unknown'), cloudEnvironment = case (
        tostring(managementGroup) has_cs 'VNET', 'VNET',
        tostring(managementGroup) has_cs 'EXTERNAL', 'EXTERNAL',
        'Unknown'), serviceType = case(
        tostring(managementGroup) endswith_cs 'Business-Critical', 'Business-Critical',
        tostring(managementGroup) endswith_cs 'Non-Business-Critical', 'Non-Business-Critical',
        'Unknown')
    )
    on subscriptionId
| project-away id1, subscriptionId1
```

### How this works? 

The above query uses a inner joins to combine two different tables (Resources & ResourceContainers) and produce the result. The power state appears as 'powerstate/running'. So, to make it bit more readable we use split & tostring function and derive the value as ‘running’ for the power state.

## Unattached Disks

```powershell
Resources
| where type =~ 'Microsoft.Compute/disks'
| where properties.diskState =~ 'Unattached'
| project id, subscriptionId, resourceGroup, diskInGB = properties.diskSizeGB, diskState = properties.diskState, timeCreated = properties.timeCreated
| join kind=inner(
    ResourceContainers
    | where type =~ 'microsoft.resources/subscriptions/resourcegroups'
    | where name endswith '-TAGS'
    | project id, subscriptionId, owners = tags.owners, contacts = tags.contacts, costcenter = tags.costcenter)
    on subscriptionId
| project-away id1, subscriptionId1
```

### Why inner join?

Each subscription has a resource group that ends with the name '-TEXT,' which contains the tag's value like owners, contacts, and cost center. The requirement is to include those values in the report so the operations team can communicate with them. 

## Charts

This section doesn’t need an introduction. Yes, we do count summarization to plot charts.

### Az VM count by OS type

```powershell
Resources
| where type =~ 'microsoft.compute/virtualMachines'
| project id, subscriptionId, osType = tostring(properties.storageProfile.osDisk.osType)
| summarize count() by osType
```    
![alt](img/VM-Count-By-OS-Type.png)

### Az VM count by power state

```powershell
Resources
| where type =~ 'microsoft.compute/virtualMachines'
| project id, subscriptionId, powerState = case (
    tostring(properties.extended.instanceView.powerState.code) =~ 'PowerState/running', "Running",
    tostring(properties.extended.instanceView.powerState.code) =~ 'PowerState/deallocated', "Deallocated",
    tostring(properties.extended.instanceView.powerState.code) =~ 'PowerState/stopped', "Stopped",
    tostring(properties.extended.instanceView.powerState.code) =~ 'PowerState/starting', "Starting",
    "Unknown"
    )
| summarize count() by powerState
```

![alt](img/VM-Count-By-Power-State.png)
### Az VM count by location

```powershell
Resources
| where type =~ 'microsoft.compute/virtualMachines'
| project id, subscriptionId, location = tostring(toupper(location))
| summarize count() by location
```

![alt](img/VM-Count-By-Region.png)

**Now that we have the basic idea of Azure Monitor Workbooks. My next blog post tentatively planned to publish on January 14, 2021, covers tabbed view and arm template.** 