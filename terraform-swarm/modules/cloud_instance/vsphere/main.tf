# Specify the provider and access details
provider "vsphere" {
  user           = "${var.vsphere_user}"
  password       = "${var.vsphere_password}"
  vsphere_server = "${var.vsphere_server}"
}

# Create a folder
resource "vsphere_folder" "docker_nodes" {
  path = "docker-terraform"
}

# Provision the Docker instances
resource "vsphere_virtual_machine" "docker_nodes" {
  count = "${var.docker_nodes}"

  name   = "${format("dck-lab%02d", count.index + 1)}"
  folder = "${vsphere_folder.docker_nodes.path}"
  vcpu   = 2
  memory = 2048

  network_interface {
    label              = "VM Network"
    ipv4_address       = "${lookup(var.instance_ips, count.index)}"
    ipv4_prefix_length = "24"
  }

  disk {
    template = "centos-7"
  }

  connection {
    user     = "${var.ssh_user}"
    password = "${var.ssh_password}"
  }

  # Install Docker on all the instances
  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://test.docker.com/ | sh",
    ]
  }
}
