output "ipv4_addresses" {
  value = "${join(",", digitalocean_droplet.cloud_instance.*.ipv4_address)}"
}
