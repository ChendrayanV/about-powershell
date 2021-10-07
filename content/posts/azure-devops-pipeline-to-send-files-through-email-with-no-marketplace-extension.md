---
title: "Azure Devops Pipeline to Send Files Through Email With No Marketplace Extension"
thumbnailImagePosition: "top"
thumbnailImage: images/Blog01.jpg
coverImage: //d1u9biwaxjngwg.cloudfront.net/cover-image-showcase/city.jpg
metaAlignment: center
coverMeta: out
date: 2021-10-07T15:11:31+05:30
draft: false
categories:
- Azure
- DevOps
tags:
- ChenV
- Azure
- Azure DevOps
keywords:
- DevOps
---

# Introduction

I was developing a PowerShell script to send Azure inventory through email, which generates a Word output with charts and tables. So, I thought of using Open XML, I used for SharePoint document library reporting (A few years ago), I searched GitHub and found a great PowerShell module PSWriteWord, and docs are super cool. Yes, this blog post is to show you the simple steps to generate a word document through Azure DevOps pipeline.

> What do we expect?  


{{< youtube sT_TfHdV1jk >}}

1. Azure Account
2. Azure DevOps Account
3. VS Code (or any of your favorite IDE)
4. PowerShell
5. SMTP information (Yes, send DOCX through email)

To make this blog post short, let me show the piece of code I used in my assignment at work.

```code
PS C:\> Get-Date
```
