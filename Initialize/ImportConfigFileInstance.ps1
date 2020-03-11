<#
  .SYNOPSIS
   load conf files
  .DESCRIPTION
   This script defines and load conf files 
  .PARAMETER Environment
     Available deployment environments:
       * dev:  Automation server (Azure devops)
       * hml: Tests & Automation server (Azure devops)
       * prd: Production  (Azure devops with approvable user)
  .EXAMPLE
     Run to load conf files.
.OUTPUTS
.NOTES
    Author: Marouan Belghith
    Date: 21 06 2019

#>

[CmdletBinding()]
param(

    [Parameter(Mandatory = $True, Position = 1)]
    [ValidateSet("dev", "hml", "prd")]
    [string]$Environment
)
    $ConfigFileInstance  = "Conf/config.instance.$($Environment).json"
    
    $global:ConfigOptionsInstance = Get-Content -Raw -Path "$ConfigFileInstance" | ConvertFrom-Json
    if (! $global:ConfigOptionsInstance) {
    Write-Error "Initialize-AzureCIAPHosting: Configuration file (Instance) [$ConfigFileInstance] not loaded"
    exit 1
    }
    Write-Information -logdata "Initialize-AzureCIAPHosting: Configuration file (Instance) [$ConfigFileInstance] loaded"
    $global:Domain = $($global:ConfigOptionsInstance.Global.Domain)
    $global:Product = $($global:ConfigOptionsInstance.Global.Product)
    $global:ProductWorkspace = $($global:ConfigOptionsInstance.Instance.Workspace)