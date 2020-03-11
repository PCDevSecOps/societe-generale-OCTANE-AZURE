<#
  .SYNOPSIS
   Destroy  CIAP hosting Socle.
  .DESCRIPTION
   This script destroys CIAP hosting Socle on a target subscription/environment.
  .PARAMETER Environment
     Available deployment environments:
       * dev:  Automation server (Azure devops)
       * hml: Tests & Automation server (Azure devops)
       * prd: Production  (Azure devops with approvable user)
  .PARAMETER Stack
   CIAP hosting Socle.
  .EXAMPLE
     .
.OUTPUTS
.NOTES
    Author: Marouan BELGHITH
    Date: 03 10 2019

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
    # 1 DESTROY AZURE CIAP HOSTING SOCLE
    #

    Write-Host "-----------------------------------------------------------------------------------------------"
    Write-Host "terraform destroy ciap socle"


    cd Socle

    terraform  destroy  -auto-approve -var-file="..\Conf\Socle\variables.tfvars" -var-file="..\Conf\Socle\backend.tfvars"  -var="environment=$($Environment)"

    # go to workspace.
    cd ..

}
catch
{
    # if any erors then break script and stop all pipelines azure devops.
    break
}
