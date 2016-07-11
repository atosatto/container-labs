# Specify the provider and access details
provider "vsphere" {
  user           = "${var.vsphere_user}"
  password       = "${var.vsphere_password}"
  vsphere_server = "${var.vsphere_server}"
}

# Create a folder
resource "vsphere_folder" "swarm_lab" {
  path = "dck-swarmlab"
}

# Provision the Docker instances
resource "vsphere_virtual_machine" "swarm_nodes" {
  count = "${var.swarm_nodes}"

  name = "${format("dck-lab%02d", count.index + 1)}"
  folder = "${vsphere_folder.swarm_lab.path}"
  vcpu   = 2
  memory = 2048

  network_interface {
    label = "VM Network"
    ipv4_address = "${lookup(var.instance_ips, count.index)}"
    ipv4_prefix_length = "24"
  }

  disk {
    template = "centos-7"
  }

  connection {
    user = "${var.ssh_user}"
    password = "${var.ssh_password}"
  }

  # Install Docker on all the instances
  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://test.docker.com/ | sh",
    ]
  }
}

# Init Swarm Cluster
resource "null_resource" "swarm_init" {
  connection {
    user        = "${var.ssh_user}"
    password    = "${var.ssh_password}"
    host        = "dck-lab01"
  }

  provisioner "remote-exec" {
    inline = [
      "docker swarm init --listen-addr '0.0.0.0:${var.swarm_port}' --secret '${var.swarm_secret}'",
    ]
  }
}

# Join Swarm Nodes
resource "null_resource" "swarm_nodes" {
  count = "${var.swarm_nodes - 1}"

  connection {
    user        = "${var.ssh_user}"
    password    = "${var.ssh_password}"
    host        = "${format("dck-lab%02d", count.index + 1)}"
  }

  depends_on = ["null_resource.swarm_init"]

  triggers {
    master_ip = "${lookup(var.instance_ips, 0)}"
  }

  provisioner "remote-exec" {
    inline = [
      "docker swarm join --secret '${var.swarm_secret}' ${self.triggers.master_ip}:${var.swarm_port}",
    ]
  }
}

# Promote Swarm Masters
/*resource "null_resource" "swarm_promote" {
  count = "${var.swarm_nodes - 1}"

  connection {
    user        = "${var.ssh_user}"
    password    = "${var.ssh_password}"
    host        = "dck-lab01"
  }

  depends_on = ["null_resource.swarm_nodes"]

  triggers {
    master_ip = "${element(split(",", module.provider_cluster.node_ipv4_addrs), 0)}"
  }

  provisioner "remote-exec" {
    inline = [
      "docker node promote '${var.swarm_secret}' ${self.triggers.master_ip}:${var.swarm_port}",
    ]
  }
}*/
