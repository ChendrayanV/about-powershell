+++
title = "Creating a simple deployment in Azure Kubernetes Service using YAML (Less than 5 min)"
description = "Declarative approach..."
author = "Chendrayan Venkatesan"
date = "2021-11-02"
tags = ["AKS","PowerShell","AKS Deployment"]
categories = ["Azure" , "AKS"]
[[images]]
  src = "img/2021/10/PODS.jpg"
  alt = "PODS"

+++

# Introduction

In my previous blog posts, we have seen imperative approaches for creating pods, deployments, replica sets and exposing them to load balancer service. The links below are for your reference. 

1. [DEPLOY NGINX APPLICATION IN AKS (LESS THAN 5 MIN)](https://about-powershell.com/blog/deploy-nginx-application-in-aks-in-5-min/)
2. [DEPLOY A NEW VERSION OF THE APPLICATION IN AKS (LESS THAN 5 MIN)](https://about-powershell.com/blog/deploy-a-new-version-of-the-application-in-aks-less-than-5-min/)
3. [DRY RUN OF REPLICAS IN AZURE KUBERNETES SERVICE (LESS THAN 5 MINUTES)](https://about-powershell.com/blog/dry-run-of-replicas-in-azure-kubernetes-service-less-than-5-minutes/)  

## YAML Basics

YAML is a human-readable data serialization language used for configurations and many other purposes. YAML stands for **Y**et **A**nother **M**arkup **L**anguage. If you are familiar with Python, you can correlate the indentation. Yes, YAML follows the same indentation. Below is the different data formats used in the YAML

> YAML is case sensitive. 

### Simple Key-Value pairs

```yaml
name: Chen
department: IT
city: Bangalore
```

### Dictionary

```yaml
person:
  name: Chen
  department: IT
  city: Bangalore
```

### Array

```yaml
skills:
  - Azure
  - IT Automation
  - PowerShell
  - Python
```

### More than one list

```yaml
employees:
  - name: Chen
    city: Bangalore
  - name: Shashi
    city: Bangalore
```

## Project Folder Structure

📦Collabrains.Cloud  
 ┣ 📂database  
 ┃ ┗ 📜employee.json  
 ┣ 📂manifest  
 ┃ ┣ 📜create-deployment.yaml  
 ┃ ┗ 📜create-service.yaml  
 ┣ 📜Dockerfile  
 ┗ 📜employee-rest-api.ps1 

 Deploy a REST API in AKS! To begin with, let us follow a simple project structure. The employee.json file underneath the database folder is the source of employee information. 

 ```json
 {
    "employee": [
        {
            "Id": "1",
            "FirstName": "Chendrayan",
            "SurName": "Venkatesan",
            "Country": "India",
            "City": "Bangalore",
            "DateOfJoining": "June 16, 2008"
        },
        {
            "Id": "2",
            "FirstName": "Shahsi",
            "SurName": "Shetty",
            "Country": "India",
            "City": "Bangalore",
            "DateOfJoining": "January 01, 2010"
        },
        {
            "Id": "3",
            "FirstName": "Matt",
            "SurName": "Hans",
            "Country": "Nederlands",
            "City": "Amsterdam",
            "DateOfJoining": "March 03, 2005"
        }
    ]
}
 ```

The main file is employee-rest-api.ps1, and this code hosts a REST API to serve other applications. 

```PowerShell
Start-PodeServer {
    Add-PodeEndpoint -Address * -Port 3000 -Protocol Http
    
    Add-PodeRoute -Method Get -Path '/employee' -ScriptBlock {             
        $Employee = Get-Content .\database\employee.json -Raw
        Write-PodeJsonResponse -Value $($Employee)
    }

    Add-PodeRoute -Method Get -Path '/employee/:id' -ScriptBlock {             
        $Employee = ((Get-Content .\database\employee.json -Raw  | ConvertFrom-Json).employee).Where(
            {
                ($_.Id -eq $WebEvent.Parameters['id'])
            }
        )
        Write-PodeJsonResponse -Value $($Employee)
    }
}
```

## Dockerize the application (Dockerfile)

```PowerShell
FROM mcr.microsoft.com/powershell:latest

WORKDIR /usr/src/app/

COPY . .    

RUN pwsh -c 'Install-Module Pode -force'

CMD [ "pwsh", "-c", "cd /usr/src/app; ./employee-rest-api.ps1" ]
```

## Build, tag & Push the docker image 

```PowerShell
PS C:\AKS-Learning\Collabrains.Cloud> docker build -t chenv/employee-rest-api:v1.0.0 .
```

```PowerShell
PS C:\AKS-Learning\Collabrains.Cloud> docker push chenv/employee-rest-api:v1.0.0
```

## Deployment Definition (create-deployment.yaml)

> Required Fields : apiVersion, kind, metadata, spec

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: chenv/ps-web-app:v1.0.0
        resources:
          limits:
            memory: "128Mi"
            cpu: "500m"
        ports:
            - containerPort: 80
```

## Service Definition (create-service.yaml)

> Required Fields : apiVersion, kind, metadata, spec

```yaml
apiVersion: v1
kind: Service
metadata:
  name: deployment-loadbalancer-service
spec:
  type: LoadBalancer
  selector:
    app: webfrontend
  ports:
    - name: http
      port: 80
      targetPort: 3000
```

## Deployment & Expose

```PowerShell
PS C:\> kubectl apply -f .\manifest\create-deployment.yaml
```

```PowerShell
PS C:\> kubectl apply -f .\manifest\create-service.yaml
```

## References

1. [Kubernetes Objects](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/)
2. [Understanding Kubernetes Objects](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/)
3. [Deploy Docker image to Azure Kubernetes Service AKS using YAML files & kubectl](https://youtu.be/9iHsPGbPSlQ)
4. [Pode](https://github.com/Badgerati/Pode)
5. [PowerShell Microservice - Hello World](https://dfinke.github.io/powershell,%20docker,%20pode/2020/08/01/PowerShell-Microservice-Hello-World.html)
6. [Kubernetes YAML Generator](https://k8syaml.com/)

## Credits

[dfinke](https://github.com/dfinke/PowerShellMicroservice) - PowerShell Microservice is very helpful.

{{< youtube fEDgqYC7cqs >}}

## Summary

Awesome, now that we know how to do deployments using YAML (declaratively). There are lot more in AKS..,. Please feel free to subscribe to my YouTube channel - [iAutomate](https://www.youtube.com/channel/UC22S6qPibfs1xa3MIII0JNw) and follow me on twitter [ChendrayanV](https://twitter.com/chendrayanv)