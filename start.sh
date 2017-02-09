#!/bin/sh

IP_ADDRESS=$(getent hosts $(hostname) | awk '{ print $1 }' | head -n 1)

ROOTUSER=root
ROOTPASS=root

glusterd -N -p /var/run/gluster.pid &
glusterrestd &

wait-for-it.sh localhost:24007 #wait for glusterd
wait-for-it.sh localhost:9000 #wait for glusterrestd

# create gluster user if it doesn't exist
glusterrest show users | grep -q ${ROOTUSER} || glusterrest useradd ${ROOTUSER} -p " "

# gluster rest password and group just in case its changed
glusterrest passwd ${ROOTUSER} -p ${ROOTPASS}
glusterrest usermod ${ROOTUSER} -g glusteradmin

if [ $(gluster peer status | head -n 1 | awk '{print $4}') -eq 0 ] && env | grep -q "PEER_DISCOVERY_NAME" ; then
  FIRST_PEER=$(getent hosts tasks.${PEER_DISCOVERY_NAME} | awk '{ print $1 }' | sort | grep -v ${IP_ADDRESS} | head -n 1)
  wait-for-it.sh ${FIRST_PEER}:9000 && curl -X POST http://${ROOTUSER}:${ROOTPASS}@${FIRST_PEER}:9000/api/1.0/peer/${IP_ADDRESS}
fi

wait