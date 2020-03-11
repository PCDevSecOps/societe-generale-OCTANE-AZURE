<#


 .SYNOPSIS

 .DESCRIPTION

 .PARAMETER storageAccountName

 .PARAMETER storageAccountKey

 .PARAMETER containerName

 .PARAMETER file
    The deployment name.

 .PARAMETER properties

 [Parameter(Mandatory=$True)]
 [string]
 $connection,
.OUTPUTS
.NOTES
    Author: Marouan BELGHITH
    Date: 20 08 2019
#>


param(
    [Parameter(Mandatory=$True, Position = 1)]
    [string]$storageAccountName,

    [Parameter(Mandatory=$True, Position = 2)]
    [string]$primaryStorageAccountKey,

    [Parameter(Mandatory=$True, Position = 3)]
    [string]$containerName,

    [Parameter(Mandatory=$True, Position = 4)]
    [string]$localFile,

    [string]$properties  = @{"ContentType" = "application/zip"}

)

Import-Module -Name AzureRM -Force

# Disable policy
# Set-ExecutionPolicy -ExecutionPolicy Unrestricted

echo  "--------------------------------------------------------------------------------------------------------------------------------"

$localpath = $PSScriptRoot

$product_url = "$localpath\..\..\..\.."
$ansible_path = "$($product_url)\ansible"

$ansiblezipfilelocation = $ansible_path
$localFile_var = "ansible.zip"
$destinationpath = "$($product_url)\$($localFile_var)"

# remove ansible file zip if already exist.

Do{
    Remove-Item -Path  $destinationpath -Force
    echo "===================== DELETING = OLD = ANSIBLE = ZIP = FILE =============================================="
}While(Test-Path $destinationpath)
echo "OLD FILE DELETED"
echo  "-------------------------------Ansible File Generate-------------------------------------------------------------------------------------------------"

[Reflection.Assembly]::LoadWithPartialName( "System.IO.Compression.FileSystem" )
[System.IO.Compression.ZipFile]::CreateFromDirectory($ansible_path, $destinationpath)

sleep 5
# create context
$context =  New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $primaryStorageAccountKey -Protocol "https"
echo  "------------------------------- Ansible Zip context------------------"
echo  "------------------------------- Ansible Start Copying to blob------------------"
#copy hosting file in blob

Set-AzureStorageBlobContent -File $destinationpath -Container $ContainerName   -Blob $localFile_var -Context $context -Force
echo  "--------------------------------------------------------------------------------------------------------------------------------"



