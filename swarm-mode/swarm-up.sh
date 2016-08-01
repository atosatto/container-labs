#!/bin/bash

SIZE=2gb
REGION=ams2
IMAGE=ubuntu-16-04-x64

PREFIX="do"

NUM_MANAGERS=3
NUM_WORKERS=3

# Create a new Docker instance on digitalocean
do_instance () {
  docker-machine create \
    --driver=digitalocean \
    --digitalocean-access-token=${DIGITAL_OCEAN_TOKEN} \
    --digitalocean-size=${SIZE} \
    --digitalocean-region=${REGION} \
    --digitalocean-private-networking=true \
    --digitalocean-image=${IMAGE} \
    $1
}

# Init a docker swarm cluster on node $1
init_cluster () {
  docker-machine ssh $1 \
    docker swarm init \
      --listen-addr $(docker-machine ip $1) \
      --advertise-addr $(docker-machine ip $1)
}

# Join the node $1 with token $2 to the cluster created by $3
join_node () {
  docker-machine ssh $1 \
    docker swarm join \
      --token $2 \
      --listen-addr $(docker-machine ip $1) \
      --advertise-addr $(docker-machine ip $1) \
      "$(docker-machine ip $3):2377"
}

# Hostname of the swarm cluster leader
swarm_leader=""
worker_tk=""
manager_tk=""

# creating the cluster instances
for (( i=1; i <= $((NUM_WORKERS + NUM_MANAGERS)); i++ ))
do

  node=${PREFIX}-sw$(printf %02d $i)
  echo "======> Creating the docker node ${node}..."
  do_instance ${node}

  if [[ $i -eq 1 ]]; then
    echo "======> Initializing first swarm manager ..."
    init_cluster "${node}"
    swarm_leader=${node}
    worker_tk=$(docker-machine ssh ${node} docker swarm join-token -q worker)
    manager_tk=$(docker-machine ssh ${node} docker swarm join-token -q manager)
  elif [[ $i -lt $(( $NUM_WORKERS + 1 )) ]]; then
    echo "======> $node joining swarm as manager ..."
    join_node "${node}" "${manager_tk}" "${swarm_leader}"
  else
    echo "======> $node joining swarm as worker ..."
    join_node "${node}" "${worker_tk}" "${swarm_leader}"
  fi

done

# list nodes
docker-machine ssh ${swarm_leader} docker node ls
