+++
author = "Chendrayan Venkatesan"
categories = ["Azure"]
tags = ["PowerShell" , "Azure Functions" , "Event Grid Trigger" , "ServiceNow"]
date = "2020-08-01"
description = "Azure Functions | Event Grid Trigger"
featured = "Wheels.jpg"
featuredalt = "Wheels"
featuredpath = "date"
linktitle = ""
title = "Logging Service Now Requests using Event Grid Trigger"
type = "post"
draft = "false"

+++

# Introduction

A colleague of mine asked a solution for raising a service request in SNOW (Service Now) for each NSG rule creation and deletion.  I requested to develop a service now catalog and allow the system to work with NSG. That means, from SNOW to Azure connectivity through REST API. However, the ask is the other way around. If a user creates/deletes the NSG rule in the portal, log a REQ with the minimum information

## Requirement:
In short, the ask is to create a REQ in SNOW when an NSG rule is created or deleted. 


## Solution

{{< youtube Ps6Li7mpNuA >}}

## Prerequisites

1. Azure Account.
2. Service Now Account (Create developer Instance if you do not have one).
3. Event Grid Subscription.
4. Azure Function App. 

> PowerShell Script

```PowerShell
param($eventGridEvent, $TriggerMetadata)
[pscustomobject]@{
    EventType    = $eventGridEvent.eventType
    EventTime    = $eventGridEvent.eventTime
    ResourceUri  = $eventGridEvent.data.resourceUri
    ResourceName = ($eventGridEvent.data.resourceUri -split "/")[-1]
    IPAddress    = ($eventGridEvent.data.claims.ipaddr)
} | ConvertTo-Json -Depth 5 

switch ($eventGridEvent.data.operationName) {
    "Microsoft.Network/networkSecurityGroups/securityRules/write" {
        $RuleInformation = Get-AzNetworkSecurityGroup -Name $(($eventGridEvent.subject -split "/")[8]) `
            -ResourceGroupName $(($eventGridEvent.subject -split "/")[4]) | 
        Get-AzNetworkSecurityRuleConfig -Name "$(($data.subject -split "/")[-1])" #-DefaultRules
        $Headers = @{Authorization = "Basic {0}" -f ([Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $ENV:SNOWADMIN, $ENV:SNOWPASSWORD)))) }
        $Uri = "https://dev36626.service-now.com/api/now/table/sc_request?sysparm_limit=1"
        $Body = [PSCustomObject]@{
            short_description    = "Operation - $($eventGridEvent.data.operationName)"
            special_instructions = "No action required - This REQ is created for auditing"
            requested_for        = "System Administrator"
            description          = $($RuleInformation | ConvertTo-Json)
            state                = 4
            request_state        = "closed_complete"
        } | ConvertTo-Json 
        Invoke-RestMethod -Uri "$($Uri)" -Method Post -Headers $Headers -ContentType 'application/json' -Body $Body

    }
    "Microsoft.Network/networkSecurityGroups/securityRules/delete" {
        $Headers = @{Authorization = "Basic {0}" -f ([Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $ENV:SNOWADMIN, $ENV:SNOWPASSWORD)))) }
        $Uri = "https://dev36626.service-now.com/api/now/table/sc_request?sysparm_limit=1"
        $Body = [PSCustomObject]@{
            short_description    = "Operation - $($eventGridEvent.data.operationName)"
            special_instructions = "No action required - This REQ is created for auditing"
            requested_for        = "System Administrator"
            description          = "$($eventGridEvent | ConvertTo-Json -Depth 5)"
            state                = 4
            request_state        = "closed_complete"
        } | ConvertTo-Json 
        Invoke-RestMethod -Uri "$($Uri)" -Method Post -Headers $Headers -ContentType 'application/json' -Body $Body
    }
    default {
        "Some Logic..."
    }
}
```


