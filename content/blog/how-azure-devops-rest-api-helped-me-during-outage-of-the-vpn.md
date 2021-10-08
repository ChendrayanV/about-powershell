+++
author = "Chendrayan Venkatesan"
categories = ["Azure DevOps"]
tags = ["WIQL" , "PowerShell"]
date = "2020-04-18"
description = "Just move on!"
featured = "Azure-DevOps01.jpg"
featuredalt = "Azure-DevOps01"
featuredpath = "date"
linktitle = ""
title = "How Azure DevOps REST API helped me during outage of the VPN?"
type = "post"
draft = "false"

+++

# Introduction

There is always an alternative is the apt statement to start this blog post! Yes, I got trouble in VPN and lost connection to most of our internal portal, and one among that is Azure DevOps (Formerly VSTS), where the code resides. Positively, no hindrances in accessing Outlook and Teams over mobile. All I need is to continue the work on code, work items and send status report.   

> REST API is the savior! Yes, connect with the one who can help you to get PAT with appropriate permission, and we are good to proceed! 

## Break the dependency

1. No, need to wait for others to send a note about the PBI descriptions.
2. Clone the code without a VPN. (If you Azure DevOps is configured that way)

## Authorize using PAT
I advise using  ` Microsoft.PowerShell.SecretsManagement` module to keep your credentials safe. It comes handy to save multiple passwords and ease to use. I have saved the PAT in `BuiltInLocalVault` and using as shown below

```PowerShell
Import-Module Microsoft.PowerShell.SecretsManagement -Verbose 
$Token = Get-Secret -Name PAT -Vault BuiltInLocalVault -AsPlainText
$Authentication = [System.Text.Encoding]::ASCII.GetBytes(":$Token")
$Authentication = [System.Convert]::ToBase64String($Authentication)
$Headers = @{Authorization = ("Basic {0}" -f $Authentication)}
```

## Let's Play
Using `$Headers` is used for authentication, we are ready to play with Azure DevOps. I have listed out the tasks I performed for my needs, but the concepts remain the same. Refer to Microsoft [docs](https://docs.microsoft.com/en-us/rest/api/azure/devops/?view=azure-devops-rest-5.1), and build the solution for your need.

> Don't forget to toggle the API version!

### List all the projects

```PowerShell
$Teams = (Invoke-RestMethod -Uri "https://xxxx-xx-xxxx.visualstudio.com/_apis/projects?api-version=5.1-preview.3" -Headers $Headers).value
$Teams | Select-Object name , visibility , lastUpdateTime
```

### List all the repositories

```PowerShell
$Teams | . {
    process {
        $Repositories = (Invoke-RestMethod -Uri "https://xxxx-xx-xxxx.visualstudio.com/$($_.name)/_apis/git/repositories?api-version=5.1" -Headers $($Headers)).value
        $Repositories | Select-Object name , @{N = 'Repo-Name'; E = {$_.project.name}} 
    }
}
```

### List all work items in your name (WIQL)

```PowerShell
$Query = [pscustomobject]@{
    query = 'SELECT * From WorkItems Where [System.AssignedTo] = "ChenV"'
} | ConvertTo-Json -Depth 10

$Results = Invoke-RestMethod -Uri "https://xxxx-xx-xxxx.visualstudio.com/{PROJECTA}/_apis/wit/wiql?api-version=5.1" `
                             -Method Post `
                             -Body $Query  `
                             -Headers $Headers `
                             -ContentType 'application/json'
$Results.workItems | Measure-Object
```

### Clone the repository

```PowerShell
PS C:\Projects> git clone https://PAT:PAT@REPOURL
```

### Read the work items comment

```PowerShell
$Results = Invoke-RestMethod -Uri "https://xxxx-xx-xxxx.visualstudio.com/{PROJECTA}/_apis/wit/workItems/91772/comments?api-version=5.1-preview.3" `
                             -Method Get `
                             -Headers $Headers
$Results
```

### Add comment in work items

```PowerShell
$body = @([pscustomobject]@{
    text = 'YOUR COMMENT'
}) | ConvertTo-Json
$Results = Invoke-RestMethod -Uri "https://xxxx-xx-xxx.visualstudio.com/PROJECTA/_apis/wit/workItems/115556/comments?api-version=5.1-preview.3" `
                             -Method Post `
                             -Headers $Headers `
                             -Body $body `
                             -ContentType 'application/json'
$Results
```

> It's worth to try PowerShell module available in the gallery

```PowerShell
PS C:\> Find-Module -Name '*VSTS'
```