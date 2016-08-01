# Specify the provider and access details
provider "vsphere" {
  user           = "${var.vsphere_user}"
  password       = "${var.vsphere_password}"
  vsphere_server = "${var.vsphere_server}"
}

# Provision the Docker instances
resource "vsphere_virtual_machine" "cloud_instance" {
  count = "${var.num_instances}"

  name   = "${format("${var.name_format}", count.index + 1)}"
  vcpu   = "${var.vm_vcpu}"
  memory = "${var.vm_memory}"

  network_interface {
    label = "${var.vm_net}"
  }

  disk {
    template = "${var.vm_template}"
  }
}
