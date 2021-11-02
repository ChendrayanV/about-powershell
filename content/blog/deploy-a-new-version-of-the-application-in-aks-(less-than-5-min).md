+++
title = "Deploy a new version of the application in AKS (Less than 5 min)"
description = "Imperative approach..."
author = "Chendrayan Venkatesan"
date = "2021-10-21"
tags = ["AKS","NGINX"]
categories = ["Azure" , "AKS"]
[[images]]
  src = "img/2021/10/PODS.jpg"
  alt = "PODS"

+++

# Introduction

In my previous [blog](https://about-powershell.com/blog/deploy-nginx-application-in-aks-in-5-min/), we described the pod deployment and exposing the app to the internet. Now, let me walk through the steps to release a new version of the application. We have two application versions in the Docker repository and they are listed below 

1. [Version 1](https://hub.docker.com/layers/173282206/chenv/collabrains-cloud/1.0.0/images/sha256-13340e9feca2d671f8fd47c11d5f4252144c75c10efb277715e77bf9650ded91?context=repo)
2. [Version 2](https://hub.docker.com/layers/173282070/chenv/collabrains-cloud/2.0.0/images/sha256-e7d89b5670ba756860f768e6fc675adc4ade3f0ded4a224f2e608d918d838288?context=repo)

{{< youtube 0F8m_FZ5kMw >}}

## Steps (High Level)

1.	Build an HTML static web application – Content is of your choice
2.	Dockerize the application
3.	Tag and publish to the Docker hub
4.	Deploy the containerized application in the AKS
5.	**Release a newer version of the application in the AKS**

### HTML Code & Dockerfile Content

```HTML
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AKS</title>
    <link rel="stylesheet" href="https://cdn.metroui.org.ua/v4.3.2/css/metro-all.min.css">
    <link href='https://fonts.googleapis.com/css?family=Montserrat' rel='stylesheet'>
    <style>
        body {
            font-family: 'Montserrat';
            font-size: 22px;
        }
    </style>
</head>

<body>
    <hr>
    <h3 style="text-align: center;">AKS | NGINX | VERSION </h3>
    <hr>
    <!-- <p style="text-align: center;">Application Version 1.0.0 | Docker tag 1.0.0</p>
    <div data-role="cube" data-cells="10" data-margin="2"></div> -->
    
    <p style="text-align: center;">Application Version 2.0.0 | Docker tag 2.0.0</p>
    <div data-role="cube" data-color="bg-cyan bd-darkCyan" data-flash-color="#aa00ff"></div>
    <script src="https://cdn.metroui.org.ua/v4/js/metro.min.js"></script>
</body>

</html>
```

```Dockerfile
FROM nginx

COPY home.html /usr/share/nginx/html
```

### Build & Tag (Version 1.0)

```PowerShell
PS C:\Projects\Collabrains.Cloud> docker build -t chenv/collabrains-cloud:1.0.0 .
```

### Push to Docker Hub - V1

```PowerShell
PS C:\Projects\Collabrains.Cloud> docker push chenv/collabrains-cloud:1.0.0
```

### Build & Tag (Version 2.0)

```PowerShell
PS C:\Projects\Collabrains.Cloud> docker build -t chenv/collabrains-cloud:2.0.0 .
```

### Push to Docker Hub - V2

```PowerShell
PS C:\Projects\Collabrains.Cloud> docker push chenv/collabrains-cloud:2.0.0
```

### Create Deployment

```PowerShell
PS C:\Projects\Collabrains.Cloud> kubectl create deployment collabrains-cloud --image=chenv/collabrains-cloud:1.0.0
```

### Expose

```PowerShell
PS C:\Projects\Collabrains.Cloud> kubectl expose deployment collabrains-cloud --type=LoadBalancer --port=80 --target-port=80 --name=collabrains-cloud-service
```

### New Version (2.0.0)

```PowerShell
PS C:\Projects\Collabrains.Cloud> kubectl set image deployment/collabrains-cloud collabrains-cloud=chenv/collabrains-cloud:2.0.0 --record=true
```

## Summary

Awesome, now that we know the basics of Pods, updating deployments. There are lot more coming up in future, please feel free to subscribe to my YouTube channel - [iAutomate](https://www.youtube.com/channel/UC22S6qPibfs1xa3MIII0JNw) and follow me on twitter [ChendrayanV](https://twitter.com/chendrayanv)