<#
  .SYNOPSIS
   INITIALIZE CIAP HOSTING
  .DESCRIPTION
   This script aims to initialize deploy elements needed by terraform to execute and configure the CIAP Hosting on Azure
  .PARAMETER Environment
     Available deployment environments:
       * dev:  Automation server (Azure devops)
       * hml: Tests & Automation server (Azure devops)
       * prd: Production  (Azure devops with approvable user)
  .EXAMPLE
     Run only for jenkins pipeline.
.OUTPUTS
.NOTES
    Author: Marouan BELGHITH
    Date: 20 08 2019
#>


[CmdletBinding()]
param(

[Parameter(Mandatory = $True, Position = 1)]
[ValidateSet("dev", "hml", "prd")]
[string]$Environment
)

$currentWorkdirectory= (Get-Item -Path "." -Verbose).FullName

Write-Host "======================= Create:SSHKeysCIAPHosting ========================================="
$load_files = ./Initialize/Set-rsaKeys.ps1 $Environment

Write-Host "======================= LOAD FILES ========================================="
$load_files = ./Initialize/Set-AzureLOADFile $Environment

Write-Host "--------------------------- End---of---SSH---SCRIPT--------------"