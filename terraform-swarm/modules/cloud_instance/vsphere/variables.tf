variable "vsphere_user" {
  description = "User name to access to vCenter server."
  default     = "root"
}

variable "vsphere_password" {
  description = "Password to access to vCenter server."
  default     = "vmware"
}

variable "vsphere_server" {
  description = "Target vCenter server."
}

variable "docker_nodes" {
  description = "The number of nodes to provision."
  default     = 3
}

variable "ssh_user" {
  description = "SSH connection username."
  default     = "rot"
}

variable "ssh_password" {
  description = "SSH connection password."
  default     = "centos"
}
