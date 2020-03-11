# Azure-IAP-CIAP-Hosting Socle

Socle is semi-automated, therefore, developer needs to manually deploy, for each `{region}` (*Azure Location*) following assets in a socle subscription: 

* Automated

    * Resource Group + 1 Azure Storage Account for TFStates with a Blob container
    * Resource Group + 1 Azure Storage Account for Referential with a Blob container
    * Resource Group for Log Analytics + 1 Azure Log Analytics

* Non automated (manual)

    * Advanced Settings for Azure Log Analytics


__Warning__ : The credentials should be provided in an encrypted way (SG-Credentials) . You can see the SG credentials libraries for more information.


On the deployment server, in the folder where you cloned the cIAP Hosting repository, use the following commands with appropriate parameters as described in helper below:


##### Automated

Copy / paste `../Conf/config.socle.template.json` to `../Conf/config.socle.json`.

Please configure `../Conf/config.socle.json`, section `"Azure", "Global, "TerraformBackend", "Terraform", "Proxy"`

```
{
    "Global": {
        "Environment": "{dev,hml,prd}",
        "Product": "iaphost",
        "Domain": "iap",
        "Version": "vX"
    },
    "Azure": {
        "Subscription": "Subscription name",
        "SubscriptionId": "socle subscription",
        "ClientId": "client id to connect to socle",
        "TenantId": "tenant id to connec to socle",
        "SecretKey": "encrypted client secret to connect to socle",
        "Region": "northeurope"
    },
    "TerraformBackend": {
        "TFStateStorageAccountSecretKey": "",
        "TFStateStorageAccountName": "",
        "TFStateStorageAccountContainerName": "tfstates"
    }
}
```

Please run 
```
 >   ./New-SocleSgCiapHosting.ps1 ENVIRONMNT_HOSTING HOSTING_STACK
```
PS: DO NOT HESITATE TO RUN AGAIN IF IT FAILS 

This will create all socle instances that will be used by our product.
In Production environments, it's recommended to NOT execute this command and get the access key from the Portal.

##### Manual deployment

##### Azure Log Analytics

The Azure Log Analytics was automatically created with those parameters:

* Name : `log-analytics-ciap-bro-socle-{region}`
* Pricing tier : Per GB (2018)
* RetentionInDays : 365 (in Usage and estimated costs / data volume management)

Update with: 

* Advanced Settings
    *  Data
        * Syslog
            * auth, authpriv, cron, daemon, kern, syslog, user
            * *Tip : do not forget to "Save"*
    * Custom Logs
        * Example file content ([sample file here](#sample-file))
        * Record delimiter : new line
        * Path Type : Linux
        * Path Names : 
            - /var/log/squid/access.log
            - /var/log/access.log
            - /usr/local/nginx/*
            - /var/log/nginx/*
            - /usr/local/nginx/logs/error.log
            - /var/log/nginx/error.log
        * Custom Log Name : Squid_blacklist(_CL)
        * *Tip : do not forget to "Save"*
        * *Tip : do not forget to click on "Apply below configuration to my linux machines"*


####### Sample file 

__Warning__ : You can find this sample file under the folder Conf/Samples to upload it when you configure your Log Analytics Workspace.

```
1556869495.026     30 ::1 TCP_MISS/200 12939 GET http://www.google.fr/ - HIER_DIRECT/74.125.193.94 text/html
1556869498.764     25 ::1 TCP_MISS/200 12956 GET http://www.google.fr/ - HIER_DIRECT/74.125.193.94 text/html
1556869499.256     28 ::1 TCP_MISS/200 12932 GET http://www.google.fr/ - HIER_DIRECT/74.125.193.94 text/html
1556869499.541     26 ::1 TCP_MISS/200 12950 GET http://www.google.fr/ - HIER_DIRECT/74.125.193.94 text/html
1556869499.796     25 ::1 TCP_MISS/200 12953 GET http://www.google.fr/ - HIER_DIRECT/74.125.193.94 text/html
1556869500.002     29 ::1 TCP_MISS/200 12992 GET http://www.google.fr/ - HIER_DIRECT/74.125.193.94 text/html
1556869500.267     26 ::1 TCP_MISS/200 12946 GET http://www.google.fr/ - HIER_DIRECT/74.125.193.94 text/html
```
##### Post Configuration
Now, Storage Account for TFstates has been created, put the Storage secret key on your COE Credential file (variable `Global.TerraformBackend.TFStateStorageAccountSecretKey` in `../Conf/config.Instance.json`).


---

# cIAP HOSTING Socle Tree
```
Azure cIAP HOSTING SOCLE

|
├─ Conf
│  ├─ config.instance.template.json
│  ├─ config.socle.template.json
│  ├─ libs
│  │  └─ retryblock.psm1
│  ├─ privatekeys
│  ├─ samples
│  │  ├─ error.sample.log
│  │  └─ sample.log
│  ├─ Socle
│  │  ├─ backend.tfvars
│  │  ├─ ImportConfigFileSocle.ps1
│  │  └─ Set-LogsAzureLOADFile.ps1
│  └─ variables
│     └─ backend.tfvars
├─ Initialize
│  ├─ ImportConfigFileInstance.ps1
│  ├─ Set-AzureLOADFile.ps1
│  └─ Set-rsaKeys.ps1
├─ New-SocleCiapHosting.ps1
├─ PreSocle
│  └─ variables
├─ Remove-SocleIAPHosting.ps1
├─ Socle
│  ├─ main.tf
│  ├─ outputs.tf
│  ├─ README.md
│  └─ variables.tf
└─ Subscriptions
   └─ New-Domain.ps1

```
