variable "api_token" {
  description = "DigitalOcean APIs AuthToken."
}

variable "num_instances" {
  description = "Number of instances to provision."
  default     = 1
}

variable "name_format" {
  description = "Format of the instance name."
  default     = "cloud-%02d"
}

variable "droplet_image" {
  description = "Droplet image ID or Slug."
  default     = "centos-7-x64"
}

variable "droplet_size" {
  description = "Instance size."
  default     = "2gb"
}

variable "droplet_region" {
  description = "Region of the droplet."
  default     = "lon1"
}

variable "ssh_user" {
  description = "SSH connection username."
  default     = "root"
}

variable "ssh_pubkey" {
  description = "SSH public_key injected into the droplets."
}
