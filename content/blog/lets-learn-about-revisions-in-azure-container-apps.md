+++
title = "My First Experience with Azure Container Apps"
description = "Pode | PowerShell | PSHTML | Azure Container Apps | Revisions"
author = "Chendrayan Venkatesan"
date = "2021-11-22"
draft = "true"
tags = ["Azure","PowerShell","Serverless","Container-Apps"]
categories = ["Azure" , "Azure Container Apps"]
[[images]]
  src = "img/2021/11/Container-Apps.jpg"
  alt = "CONTAINER-APPS"

+++

# Introduction

I am a great fan of serverless and containers. So, the Azure Container Apps announcement at Ignite 2021 is a treat for me and many. In my previous blog post, we covered the basics or got introduced to containers apps. This blog post is to talk about the revisions. 

##  What is a revision in container apps? 

Each revision is a variation of your container app that can have different settings for traffic allocations, autoscaling, or Dapr. Create a new revision to make changes to your app, and start by selecting any existing revision. In any application development, enhancements, feature releases, upgrades of apps, or bug fixes are standard practices. Each requires a minimum of one deployment and downtime. 

## Show us in Action

Revisions in Azure Container Apps also help us to deploy a new version of the application. Let me walk through the steps. Refer to the two versions of the Docker application listed below

[Version 1](https://hub.docker.com/layers/178515738/chenv/reactor/v1.0.0/images/sha256-285fd06e77ff95c743a7c2505fb7cd185b89de4683b622b1f68b27fb15e45ec5?context=repo)

[Version 2](https://hub.docker.com/layers/178509575/chenv/reactor/V1.0.1/images/sha256-82ead3f3320d490eae856b2275a3d5228553ac33c7fa213f03688de042d1fdbc?context=repo)

Indeed, there is no significant difference in versions. For our demo, we made a minor change to the text. Yes, your guess is correct; Roll out v2 in production and get rid of v1. 

## How? 

