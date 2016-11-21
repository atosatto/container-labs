#!/bin/bash

####
## Create a Docker Swarm cluster on DigitalOcean.
##
## To clean up the cluster run
## $ docker-machine ls -q | grep do-sw | xargs docker-machine rm -f
####

SIZE=2gb
REGION=ams2
IMAGE=ubuntu-16-04-x64

PREFIX="do"

# Number of Docker Swarm Managers
NUM_MANAGERS=1
# Number of Docker Swarm Workers
NUM_WORKERS=2

# Create a new Docker instance on DigitalOcean
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
  ip="$(default_ip $1)"
  eval "$(docker-machine env $1)"
  docker swarm init \
    --listen-addr "${ip}" \
    --advertise-addr "${ip}"
}

# Join the node $1 with token $2 to the cluster created by $3
join_node () {
  ip="$(default_ip $1)"
  eval "$(docker-machine env $1)"
  docker swarm join \
    --token $2 \
    --listen-addr "${ip}" \
    --advertise-addr "${ip}" \
    "$3:2377"
}

# Get the swarm worker join token
worker_join_token () {
  eval "$(docker-machine env $1)"
  docker swarm join-token -q worker
}

# Get the swarm manager join token
manager_join_token () {
  eval "$(docker-machine env $1)"
  docker swarm join-token -q manager
}

# Get the instance default ip address
default_ip () {
  docker-machine ssh $1 \
    ip route get 8.8.8.8 | awk '{print $NF; exit}'
}

# Hostname of the swarm cluster leader
swarm_manager_name=""
swarm_manager_addr=""
worker_tk=""
manager_tk=""

# creating the cluster instances
for (( i=1; i <= $((NUM_WORKERS + NUM_MANAGERS)); i++ ))
do

  node=${PREFIX}-sw$(printf %02d $i)
  echo "======> Creating ${node} on DigitalOcean..."
  do_instance ${node}

  if [[ $i -eq 1 ]]; then
    echo "======> Initializing ${node} as first swarm manager ..."
    init_cluster "${node}"
    swarm_manager_name=${node}
    swarm_manager_addr=$(default_ip ${node})
    worker_tk=$(worker_join_token ${node})
    manager_tk=$(manager_join_token ${node})
  elif [[ $i -lt $(( $NUM_MANAGERS + 1 )) ]]; then
    echo "======> $node joining swarm as manager ..."
    join_node "${node}" "${manager_tk}" "${swarm_manager_addr}"
  else
    echo "======> $node joining swarm as worker ..."
    join_node "${node}" "${worker_tk}" "${swarm_manager_addr}"
  fi

done

# list nodes
eval "$(docker-machine env ${swarm_manager_name})"
docker node ls
