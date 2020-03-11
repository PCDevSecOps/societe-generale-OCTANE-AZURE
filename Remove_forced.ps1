[CmdletBinding()]
param(
    [Parameter(Mandatory = $True, Position = 1)]
    [string]$Subscription
)


try
{

    #Connect to azure with your crendential
    az login

    # set current subscription.
    az account set --subscription  $Subscription


    # delete resource group.
    az group delete --name octane-rg  --yes  --verbose

    sleep -Seconds 360

    # resource group array
    $resourcegroups1 = @("admin-rg", "up-rg", "backend-rg")

    # delete all ressource groups in the current subscription provided as parameter in this script.
    foreach ($resourcegroup in $resourcegroups1)
    {

        #  Delete  resource group in parallel
        Write-Host  "delete resource group:   $resourcegroup"
        az group delete --name $resourcegroup --no-wait  --yes  --verbose
    }


    sleep -Seconds 180

    $resourcegroups2 = @( "low-rg", "mid-rg" )

    # delete all ressource groups in the current subscription provided as parameter in this script.
    foreach ($resourcegroup in $resourcegroups2)
    {
        #  Delete  resource group in parallel
        Write-Host  "delete resource group:   $resourcegroup"
        az group delete --name $resourcegroup  --yes  --verbose --no-wait
    }
}
catch
{
    break
}








