+++
title = "Test and Deploy Bicep Template for Azure Function App using Azure DevOps"
description = "first leg in Azure DevOps..."
author = "Chendrayan Venkatesan"
draft = "false"
date = "2022-03-10"
tags = ["Azure Front Door", "Serverless Compute" , "Azure Function"]
categories = ["Azure-Functions"]
[[images]]
  src = "img/2022/03/Own-Error.jpg"
  alt = "Own Error"

+++

# Introduction

As DevOps folks, we all know that deploying code into the infrastructure without testing is not good. Yes, nobody disagrees! When it comes to the infrastructure as a code, the testing rules may differ, but the common factors are applicable. In this blog post, let me walk you through the steps to deploy Azure Function app in multiple regions with proper testing in place. 

I have a bunch of bicep codes. What should I test? Where should I start? Without a wait, you go [here](https://docs.microsoft.com/en-us/learn/modules/test-bicep-code-using-azure-pipelines/). 

Hey, no doubt! I use the same template with minor modifications that meet my goals. The below image depicts the flow 

![Stages](https://raw.githubusercontent.com/ChendrayanV/about-powershell/main/static/img/2022/03/Stages.png)

## Stages

### Lint 

```YAML
  - stage: Lint
    jobs:
      - job: Lint
        steps:
          - task: AzureCLI@2
            name: LintBicepCode
            displayName: 'Run Bicep linter'  
            inputs:
              azureSubscription: automata
              scriptType: pscore
              scriptLocation: inlineScript
              inlineScript: |
                az bicep build --file template/main.bicep
```

### Validate (North Europe)

```YAML
  - stage: ValidateEN
    jobs:
      - job: Validate
        steps:
          - task: AzureCLI@2
            name: RunPreflightValidation
            displayName: Run preflight validation
            inputs:
              azureSubscription: 'automata'
              scriptLocation: inlineScript
              scriptType: pscore
              inlineScript: |
                az deployment sub validate `
                  --name 'automata-en-validate' `
                  --template-file template/main.bicep `
                  --location northeurope `
                    --parameters resourceGroupname='rgp-func-prim-dev-en' `
                        location='northeurope' `
                        storageaccountname='stgfuncprimdeven' `
                        appinsightname='ai-prim-automata-en-dev' `
                        appserviceplanname='asp-prim-automata-en-dev' `
                        functionappname='func-prim-automata-en-dev'
```

### Deploy (North Europe)

```YAML
  - stage: DeployEN
    displayName: 'Deploy(North Europe)'
    jobs:
      - job: Deploy
        steps:
          - task: AzureCLI@2
            name: Deploy
            inputs:
              azureSubscription: automata
              scriptType: pscore
              scriptLocation: inlineScript
              inlineScript: |
                az deployment sub create `
                    --name 'automata-north-europe' `
                    --template-file template/main.bicep `
                    --location northeurope `
                      --parameters resourceGroupname='rgp-func-prim-dev-en' `
                          location='northeurope' `
                          storageaccountname='stgfuncprimdeven' `
                          appinsightname='ai-prim-automata-en-dev' `
                          appserviceplanname='asp-prim-automata-en-dev' `
                          functionappname='func-prim-automata-en-dev'
```

### Validate (West US)

```YAML
  - stage: ValidateUW
    jobs:
      - job: Validate
        steps:
          - task: AzureCLI@2
            name: RunPreflightValidation
            displayName: Run preflight validation
            inputs:
              azureSubscription: 'automata'
              scriptLocation: inlineScript
              scriptType: pscore
              inlineScript: |
                az deployment sub validate `
                  --name 'automata-uw-validate' `
                  --template-file template/main.bicep `
                  --location westus `
                    --parameters resourceGroupname='rgp-func-prim-dev-uw' `
                        location='westus' `
                        storageaccountname='stgfuncprimdevuw' `
                        appinsightname='ai-prim-automata-uw-dev' `
                        appserviceplanname='asp-prim-automata-uw-dev' `
                        functionappname='func-prim-automata-uw-dev'
```

### Deploy (West US)

```YAML
  - stage: DeployUW
    displayName: 'Deploy(West US)'
    jobs:
      - job: Deploy
        steps:
          - task: AzureCLI@2
            name: Deploy
            inputs:
              azureSubscription: automata
              scriptType: pscore
              scriptLocation: inlineScript
              inlineScript: |
                az deployment sub create `
                    --name 'automata-west-us' `
                    --template-file template/main.bicep `
                    --location westus `
                      --parameters resourceGroupname='rgp-func-prim-dev-uw' `
                          location='westus' `
                          storageaccountname='stgfuncprimdevuw' `
                          appinsightname='ai-prim-automata-uw-dev' `
                          appserviceplanname='asp-prim-automata-uw-dev' `
                          functionappname='func-prim-automata-uw-dev'
```