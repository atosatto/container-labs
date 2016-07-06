#!/bin/bash

SIZE=2gb
REGION=ams2
IMAGE=ubuntu-15-10-x64

PREFIX="do"

NUM_MANAGERS=3
NUM_WORKERS=3

# create the swarm leader
docker-machine create \
  --driver=digitalocean \
  --digitalocean-access-token=${DIGITAL_OCEAN_TOKEN} \
  --digitalocean-size=${SIZE} \
  --digitalocean-region=${REGION} \
  --digitalocean-private-networking=true \
  --digitalocean-image=${IMAGE} \
  --engine-install-url=https://test.docker.com \
  ${PREFIX}-sw01
docker-machine ssh ${PREFIX}-sw01 docker swarm init

# create the additional swarm managers
for (( i=2; i <= ${NUM_MANAGERS}; i++ ))
do
  hostname=${PREFIX}-sw$(printf %02d $i)
  docker-machine create \
    --driver=digitalocean \
    --digitalocean-access-token=${DIGITAL_OCEAN_TOKEN} \
    --digitalocean-size=${SIZE} \
    --digitalocean-region=${REGION} \
    --digitalocean-private-networking=true \
    --digitalocean-image=${IMAGE} \
    --engine-install-url=https://test.docker.com \
    ${hostname}
  docker-machine ssh ${hostname} docker swarm join --manager $(docker-machine ip ${PREFIX}-sw01):2377
done

# create the swarm workers
for (( i=$((NUM_MANAGERS + 1)); i <= $((NUM_WORKERS + NUM_MANAGERS)); i++ ))
do
  hostname=${PREFIX}-sw$(printf %02d $i)
  docker-machine create \
    --driver=digitalocean \
    --digitalocean-access-token=${DIGITAL_OCEAN_TOKEN} \
    --digitalocean-size=${SIZE} \
    --digitalocean-region=${REGION} \
    --digitalocean-private-networking=true \
    --digitalocean-image=${IMAGE} \
    --engine-install-url=https://test.docker.com \
    ${hostname}
  docker-machine ssh ${hostname} docker swarm join $(docker-machine ip ${PREFIX}-sw01):2377
done

# list nodes
docker-machine ssh ${PREFIX}-sw01 docker node ls
