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

"Swarm Mode" implementation relies on the SwarmKit project.
SwarmKit it's a library that provides all the building blocks required
to implement a distributed application-level clustered tasks scheduler.
SwarmKit tasks are the orchestrator scheduling unit and can be:
applications, containers, unikernel, vms, storage volumes, etc.
The docker-engine "Swarm Mode", right now, leverage SwarmKit to provision
containers.
The Docker Engine exposes all these informations through the
`docker service ps` command listing the tasks provisioned by the scheduler,
its state and node in which are running.

```bash
$ docker service ps cat-app
ID                         NAME            IMAGE            NODE                            DESIRED STATE  CURRENT STATE           ERROR
4arryw3w5bcahdk154kmwnpte  cat-app.1       markchurch/cats  do-sw01  Running        Running 4 minutes ago
6y4d56horbwdqripne3ez0bnu  cat-app.2       markchurch/cats  do-sw01  Running        Running 4 minutes ago
9hairy0bcrhjvvhpyyighfrx9  cat-app.3       markchurch/cats  do-sw01  Running        Running 4 minutes ago
cv1yqsz2d4vtq2fsiq8cqcfy9  cat-app.4       markchurch/cats  do-sw03  Running        Running 4 minutes ago
6le9bmgqjtqkh3fdsyv7p8wha  cat-app.5       markchurch/cats  do-sw01  Running        Running 4 minutes ago
emkrm3ue32ymar6jnyys6vrvr  cat-app.6       markchurch/cats  do-sw03  Running        Running 4 minutes ago
1e79cv8nlkfntm3mmj8j4q8c7  cat-app.7       markchurch/cats  do-sw03  Running        Running 4 minutes ago
cbmy4i85r8gp4ucnbmv6slyf3  cat-app.8       markchurch/cats  do-sw02  Running        Running 4 minutes ago
5vubw2zgmklk9f2fn3wu7ed79  cat-app.9       markchurch/cats  do-sw01  Running        Running 4 minutes ago
4jbuo618nf02tau5o3jsqddqi  cat-app.10      markchurch/cats  do-sw03  Running        Running 4 minutes ago
a9ovrcbtipms4n4sdq2ja2654  cat-app.11      markchurch/cats  do-sw02  Running        Running 4 minutes ago
9dfgk3nxocrrfd1rm2qmmr7je   \_ cat-app.11  markchurch/cats  do-sw03  Shutdown       Rejected 5 minutes ago  "failed to allocate gateway (1…"
2jwmfe96nho7p6d628nx8pp24  cat-app.12      markchurch/cats  do-sw03  Running        Running 4 minutes ago
a20n1kk7sbt3vmsol1lv24900  cat-app.13      markchurch/cats  do-sw02  Running        Running 4 minutes ago
2obyq7pewbnrfw56ps3hdt0x5  cat-app.14      markchurch/cats  do-sw03  Running        Running 4 minutes ago
cshhnpn2p407r53ggipirt1qn  cat-app.15      markchurch/cats  do-sw03  Running        Running 4 minutes ago
1dm4eet9wvsoxe2u2qpcrx7pa  cat-app.16      markchurch/cats  do-sw02  Running        Running 4 minutes ago
4gye2xkanqwqgwshgpswsttqz  cat-app.17      markchurch/cats  do-sw01  Running        Running 5 minutes ago
19lbbqtafkqgupejmsvcg6i1g  cat-app.18      markchurch/cats  do-sw02  Running        Running 5 minutes ago
1kg8h3bh99eztcj0i5gizbsqt  cat-app.19      markchurch/cats  do-sw02  Running        Running 4 minutes ago
eh7ncc1swvcgqpawrpd4jpjlk  cat-app.20      markchurch/cats  do-sw02  Running        Running 4 minutes ago
1x8fxalnftq705obwdw2ia5c9  cat-app.21      markchurch/cats  do-sw03  Running        Running 4 minutes ago
eu31wt283bbu1fxo63x7xyvqe  cat-app.22      markchurch/cats  do-sw01  Running        Running 5 minutes ago
bkm0u6pks30zw6trjkyjugvzv  cat-app.23      markchurch/cats  do-sw02  Running        Running 4 minutes ago
4fd9dp5i2x8wdgm8tv443l47z  cat-app.24      markchurch/cats  do-sw02  Running        Running 4 minutes ago
4io3ltzfox1786g2xnz3pq1ld  cat-app.25      markchurch/cats  do-sw03  Running        Running 4 minutes ago
88jxvk7jg7eoi4utkv31fby8n   \_ cat-app.25  markchurch/cats  do-sw02  Shutdown       Rejected 5 minutes ago  "failed to allocate gateway (1…"
3xgo6xcfw3ivqc3s3pryqqjqb  cat-app.26      markchurch/cats  do-sw02  Running        Running 4 minutes ago
ar4lrwlf6uwd9pjmv2utzp4b2  cat-app.27      markchurch/cats  do-sw01  Running        Running 4 minutes ago
0cirgurq65ccpxucm0rpo0ova  cat-app.28      markchurch/cats  do-sw01  Running        Running 4 minutes ago
4z5bysnai014zz8jurrqtsh0q  cat-app.29      markchurch/cats  do-sw01  Running        Running 4 minutes ago
14cwjdds31ngq2l8h7tn691vh  cat-app.30      markchurch/cats  do-sw03  Running        Running 4 minutes ago
```

Lab recording
-------------

Watch it on the web at https://asciinema.org/a/6519t70w1k7xo9iqxek2slm9x.
Play it on the shell

```bash
$ asciinema play services-demo-rec.json
```

References and useful links
---------------------------

- https://docs.docker.com/engine/swarm/
- https://github.com/docker/dcus-hol-2016/tree/master/docker-orchestration
- https://speakerdeck.com/hilbert/docker-engine-from-one-to-hundreds-nodes
