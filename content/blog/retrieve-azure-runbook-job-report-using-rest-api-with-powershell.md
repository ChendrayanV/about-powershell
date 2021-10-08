+++
author = "Chendrayan Venkatesan"
categories = ["Azure Automation Account" , "Azure RunBook Report"]
tags = ["Resource Graph" , "PowerShell" , "REST API"]
date = "2021-02-16"
description = "Fun at work!"
featured = "Feb-16-Report.jpg"
featuredalt = "Feb-16-Report"
featuredpath = "date"
linktitle = ""
title = "Retrieve Azure Runbook Job Report using REST API with PowerShell"
type = "post"
draft = "false"

+++

# Introduction

The tile may hit a question WHY? Because automation accounts and runbooks are almost outdated in 2021. Most prefer to use alternative solutions like Logic Apps, Function App Power Automate, or others. Hang On! Runbooks are still in use. Of late, I got a requirement to send a report on runbooks that got invoked in the last one hour. 

> In PowerShell, it’s easy, as shown below

```powershell
$Params = @{
    RunbookName           = 'MYRUNBOOKNAME'
    ResourceGroupName     = 'MYRESOURCEGROUPNAME'
    AutomationAccountName = 'MYAUTOMATIONACCOUNTNAME'
    StartTime             = $(Get-Date).AddHours(-1)
}
Get-AzAutomationJob @Params
```

In my case, the code needs to loop through 200 + subscriptions. Yes, that’s the reason I used REST API with PowerShell. By this approach, the code is befitting in the Azure Function app. 

```powershell
#region - Query
$Query = "Resources 
| where type =~ 'Microsoft.Automation/automationaccounts/runbooks' and location =~ 'northeurope' and name =~ '{YOUR RUNBOOK NAME}'
| project id, name , resourceGroup, subscriptionId, automationAccountName = tostring(split(id,'/')[8])"
$PageSize = 1000
$Iteration = 0
$SearchParams = @{
    Query = $($Query)
    First = $PageSize
}
[System.Collections.ArrayList]$Runbooks = @()
do {
    $Iteration += 1
    $PageResults = Search-AzGraph @SearchParams -Verbose
    $SearchParams.Skip += $PageResults.Count
    $Runbooks.AddRange($PageResults)
} while ($PageResults.Count -eq $PageSize)
#endregion
```

```powershell
#region - Generate Headers
$azureRmProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
$currentAzureContext = Get-AzContext
$profileClient = New-Object Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient($azureRmProfile)
$authorization = "Bearer {0}" -f ($profileClient.AcquireAccessToken($currentAzureContext.Subscription.TenantId).AccessToken)
$Headers = @{Authorization = $authorization }
#endregion
```

```powershell
#region - Fetch Last One Hour Job Status
[System.Collections.ArrayList] $Results = @()
$Runbooks | . {
    process {
        $startTime = [datetime]::UtcNow.AddHours(-1).ToString('yyyy-MM-ddTHH:mm:ss.ffffffZ')
        $Result = Invoke-RestMethod -Uri "https://management.azure.com/subscriptions/$($_.subscriptionId)/resourceGroups/$($_.resourceGroup)/providers/Microsoft.Automation/automationAccounts/$($_.automationAccountName)/jobs?`$filter=properties/startTime ge $($startTime) and properties/runbook/name eq 'Start-PaaSComplianceCheck-Autofix'&api-version=2017-05-15-preview" -Headers $Headers
        $Results.AddRange($Result.value)
    }
}
$Collections = $Results | Select-Object @{Name = 'SubscriptionId'; Expression = { ($_.id -split '/')[2] } }, 
@{Name = 'ResourceGroupName'; Expression = { ($_.id -split '/')[4] } }, 
@{Name = 'AutomationAccountName'; Expression = { ($_.id -split '/')[8] } }, 
@{Name = 'LastModifiedTime'; Expression = { ([datetime]::Parse($_.properties.lastModifiedTime)) } },
@{Name = 'Status'; Expression = { ($_.properties.status) } } | Where-Object { $_.Status -eq 'Failed' }
#endregion
```

Hey, hang around with me – I would like to show a simple PSHTML trick to make your report super fancy in no time. 

```powershell
$HtmlPart = html -Content {
        head -Content {
            style -Content $StyleSheet
        }

        body -content {
            hr 
            h4 -Content "SOME TEXT"
            h5 -Content $(Get-Date)
            h5 -Content "MEANINGFUL HEADERS"
            hr
            table -content {
                th -content 'SubscriptionId'
                th -content 'ResourceGroupName'
                th -content 'AutomationAccountName'
                th -content 'LastModifiedTime'
                th -content 'Status'
                foreach ($Collection in $Collections) {
                    tr -content {
                        td -content {
                            $Collection.SubscriptionId
                        }
                        td -content {
                            $Collection.ResourceGroupName
                        }
                        td -content {
                            $Collection.AutomationAccountName
                        }
                        td -content {
                            $Collection.LastModifiedTime
                        }
                        if ($Collection.Status -ne 'Completed') {
                            td -content {
                                $Collection.Status
                            } -Style "background-color:RED"
                        }
                        else {
                            td -content {
                                $Collection.Status
                            } -Style "background-color:GREEN"
                        }
                    }
                }
            }   
        }
    }
```

> StyleSheet

```css
body {
    background: white;
    font-family: ShellLight;
}

th {
    background: skyblue;
    color: black;
}

table {
    width: 100%;
    border: 1
}
```

That's for now! Let me connect with you sooner with another exciting topic. 