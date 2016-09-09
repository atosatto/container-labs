Docker Swarm Provisioning with Ansible and Vagrant
==================================================

Docker "Swarm Mode" cluster provisioning with Ansible and Vagrant.

Prerequisites
-------------

- [Ansible](https://www.ansible.com/)
- A DigitalOcean account and a valid API AuthToken (see https://cloud.digitalocean.com/settings/api/tokens)

Requirements
------------

- [vagrant-digitalocean](https://github.com/devopsgroup-io/vagrant-digitalocean): Official DigitalOcean Vagrant Plugin

  ```bash
  vagrant plugin install vagrant-digitalocean
  ```

Usage
-----

Export your DigitalOcean APIs access token

```bash
export DIGITAL_OCEAN_TOKEN='mytoken'
```

Download and install the [atosatto.docker-swarm](https://galaxy.ansible.com/atosatto/docker-swarm/)
role from Ansible Galaxy.

```bash
ansible-galaxy install -r requirements.yml
```

Run `vagrant` to create the swarm cluster

```bash
vagrant up
```

To destroy the swarm cluster run

```bash
vagrant destroy
```
