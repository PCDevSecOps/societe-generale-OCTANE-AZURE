<#
  .SYNOPSIS
   load conf files for builing Socle
  .DESCRIPTION
   This script defines and load conf files 
  .EXAMPLE
     Run to load conf files.
.OUTPUTS
.NOTES
    Author: Marouan Belghith
    Date: 25 09 2019

#>

[CmdletBinding()]
param()
    $ConfigFileSocle  = "Conf/config.socle.json"
    
    $global:ConfigOptionsSocle = Get-Content -Raw -Path "$ConfigFileSocle" | ConvertFrom-Json
    if (! $global:ConfigOptionsSocle) {
        Write-Error "Initialize-AzureCIAPHosting: Configuration file (Socle) [$ConfigFileSocle] not loaded"
    exit 1
    }
    Write-Information "Initialize-AzureCIAPHosting: Configuration file (Socle) [$ConfigFileSocle] loaded"
    $global:Domain = $($global:ConfigOptionsSocle.Global.Domain)
    $global:Product = $($global:ConfigOptionsSocle.Global.Product)
    Write-Information "Initialize [$global:ConfigOptionsSocle] loaded"