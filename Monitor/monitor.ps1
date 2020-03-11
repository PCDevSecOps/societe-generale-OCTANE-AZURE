<#
  .SYNOPSIS
   Monitor Web Apps.
  .DESCRIPTION
   This script invokes the monitoring URL to check if Alive
.OUTPUTS
.NOTES
    Author: Marouan BELGHITH
    Date: 19 12 2019
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $True, Position = 1)]
    [string]$CIAP_Region,
    [Parameter(Mandatory = $True, Position = 2)]
    [string]$ENVIRONMNT_HOSTING,
    [Parameter(Mandatory = $True, Position = 3)]
    [string]$CIAP_URL
)

# Use proxy
$Browser = New-Object System.Net.WebClient
$Browser.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials

add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

 $website = Invoke-WebRequest -Uri $CIAP_URL
 $time = (Measure-Command -Expression { $website =  Invoke-WebRequest -Uri $CIAP_URL -UseBasicParsing }).Milliseconds
 if (($website.StatusCode -ne "200") -or (-not $website.RawContent.Contains("(____\___))")))
 {
   Write-Host "Status Code = $($website.StatusCode)" 
   Write-Host "Content : $($website.RawContent)"

    $params = @{
        SmtpServer                 = "smtp-server-url"
        From                       = "toto@toto.com"
        To                         = "toto@toto.com"
        Subject                    = "MONITORING ALERT - CIAP PRODUCT HOSTING AZURE V3 $ENVIRONMNT_HOSTING"
        Body                       = "MONITORING ALERT - CIAP PRODUCT HOSTING AZURE V3 $ENVIRONMNT_HOSTING - $CIAP_Region - URL $CIAP_URL"
        DeliveryNotificationOption = ("OnSuccess", "OnFailure")
    }
    Send-MailMessage -BodyAsHtml @params

    exit 1
 }

