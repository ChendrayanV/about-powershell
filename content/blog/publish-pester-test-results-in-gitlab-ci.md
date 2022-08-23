+++
title = "Publish Pester Test Results in GitLab CI"
description = "Pester | GitLab | PowerShell"
author = "Chendrayan Venkatesan"
draft = "false"
date = "2022-08-23"
tags = ["PowerShell", "Pester" , "GitLab"]
categories = ["GitLab"]
[[images]]
  src = "img/2022/08/GitLab.jpeg"
  alt = "gitlab-series"

+++

# Introduction

I wasn’t sure about the steps to publish the Pester test results in GitLab CI. So, I continued to search over the internet, and as you all know, the search teaches many things. I got many valuable tips and tricks, and here is my version that may help a few. 

## Requirement

- Publish the Pester test results as shown below. 
- Consider using the PowerShell script analyzer in the pipeline. 

## Solution

> .gitlab-ci.yml 

```YAML
stages:
  - pester

0-pester-test:
  stage: pester
  tags:
    - chen
  only:
    - main
  script:
    - | 
      $Container = New-PesterContainer -Path '.\tests\powershell.gitlab.tests.ps1' -Data @{
          Organization = ${url_prefix}; 
          PAT = ${gitlab_pat} 
      } 
      $Config = New-PesterConfiguration
      $Config.Run.PassThru = $true
      $Config.Run.Container = $Container
      $Result = Invoke-Pester -Configuration $Config 
      $Result | Export-JUnitReport -Path '.\testResults.xml'
  artifacts:
    paths: 
      - '.\testResults.xml'
    expire_in: 1 week
    reports:
      junit: .\testResults.xml
```

> Test Case - For Demo (Pester with Param) - powershell.gitlab.tests.ps1

```PowerShell
[CmdletBinding()]
param (
    $Organization,

    $PAT
)

Describe 'PowerShell.GitLab.Utility' {    
    BeforeAll {
        Import-Module .\powershell.gitlab.utility.psd1 -Verbose -Force
        Connect-GitLab -Organization $($Organization) -PAT $($PAT)
    }
    
    It "PowerShell Script Analyzer" {
        (Invoke-ScriptAnalyzer -Path .\tests -Recurse -Severity Error).Count | Should -BeExactly 0
    }

    It "Cmdlet Count" {
        (Get-Command -Module powershell.gitlab.utility).count  | Should -BeExactly 3
    }

    It "Get-GitLabProject" {
        Get-GitLabProject -GroupId '56890329' | Should -BeOfType [System.Management.Automation.PSCustomObject]
    }
}
```

## Outcome 

![Outcome](/img/Outcome.png)

## PowerShell Script Analyzer (For Reference)

![Outcome](/img/PSSA.png)

![Outcome](/img/PSSA-1.png)

## Summary

This blog post is just a start-over. I got a plan to release weekly blogs on GitLab to develop, test, and release PowerShell modules. Stay tuned! 