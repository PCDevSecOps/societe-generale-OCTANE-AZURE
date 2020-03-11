# cIAP HOSTING



## Presentation

---



Several functionalities are implemented :
* automated haproxy configuration (if chosen)


There are 2 roles:

* common : common tasks
* lb : shunt streams based on rules 


## Common role

---

Tasks implemented:

* Retrieve information about instances
* Load Balancers
  * add or remove ports for each configured domain
* Security Groups: 
  * grant or revoke ports for each configured domain
  * configure ports
  * configure healthcheck ports
* Configure specific repositories:
  * Centos
* Install softwares:
  * epel-release
  * vim
  * iptables
  * suricata
* Remove softwares:
  * firewalld
* Configure system
  * change bash behaviour
  * add motd
  * change vimrc behaviour
* Add healthcheck responder



## Load balancer role  

---

Tasks implemented:

* Create self-signed certificates (per domain, needed to start haproxy)
* Generate technical SSL certificates
* Install and configure softwares:
  * SELinux
  * rsyslog
* Customization of common softwares


# Usage
---

Please see userGuide for ansible ciap hosting configuration.


two usages are available :

* revokedomain: remove an existing domain from an HOSTING stack
* grantdomain: add a new domain to an HOSTING stack


Main Playbook used
---

```yaml
---
- name: Apply common configuration to "{{ stack }}"
  hosts: "stack_{{ stack }}"
  become: yes
  gather_facts: yes
  roles:
    - common

- name: cIAP "{{ stack }}" setup for "mid_lb"
  hosts: "stack_{{ stack }}:&mid"
  become: yes
  gather_facts: yes
  roles:
    - "mid_lb"
 
```

# Dependencies

---

Does not depend on any other roles, but the host need to have:

* the function tag
* the stage tag
* the stack name.

An `ansible.cfg` is present on the current directory with :

```ini

[defaults]
retry_files_enabled = false
inventory = azure_rm.py
remote_user = cloud-user
stdout_callback = debug
host_key_checking = false

```

---

# Ansible Tree

```
└─ansible
  ├─ ansible.cfg
  ├─ azure_rm.ini
  ├─ azure_rm.py
  ├─ certificates
  │  ├─ marouan-lucas.com.crt
  │  └─ marouan-lucas.com.key
  ├─ cli_api_hosting_azure.sh
  ├─ custom_rules
  │  └─ toto.com
  │     ├─ blacklist.conf
  │     ├─ custom.conf
  │     └─ whitelist.conf
  ├─ group_vars
  │  ├─ all.yml
  │  └─ smoketest.yml
  ├─ hosts
  ├─ main.yml
  ├─ READme.md
  ├─ roles
  │  ├─ common
  │  │  ├─ handlers
  │  │  │  └─ main.yml
  │  │  ├─ tasks
  │  │  │  ├─ grant
  │  │  │  │  ├─ azure_lb.yml
  │  │  │  │  ├─ azure_rg.yml
  │  │  │  │  ├─ azure_sg.yml
  │  │  │  │  └─ azure_vm.yml
  │  │  │  ├─ init
  │  │  │  │  └─ ssl.yml
  │  │  │  ├─ main.yml
  │  │  │  └─ revoke
  │  │  └─ templates
  │  ├─ low_fw
  │  │  ├─ handlers
  │  │  │  └─ main.yml
  │  │  ├─ tasks
  │  │  │  ├─ grant
  │  │  │  │  ├─ iptables.yml
  │  │  │  │  ├─ nginx.yml
  │  │  │  │  └─ nginx_directories.yml
  │  │  │  ├─ main.yml
  │  │  │  └─ revoke
  │  │  │     └─ nginx.yml
  │  │  └─ templates
  │  │     └─ grant
  │  │        ├─ iptables.j2
  │  │        └─ nginx_conf.j2
  │  └─ mid_waf
  │     ├─ files
  │     │  ├─ rules_blacklist_fqdn.conf
  │     │  ├─ rules_custom_fqdn.conf
  │     │  ├─ rules_whitelist_fqdn.conf
  │     │  └─ unicode.mapping
  │     ├─ handlers
  │     │  └─ main.yml
  │     ├─ tasks
  │     │  ├─ grant
  │     │  │  ├─ iptables.yml
  │     │  │  ├─ modsecurity.yml
  │     │  │  ├─ nginx.yml
  │     │  │  ├─ ssl.yml
  │     │  │  ├─ suricata-hosting.yml
  │     │  │  └─ suricata.yml
  │     │  ├─ init
  │     │  │  └─ suricata.yml
  │     │  ├─ main.yml
  │     │  └─ revoke
  │     │     ├─ nginx.yml
  │     │     └─ suricata.yml
  │     ├─ templates
  │     │  ├─ crs-setup.conf.j2
  │     │  ├─ demo.conf.j2
  │     │  ├─ hosting.rules.j2
  │     │  ├─ iptables.j2
  │     │  ├─ iptablesv2.j2
  │     │  ├─ modsec.conf.j2
  │     │  ├─ nginx_conf.j2
  │     │  ├─ suricata.service.j2
  │     │  └─ suricata.yaml.j2
  │     └─ vars
  │        ├─ domains_with_blacklisted_urls.yml
  │        └─ domains_with_whitelisted_urls.yml
  └─ vars
     ├─ granted_domains_hostingdev.yml
     └─ revoked_domains_hostingtest.yml


```

To generate certbot certificate:

certbot --cert-name ocs.hosting.com -d ocs.hosting.com --manual --preferred-challenges dns certonly

