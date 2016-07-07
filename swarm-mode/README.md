
```bash
docker-machine ls                                                                            !10013
NAME      ACTIVE   DRIVER         STATE     URL                          SWARM   DOCKER        ERRORS
do-sw01   -        digitalocean   Running   tcp://95.85.14.252:2376              v1.12.0-rc3
do-sw02   -        digitalocean   Running   tcp://95.85.14.34:2376               v1.12.0-rc3
do-sw03   -        digitalocean   Running   tcp://95.85.14.62:2376               v1.12.0-rc3
do-sw04   -        digitalocean   Running   tcp://146.185.159.26:2376            v1.12.0-rc3
do-sw05   -        digitalocean   Running   tcp://146.185.178.76:2376            v1.12.0-rc3
do-sw06   -        digitalocean   Running   tcp://146.185.162.103:2376           v1.12.0-rc3
```

```bash
eval $(docker-machine env do-sw01)
```

```bash
docker network create -d overlay catnet                                                      !10019
a0cu2jdqywf35razz55giu2uo
```

```bash
docker network ls                                                                            !10020
NETWORK ID          NAME                DRIVER              SCOPE
a1a2ca690b2b        bridge              bridge              local
a0cu2jdqywf3        catnet              overlay             swarm
56460f28d721        docker_gwbridge     bridge              local
dc33429ac17d        host                host                local
eczh26vnzr39        ingress             overlay             swarm
298bfdda1928        none                null                local
```

```bash
docker service create --name cat-app --network catnet -p 8000:5000 markchurch/cats           !10023
evr16r1s5xb1wwlowwjgbv4xy
```

```bash
docker service ls                                                                            !10024
ID            NAME     REPLICAS  IMAGE            COMMAND
evr16r1s5xb1  cat-app  0/1       markchurch/cats
```

```bash
docker service update --replicas 100 cat-app
cat-app
```

```bash
docker service tasks cat-app
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

```bash
docker service ls
ID            NAME     REPLICAS  IMAGE            COMMAND
evr16r1s5xb1  cat-app  30/30   markchurch/cats
```
