# Provisioning the cloud instances
module "cloud_instance" {
  source        = "modules/cloud_instance/digitalocean"
  name_format   = "do-swarm%02d"
  num_instances = "${var.swarm_nodes}"
  api_token     = "${var.do_token}"
  ssh_user      = "${var.ssh_user}"
  ssh_pubkey    = "${var.ssh_pubkey}"
}

# Install the docker-engine
resource "null_resource" "docker_engine" {
  count = "${var.swarm_nodes}"

  connection {
    host = "${element(split(",", module.cloud_instance.ipv4_addresses), count.index)}"
    user = "${var.ssh_user}"
  }

  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://test.docker.com/ | sh",
      "systemctl enable docker",
      "systemctl start docker",
    ]
  }
}

# Init "swarm mode"
resource "null_resource" "swarm_init" {
  count = 1

  connection {
    host = "${element(split(",", module.cloud_instance.ipv4_addresses), 0)}"
    user = "${var.ssh_user}"
  }

  depends_on = ["null_resource.docker_engine"]

  provisioner "remote-exec" {
    inline = [
      "docker swarm init --listen-addr '0.0.0.0:${var.swarm_port}' --secret '${var.swarm_secret}'",
    ]
  }
}

# Join nodes
resource "null_resource" "swarm_join" {
  count = "${var.swarm_nodes - 1}"

  connection {
    host = "${element(split(",", module.cloud_instance.ipv4_addresses), count.index + 1)}"
    user = "${var.ssh_user}"
  }

  depends_on = ["null_resource.swarm_init"]

  triggers {
    //  master_ip = "${lookup(var.instance_ips, 0)}"
    master_ip = "${element(split(",", module.cloud_instance.ipv4_addresses), 0)}"
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
