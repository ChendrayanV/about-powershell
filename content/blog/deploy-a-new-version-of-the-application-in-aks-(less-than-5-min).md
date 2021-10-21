+++
title = "deploy-a-new-version-of-the-application-in-aks-(less-than-5-min)"
description = ""
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

1. (Version 1)[https://hub.docker.com/layers/173282206/chenv/collabrains-cloud/1.0.0/images/sha256-13340e9feca2d671f8fd47c11d5f4252144c75c10efb277715e77bf9650ded91?context=repo]
2. (Version 2)[https://hub.docker.com/layers/173282070/chenv/collabrains-cloud/2.0.0/images/sha256-e7d89b5670ba756860f768e6fc675adc4ade3f0ded4a224f2e608d918d838288?context=repo]

{{< youtube 0F8m_FZ5kMw >}}

## Steps (High Level)

1.	Build an HTML static web application – Content is of your choice
2.	Dockerise the application
3.	Tag and publish to the Docker hub
4.	Deploy the containerized application in the AKS
5.	**Release a newer version of the application in the AKS**


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