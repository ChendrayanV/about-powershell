+++
author = "Chendrayan Venkatesan"
categories = ["Azure"]
tags = ["Azure Function" , "Durable", "C#"]
date = "2020-06-28"
description = ""
featured = "Sand-Clock.jpg"
featuredalt = "Sand-Clock"
featuredpath = "date"
linktitle = ""
title = "MY FIRST EXPERIENCE WITH THE AZURE DURABLE FUNCTIONS"
type = "post"
draft = "false"

+++

## Introduction

Of late, I got a requirement to start the Azure runbooks programmatically (start a runbook through another runbook), and as a PowerShell fan, I said, “Start-AzAutomationAccountRunBook” is one best way to achieve it. An hour later, I got a call to build a script that waits until the job completes and gets the output. Here is a quick way “-Wait” parameter. Solved the issue? Yes! Now, it’s time for us to deliver a REST API endpoint, which is required to invoke in an Azure Pipeline for the business process. 

As you guessed, I did that! I did a lift shift of the PowerShell script to Azure functions, and all worked fine as expected. One beautiful day the issue occurred “503 Time-Out Occurred”. First, I thought the issue is due to a cold and warm start. But that’s not the case here! The HTTP trigger is to call the parent runbook, which may run more than 230 seconds and times out. The maximum timeout of HTTP Trigger is 230 seconds (4 minutes), and this can’t be changed. 

When the runbook job is submitted, it gets queued and then moves to “running,” waits until the job completes, and then returns the output. 

> The below snippet does the same.

```PowerShell
$params = @{
    Name                  = "iTrigger"
    ResourceGroupName     = "iAutomate"
    AutomationAccountName = "iautomate-AAA"
    Parameters            = @{FirstName = 'Chen'; SurName = 'V'; Skills = @('C#' , 'PowerShell') }
    Wait                  = $true 
}
Start-AzAutomationRunbook @params
```

## Azure Durbale Functions

> If you are new to Azure Durable Functions, please refer to this [document](https://docs.microsoft.com/en-us/azure/azure-functions/durable/durable-functions-overview?tabs=csharp) to get to know more information.

An overview of my requirement is depicted below 

![image](img/2020/06/async-http-api.png)

### HTTP Starter Function

```C#
[FunctionName("FunctionName_HTTPStart")]
        public static async Task<HttpResponseMessage> HttpStart(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", "post")] HttpRequestMessage req,
            [DurableClient] IDurableOrchestrationClient starter,
            ILogger log)
        {
            var groupRequest = await req.Content.ReadAsAsync<iRunBook>();
            string instanceId = await starter.StartNewAsync("FunctionName", groupRequest);
            log.LogInformation($"Started orchestration with ID = '{instanceId}'.");
            return starter.CreateCheckStatusResponse(req, instanceId);
        }
```

### HTTP Durable Function

```C#
do
{
    result = automationManagementClient.Jobs.Get(Environment.GetEnvironmentVariable("RESOURCE_GROUP"), Environment.GetEnvironmentVariable("AUTOMATION_ACCOUNT_NAME"), jobCreateResponse.Job.Properties.JobId);
    System.Threading.Thread.Sleep(30000);
} while ((result.Job.Properties.Status != JobStatus.Completed) && (result.Job.Properties.Status != JobStatus.Failed) && ((result.Job.Properties.Status != JobStatus.Stopped) && ((result.Job.Properties.Status != JobStatus.Suspended))));
System.Threading.Thread.Sleep(30000);
JobGetOutputResponse jobGetOutputResponse = automationManagementClient.Jobs.GetOutput(Environment.GetEnvironmentVariable("RESOURCE_GROUP"), Environment.GetEnvironmentVariable("AUTOMATION_ACCOUNT_NAME"), jobCreateResponse.Job.Properties.JobId);
return jobGetOutputResponse.Output;
```

### iRunBook Model

```C#
using System;

namespace iRunBook
{
    public string FirstName {get;set;}
    public string SurName {get;set;}
    public string Skills {get;set;}
}
```

### Challenge 

The runbook we need to start has three parameters like listed below

1. FirstName (String)
2. SurName (String)
3. Skills (Array)

> The `JobCreateParameters` has parameters properties which is of type **IDictionary<String, String>** 

So, the client code to invoke the parameters needs a minor modification as shown below

```PowerShell
$body = [pscustomobject]@{
    FirstName = "Chendrayan"
    SurName   = "Venkatesan"
    Skills    = '["C#" , "PowerShell" , "Webframework"]'
} | ConvertTo-Json 
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12
 
$Params = @{
    Uri         = "https://iSite.azurewebsites.net/api/FunctionName_HttpStart"
    Method      = "POST"
    Body        = $body
    ContentType = "application/json"
    Verbose     = $true
}
$invokeResponse = Invoke-RestMethod @Params
Start-Sleep -Seconds 5
do {
    Start-Sleep -Seconds 5
    $status = Invoke-RestMethod $invokeResponse.statusQueryGetUri -Verbose
    $status
} until ($status.runtimeStatus -eq 'Completed' -or $status.runtimeStatus -eq 'Failed')
```

## Conclusion

A simple conversion of my PowerShell script to C# helped me to solve the issue. In the HTTP durable function, we used `do while` loop to monitor the status and fetch the output. Yes, we can use the ASYNC programming pattern, which I am working on to share in my upcoming blog posts with another real-world example. Please share your valuable feedback. Follow me on [twitter](https://twitter.com/chendrayanv).