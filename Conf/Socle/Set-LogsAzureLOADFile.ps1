<#
  .SYNOPSIS
   create credential of Logs on azure service principal file authentication as terraform parameter file.
  .DESCRIPTION
   create credential of Logs on azure service principal file authentication as terraform parameter file.
  .PARAMETER Environment
     Available deployment environments:
       * dev:  Automation server
       * prd: Production  (Azure devops with approvable user)
  .EXAMPLE
     
.OUTPUTS
.NOTES
    Author: Marouan BELGHITH
    Date: 25-09-2019
#>


[CmdletBinding()]
param(

[Parameter(Mandatory = $True, Position = 1)]
[ValidateSet("dev", "hml", "prd")]
[string]$Environment
)

$currentWorkdirectory= (Get-Item -Path "." -Verbose).FullName

Write-Host " currentWorkdirectory : $currentWorkdirectory "
# Import Config Files
$set_conf = ./Conf/Socle/ImportConfigFileSocle.ps1

Write-Host "--------------------------- Uncrypt secrets --------------"

$env:tf_client_secret = $global:ConfigOptionsSocle.Azure.SecretKey
#
# 1     CREATE TERRAFROM BACKEND TO STORE CIAP HOSTING TERRRAFORM STATE FILE
#
# go to workspace.
cd  $currentWorkdirectory

# create variable.tfvars and add subscription_id, client_id, client_secret and tenant_id.
Set-Content -Path ".\Conf\Socle\variables.tfvars"  -Value "subscription_id = `"$($global:ConfigOptionsSocle.Azure.SubscriptionId)`""
Add-Content -Path ".\Conf\Socle\variables.tfvars"  -Value "client_id = `"$($global:ConfigOptionsSocle.Azure.ClientId)`""
Add-Content -Path ".\Conf\Socle\variables.tfvars"  -Value "client_secret = `"$($env:tf_client_secret)`""
Add-Content -Path ".\Conf\Socle\variables.tfvars"  -Value "tenant_id = `"$($global:ConfigOptionsSocle.Azure.TenantId)`""

