# Yet Another Docker GlusterFS

This should bring up a relatively small footprint debian based docker container with gluster

I've built it with docker swarm in mind, so that as you bring the swarm up, the peers should automagically find each other and connect.

I've also added the gluster rest api.

So you should be able to do something like:

```shell
docker network create --driver overlay storage
ROOTUSER=root ROOTPASS=letmein docker deploy -c docker-compose.yml gluster
```

Then any docker services you have that require storage just need to also be in the storage network.

If you're using docker-flow for ingress then it should also bring up on that, see the `docker-compose.yml` for more details on that.

Then you can do something like:
```shell
curl -X POST http://root:letmein@localhost:9000/api/1.0/volume/gv1 -d \
"bricks=bricksserver1:/brick/b1,bricksserver2:/brick/b2&start=1&replica=2"

```