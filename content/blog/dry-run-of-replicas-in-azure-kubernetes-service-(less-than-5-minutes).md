+++
title = "Dry run of Replicas in Azure Kubernetes Service (less than 5 minutes)"
description = "Imperative approach..."
author = "Chendrayan Venkatesan"
date = "2021-10-24"
tags = ["AKS","NGINX"]
categories = ["Azure" , "AKS"]
[[images]]
  src = "img/2021/10/PODS.jpg"
  alt = "PODS"

+++

# Introduction

Below two blog posts are to demonstrate creating Pod & Deployment imperatively.  
    1.	[Creating Pods](https://about-powershell.com/blog/deploy-nginx-application-in-aks-in-5-min/)  
    2.	[Updating the application to a newer version](https://about-powershell.com/blog/deploy-a-new-version-of-the-application-in-aks-less-than-5-min/).

> Disclaimer: This post is to show scaling the application (With no YAML) & not recommended for production. 

In this post let me walk through the simple steps for creating replicas. In simple words, replicas are nothing but a copy of the pods running to maintain the availability of an application. **Why we need replicas?** In case the pod crashed or accidently deleted, automatically another identical pod will be in place to maintain the application availability and that feature is provided by creating replica sets. 

{{< youtube K3Ht_PPZBdY >}}

## Steps (High Level)

    1.	Build a node.js application to print the hostname. 
    2.	Dockerize the application
    3.	Tag and publish to the Docker hub
    4.	Deploy the containerized application in the AKS
    5.  Scale the application (6 - Scale-up | 3 - Scale-down)
    6.	Access the application to check the host

### Creating a node application

We are creating a node js application for our demo purpose. The functionality of the application is to print the hostname in which the application is running. The hostname confirms the request hitting the respective pod. Below, is the simple node js application (app.js) which serves the purpose for our demo. 

> Make sure node & npm is installed in your development machine. 

### Step 1

```
PS C:\Projects\Collabrains.Cloud> npm init -y
```

### Step 2

```
PS C:\Projects\Collabrains.Cloud> npm install express
```

### Step 3

```
PS C:\Projects\Collabrains.Cloud> npm install pug
```

### Step 4 (app.js)

```
const express = require('express');
const app = express();
const os = require('os');
const port = 3000;
const host = '0.0.0.0';

app.set('views', './views');
app.set('view engine', 'pug');

var HOSTNAME = os.hostname
app.get('/', function (req, res) {
    res.render('index', { title: 'AKS | Demo', message: HOSTNAME });
});

app.listen(port, host, () => {
    console.log(`Server started at ${host} port ${port}`);
});     
```

### Step 5 (view.pug)

```
meta(charset="UTF-8")
meta(http-equiv="X-UA-Compatible", content="IE=edge")
meta(name="viewport", content="width=device-width,initial-scale=1")
title=title
link(rel="stylesheet", href="https://cdn.metroui.org.ua/v4.3.2/css/metro-all.min.css")
link(href="https://fonts.googleapis.com/css?family=Montserrat", rel="stylesheet")
style.
  
  body {
              font-family: 'Montserrat';
              font-size: 22px;
          }
hr
h3(style="text-align: center;") AKS - POD DEMO
hr
p(style="text-align: center;") Application is running on the host...
p(style="text-align: center;")=message
div(data-role="cube", data-cells="10", data-margin="2")
script(src="https://cdn.metroui.org.ua/v4/js/metro.min.js")
```

### Step 6 (Dockerfile)

```
FROM node:alpine

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install

COPY . .

CMD [ "node", "app.js" ]
```

### Step 7 (Test Locally)

```
PS C:\Projects\Collabrains.Cloud> node .\app.js
```

```
PS C:\Projects\Collabrains.Cloud> docker run -p 8080:8080 -d chenv/collabrains.cloud:v1.0.0
```

### Step 8 (Build & tag)

```
PS C:\Projects\Collabrains.Cloud> docker build -t chenv/collabrains.cloud:v1.0.1 .
```

### Step 9 (Push the image)

```
PS C:\Projects\Collabrains.Cloud> docker push chenv/collabrains.cloud:v1.0.1
```

### Step 10 (Create a deployment)

```
PS C:\Projects\Collabrains.Cloud> kubectl create deployment collabrains.cloud --image=chenv/collabrains.cloud:v1.0.1
```

### Step 11 (Expose the deployment| LB Service)

```
PS C:\Projects\Collabrains.Cloud> kubectl expose deployment collabrains.cloud --type=LoadBalancer --port=80 --target-port=3000 --name=collabrains-cloud-service
```


### Step 12 (Scale the deployment)

```
PS C:\Projects\Collabrains.Cloud> kubectl scale --replicas=6 deployment/collabrains.cloud
```

```PowerShell
PS C:\Projects\Collabrains.Cloud> kubectl scale --replicas=5 deployment/aks-replicas-demo
```

## Summary

Awesome, now that we know the basics of Pods, Deployments and Service. There are lot more coming up in future, please feel free to subscribe to my YouTube channel - iAutomate and follow me on twitter [ChendrayanV](https://twitter.com/chendrayanv)