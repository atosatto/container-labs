#!/bin/bash

SIZE=2gb
REGION=ams2
IMAGE=ubuntu-15-10-x64

PREFIX="do"

NUM_MANAGERS=3
NUM_WORKERS=3

SWARM_SECRET="doswarmlab"

# Create a new Docker instance on digitalocean
do_instance () {
  docker-machine create \
    --driver=digitalocean \
    --digitalocean-access-token=${DIGITAL_OCEAN_TOKEN} \
    --digitalocean-size=${SIZE} \
    --digitalocean-region=${REGION} \
    --digitalocean-private-networking=true \
    --digitalocean-image=${IMAGE} \
    --engine-install-url=https://test.docker.com \
    $1
}

# Init a docker swarm cluster on node $1
init_cluster () {
  docker-machine ssh $1 \
    docker swarm init \
      --secret ${SWARM_SECRET}
  echo "$(docker-machine ssh $1 docker info | grep CACertHash | sed -e 's/CACertHash://')"
}

# Join node $2 to the cluster managed by $1
join_node () {
  docker-machine ssh $2 \
    docker swarm join \
      --secret ${SWARM_SECRET} \
      --ca-hash $3 \
      "$(docker-machine ip $1):2377"
}

# Promote node $2 to manager of the swarm cluster.
# The promotion is performed by the manager $1.
promote_node () {
  nodeid=$(docker-machine ssh $2 docker info | grep NodeID | sed -e 's/NodeID://')
  docker-machine ssh $1 \
    docker node promote ${nodeid}
}

# Hostname of the swarm cluster leader
swarm_leader=""
swarm_cacert=""

# creating the cluster instances
for (( i=1; i <= $((NUM_WORKERS + NUM_MANAGERS)); i++ ))
do

  node=${PREFIX}-sw$(printf %02d $i)
  do_instance ${node}

  if [[ $i -eq 1 ]]; then
    swarm_cacert=$(init_cluster ${node})
    swarm_leader=${node}
  else
    join_node ${swarm_leader} ${node} ${swarm_cacert}
    if [[ $i -lt $(( $NUM_WORKERS + 1 )) ]]; then
      promote_node ${swarm_leader} ${node}
    fi
  fi

done

# list nodes
docker-machine ssh ${swarm_leader} docker node ls
