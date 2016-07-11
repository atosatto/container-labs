variable "vsphere_user" {
  description = "User name to access to vCenter server."
  default = "root"
}

variable "vsphere_password" {
  description = "Password to access to vCenter server."
  default = "vmware"
}

variable "vsphere_server" {
  description = "Target vCenter server."
}

variable "ssh_user" {
  description = "SSH connection username."
  default = "rot"
}

variable "ssh_password" {
  description = "SSH connection password."
  default = "centos"
}

variable "swarm_nodes" {
  description = "The number of nodes in the Docker Swarm cluster."
  default = 3
}

variable "instance_ips" {
  default = {
    "0" = "10.11.12.100"
    "1" = "10.11.12.101"
    "2" = "10.11.12.102"
  }
}

variable "swarm_port" {
  description = "Docker Swarm API listening port."
  default = 2376
}

variable "swarm_secret" {
  description = "Secret required to add nodes to the swarm cluster."
  default = "swarmsecret"
}
