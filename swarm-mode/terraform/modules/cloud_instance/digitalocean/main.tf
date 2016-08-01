# Specify the provider and access details
provider "digitalocean" {
  token = "${var.api_token}"
}

# Create an SSH key
resource "digitalocean_ssh_key" "terraform_ssh_key" {
  name       = "Terraform - Docker Module"
  public_key = "${file(var.ssh_pubkey)}"
}

# Provision the cloud instances
resource "digitalocean_droplet" "cloud_instance" {
  count = "${var.num_instances}"

  image    = "${var.droplet_image}"
  region   = "${var.droplet_region}"
  name     = "${format("${var.name_format}", count.index + 1)}"
  size     = "${var.droplet_size}"
  ssh_keys = ["${digitalocean_ssh_key.terraform_ssh_key.id}"]
}
