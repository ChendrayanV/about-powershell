+++
title = "Generate Dynamic Pipeline for folder-specific changes in GitLab"
description = "a simple method to manage mono repository"
author = "Chendrayan Venkatesan"
draft = "false"
date = "2022-08-31"
tags = ["PowerShell", "Dynamic-Pipeline" , "GitLab"]
categories = ["GitLab"]
[[images]]
  src = "img/2022/08/Dynamic-Pipe.jpeg"
  alt = "gitlab-series"

+++

# Introduction

As a DevSecOps focal, I get exciting tasks. Of late, I was battling with mono and multi-repositories. It's easy to convince many, but few won't agree to the project scaffolding change. So, we need to identify the best possible way. I am sure this is not a thin-on-the-ground requirement. Yes,  you may need this trick to compromise the team who doesn't wish to go for the mono to multi repository.

**What is a mono repository?**

***A repository with multiple projects***

**What is a multi-repository concept?**

***Each repository contains a single project.***

Both have their pros and cons. Hold on! We aren't here to talk about mono versus multi, and if you want to know more about it, here is the reference link. 

## Requirement 

- We have 10+ folders, and each has microservice applications source code. 
- Team may add 20 more projects to the mono repository. 
- We need a pipeline to run based on the change in the folder or folders.
- All the folders follow the same structure. 

## Solution

Dynamic Pipeline. Yes, generate a pipeline and trigger based on the rule. There are solutions available in Python (Refer to the credits section). I made a minor tweak to meet business requirements. As you know, my version is in PowerShell. 
For our demo, I created the project structure as illustrated below 

📦PS.Enterprise.Utility  
 ┣ 📂AzDO  
 ┃ ┣ 📂tests  
 ┃ ┃ ┗ 📜AzDO.tests.ps1  
 ┃ ┣ 📜AzDO.psd1  
 ┃ ┗ 📜AzDO.psm1  
 ┣ 📂GitLab  
 ┃ ┣ 📂tests  
 ┃ ┃ ┗ 📜GitLab.tests.ps1  
 ┃ ┣ 📜GitLab.psd1  
 ┃ ┗ 📜GitLab.psm1  
 ┣ 📂Utility  
 ┃ ┣ 📂src  
 ┃ ┗ 📂tests  
 ┃ ┃ ┗ 📜Utility.tests.ps1  
 ┣ 📜.gitlab-ci.yml  
 ┣ 📜parent-boiler-plate.txt  
 ┣ 📜README.md  
 ┗ 📜script.ps1  

 A change in AzDo should run a job for AzDo and not for other folders. 

 ![Requirement](/img/Requitement.png)

 ```YAMl (.gitlab-ci.yml)
stages:
  - generate-jobs
  - trigger-generated-pipeline

generate:
  stage: generate-jobs
  tags:
    - "chenvpsutility"
  script:
    - .\script.ps1
  artifacts:
    paths:
      - child-pipeline-gitlab-ci.yml

trigger:
  stage: trigger-generated-pipeline
  trigger:
    include:
      - artifact: child-pipeline-gitlab-ci.yml
        job: generate
    strategy: depend
 ```

 The parent pipeline (.gitlab-ci.yml) invokes the script (PowerShell), that generates the child pipeline and upload the child-pipeline to the artifact. The Trigger stage calls to run it. 

 ```PowerShell (script.ps1)
$Directories = Get-ChildItem | Where-Object { $_.PSIsContainer -eq $true } 
$Directories | . {
    process {
        @"
$($_.Name)-Build-Job:
  stage: PS-BUILD
  tags:
    - "chenvpsutility"
  rules:
    - changes:
        - $($_.Name)/**/*
  script:
    - .\$($_.Name)\tests\$($_.Name).tests.ps1

"@
    }
} | Out-File '.\child-pipeline-gitlab-ci.yml' -Encoding ascii

$ChildPipeline = '.\child-pipeline-gitlab-ci.yml'
$ParentPipeline = '.\parent-boiler-plate.txt'
$(Get-Content $ParentPipeline; Get-Content $ChildPipeline) | Set-Content $ChildPipeline -Encoding Ascii
 ```

 Now, change in AzDo / GitLab / Utility - The pipeline triggers for the specific folder. Yes, you add a new folder with the same structure, a new job gets created. 

 ## Output 

 ![Output](/img/Output-Dynamic-Pipeline.png)

Here, the boilerplate is extendable. For my requirement, I just added the stages keyword.

```YAML (parent-boiler-plate.txt)
stages:
  - PS-BUILD


```

> The newline is for proper spacing to meet YAML schema (GitLab). For now, don't change the indentation in script.ps1.

## Credits

- [Andras Kelle](https://infinitelambda.com/post/dynamic-pipeline-generation-gitlab/)
- [DevOps228 - AWS Terraform GitLab](https://www.youtube.com/watch?v=rbgXglWmntk)

 ## Summary

 This one requirement made me busy for 8 hours. To be precise, one business day! So, I hope that it helps someone looking for this solution. Please feel free to add your comments. 