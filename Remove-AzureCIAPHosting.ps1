<#
  .SYNOPSIS
   Destroy  CIAP hosting stack.
  .DESCRIPTION
   This script destroes CIAP hosting stack on a target subscription/environment, 1 public ip, 1 Loadbalancer 2 VMs haproxy in frontend , 1 VM admin  .
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
    Author: Youcef FETHOUNE &  Marouan BELGHITH
    Date: 22 07 2019

#>


[CmdletBinding()]
param(

    [Parameter(Mandatory = $True, Position = 1)]
    [ValidateSet("dev", "hml", "prd")]
    [string]$Environment,
    [Parameter(Mandatory = $True, Position = 2)]
    [string]$Stack
)



try
{
    #
    # DESTROY CIAP HOSTING Instances
    #

    Write-Host "-----------------------------------------------------------------------------------------------"
 
    cd Instance

    terraform  destroy  -auto-approve -var-file="..\Conf\variables\access.tfvars" -var-file="..\Conf\variables\logs.tfvars" -var-file="..\Conf\variables\variables.tfvars" -var="environment=$($Environment)"   -var="stack=$($Stack)"


    #
    # 3 DESTROY STORAGE ACCOUNT WHICH HOSTS TERRAFORM STATE FILE
    #

    #  destroy backend hosting
    Write-Host "-----------------------------------------------------------------------------------------------"
    Write-Host "terraform destroy storage acccount which hosts ciap hosting terraform state file"

    # go to workspace.
    cd ..


}
catch
{
    # if any erors then break script and stop all pipelines azure devops.
    break
}
