Docker Swarm Provisioning with Ansible
======================================

Docker "Swarm Mode" cluster provisioning with Ansible.

Prerequisites
-------------

- [Ansible](https://www.ansible.com/)
- A DigitalOcean account and a valid API AuthToken (see https://cloud.digitalocean.com/settings/api/tokens)

Requirements
------------

- [Dopy](https://github.com/Wiredcraft/dopy): DigitalOcean APIs Python wrapper

  ```bash
  pip install dopy
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

Run the `swarm-up` playbook

```bash
ansible-playbook -i local -e do_token=$DIGITAL_OCEAN_TOKEN swarm-up.yml
```
