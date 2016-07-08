Docker "Swarm Mode" Lab
=======================

1. Bring up the Lab
-------------------

Run the `swarm-up.sh` script to provision on digitalocean a cluster
of 3 Manager and 3 Workers.
Notice that in order to let the script works, you should have
`docker-machine` installed and the `DIGITAL_OCEAN_TOKEN="dotoken"` variable
exported in your env.

```bash
$ ./swarm-up.sh
[...]
ID                           HOSTNAME  MEMBERSHIP  STATUS  AVAILABILITY  MANAGER STATUS
12wi5akdqwn0r4o6fzo6030w6    do-sw06   Accepted    Ready   Active
2j559nfxk4s0u30na9mcthrhh    do-sw05   Accepted    Ready   Active
8cn08zr9bocyqjprnwye9snu9    do-sw04   Accepted    Ready   Active
9uxy02gl6jv97gfu75z3xfha4    do-sw03   Accepted    Ready   Active        Reachable
9xykkntcwuv7ga3hhtf9bs2q9    do-sw02   Accepted    Ready   Active        Reachable
cao484yrumhqhmgtka9h22aes *  do-sw01   Accepted    Ready   Active        Leader
```

Once you have your swarm cluster up & running you can use `docker-machine`
to list the active nodes

```bash
$ docker-machine ls
NAME      ACTIVE   DRIVER         STATE     URL                          SWARM   DOCKER        ERRORS
do-sw01   -        digitalocean   Running   tcp://95.85.14.252:2376              v1.12.0-rc3
do-sw02   -        digitalocean   Running   tcp://95.85.14.34:2376               v1.12.0-rc3
do-sw03   -        digitalocean   Running   tcp://95.85.14.62:2376               v1.12.0-rc3
do-sw04   -        digitalocean   Running   tcp://146.185.159.26:2376            v1.12.0-rc3
do-sw05   -        digitalocean   Running   tcp://146.185.178.76:2376            v1.12.0-rc3
do-sw06   -        digitalocean   Running   tcp://146.185.162.103:2376           v1.12.0-rc3
```

and to setup you local docker client to forward commands to the docker swarm leader.

```bash
$ eval $(docker-machine env do-sw01)
```

2. Overlay network creation
---------------------------

Create a new overlay network using the `docker network` command.
The `-d` flag let's you specify which network driver to use.
In "Swarm Mode" the overlay network does not require an external key-value store.
It is integrated into the engine.
The overlay provides reachability between the hosts across the underlay network.
Out of the box containers on the same overlay network will be able to ping
each other without any other special configuration.

```bash
$ docker network create -d overlay catnet
a0cu2jdqywf35razz55giu2uo

$ docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
a1a2ca690b2b        bridge              bridge              local
a0cu2jdqywf3        catnet              overlay             swarm
56460f28d721        docker_gwbridge     bridge              local
dc33429ac17d        host                host                local
eczh26vnzr39        ingress             overlay             swarm
298bfdda1928        none                null                local
```

3. Spawning docker services
---------------------------

Services are a new concept in Docker 1.12.
They work with swarms and are intended for long-running cluster-wide containers.
The `docker service create` command takes exactly the same basic arguments of
`docker run` plus some extras needed to provision containers in cluster
(e.g. the `--replicas` flag).

```bash
$ docker service create --name cat-app --network catnet -p 8000:5000 markchurch/cats
evr16r1s5xb1wwlowwjgbv4xy
```

To list the running services we can use the `docker service ls` command.
The output it's very similar to the one of kubernetes's `kubectl get pods`
as the underlying concepts are pretty similar: the "swarm mode"
implements a state reconciliation algorithm based on Raft, thus it
keeps monitoring the state of the cluster and tries to converge it
to the desired state.

```bash
$ docker service ls
ID            NAME     REPLICAS  IMAGE            COMMAND
evr16r1s5xb1  cat-app  0/1       markchurch/cats
```

Scaling the number of active instances of a service requires to update
its definition using the `docker service update` command.
Swarm will now try to converge the number of active containers for the service
`cat-app` in the cluster to the new replica value.

```bash
$ docker service update --replicas 30 cat-app
cat-app

$ docker service ls
ID            NAME     REPLICAS  IMAGE            COMMAND
evr16r1s5xb1  cat-app  1/30       markchurch/cats

$ docker service ls
ID            NAME     REPLICAS  IMAGE            COMMAND
evr16r1s5xb1  cat-app  30/30       markchurch/cats
```

"Swarm Mode" is implemented over the SwarmKit project.
SwarmKit it's a library that provides all the building blocks required
to implement a distributed application-level clustered tasks scheduler.
SwarmKit's tasks are the scheduled unit of the orchestration and
can be whatever it's required by its implementation:
applications, containers, unikernel, vms, storage volumes, etc.
The docker-engine "Swarm Mode", right now, leverage SwarmKit to provision
containers.
The Docker Engine exposes all these informations through the
`docker service tasks` command listing the tasks provisioned by the scheduler,
its state and node in which are running.

```bash
$ docker service tasks cat-app
ID                         NAME         SERVICE  IMAGE            LAST STATE              DESIRED STATE  NODE
dy7hicejamm0c5d9v9xebtj9y  cat-app.1    cat-app  markchurch/cats  Running About a minute  Running        do-sw01
9a2az4z0bajolfa4gh4e77nyi  cat-app.2    cat-app  markchurch/cats  Preparing 2 seconds     Running        do-sw04
acor0wgtsvnbibpapsnll0yxr  cat-app.3    cat-app  markchurch/cats  Preparing 2 seconds     Running        do-sw06
2a06eipx0ss75yqs5ade2f0r5  cat-app.4    cat-app  markchurch/cats  Preparing 2 seconds     Running        do-sw05
99zv7ndrspa9f4ah766qoke4z  cat-app.5    cat-app  markchurch/cats  Preparing 2 seconds     Running        do-sw06
7f5sf8wg12xtaxzt10fgiksw0  cat-app.6    cat-app  markchurch/cats  Preparing 2 seconds     Running        do-sw05
2fxu68j0i54gv3ucfye2mq08u  cat-app.7    cat-app  markchurch/cats  Preparing 2 seconds     Running        do-sw03
cqctkgtjlwau6l81q6uhdbhqr  cat-app.8    cat-app  markchurch/cats  Starting 2 seconds      Running        do-sw01
6g4pqpy32qay26fv72fjims12  cat-app.9    cat-app  markchurch/cats  Preparing 2 seconds     Running        do-sw03
e33omn80onpsftr2m8i6skyoi  cat-app.10   cat-app  markchurch/cats  Preparing 2 seconds     Running        do-sw01
em8cmm1y2510nrwj2pn0qb003  cat-app.11   cat-app  markchurch/cats  Preparing 2 seconds     Running        do-sw01
dnraaed68yw7023z0ym7eh5xb  cat-app.12   cat-app  markchurch/cats  Preparing 2 seconds     Running        do-sw02
6ufcndskeycnrsh4dbal5vd6c  cat-app.13   cat-app  markchurch/cats  Preparing 2 seconds     Running        do-sw05
05xizhxhmet8en8rhwirchubz  cat-app.14   cat-app  markchurch/cats  Preparing 2 seconds     Running        do-sw05
3ma4joixqqszmbseytnglffty  cat-app.15   cat-app  markchurch/cats  Preparing 2 seconds     Running        do-sw04
9n42x7mecy21d1rjbkd563nnm  cat-app.16   cat-app  markchurch/cats  Starting 2 seconds      Running        do-sw01
0qvdfnm97jpmb5x1gidl11rmb  cat-app.17   cat-app  markchurch/cats  Preparing 2 seconds     Running        do-sw02
cdfhaqsh8w7kaih3ze3x0mdaz  cat-app.18   cat-app  markchurch/cats  Preparing 2 seconds     Running        do-sw04
0k17f532coav05ymp3bg5m9qu  cat-app.19   cat-app  markchurch/cats  Preparing 2 seconds     Running        do-sw02
ab6okswyzjsavzfg5j0lat9zs  cat-app.20   cat-app  markchurch/cats  Preparing 2 seconds     Running        do-sw02
90o27th3wcds488ss70svd9f6  cat-app.21   cat-app  markchurch/cats  Preparing 2 seconds     Running        do-sw03
6h3cwv6qpq9aq0sh1pqqbox5x  cat-app.22   cat-app  markchurch/cats  Preparing 2 seconds     Running        do-sw06
bp521i62wb7d5mcqpnqrn4qvn  cat-app.23   cat-app  markchurch/cats  Preparing 2 seconds     Running        do-sw03
92bc896wza378vjbrmno4x2dj  cat-app.24   cat-app  markchurch/cats  Preparing 2 seconds     Running        do-sw01
4pl5v2izho97ny2o4udp4065h  cat-app.25   cat-app  markchurch/cats  Preparing 2 seconds     Running        do-sw01
cdtjbhxjh01w79vzxr15hso87  cat-app.26   cat-app  markchurch/cats  Preparing 2 seconds     Running        do-sw01
735xvnzar77smxdc3bden78wh  cat-app.27   cat-app  markchurch/cats  Preparing 2 seconds     Running        do-sw06
d0kutpq87ekny0c2nq2w6nmkd  cat-app.28   cat-app  markchurch/cats  Preparing 2 seconds     Running        do-sw02
e3a7alyc8d2xon9qd2dcbzh77  cat-app.29   cat-app  markchurch/cats  Preparing 2 seconds     Running        do-sw01
3jhrdddbgfl2bemyrffhlq37u  cat-app.30   cat-app  markchurch/cats  Preparing 2 seconds     Running        do-sw03
```

Lab recording
-------------

Watch it on the web at https://asciinema.org/a/6xvacwh5mura4zw924as9rabv.
Play it on the shell

```bash
$ asciinema play services-demo-rec.json
```

References and useful links
---------------------------

- https://docs.docker.com/engine/swarm/
- https://github.com/docker/dcus-hol-2016/tree/master/docker-orchestration
- https://speakerdeck.com/hilbert/docker-engine-from-one-to-hundreds-nodes
