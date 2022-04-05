+++
title = "Fuse Function App API with Azure Static Web App"
description = "a perfect combo..."
author = "Chendrayan Venkatesan"
draft = "false"
date = "2022-04-05"
tags = ["Azure Static Web App", "Serverless Compute" , "Azure Function", "PSHTML"]
categories = ["Azure-Functions"]
[[images]]
  src = "img/2022/04/PizzaandBeer.jpg"
  alt = "a-perfect-combo"

+++

# Introduction 

My friend and I worked on a simple HTML UI to collect user input and process exchange activities in the backend through PowerShell scripts. It was easy using the Pode and PSHTML PowerShell modules. I read about the static web app and thought of burning my night oil, and to my wonder, I made it to work :) . Yes, in this blog post, I walk through the steps to develop a static web app and fuse it with the Azure Function app. 

***Disclaimer: We do both static web and function apps locally. In my next post, I show the steps to deploy on the cloud.***  

## Project Scaffolding 

📦AdminUI  
 ┣ 📂api  
 ┃ ┣ 📂.vscode  
 ┃ ┃ ┗ 📜extensions.json  
 ┃ ┣ 📂home  
 ┃ ┃ ┣ 📜function.json  
 ┃ ┃ ┗ 📜run.ps1  
 ┃ ┣ 📂register  
 ┃ ┃ ┣ 📜function.json  
 ┃ ┃ ┗ 📜run.ps1  
 ┃ ┣ 📜.gitignore  
 ┃ ┣ 📜host.json  
 ┃ ┣ 📜local.settings.json  
 ┃ ┣ 📜profile.ps1  
 ┃ ┗ 📜requirements.psd1  
 ┣ 📂src  
 ┃ ┣ 📜index.html  
 ┃ ┗ 📜index.ps1  
 ┗ 📜readme.md  



## References & Pre

***Credits / Source***

[Tutorial: Publish Azure Static Web Apps with Azure DevOps](https://docs.microsoft.com/en-us/azure/static-web-apps/publish-devops)  
[Vanilla API App](https://github.com/staticwebdev/vanilla-api.git)

***SWA CLI***  

[static Web App CLI](https://github.com/Azure/static-web-apps-cli)

***Func CLI***  

[Work with Azure Functions Core Tools](https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local?tabs=v4%2Cwindows%2Ccsharp%2Cportal%2Cbash)

## Solution 

### Step 1

```PowerShell
D:\AdminUI\api> func init --worker-runtime powershell   
```

### Step 2 (api/home/run.ps1)

```PowerShell
func new --name home --template HTTPTrigger --language PowerShell
```
> Replace run.ps1 with the below snippet

```PowerShell
using namespace System.Net
param($Request, $TriggerMetadata)
$body = [PSCustomObject]@{
    Name = "Chendrayan Venkatesan"
    City = "Bengaluru"
}
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        ContentType = "application/json"
        StatusCode  = [HttpStatusCode]::OK
        Body        = $($body)
    })

```

### Step 3 (api/register/run.ps1)

```PowerShell
func new --name register --template HTTPTrigger --language PowerShell
```
> Replace run.ps1 with the below snippet


```PowerShell
using namespace System.Net
using namespace System.Web;
param($Request, $TriggerMetadata)
$formdata = ([ordered]@{ })
$DecodedBody = [System.Web.HttpUtility]::UrlDecode($Request.Body)
($($DecodedBody) -split "&").ForEach( { $value = $_.split("="); $formdata.Add($value[0], $value[1]) }) 
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        ContentType = 'application/json'
        # headers    = @{'content-type' = 'application/json' }
        StatusCode = [HttpStatusCode]::OK
        Body       = $($formdata)
    })

```


### Step 4 (Index.ps1)

> Location - "src"

```PowerShell
html -Content {
    head -Content {
        meta -charset 'UTF-8'
        meta -name 'viewport' -content_tag 'width=device-width, initial-scale=1.0'
        title -Content 'Atti`Dude'
        Link -href 'https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css' -rel 'stylesheet' -Integrity 'sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC' -CrossOrigin 'anonymous'
        style -Content {
            "@import url('https://fonts.googleapis.com/css2?family=Raleway:wght@300&display=swap')"
        }
    }

    Body -Content {
        nav -Class 'navbar navbar-expand-lg navbar-dark bg-dark' -Content {
            Div -Class 'container-fluid' -Content {
                a -Class 'navbar-brand' -Content 'Atti`Dude' -href '#'
            }
        }
        br 
        Div -Class 'container' -Content {
            h3 -Style 'text-align: center;' -Content {
                "Hello " + $(span -Content {} -Id 'name')
            }
            p -Style 'text-align: center;' -Content {
                $(span -Content {} -Id 'city')
            }
            hr
            form -action '/api/register' -method 'post' -enctype 'application/x-www-form-urlencoded' -target "_blank" -Content {
                Div -Class 'mb-3' -Content {
                    label -Content 'First Name' -Class 'form-label' -Id 'lbl-first_name' -Attributes @{'for' = 'first_name' }
                    br
                    input -type 'text' -name 'first_name' -required -Id 'first_name'
                }
                Div -Class 'mb-3' -Content {
                    label -Content 'Last Name' -Class 'form-label' -Id 'lbl-last_name' -Attributes @{'for' = 'last_name' }
                    br
                    input -type 'text' -name 'last_name' -required -Id 'last_name'
                }
                button -class 'btn btn-primary' -content 'Submit'
            } 
        }
        script -src 'https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js' -integrity 'sha384-MrcW6ZMFYlzcLA8Nl+NtUVF0sA7MsXsP1UyJoMp4YLEuNSfAP+JcXn/tWtIaxVXM' -crossorigin 'anonymous'
        script -content {
            @"
            (async function () {
                let response = await fetch(``api\\home``);
                let res = await response.json();

                document.querySelector("#name").innerHTML = res.Name
                document.querySelector("#city").innerHTML = res.City
            })();
"@
        }
    } -Style "font-family: 'Raleway', sans-serif;"
}
```

### Step 4 (Complie to HTML)

```PowerShell
D:\AdminUI\api> .\index.ps1 | Out-File .\index.html -Force ; swa start .\ --api-location http://localhost:7071   
```

### Step 5 (Start the Function App)

```PowerShell 
D:\AdminUI\api> func start
```

### Output 

{{< youtube XPHxlX4oQe4 >}}


## Summary 
Congratulations! You have successfully developed and tested a static web app fused with the function app. In my next blog post, I will walk through the steps to deploy the solution on Azure through the DevOps way. 