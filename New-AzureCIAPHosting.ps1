<#
  .SYNOPSIS
   Deploy new CIAP hosting stack.
  .DESCRIPTION
   This script deploys a new CIAP hosting stack on a target subscription/environment, 1 public ip, 1 Loadbalancer 2 VMs haproxy in frontend , 1 VM admin  .
   For now referential is managed manually
  .PARAMETER Environment
     Available deployment environments:
       * dev:  Automation server (Azure devops)
       * hml: Tests & Automation server (Azure devops)
       * prd: Production  (Azure devops with approvable user)
  .PARAMETER Stack
  define tag for all VM Azure that are comprised in CIAP hosting stack.  vm admin is not concerned.
  .EXAMPLE
     Run only form pipeline azure devops.
.OUTPUTS
.NOTES
    Author: Marouan BELGHITH
    Date: 20 08 2019
#>
[CmdletBinding()]
param(

    [Parameter(Mandatory = $True, Position = 1)]
    [ValidateSet("dev", "hml", "prd")]
    [string]$Environment,
    [Parameter(Mandatory = $True, Position = 2)]
    [string]$Stack
)
    $ProjectrootPath = (Get-Item -Path "." -Verbose).FullName
    $RetryBlockPath = "Conf\libs\retryblock.psm1"
    $RetryBlockFullPath = Join-Path $ProjectrootPath $RetryBlockPath
    Import-Module $RetryBlockFullPath

    
    Write-Host "======================= BUILD START ========================================="

try {
    
    #
    # 1  CREATE CIAP HOSTING
    #
    $access_keys = Get-Content -Path  Conf\variables\access.tfvars | Out-String | ConvertFrom-StringData
    $ARM_ACCESS_KEY= $access_keys.access_key1_storage_account_backend
    $env:ARM_ACCESS_KEY= $ARM_ACCESS_KEY.Replace("`"","")
    $ARM_ACCESS_KEY = $env:ARM_ACCESS_KEY
    
    # go to Instance (hosting ciap hosting configuration) to run terraform command so that to create whole ciap hosting
    cd Instance\
    terraform workspace new $global:ProductWorkspace
    Write-Host "-----------------------------------------------------------------------------------------------"
    Write-Information  "terraform init apply ciap hosting"
    terraform  init -backend-config="..\Conf\variables\backend.tfvars" -var-file="..\Conf\variables\variables.tfvars"
    
    Write-Host "---------- CIAP HOSTING INITIATED -------------------"
    Start-Sleep -Seconds 5 
    Write-Information  "terraform apply ciap hosting"
    terraform  apply -parallelism=2 -auto-approve -var-file="..\Conf\variables\access.tfvars" -var-file="..\Conf\variables\logs.tfvars" -var-file="..\Conf\variables\variables.tfvars" -var="environment=$($Environment)"   -var="stack=$($Stack)"
    
    Write-Host "------- Start Sleeping- after-deploy-hosting----------------"
    Start-Sleep -Seconds 10 
    Write-Host "------- Wake Up-------------------"

    # go to workspace.
    cd ..

}
catch
{
    # if any erors then break script and stop all pipelines.
    break
}