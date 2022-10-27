+++
title = "Untapping Infrastructure Registry in GitLab – Part 1"
description = "an intro to infrastructure registry…"
author = "Chendrayan Venkatesan"
draft = "false"
date = "2022-10-27"
tags = ["Azure" , "Terraform" , "GitLab"]
categories = ["GitLab"]
[[images]]
  src = "img/2022/10/Blog-GitLab-01.jpg"
  alt = "gitlab-series"

+++

# Introduction

Yesterday I spent a few hours in Infrastructure Registry for my learning. Oh, well, I am not impressed with the implementation work. But I still love the feature. So, here is the blog post to get started. 

## Prerequisites

- Azure Account. 
    - Refer [here](https://azure.microsoft.com/en-gb/free/) for free access (12 Months) 
- GitLab Account. 
    - [Set up your own GitLab instance](https://about.gitlab.com/free-trial/)

## Requirement

- Create a Terraform module
- Publish to Infrastructure Registry 
- Consume the module to create Azure resources 

## Solution

> **Note:** For now, let us ignore the quality of the project scaffolding, security, code scanning, process, and protocols.

This blog post shows how I hooked up to demonstrate the infrastructure registry—enough theory. Let’s play on! 

> Step 1: Create a repository for the Terraform module. Below is an illustration of the project structure. 

```Markdown
📦azurerm  
 ┣ 📜.gitlab-ci.yml  
 ┣ 📜main.tf  
 ┗ 📜README.md  
```

```YAML (.gitlab-ci.yml )
stages:
  - upload

image: curlimages/curl:latest

variables:
  TERRAFORM_MODULE_DIR: ${CI_PROJECT_DIR}
  TERRAFORM_MODULE_NAME: ${CI_PROJECT_NAME}
  TERRAFORM_MODULE_SYSTEM: azure
  TERRAFORM_MODULE_VERSION: "0.0.3"

upload:
  stage: upload
  script:
    - tar -cvzf ${TERRAFORM_MODULE_NAME}-${TERRAFORM_MODULE_SYSTEM}-${TERRAFORM_MODULE_VERSION}.tgz -C ${TERRAFORM_MODULE_DIR} --exclude=./.git .
    - 'curl --header "JOB-TOKEN: ${CI_JOB_TOKEN}" --upload-file ${TERRAFORM_MODULE_NAME}-${TERRAFORM_MODULE_SYSTEM}-${TERRAFORM_MODULE_VERSION}.tgz ${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/terraform/modules/${TERRAFORM_MODULE_NAME}/${TERRAFORM_MODULE_SYSTEM}/${TERRAFORM_MODULE_VERSION}/file'

```

```Terraform (main.tf)
resource "azurerm_resource_group" "rg" {
  name     = "rgp-chendrayan-dev"
  location = "eastus"
  tags = {
    "environment" = "develop"
    "owner"       = "chendrayan venkatesan"
  }
}
```

Step 2: Commit and Push 

```PowerShell
PS C:\repos\azurerm> git add .
PS C:\repos\azurerm> git commit -m 'Your COMMIT message'
PS C:\repos\azurerm> git push -u origin master
```

A distributable module is ready for use across the organization after successfully executing the pipeline. 

![Output](/img/Infrastructure-Registry-01.png) 

![Output](/img/Infrastructure-Registry-02.png)

Step 3: Consume the Module (Any Project in GitLab instance)

Here is the project scaffolding for consuming the module 

📦ColorsOfCuisines  
 ┣ 📜.gitlab-ci.yml  
 ┣ 📜main.tf  
 ┗ 📜README.md  

```Terraform (main.tf)
provider "azurerm" {
  features {}
}
module "my_module_name" {
  source  = "gitlab.com/Platform-Engineering-Dev/azurerm/azure"
  version = "0.0.2"
}
```

```YAML (.gitlab-ci.yml)
include:
  - template: Terraform.latest.gitlab-ci.yml

variables:
  TF_CLI_CONFIG_FILE: $CI_PROJECT_DIR/.terraformrc

before_script:
  - echo -e "credentials \"$CI_SERVER_HOST\" {\n  token = \"$CI_JOB_TOKEN\"\n}" > $TF_CLI_CONFIG_FILE
```

## Output

![Output](/img/Infrastructure-Registry-03.png)


## What's next? 

- Refactoring the code.
- Real-world examples with production-ready projects.

**Stay Tuned!**