
data "template_file" "cloudconfig" {
  template = "${file("${path.module}/${var.cloudconfig_file}")}"

}


data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content      = "${data.template_file.cloudconfig.rendered}"
  }
}
