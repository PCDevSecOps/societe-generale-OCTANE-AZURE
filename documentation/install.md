# AZURE cIAP Hosting 

## Presentation

---

This documentation will lead you on a way to install an IAP HOSTING stack.

We presuppose the reader has minimal knowledge on:

* Azure technologies
* Powershell
* Ansible

First of all you will need to have a proper Azure environment and sufficient authorizations to perform all actions.

__All accounts, users, ports or other references are randomly created and are not related to existing ones. :-)__

## Prerequisite

To setup the environment for `CIAP HOSTING`, the sections below will describe the steps to be followed:

#### Libraries

Make sure to integrate the following libraries:

- **OpenSSL** : Download OpenSSL and install it on your environment
- **SSH-KEYGEN**: Download SSH-Keygen and install it on your environment
- **Terraform**: Download terraform binary and add it in your <kbd>$path</kbd>


#### Servers
To deploy `CIAP HOSTING`, you need to have access to a **Windows Machine** .

#### Repository

Code source could be cloned from this repository.

#### Configuration files

Configuration files are placed in 'conf' directory.

The file <kbd>Conf/config.socle.json </kbd> must be edited to match the following structure:

```json
{
    "Global": {
        "Environment": "{dev,hml,prd}",
        "Product": "hosting",
        "Domain": "iap",
        "Version": "vX"
    },
    "Azure": {
        "Subscription": "xxxx-xxxx-xxxx-xxxx",
        "SubscriptionId": "xxxxxxxxxxxxxxxx",
        "ClientId": "client id to connect to socle subscription",
        "TenantId": "tenant id to connect to socle subscription",
        "SecretKey": "client secret to connect to socle subscription",
        "Region": "northeurope"
    },
    "TerraformBackend": {
        "TFStateStorageAccountSecretKey": "",
        "TFStateStorageAccountName": "",
        "TFStateStorageAccountContainerName": "tfstates"
    }
}
```

The file <kbd>Conf/config.instance.{dev,hml,prd}.json</kbd> must be edited to match the following structure:

```json
{
    "Global": {
        "Environment": "{dev,hml,prd}",
        "Product": "hosting",
        "Domain": "iap",
        "Version": "vX"
    },
    "Azure": {
        "Subscription": "xxxx-xxxx-xxxx-xxxx",
        "SubscriptionId": "xxxxxxxxxxxxxxxx",
        "ClientId": "client id to connect to instance subscription",
        "TenantId": "tenant id to connect to instance subscription",
        "SecretKey": "client secret to connect to instance subscription",
        "Region": "northeurope"
    },
    "Instance": {
        "Workspace": "workspace name"
    },
    "TerraformBackend": {
        "TFStateStorageAccountSecretKey": "",
        "TFStateStorageAccountName": "",
        "TFStateStorageAccountContainerName": "tfstates"
    }
}
```

#### Permissions and credentials

To manage the `CIAP Hosting`, you need to be at least a contributor on an Azure Subscription.

## Product socle CRUD

### Create

In order to create `CIAP HOSTING` socle, make sure to follow the described instructions below:

- Step 1: Update the file <kbd>Conf/config.socle.json</kbd> with the necessary information [configuration-files](#configuration-files)
- Step 2: Please run:

```bash
> ./New-SocleCiapHosting.ps1 ENVIRONMENT STACK
```

** ENVIRONMENT : ** dev, hml, prod

** STACK : ** The Stack you are deploying


- Step 3: Once the *Storage Account* for **TFstates** has been created, update the variable `Global.TerraformBackend.TFStateStorageAccountSecretKey` in <kbd>Conf/config.instance.{dev,hml,prd}.json</kbd> and store the Storage secret key on **SG-COE-Credentials** .

- Step 4: Configure Advanced Settings for *Azure Log Analytics*

The *Azure Log Analytics* was automatically created with those parameters:

* Name : `log-analytics-ciap-hosting-socle-{region}`
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
            - /var/log/*
            - /usr/local/nginx/*.log
            - /var/log/nginx/*.log
            - /usr/local/nginx/logs/*.log
            - /var/log/nginx/*.log
            - /var/log/suricata/{published_domain}/*.log
        * Custom Log Name : Applicatif(_CL)
        * *Tip : do not forget to "Save"*
        * *Tip : do not forget to click on "Apply below configuration to my linux machines"*

- Step 5: Update Referential. [referential-socle](#referential-socle)




##### Sample file

_You can find this sample file under the folder <kbd>Conf/Samples</kbd> to upload it when you configure your *Log Analytics Workspace*._

```
1556869495.026     30 ::1 TCP_MISS/200 12939 GET http://www.google.fr/ - HIER_DIRECT/74.125.193.94 text/html
1556869498.764     25 ::1 TCP_MISS/200 12956 GET http://www.google.fr/ - HIER_DIRECT/74.125.193.94 text/html
1556869499.256     28 ::1 TCP_MISS/200 12932 GET http://www.google.fr/ - HIER_DIRECT/74.125.193.94 text/html
1556869499.541     26 ::1 TCP_MISS/200 12950 GET http://www.google.fr/ - HIER_DIRECT/74.125.193.94 text/html
1556869499.796     25 ::1 TCP_MISS/200 12953 GET http://www.google.fr/ - HIER_DIRECT/74.125.193.94 text/html
1556869500.002     29 ::1 TCP_MISS/200 12992 GET http://www.google.fr/ - HIER_DIRECT/74.125.193.94 text/html
1556869500.267     26 ::1 TCP_MISS/200 12946 GET http://www.google.fr/ - HIER_DIRECT/74.125.193.94 text/html
```


### Read

Once the socle created, you can review its details in the referential listed in the section below [referential-socle](#referential-socle)

- Step 1: Login to *Azure Portal*
- Step 2: Access Resource Group 'log-analytics-ciap-host-socle-{cio}-{region}'

### Update

The Socle does not need nor support update operations.

### Delete

To delete the resources created, please follow carefully the steps listed below:

- Step 1: Please run

```bash
> ./Remove-SocleSgIAPHosting.ps1 ENVIRONMENT STACK
```

** ENVIRONMENT : ** dev, hml, prod

** STACK : ** The Stack you are deleting


## Product instance CRUD

### Create

> Each instance must have a unique name which will be designed as _STACK_.

In order to instantiate a CIAP Hosting instance named _STACK_, make sure to follow the described instructions below:

- Step 1: Check the configuration file <kbd>Conf/config.instance.{dev,hml,prd}.json</kbd> if you haven't done it in the (see [configuration-files](#configuration-files))
- Step 2: Check/Update the file <kbd>Conf/variables/access.tfvars</kbd> with the Storage secret key that has been generated after deployment of socle.
- Step 3: Check/Update the file <kbd>Conf\variables\logs.tfvars</kbd> with the azure_logs_loganalytics_workspaceid and the azure_logs_loganalytics_workspacekey that has been generated after deployment of socle.
- Step 4: Please run  `./Initialize-SgAzureCIAPHosting.ps1 ENVIRONMNT` where _ENVIROMENT_ is one of dev, hml or prd.
- Step 5: Please run  `./New-AzureCIAPHosting.ps1 ENVIRONMNT STACK`
- Step 6: [Update referential](#instances-referential) in this page and in the [user guide](userguide/#instances)

### Read

Once the instance created, we can access the instance following the steps below:

- Step 1: Download the Admin SSH Keys from the Azure Keyvault ([sample command here](#access-keys))
- Step 2: Connect through SSH to Admin VM


### Update

You can not update an instance for the moment. You have to delete and re-create it.

### Delete

To delete the instance created, please follow carefully the steps listed below:

- Run  Remove-AzureCIAPHosting.ps1 script with environment and stack name as parameters:

```
> Remove-AzureCIAPHosting.ps1 ENVIRONMNT STACK
```
