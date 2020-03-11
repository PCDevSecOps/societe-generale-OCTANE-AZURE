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


## Product subscriptions CRUD

### Create

In order to create a subscription in a given `CIAP Hosting` instance, make sure to follow the described instructions below:

- Step 1: Manually Peer new App-Vnet with `CIAP Hosting` stack through the **hosting-Vnet**
- Step 2: SSH to admin VM. Admin SSH Keys are in the the *Azure Keyvault* under the Admin-RG ([sample command here](#access-keys))
- Step 3: Create from Admin VM  under  <kbd>ansible\vars\</kbd> folder the file `granted_domains_${stack}.yml`  (if it does not exist) with the following content:

```yaml
granted_domains:
- backend_fqdn: ${private_ip_app_vm} or Private DNS Zone alias
  backend_port: 443
  backend_protocol: https
  domain: ${domain_name_label}
  email: toto@toto.com
  havp_listening_ip: 127.0.0.1
  havp_listening_port: 25997
  havp_protocol: https
  http: false
  http2_listening_ip: 127.0.0.1
  http2_listening_port: 15997
  http_listening_ip: 0.0.0.0
  http_listening_port: 10997
  https_listening_ip: 0.0.0.0
  https_listening_port: 443
  id: 997
  mod_security: 'on'
  preserve_host: true
  proxy_timeout: 5
```

where:

- **private_ip_app_vm** is the ip of private app VM;
- **domain_name_label** is the domain that has to be published for the Application.

Each domain is a new item in the _granted_domains_ list.

- Step 4: Run ansible-playbook command to publish new domains

```bash
cd  ~/hostingconfiguration
source  ./virtualenv/bin/activate
./virtualenv/bin/ansible-playbook -i azure_rm.py  main.yml -e stack=${stack} --tags grantdomain
deactivate
```

- Step 5: If you are subscribing using a private DNS Zone, make sure you have the role `Private DNS Zone Contributor`, then Link the `CIAP Hosting Zone` to the **Hosting-Vnet**:

```shell
az network private-dns link vnet create -g ${app-resource-group} -n ${app-link-name} -z ${dns-zone-name} -v ${hosting-vnet} -e false
```

or see [Link-Private-DNS-Zone](https://docs.microsoft.com/fr-fr/azure/dns/private-dns-getstarted-portal#link-the-virtual-network)

- Step 6: Create a snapshot of admin-vm
Finally [update the referential](#subscriptions-referential) in this page.

### Read

To list subscriptions in a given instance refers to [the referential](#subscriptions-referential) in this page. You can also check the <kbd>granted_domains_${stack}.yml</kbd> file on administration server (see [above](#create_2)).

### Update

In case of an update, make sure to follow the described instructions below:

- Step 1: SSH to admin VM. Admin SSH Keys are in the the Azure Keyvault under the Admin-RG ([sample command here](#access-keys))
- Step 2: Update the file `granted_domains_{stack}.yml` under  `ansible\vars\` folder.  Make sure to use different https ports:

```yaml
granted_domains:
- backend_fqdn: ${private_ip_app_vm}
  backend_port: 443
  backend_protocol: https
  domain: ${domain_name_label}
  email: toto@toto.com
  havp_listening_ip: 127.0.0.1
  havp_listening_port: 25997
  havp_protocol: https
  http: false
  http2_listening_ip: 127.0.0.1
  http2_listening_port: 15997
  http_listening_ip: 0.0.0.0
  http_listening_port: 10997
  https_listening_ip: 0.0.0.0
  https_listening_port: 443
  id: 997
  mod_security: 'on'
  preserve_host: true
  proxy_timeout: 5
```

- Step 3: Run ansible-playbook command to publish new domains

```bash
cd  ~/hostingconfiguration
source  ./virtualenv/bin/activate
./virtualenv/bin/ansible-playbook -i azure_rm.py  main.yml -e stack={stack}  --tags grantdomain
deactivate
```
- Step 4: Create a snapshot of admin-vm

### Delete

To unsubscribe from the product `CIAP Hosting`, please follow carefully the steps listed below:

- Step 1: Manually Delete the existing Peering between the *App* and `CIAP Hosting` stack
- Step 2: SSH to admin VM. Admin SSH Keys are in the the Azure Keyvault under the Admin-RG ([sample command here](#access-keys))
- Step 3: Edit the file `revoked_domains_{stack}.yml `  ( if does not exit )  with following block content. It is possible to append multiple block of granted_domains for revoking several domains.

```yaml
revoked_domains:
- backend_fqdn: ${private_ip_app_vm}
  backend_port: 443
  backend_protocol: https
  domain: ${domain_name_label}
  email: toto@toto.com
  havp_listening_ip: 127.0.0.1
  havp_listening_port: 25997
  havp_protocol: https
  http: false
  http2_listening_ip: 127.0.0.1
  http2_listening_port: 15997
  http_listening_ip: 0.0.0.0
  http_listening_port: 10997
  https_listening_ip: 0.0.0.0
  https_listening_port: 443
  id: 997
  mod_security: 'on'
  preserve_host: true
  proxy_timeout: 5
```
- **private_ip_app_vm** is the ip of app VM.
- **domain_name_label** is the domain that has to be published for app.

- Step 4: Edit the file `granted_domains_{stack}.yml ` and remove the domain from the _granted_domains_ list.

```bash
cd  ~/hostingconfiguration
source  ./virtualenv/bin/activate
./virtualenv/bin/ansible-playbook -i azure_rm.py  main.yml -e stack={stack}  --tags revokedomain
deactivate
```

- Step 5: Run ansible-playbook command to delete domain(s)
- Step 6: Create a snapshot of admin-vm


## Run

All configuration changes are done from VM admin.

```
ssh vmadmin@ipvmadmin -i ~/privatekeysshvmadmin
```

##### ACCESS KEYS
The SSH Access Key can be downloaded through *Azure CLI*

```
 az keyvault secret download --vault-name ciaphostingkeyvault --name privatekeyhaproxy --file privatekeysshvmadmin
```
PS: You need to grand access through *Azure Keyvault* Access policies


### Patching

All VM instances are automatically built using the latest Image. However, you need to run **yum update** to check the Linux is up to date.

Others components (*Logs*, *Storage*...) are fully managed (built-in patch management) by *Azure*.
