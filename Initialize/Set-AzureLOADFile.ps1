<#
  .SYNOPSIS
   create credential azure service principal file authentication as terraform parameter file.
  .DESCRIPTION
   create credential azure service principal file authentication as terraform parameter file.
  .PARAMETER Environment
     Available deployment environments:
       * dev:  Automation server (Azure devops)
       * hml: Tests & Automation server (Azure devops)
       * prd: Production  (Azure devops with approvable user)
  .EXAMPLE
     Run only form pipeline azure devops.
.OUTPUTS
.NOTES
    Author: Youcef FETHOUNE && Marouan BELGHITH
    Date: 01 07 2019
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
$set_conf = ./Initialize/ImportConfigFileInstance.ps1 $Environment

Write-Host "--------------------------- Uncrypt secrets --------------"

$env:tf_client_secret = $global:ConfigOptionsInstance.Azure.SecretKey
#
# 1     CREATE TERRAFROM BACKEND TO STORE CIAP HOSTING TERRRAFORM STATE FILE
#
# go to workspace.
cd  $currentWorkdirectory

# go to terraform configuration for creating azure crendential tfvars file


# add ssh publickeys to variables

$adminpublickey = Get-Content -Path "Conf\privatekeys\admin.pub"
$haproxypublickey = Get-Content -Path "Conf\privatekeys\haproxy.pub"
$wafpublickey = Get-Content -Path "Conf\privatekeys\waf.pub"
$fwpublickey = Get-Content -Path "Conf\privatekeys\fw.pub"

$env:adminpublickey = $adminpublickey.Substring(0,$adminpublickey.IndexOf('==')+2)
$env:haproxypublickey = $haproxypublickey.Substring(0,$haproxypublickey.IndexOf('==')+2)
$env:wafpublickey = $wafpublickey.Substring(0,$wafpublickey.IndexOf('==')+2)
$env:fwpublickey = $fwpublickey.Substring(0,$fwpublickey.IndexOf('==')+2)



# create variable.tfvars and add subscription_id, client_id, client_secret and tenant_id.
Set-Content -Path ".\Conf\variables\variables.tfvars"  -Value "subscription_id = `"$($global:ConfigOptionsInstance.Azure.SubscriptionId)`""
Add-Content -Path ".\Conf\variables\variables.tfvars"  -Value "client_id = `"$($global:ConfigOptionsInstance.Azure.ClientId)`""
Add-Content -Path ".\Conf\variables\variables.tfvars"  -Value "client_secret = `"$($env:tf_client_secret)`""
Add-Content -Path ".\Conf\variables\variables.tfvars"  -Value "tenant_id = `"$($global:ConfigOptionsInstance.Azure.TenantId)`""

# Add SSH PUBLIC KEYS 
Add-Content -Path ".\Conf\variables\variables.tfvars"  -Value "pub_key_haproxy = `"$($env:haproxypublickey)`""
Add-Content -Path ".\Conf\variables\variables.tfvars"  -Value "pub_key_waf = `"$($env:wafpublickey)`""
Add-Content -Path ".\Conf\variables\variables.tfvars"  -Value "pub_key_fw = `"$($env:fwpublickey)`""
Add-Content -Path ".\Conf\variables\variables.tfvars"  -Value "pub_key_admin = `"$($env:adminpublickey)`""



$variables = Get-Content -Path ".\Conf\variables\variables.tfvars"
Write-Host "=== variables :====  $variables ========="

