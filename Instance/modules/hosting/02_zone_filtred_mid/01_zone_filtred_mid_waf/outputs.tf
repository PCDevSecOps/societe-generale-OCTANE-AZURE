output "hostname" {
  value = "${var.hostname}"
}


output "vm_fqdn" {
  value = "${azurerm_public_ip.lbpip.fqdn}"
}



output "vms_ssh_access" {
  value = "${formatlist("SSH_URL=%v@%v -p %v", var.admin_username, azurerm_lb.lb.private_ip_address, azurerm_lb_nat_rule.tcp.*.frontend_port)}"
}





output "vmmids_ip_address" {
  value = "${join(",", azurerm_network_interface.nic.*.private_ip_address)}"
}



output "clb_up_mid_dns_name" {
  value =  "${azurerm_lb.lb.private_ip_address}"
}



output "vmmids_id" {

  value = "${join(",",azurerm_virtual_machine.vm.*.id)}"

}




