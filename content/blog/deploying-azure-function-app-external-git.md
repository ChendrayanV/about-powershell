+++
author = "Chendrayan Venkatesan"
categories = ["Azure"]
tags = ["Azure Functions" , "External Git" , "Azure DevOps" , "Deployment"]
date = "2020-04-17"
description = "An alternative may save time!"
featured = "External-Git-Configuration.jpg"
featuredalt = "External-Git-Configuration"
featuredpath = "date"
linktitle = ""
title = "DEPLOYING AZURE FUNCTION APP - EXTERNAL GIT"
type = "post"
draft = "false"

+++

# Introduction 

I bet most of you don’t need this! Having said that, if your organization has Azure DevOps (Formerly VSTS) in directory A and Azure on directory B. Then, deploying Azure Function App using external git may help you. 

## Why not Zip deploy? 

Yes, that’s the optimal way to do! In my case, the roller coaster ride for simple requirements is quite common. Consider, Azure Functions source code is available with vendors, and it’s an end to end solution to be deployed at your workplace in a shorter time, and building a pipeline may take a few hours or process may delay the deployment. 

## Solution – A Quick Win!

Yes, external git is a quick win for you to save time. It’s effortless! Get the Personal Access Token (PAT) from the vendor’s source control (Git). You may get something 52 characters gibberish text, and that’s the token. 

1. Open the Azure function app and then platform feature.
2. Select all settings and choose the deployment center. 
3. Choose the external git – Click Continue – Select KUDU (App service build service).

The configuration window appears, as shown below. 

![External-Git-Configuration](/img/2020/04/External-Git-Configuration.png)

1.	Repository  
    a.	http://PAT:PAT@REPOURL
2.	Branch  
    a.	Type in the desired git branch. 
3.	User Name  
    a.	PAT
4.	Password  
    a.	PAT