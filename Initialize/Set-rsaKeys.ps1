<#
  .SYNOPSIS
   Prepare Private keys for Admin & haproxy.
  .DESCRIPTION
   Prepare Private keys for Admin & haproxy then copy them to azurerm account.
  .PARAMETER Environment
     Available deployment environments:
       * dev:  Automation server 
       * hml: Tests & Automation server 
       * prd: Production 
  .EXAMPLE
     Run only for jenkins pipeline.
.OUTPUTS
.NOTES
    Author: Marouan BELGHITH
    Date: 13 06 2019
#>


[CmdletBinding()]
param(

[Parameter(Mandatory = $True, Position = 1)]
[ValidateSet("dev", "hml", "prd")]
[string]$Environment
)

$currentWorkdirectory= (Get-Item -Path "." -Verbose).FullName

#
# 1     Find or CREATE Private keys for Admin & haproxy
#
# go to workspace.
cd  $currentWorkdirectory
Write-Host "--------------------------- Delete--old---Keys--if--exists----------------"
# go to privekeys folder
New-Item -ItemType Directory -Force -Path Conf\privatekeys

cd Conf\privatekeys\
If (Test-Path admin -PathType Leaf) {
  Remove-Item "admin"
}
If (Test-Path haproxy -PathType Leaf) {
  Remove-Item "haproxy"
}
If (Test-Path admin.pub -PathType Leaf) {
  Remove-Item "admin.pub"
}
If (Test-Path haproxy.pub -PathType Leaf) {
  Remove-Item "haproxy.pub"
}
If (Test-Path waf -PathType Leaf) {
  Remove-Item "waf"
}
If (Test-Path fw -PathType Leaf) {
  Remove-Item "fw"
}
If (Test-Path waf.pub -PathType Leaf) {
  Remove-Item "waf.pub"
}
If (Test-Path fw.pub -PathType Leaf) {
  Remove-Item "fw.pub"
}
Write-Host "--------------------------- Generate---Keys --------------"

If (Test-Path encryptedadmin -PathType Leaf) {
  Remove-Item "encryptedadmin"
}
ssh-keygen -m PEM -t rsa -b 4096 -f admin -q -N ciaphostingcoe
Copy-Item  admin  -Destination encryptedadmin
openssl rsa -in encryptedadmin -out admin -passin pass:ciaphostingcoe

# ssh-keygen -t rsa -b 4096 -f haproxy -q -N '' -C ''
# ssh-keygen -t rsa -b 4096 -f waf -q -N '' -C ''
# ssh-keygen -t rsa -b 4096 -f fw -q -N '' -C ''

# WORKING WITH SAME KEY FOR DEV PURPOSES

Copy-Item  admin  -Destination haproxy
Copy-Item  admin  -Destination fw
Copy-Item  admin  -Destination waf

Copy-Item  admin.pub  -Destination haproxy.pub
Copy-Item  admin.pub  -Destination fw.pub
Copy-Item  admin.pub  -Destination waf.pub

Write-Host "--------------------------- Find ---Keys--ORIGINAL LOCATION --------------"

$admin = Get-ChildItem "admin"
$haproxy = Get-ChildItem "haproxy"
$waf = Get-ChildItem "waf"
$fw = Get-ChildItem "fw"
$fwfilepath = $fw.FullName
$waffilepath = $waf.FullName
$haproxyfilepath = $haproxy.FullName
$adminfilepath = $admin.FullName

cd $currentWorkdirectory

Write-Host "--------------------------- Remove old ssh keys--------------"

If (Test-Path Conf\variables\private_key_waf -PathType Leaf) {
  Remove-Item "Conf\variables\private_key_waf"
}
If (Test-Path Conf\variables\private_key_fw -PathType Leaf) {
  Remove-Item "Conf\variables\private_key_fw"
}
If (Test-Path Conf\variables\private_key_admin -PathType Leaf) {
  Remove-Item "Conf\variables\private_key_admin"
}
If (Test-Path Conf\variables\private_key_haproxy -PathType Leaf) {
  Remove-Item "Conf\variables\private_key_haproxy"
}

If (Test-Path Conf\variables\private_key_waf -PathType Leaf) {
  Remove-Item "Conf\variables\private_key_waf"
}
If (Test-Path Conf\variables\private_key_fw -PathType Leaf) {
  Remove-Item "Conf\variables\private_key_fw"
}
If (Test-Path Conf\variables\private_key_admin -PathType Leaf) {
  Remove-Item "Conf\variables\private_key_admin"
}
If (Test-Path Conf\variables\private_key_haproxy -PathType Leaf) {
  Remove-Item "Conf\variables\private_key_haproxy"
}

Write-Host "--------------------------- Copy---New---Keys--to--Destination--------------"

Copy-Item  "$adminfilepath"  -Destination "Conf\variables\"
Copy-Item  "$haproxyfilepath"  -Destination "Conf\variables\"
Copy-Item  "$waffilepath"  -Destination "Conf\variables\"
Copy-Item  "$fwfilepath"  -Destination "Conf\variables\"

Copy-Item  "$adminfilepath"  -Destination "Conf\variables\"
Copy-Item  "$haproxyfilepath"  -Destination "Conf\variables\"
Copy-Item  "$waffilepath"  -Destination "Conf\variables\"
Copy-Item  "$fwfilepath"  -Destination "Conf\variables\"

cd Conf\variables
Rename-Item "admin" -NewName "private_key_admin"
Rename-Item "haproxy" -NewName "private_key_haproxy"
Rename-Item "waf" -NewName "private_key_waf"
Rename-Item "fw" -NewName "private_key_fw"


cd  $currentWorkdirectory

Write-Host "--------------------------- End---of---SSH---SCRIPT--------------"