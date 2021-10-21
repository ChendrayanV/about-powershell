+++
title = "Deploy NGINX application in AKS (Less than 5 min)"
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

Of late, we did a AKS workshop and a team got stuck in deploying a simple HTML application and get the home page working. It’s not a complex one! Let me walk through the steps to get this sorted. 

{{< youtube B459V1rw2lk >}}

## Project Structure & Code

HTML application project folder structure

*The docker file content is as follows - Yes, team has a HTML file named 'home.html'*

```Docker
FROM nginx

COPY home.html /usr/share/nginx/html
```

HTML file content for your reference. 

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
    <h3 style="text-align: center;">Azure Kubernetes Service</h3>
    <hr>
    <p style="text-align: center;">Application Version 1.0</p>
    <script src="https://cdn.metroui.org.ua/v4/js/metro.min.js"></script>
</body>

</html>
```

### Deploy the pod using the kubectl

```PowerShell
PS C:\> kubectl run collabrains-cloud-dev --image chenv/collabrains-cloud-dev
```

### Expose the application to internet using Load Balancer service 

```PowerShell 
PS C:\> kubectl expose pod collabrains-cloud-dev --type=LoadBalancer --port=80 --name=collabrains-cloud-dev
```

### Get the public IP

```PowerShell
PS C:\> kubectl get svc
```

Accessing the public IP through the browser didn't give the expected result.

## What went wrong?

Practically, there is no issue. Instead of your home.html the index.html is rendering. Because, that is the default index page. So, to access your home page navigate to http://PUBLICIP/HOME.HTML or overwrite the index file by renaming the home.html to index.html. Don't forget to update the same in Dockerfile. 

### Replica Set

Now, we need to get replica set sorted... Use the below YAML 

```PowerShell

```