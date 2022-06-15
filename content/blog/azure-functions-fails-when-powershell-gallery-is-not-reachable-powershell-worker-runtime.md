+++
title = "Azure Functions Fails when PowerShell Gallery is not reachable – PowerShell Worker Runtime"
description = "Alternative way to load PowerShell modules"
author = "Chendrayan Venkatesan"
draft = "false"
date = "2022-06-15"
tags = ["Azure Function App", "Serverless Compute" , "Azure Function"]
categories = ["Azure-Functions"]
[[images]]
  src = "img/2022/06/Work.jpg"
  alt = "a-perfect-combo"

+++

# Introduction

It’s essential to keep a backup plan to keep the Azure Functions healthy and working as expected. Twice I experienced the issue and ended up in incidents. Because my function code requires dependent modules that get auto-load from the PowerShell Gallery

## Environment

- Azure Functions with a PowerShell worker runtime. 
- Function code requires dependent modules from PowerShell Gallery. 

## Problem

When a PowerShell Gallery 

1.	Fail to work
2.	Working intermittently 
3.	Slower in performance

# Solution

When a developer creates an Azure Function with a PowerShell worker runtime, the `requirements.psd1` file looks like below 

```PowerShell
# This file enables modules to be automatically managed by the Functions service.
# See https://aka.ms/functionsmanageddependency for additional information.
#
@{
    # For latest supported version, go to 'https://www.powershellgallery.com/packages/Az'. 
    # To use the Az module in your function app, please uncomment the line below.
    # 'Az' = '8.*'
}
```

What’s new in it? Nothing, if we need a dependent module for our code to function, we mention the module name and its version in the hashtable. For example, I need to load the PSHTML module for my function to render HTML. I need to modify it as below. 

```PowerShell
# This file enables modules to be automatically managed by the Functions service.
# See https://aka.ms/functionsmanageddependency for additional information.
#
@{
    # For latest supported version, go to 'https://www.powershellgallery.com/packages/Az'. 
    # To use the Az module in your function app, please uncomment the line below.
    # 'Az' = '8.*'
    'PSHTML' = '0.8.2'
}
```
What happens if the PowerShell gallery is unreachable? Azure Functions fail to work! It’s as simple as that! What’s the alternative? I created a modules folder under the project root. So, the structure of my project folder looks like below 

> Project Folder Structure

📦iAzFunc  
 ┣ 📂.vscode  
 ┃ ┗ 📜extensions.json  
 ┣ 📂modules  
 ┃ ┗ 📂PSHTML  
 ┃ ┃ ┗ 📂0.8.2  
 ┣ 📜.gitignore  
 ┣ 📜host.json  
 ┣ 📜local.settings.json  
 ┣ 📜profile.ps1  
 ┗ 📜requirements.psd1  

# Summary 

- A maximum of 10 modules are allowed to load through requirements.psd1 
- If we store modules locally, there are no limits as far as I know. But, the project folder size increases. 
- To save modules locally, use the below snippet. 

```PowerShell 
PS C:\iAzFunc> Save-Module -Name 'PSHTML' -Path '.\modules'
```

Happy Azure Functions! 