<#
  .SYNOPSIS
   Deploy socle CIAP hosting stack.
  .DESCRIPTION
   This script deploys a new socle for CIAP hosting stack
  .PARAMETER Environment
     Available deployment environments:
       * dev:  Automation server 
       * hml: Tests & Automation server 
       * prd: Production  
  .EXAMPLE
     Run only once for all CIAP Hosting.
.OUTPUTS
.NOTES
    Author: Marouan BELGHITH
    Date: 13 09 2019
#>


[CmdletBinding()]
param(

    [Parameter(Mandatory = $True, Position = 1)]
    [ValidateSet("dev", "hml", "prd")]
    [string]$Environment
)
    $ProjectrootPath = (Get-Item -Path "." -Verbose).FullName


    echo "======================= SET CREDENTIALS ========================================="
    $set_credentials = ./Conf/Socle/Set-LogsAzureLOADFile.ps1 $Environment

    echo "======================= BUILD LOGS  ========================================="

try {
    
    #
    # 1 CREATE LOG ANALYTICS
    #
    cd Socle\
    echo "-------------------------------- terraform init ---------------------------------------------------------------"
    echo  "terraform init SOCLE"
    terraform  init -force-copy -reconfigure
    
    terraform  apply  -auto-approve -var-file="..\Conf\Socle\variables.tfvars" -var-file="..\Conf\Socle\backend.tfvars"  -var="environment=$($Environment)" -parallelism=1

    echo "------- Socle Log Analytics CREATED -------------------"
    Start-Sleep -Seconds 10 
    echo "------- Wake Up & Export -------------------"
    $azure_logs_loganalytics_workspaceid=terraform  output azure_logs_loganalytics_workspaceid
    $env:azure_logs_loganalytics_workspaceid=$azure_logs_loganalytics_workspaceid
    Start-Sleep -Seconds 5
    $azure_logs_loganalytics_workspacekey=terraform  output azure_logs_loganalytics_workspacekey
    $env:azure_logs_loganalytics_workspacekey=$azure_logs_loganalytics_workspacekey
    $ARM_ACCESS_KEY=terraform  output access_key1_storage_account_backend
    $env:ARM_ACCESS_KEY=$ARM_ACCESS_KEY
    Set-Content -Path ".\..\Conf\variables\logs.tfvars"  -Value "azure_logs_loganalytics_workspaceid = `"$($env:azure_logs_loganalytics_workspaceid)`""
    add-Content -Path ".\..\Conf\variables\logs.tfvars"  -Value "azure_logs_loganalytics_workspacekey = `"$($env:azure_logs_loganalytics_workspacekey)`""
    echo "============== azure_logs_loganalytics_workspaceid EXPORTED ============"
    Set-Content -Path ".\..\Conf\variables\access.tfvars"  -Value "access_key1_storage_account_backend = `"$($ARM_ACCESS_KEY)`""
    
    
    echo "============== access key EXPORTED ============"
    cd ..
    Start-Sleep -Seconds 5 
    Write-Host "------- BACKEND STORAGE ACCOUNT CREATED -------------------"
}
catch
{
    # if any erors then break script and stop all pipelines.
    break
}