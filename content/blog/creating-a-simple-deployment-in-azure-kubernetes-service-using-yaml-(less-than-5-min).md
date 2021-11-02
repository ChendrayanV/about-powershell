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

## YAML Basics

YAML is a human-readable data serialization language used for configurations and many other purposes. YAML stands for **Y**et **A**nother **M**arkup **L**anguage. If you are familiar with Python, you can correlate the indentation. Yes, YAML follows the same indentation. Below is the different data formats used in the YAML

> Beware YAML is case sensitive. 

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

## Deployment Definition

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

## Service Definition

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

## Summary

Awesome, now that we know how to do deployments using YAML (declaratively). There are lot more coming up in future, please feel free to subscribe to my YouTube channel - [iAutomate](https://www.youtube.com/channel/UC22S6qPibfs1xa3MIII0JNw) and follow me on twitter [ChendrayanV](https://twitter.com/chendrayanv)