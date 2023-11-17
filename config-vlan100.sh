#!/bin/bash

#
# This script aims to configure the vlan100 interface of r2lab (FIT and PC) nodes
# and makes the node "x" reachable as "x-v100"
#

function usage() {
    echo "USAGE:"
    echo "config-vlan100.sh node-name interface-name address-suffix"
    exit 1
}


if [ $# -ne 3 ]; then
    usage
fi

NODENAME="$1"
IFNAME="$2"
ADDR_SUFFIX="$3"

echo "ip link add link $IFNAME name $IFNAME.100 type vlan id 100"
ip a | grep -Eq ": $IFNAME.100@$IFNAME:.*state UP"|| ip link add link "$IFNAME" name "$IFNAME".100 type vlan id 100

echo "ip link set up dev $IFNAME.100"
ip link set up dev "$IFNAME".100

echo "ip addr flush dev $IFNAME.100"
ip addr flush dev "$IFNAME".100

echo "ip addr add 192.168.100.$ADDR_SUFFIX/24 dev $IFNAME.100"
ip addr add 192.168.100."$ADDR_SUFFIX"/24 dev "$IFNAME".100

echo "ensure that $NODENAME is present in /etc/hosts"
grep -Eq $NODENAME /etc/hosts || echo "192.168.100.$ADDR_SUFFIX   $NODENAME" >> /etc/hosts








