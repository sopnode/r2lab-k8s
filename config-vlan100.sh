#!/bin/bash

#
# This script configure vlan100 interface of r2lab nodes
#

function usage() {
    echo "USAGE:"
    echo "config-vlan100.sh interface-name address-suffix"
    exit 1
}


if [ $# -ne 2 ]; then
    usage
fi

IFNAME="$1"
ADDR_SUFFIX="$2"

echo "ip link add link $IFNAME name $IFNAME.100 type vlan id 100"
ip a | grep -Eq ": $IFNAME.100@$IFNAME:.*state UP"|| ip link add link "$IFNAME" name "$IFNAME".100 type vlan id 100

echo "ip link set up dev $IFNAME.100"
ip link set up dev "$IFNAME".100

echo "ip addr flush dev $IFNAME.100"
ip addr flush dev "$IFNAME".100

echo "ip addr add 192.168.100.$ADDR_SUFFIX/24 dev $IFNAME.100"
ip addr add 192.168.100."$ADDR_SUFFIX"/24 dev "$IFNAME".100








