+++
title = "My First Experience with Azure Container Apps"
description = "MS Graph API | Pode | PowerShell | PSHTML"
author = "Chendrayan Venkatesan"
date = "2021-11-21"
draft = "false"
tags = ["Azure","PowerShell","Serverless","Container-Apps",""]
categories = ["Azure" , "Azure Container Apps"]
[[images]]
  src = "img/2021/11/Container-Apps.jpg"
  alt = "CONTAINER-APPS"

+++

> Credits

1. [Matthew Kelly](https://github.com/Badgerati) | Author of [Pode](https://github.com/Badgerati/Pode) PowerShell module. 
2. [PowerShell Microservice - Hello World](https://dfinke.github.io/powershell,%20docker,%20pode/2020/08/01/PowerShell-Microservice-Hello-World.html) by [Doug Finke](https://github.com/dfinke)
3. [Stephane Van Gulick](https://github.com/Stephanevg) | Author of [PSHTML](https://github.com/Stephanevg/PSHTML) PowerShell module. 

# Introduction

Azure Container Apps is a super catchy, fantastic serverless container service and won many hearts post the announcement in Microsoft Ignite 2021. This blog post walks you through the simple steps to deploy a PowerShell web application to say hello world. 

> Disclaimer: This is my first experience using the container app. So, only fundamentals are my focus.

## Tell about Azure Container Apps

1. In short, it’s a fully managed serverless container that allows us to deploy modern apps and micro-services. 
2. Many developers experience complexity in Kubernetes. Yes, there are many tools around to overcome it. However, Azure Container Apps allows developers to focus more on the code, and the rest are all managed by Microsoft. 
3. Allows hosting HTTP-based API, microservices, event processing, and background task. 
4. Auto-scaling
5. Simple configurations to perform modern app / micro-services lifecycle tasks. 

## How about the pricing?

For now, it’s answered in the [FAQ](https://azure.microsoft.com/en-us/services/container-apps/#faq). 

## Could you show us what you have? 

Oh yeah! No more theory. Let us get on the action! 

### Prerequisites

1.	Pode. 
2.	VSCode (or any IDE).
3.	PowerShell 7.1.2 (6.0 + for Kestrel routing in Pode.)
4.	Azure Account. 
5.	Docker Account.
6.	Docker CLI.

### Project Structure 

📦reactor  
 ┣ 📂.git  
 ┣ 📂src  
 ┃ ┣ 📂views  
 ┃ ┃ ┣ 📜home.ps1  
 ┃ ┣ 📜app.ps1  
 ┃ ┗ 📜Dockerfile  
 ┗ 📜readme.md  

### App (Main File to Start the Server)

```PowerShell
Start-PodeServer -Threads 2 {
    Add-PodeEndpoint -Address * -Port 3000 -Protocol Http
    Set-PodeViewEngine -Type PSHTML -Extension PS1 -ScriptBlock {
        param($path, $data)
        return (. $path $data)
    }
    Add-PodeRoute -Method Get -Path '/' -ScriptBlock {
        Write-PodeViewResponse -Path 'home.ps1'
    }
}
```

### Views | Login Page (Home.ps1)

```PowerShell
param($data)

function CustomCard {
    Param (
        $ImageSrc
    )

    Div -Class 'cell-lg-4' -Content {
        Div -Class 'price-item text-center bg-white win-shadow' -Content {
            Div -Class 'price-item-header p-6' -Content {
                Div -Class 'img-container rounded' -Content {
                    img -src $($ImageSrc)
                    Div -Class 'image-overlay op-green' 
                }
            }
        }
    }
}
return html -Content {
    head -Content {
        Title -Content "Az Container Apps | Home"
        Link -href "https://cdn.metroui.org.ua/v4.3.2/css/metro-all.min.css" -rel "stylesheet"
        script -src "https://cdn.metroui.org.ua/v4/js/metro.min.js"
    }
    body -Content {
        (1..3).ForEach({ br })
        Div -Class 'container' -Content {
            h3 -Class 'Secondary fg-lightRed' -Content 'Work In Progress...' -Style 'text-align:center'
            hr
            Div -Class 'row flex-align-center rounded' -Content {
                @(
                    "https://media.istockphoto.com/photos/automation-industrial-business-process-workflow-optimisation-picture-id1280048451?b=1&k=20&m=1280048451&s=170667a&w=0&h=vPUK1jUkpkczueFaya2ZGdjDtNQKRo75f6yEzsXMY7A=",
                    "https://images.unsplash.com/photo-1579621970795-87facc2f976d?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8Y29zdHxlbnwwfHwwfHw%3D&auto=format&fit=crop&w=500&q=60",
                    "https://images.unsplash.com/photo-1582213782179-e0d53f98f2ca?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8N3x8dGVhbXxlbnwwfHwwfHw%3D&auto=format&fit=crop&w=500&q=60"
                ).ForEach(
                    {
                        CustomCard -ImageSrc $($_)  
                    }
                )
                
            }
            hr 
        }
    }
}
```

### Build and Push to DockerRegistry

```Dockerfile
FROM mcr.microsoft.com/powershell:latest

WORKDIR /usr/src/app/

COPY . .    

RUN pwsh -c "Install-Module 'Pode', 'PSHTML' -Force -AllowClobber"

CMD [ "pwsh", "-c", "cd /usr/src/app; ./app.ps1" ]
```

### Build and Push

```PowerShell
PS C:\reactor> docker build -t chenv/reactor:V1.0.0 .
PS C:\reactor> docker push chenv/reactor:V1.0.0
```

### Create Container Apps & Deploy 

{{< youtube MvfzFCKSphk >}}


### References

1. [Pode](https://github.com/Badgerati/Pode)
2. [PSHTML](https://github.com/Stephanevg/PSHTML)
3. [Azure Container Apps](https://azure.microsoft.com/en-us/services/container-apps/)

### Summary

Congratulations on running your first Azure Container Apps using PowerShell, Pode, PSHML, and Microsoft Graph API. There are a lot more coming up in the future, and please feel free to subscribe to my YouTube channel - iAutomate and follow me on Twitter [ChendrayanV](https://twitter.com/chendrayanv) 