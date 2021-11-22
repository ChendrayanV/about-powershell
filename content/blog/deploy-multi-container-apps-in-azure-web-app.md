+++
title = "Deploy multi-container apps in Azure web app"
description = "Pode | PowerShell | PSHTML | Azure Web App"
author = "Chendrayan Venkatesan"
date = "2021-11-22"
draft = "false"
tags = ["Azure","PowerShell","Serverless","Container-Apps"]
categories = ["Azure" , "Azure Web Apps", "Docker Compose" , "Multi-Container-Apps"]
[[images]]
  src = "img/2021/11/Container-Apps.jpg"
  alt = "CONTAINER-APPS"

+++

# Introduction

Cooking is my hobby, and I am interested in learning technologies. I am a great fan of Azure, PowerShell, Web-Framework, Serverless, DevOps, and Cloud Automation. Yes, I have no experience in developing web apps / glossy web pages for production use. But, nothing stopped me from building one for my learning. This blog post walks you through the steps to deploy a multi-container apps in the Azure web app. Yes, let’s make a site for cooking. 

## Home Page (views/index.ps1)

```PowerShell

```

## Why multi-container apps? 

In my previous blog posts, a single container is in use for the demo. Using a multi-container, we can solve a few challenges. We build an API for the cooking recipe and consume that in a web application for our demo. So, API and APP reside in two different containers. The advantages of it are as follows

1. Scale the containers independently.  
2. Provide API for other teams with no higher loads on applications.  
3. Update the versions and maintain isolation.  
4. For a while, let’s don’t think about the networking core concepts. Docker-Compose handles it. If two containers are in the same     network, they can communicate with each other.  

## Project Folder Structure

📦Collabrains.Cloud
 ┣ 📂application
 ┃ ┣ 📂views
 ┃ ┃ ┗ 📜index.ps1
 ┃ ┣ 📜app.ps1
 ┃ ┗ 📜Dockerfile
 ┣ 📂products
 ┃ ┣ 📂routes
 ┃ ┃ ┗ 📜products.ps1
 ┃ ┣ 📜Dockerfile
 ┃ ┗ 📜server.ps1
 ┣ 📜docker-compose.yml
 ┗ 📜readme.md



## References

1. [Multi-Container-Apps](https://docs.docker.com/get-started/07_multi_container/)
2. [Using Docker Compose](https://docs.docker.com/get-started/08_using_compose/)