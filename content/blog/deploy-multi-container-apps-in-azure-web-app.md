+++
title = "Deploy multi-container apps in Azure web app"
description = "Pode | PowerShell | PSHTML | Azure Web App"
author = "Chendrayan Venkatesan"
date = "2021-11-22"
draft = "true"
tags = ["Azure","PowerShell","Serverless","Container-Apps"]
categories = ["Azure" , "Azure Web Apps", "Docker Compose" , "Multi-Container-Apps"]
[[images]]
  src = "img/2021/11/spices-multi-container.jpg"
  alt = "CONTAINER-APPS"

+++

# Introduction

Cooking is my hobby, and I am interested in learning technologies. I am a great fan of Azure, PowerShell, Web-Framework, Serverless, DevOps, and Cloud Automation. Yes, I have no experience in developing web apps / glossy web pages for production use. But, nothing stopped me from building one for my learning. This blog post walks you through the steps to deploy a multi-container apps in the Azure web app. Yes, let’s make a static site for cooking. **(Just a simple demo with no features / functional site)**

In my future blogs, I continue to write about multi-container and enhance the site with additional features like 
1. Improvise the look & feel
2. Adding database
3. Improve the performance
4. Follow Docker's best practices. 

And much more…


## Takeaways
1. Build two applications (REST API & Web Application)
2. Dockerize the REST API & Web App. 
3. Deploy the multi-containers in the Azure web application using Docker-Compose

We build a site with a drop-down field, and its values are the output of the REST API (another container).

## Why multi-container apps? 

In my previous blog posts, a single container is in use for the demo. Using a multi-container, we can solve a few challenges. We build an API for the food menu and consume that in a web application for our demo. So, API and APP reside in two different containers. The advantages of it are as follows

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
 ┃ ┃ ┗ 📜food-menu.ps1  
 ┃ ┣ 📜Dockerfile  
 ┃ ┗ 📜server.ps1  
 ┣ 📜docker-compose.yml  
 ┗ 📜readme.md  

## Application (Web Server)

> SERVER.PS1

### Home Page (application/views/index.ps1)

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
            h3 -Class 'Secondary fg-lightRed' -Content 'Colors of Cuisine...' -Style 'text-align:center'
            hr
            Div -Class 'row flex-align-center rounded' -Content {
                @(
                    "https://media.istockphoto.com/photos/dabba-masala-picture-id465015726?b=1&k=20&m=465015726&s=170667a&w=0&h=IsNYymgb7aX2qZcZ-IdBVZ7xC1m6JNJ9ZFOcEvF_PiM=",
                    "https://media.istockphoto.com/photos/idly-or-idli-picture-id1306083224?b=1&k=20&m=1306083224&s=170667a&w=0&h=USIy9AUuJVA2dboZOHdAc8EUl_1QHWbivvRJUEYQfWk=",
                    "https://media.istockphoto.com/photos/frying-egg-in-a-cooking-pan-in-domestic-kitchen-picture-id1129381764?b=1&k=20&m=1129381764&s=170667a&w=0&h=P3Gw15Zps0Mu_NF7wNwVkfpVqGV3LC7Pg1YbZXBMcnc="
                ).ForEach(
                    {
                        CustomCard -ImageSrc $($_)  
                    }
                )
            }
            hr 
            h3 -Class 'Secondary fg-lightRed' -Content $('Food Menu') -Style 'text-align:center'
            $items = Invoke-RestMethod -Uri 'http://colors-of-cuisine:3000/food-menu'
            selecttag -Content {
                foreach($Item in $Items.items) {
                    option -Content $Item.name
                }
            } -name 'reason'
        }
    }
}
```

### Application (application/app.ps1)

```PowerShell
Start-PodeServer {
    Add-PodeEndpoint -Address * -Port 80 -Protocol Http
    Set-PodeViewEngine -Type PSHTML -Extension PS1 -ScriptBlock {
        param($path, $data)
        return (. $path $data)
    }
    Add-PodeRoute -Method Get -Path '/index' -ScriptBlock {
        Write-PodeViewResponse -Path "index.ps1"
    }
}
```

### Dockerize (Dockerfile)

```Dockerfile
FROM mcr.microsoft.com/powershell:latest

WORKDIR /usr/src/app/

COPY . .    

RUN pwsh -c "Install-Module 'Pode' , 'PSHTML' -Force -AllowClobber"

CMD [ "pwsh", "-c", "cd /usr/src/app; ./app.ps1" ]
```

## REST Application (REST API Server)

> APP.PS1 | 

### Route (products/routes/food-menu.ps1)

```PowerShell
[PSCustomObject]@{
    items = @(
        [PSCustomObject]@{
            name = 'Idly + Chutney'
        }
        [PSCustomObject]@{
            name = 'Dosae + Chicken Curry'
        }
        [PSCustomObject]@{
            name = 'Idly + Lamb Curry'
        }
    )
}
```

### App (products/app.ps1)

```PowerShell
Start-PodeServer  {
    Add-PodeEndpoint -Address * -Port 3000 -Protocol Http
    Add-PodeRoute -Method Get -Path '/food-menu' -ScriptBlock {
        Write-PodeJsonResponse -Value $( & .\routes\food-menu.ps1)
    }
}
```

### Dockerize (Dockerfile)

```Dockerfile
FROM mcr.microsoft.com/powershell:latest

WORKDIR /usr/src/server/

COPY . .    

RUN pwsh -c "Install-Module 'Pode' -Force -AllowClobber"

CMD [ "pwsh", "-c", "cd /usr/src/server; ./server.ps1" ]
```

## Get on Action

{{< youtube jC23hgGkdIM >}}

## References

1. [Multi-Container-Apps](https://docs.docker.com/get-started/07_multi_container/)
2. [Using Docker Compose](https://docs.docker.com/get-started/08_using_compose/)

## Summary

Awesome, you have a PowerShell web-application up & running in Azure webn app as a Docker container. There are lot more coming up in future, please feel free to subscribe to my YouTube channel - [iAutomate](https://www.youtube.com/channel/UC22S6qPibfs1xa3MIII0JNw) and follow me on twitter [ChendrayanV](https://twitter.com/chendrayanv)