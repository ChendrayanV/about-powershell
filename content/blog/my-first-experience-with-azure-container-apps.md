+++
title = "My First Experience with Azure Container Apps"
description = "MS Graph API | Pode | PowerShell | PSHTML"
author = "Chendrayan Venkatesan"
date = "2021-11-17"
tags = ["Azure","PowerShell","Serverless","Container-Apps",""]
categories = ["Azure" , "Azure Container Apps"]
[[images]]
  src = "img/2021/11/Container-Apps.jpg"
  alt = "CONTAINER-APPS"

+++

> Credits

1. [Matthew Kelly](https://github.com/Badgerati) | Author of [Pode](https://github.com/Badgerati/Pode) PowerShell module. 
2. Doug Finke - [PowerShell Microservice - Hello World](https://dfinke.github.io/powershell,%20docker,%20pode/2020/08/01/PowerShell-Microservice-Hello-World.html) 
3. [Stephane Van Gulick](https://github.com/Stephanevg) | Author of [PSHTML](https://github.com/Stephanevg/PSHTML) PowerShell module. 

# Introduction

Azure Container Apps is a super catchy, fantastic serverless container service and won many hearts post the announcement in Microsoft Ignite 2021. This blog post walks you through the simple steps to deploy a PowerShell web application to read Microsoft 365 data using Graph API. 

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
 ┃ ┃ ┗ 📜index.ps1  
 ┃ ┣ 📜app.ps1  
 ┃ ┗ 📜Dockerfile  
 ┗ 📜readme.md  

### App (Main File to Start the Server)

```PowerShell
Start-PodeServer {
    # Listen to port 3000 in localhost
    Add-PodeEndpoint -Address * -Port 3000   -Protocol Http
    
    # Set the view engine (PSHTML)
    Set-PodeViewEngine -Type PSHTML -Extension PS1 -ScriptBlock {
        param($path, $data)
        return (. $path $data)
    }

    # Index
    Add-PodeRoute -Method Get -Path '/' -ScriptBlock {
        Write-PodeViewResponse -Path 'index.ps1'
    }

    # Login Route (OAuth)
    Add-PodeRoute -Method Post -Path '/appoauth2' -ScriptBlock {
        $Global:ClientId = $WebEvent.Data['client_id']
        $Global:TenantId = $WebEvent.Data['tenant_id']
        $Global:ClientSecret = $WebEvent.Data['client_secret']
        $Body = @{    
            Grant_Type    = "client_credentials"
            Scope         = "https://graph.microsoft.com/.default"
            client_Id     = $Global:ClientId
            Client_Secret = $Global:ClientSecret
        }
        $ConnectGraph = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$($Global:TenantId)/oauth2/v2.0/token" -Method POST -Body $Body
        $Global:Headers = @{Authorization = "{0} {1}" -f ($ConnectGraph.token_type, $ConnectGraph.access_token) } 
        $Response = [PSCustomObject]@{
            Message    = "Success"
            TokenType  = $($ConnectGraph.token_type)
            StatusCode = $WebEvent.Response.StatusCode
        }
        Write-PodeJsonResponse -Value $($Response)
    }

    # Home Page
    Add-PodeRoute -Method Get -Path '/home' -ScriptBlock {
        Write-PodeViewResponse -Path 'home.ps1'
    }
}
```

### Views | Login Page (Index.ps1)

```PowerShell
param($data)

return html -Content {
    head -Content {
        Title -Content "Reactor | Home"
        Link -href "https://cdn.metroui.org.ua/v4.3.2/css/metro-all.min.css" -rel "stylesheet"
        script -src "https://cdn.metroui.org.ua/v4/js/metro.min.js"
    }
    body -Content {
        # Menu Bar
        Div -Class "container bg-blue fg-white pos-fixed fixed-top z-top" -Content {
            header -Class "app-bar container bg-blue fg-white pos-relative" `
                -Attributes @{'data-role' = 'appbar'; 'data-expand-point' = 'md' } -Content {
                a -href "#" -Class "brand fg-white no-hover" -Content "REACTOR" -Target "_blank"
                ul -Class "app-bar-menu ml-auto" -Content {
                    li -Content { a -href "/about" -Content "About" }
                    li -Content { a -href "/dashboard" -Content "Dashboard" }
                    li -Content { a -href "/contact" -Content "Contact" }
                    li -Content { a -href "/calendar-event" -Content "Book an Event" }
                }
            }
        }
        (1..3).ForEach({ br })
        Div -Class 'container' -Content {
            form -action "/appoauth2" -method "post" -enctype 'multipart/form-data' -content {
                div -class 'form-group' -content {
                    label -content 'Client Id'
                    input -type 'text' -name 'client_id'
                }
                div -class 'form-group' -content {
                    label -content 'Tenant Id'
                    input -type 'password' -name 'tenant_id'
                }
                div -class 'form-group' -content {
                    label -content 'Client Secret'
                    input -type 'password' -name 'client_secret'
                }
                div -class 'form-group' -content {
                    button -class 'button bg-blue outline rounded' -content 'Login'
                }
            }
        }
    }
}
```

### View | Home Page (Home.ps1)

```PowerShell
param($data)

return html -Content {
    head -Content {
        Title -Content "Reactor | Home"
        Link -href "https://cdn.metroui.org.ua/v4.3.2/css/metro-all.min.css" -rel "stylesheet"
        script -src "https://cdn.metroui.org.ua/v4/js/metro.min.js"
    }
    body -Content {
        # Menu Bar
        $colors = @('blue' , 'green' , 'brown' , 'magenta' , 'orange')
        $bgColor = $colors | Get-Random
        Div -Class "container bg-$($bgColor) fg-white pos-fixed fixed-top z-top" -Content {
            header -Class "app-bar container bg-$($bgColor) fg-white pos-relative" `
                -Attributes @{'data-role' = 'appbar'; 'data-expand-point' = 'md' } -Content {
                a -href "#" -Class "brand fg-white no-hover" -Content "REACTOR" -Target "_blank"
                ul -Class "app-bar-menu ml-auto" -Content {
                    li -Content { a -href "/about" -Content "About" }
                    li -Content { a -href "/dashboard" -Content "Dashboard" }
                    li -Content { a -href "/contact" -Content "Contact" }
                    li -Content { a -href "/calendar-event" -Content "Book an Event" }
                }
            }
        }
        (1..2).ForEach({ br })
        Div -Class 'container' -Content {
            '<div data-role="countdown" data-days="1"></div>'
            h5 -content "Your Day look awesome..."
            table -Class "table striped" -Content {
                thead -Content {
                    tr -content {
                        th -Content "Organizer"
                        th -Content "Subject"
                        th -content "Sensitivity" 
                        th -content "Start(UTC)"
                        th -Content "LocalTime"
                    }
                }
                tbody -Content {
                    $MgUserCalendar = Invoke-RestMethod -Uri 'https://graph.microsoft.com/v1.0/users/18804ea8-1129-4996-8fba-a253d2574122/calendar' -Headers $Headers
                    $MgUserCalendarEvents = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/users/18804ea8-1129-4996-8fba-a253d2574122/calendars/$($MgUserCalendar.Id)/events" -Headers $Headers 
                    foreach ($MgUserCalendarEvent in $MgUserCalendarEvents.value) {
                        tr -content {
                            if ((([DateTime]($($MgUserCalendarEvent.Start).DateTime))).Where({ $_.Date -eq ([datetime]::UtcNow.Date) })) {
                                td -Content {
                                    $($MgUserCalendarEvent.Organizer.EmailAddress.Name)
                                }
                                td -Content {
                                    $($MgUserCalendarEvent.Subject)
                                }
                                td -Content {
                                    $($MgUserCalendarEvent.Sensitivity)
                                }
                                
                                td -Content {
                                    (([DateTime]($($MgUserCalendarEvent.Start).DateTime))).Where({ $_.Date -eq ([datetime]::UtcNow.Date) })
                                }
                                td -Content {
                                    (Get-Date).ToShortTimeString()
                                }
                                
                            }
                        }
                    }
                }
            } 
            
        }
        hr
        # (1..2).Foreach({ br })
        Div -Class 'container' -Content {
            h5 -Content "Your action please..."

            $collection = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/users/18804ea8-1129-4996-8fba-a253d2574122/messages?`$filter=importance eq 'high' and isRead eq false" -Headers $Headers
            foreach ($item in $collection.value) {
                Div -class "remark alert" -content {
                    $item.subject
                    br
                    $item.Sender.EmailAddress.Name
                }
            }
        }
        (1..2).ForEach({ br })
        Div -Class 'container' -Content {
            h5 -Content 'User Information'
            Div -Attributes @{"data-role" = "accordion"; "data-one-frame" = "true"; "data-show-active" = "true" } -Content {
                $Users = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/users" -Headers $Global:Headers
                foreach ($User in $Users.value) {
                    Div -Class 'frame' -Content {
                        Div -Class 'heading' -Content $($User.displayName)
                        Div -Class 'content' -Content {
                            Div -Class 'p-2' -Content {
                                $User.jobTitle
                                br 
                                b -Content $User.mobilePhone
                            }
                        }
                    }
                }
            }
        }
    }
}
```

### Sumarry

Congratulations on running your first Azure Container Apps using PowerShell, Pode, PSHML, and Microsoft Graph API. There are a lot more coming up in the future, and please feel free to subscribe to my YouTube channel - iAutomate and follow me on Twitter [ChendrayanV](https://twitter.com/chendrayanv) 