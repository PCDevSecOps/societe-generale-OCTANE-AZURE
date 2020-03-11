
data "template_file" "cloudconfig" {
  template = "${file("${path.module}/scripts/configuration_admin.sh")}"

  vars = {

    access_key1_storage_account_fileshare = "${var.access_key1_storage_account_fileshare}"

    blob_container_name                   = "${var.storage_account_blob_name}"
    hosting_configuration_zip_file         = "${var.hosting_configuration_zip_file}"
    blob_endpoint                         = "${var.hosting_configuration_blob_endpoint}"
    admin_password_haproxy                = "${var.admin_password_haproxy}"
    admin_username_haproxy                = "${var.admin_username_haproxy}"
    ssh_port_haproxy                       = "${var.ssh_port_haproxy}"
    blob_endpoint                          = "${var.hosting_configuration_blob_endpoint}"
    private_key_haproxy                    = "${var.private_key_haproxy}"
    vm_ip_addresses_haproxy                = "${var.vm_ip_addresses_haproxy}"
    stack                                  =  "${var.stack}"

    subscription_id                         = "${var.subscription_id}"
    client_id                               = "${var.client_id}"
    client_secret                           = "${var.client_secret}"
    tenant_id                               = "${var.tenant_id}"
    resource_group                          = "${var.resource_group}"
    randominstance                            = "${var.randominstance}"
    clb_up_mid_dns_name                     = "${var.clb_up_mid_dns_name}"
    clb_mid_low_dns_name                    = "${var.clb_mid_low_dns_name}"
  }
}



data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content = "${data.template_file.cloudconfig.rendered}"
  }
}