Swarm Mode Cluster Provisioning with Terraform
==============================================

Docker "Swarm Mode" cluster provisioning with Terraform.

Prerequisites
-------------

- [Terraform](https://www.terraform.io/downloads.html)
- A DigitalOcean account and a valid API AuthToken (see https://cloud.digitalocean.com/settings/api/tokens)

Usage
-----

Export your DigitalOcean APIs access token

```
export DIGITAL_OCEAN_TOKEN='mytoken'
```

Copy and edit the `terraform-swarm.tfvars.example` file to reflect your setup

```bash
$ cp terraform-swarm.tfvars.example terraform-swarm.tfvars

$ vi terraform-swarm.tfvars
```

Then apply the terraform configuration

```bash
# load the cloud-instance module
$ terraform get

# apply the terraform configuration
$ TF_VAR_do_token=$DIGITAL_OCEAN_TOKEN terraform apply -var-file=terraform-swarm.tfvars
```
