variable "do_token" {
  description = "DigitalOcean APIs AuthToken."
}

variable "ssh_user" {
  description = "SSH connection username."
  default     = "root"
}

variable "ssh_pubkey" {
  description = "SSH public_key injected into the DigitalOcean droplets."
}

variable "swarm_nodes" {
  description = "The number of nodes in the Docker Swarm cluster."
  default     = 3
}

/*
variable "instance_ips" {
  default = {
    "0" = "10.11.12.100"
    "1" = "10.11.12.101"
    "2" = "10.11.12.102"
  }
}
*/

variable "swarm_port" {
  description = "Docker Swarm API listening port."
  default     = 2376
}

variable "swarm_secret" {
  description = "Secret required to add nodes to the swarm cluster."
  default     = "swarmsecret"
}
