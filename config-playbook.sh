#!/bin/bash

#
# This script modifies the ansible playbook to handle various worker nodes (R2lab FIT and/or PC nodes)
#

function usage() {
    echo "USAGE:"
    echo "config-playbook.sh master-node [fit-nodes] [pc-nodes] [sopnode]"
    exit 1
}



DIR="/root/SLICES/sopnode/ansible/inventories/sopnode_r2lab"

IP_FIT_PREFIX="192.168.3."
IP_PC_PREFIX="192.168.3.9"

items=""

if [ $# -eq 0 ]; then
    usage
fi

MASTER="$1"; shift
case "$MASTER" in
    sopnode-l1*)
	gener_hosts="$DIR/generic/hosts-l1-master"
	cp $gener_hosts $DIR/cluster/hosts
	echo "select master $MASTER"
	;;
    sopnode-w1*)
	gener_hosts="$DIR/generic/hosts-w1-master"
	cp $gener_hosts $DIR/cluster/hosts
	echo "select master $MASTER"
	;;
    *)
	echo "Error, unknown master $MASTER"
	usage
	;;
esac

if [ $# -eq 0 ]; then
    echo "Configuring playbook for a single node cluster"
    perl -i -pe "BEGIN{undef $/;} s/WORKER_ITEMS\n//smg" $DIR/cluster/hosts
else
    for WORKER in "$@"
    do
	case "$WORKER" in
	    pc01*|pc02*)
		id=$(echo "$WORKER" | sed -e "s/^pc0//")
		IP="$IP_PC_PREFIX$id"
		echo "handling $WORKER IP: $IP"
		;;
	    fit0*)
		# handle fit08 specific case as 08 is interpreted as an octal value
		id=$(echo "$WORKER" | sed -e "s/^fit0//")
		IP="$IP_FIT_PREFIX"$id
		echo "handling $WORKER $IP"
		;;
	    fit*)
		id=$(echo "$WORKER" | sed -e "s/^fit//")
		IP="$IP_FIT_PREFIX"$id
		echo "handling $WORKER $IP"
		;;
	    sopnode-l1*)
		IP="192.168.3.250"
		;;
	    sopnode-w1*)
		IP="192.168.3.251"
		;;
	    *)
		echo "Error, unknown worker $WORKER"
		usage
		;;
	esac
	items=$items"        $IP:\n"
	items=$items"          xx-name: $WORKER\n"
	items=$items"          xx-local-ip: $IP\n"
	case "$WORKER" in
	    sopnode-*)
		items=$items"          xx-docker-root-home: true\n"
		;;
	esac
    done
    cp $gener_hosts $DIR/cluster/hosts
    perl -i -pe "BEGIN{undef $/;} s/WORKER_ITEMS\n/$items/smg" $DIR/cluster/hosts
fi
echo "Configuring Ansible playbook $DIR/hosts for master $MASTER:"
diff $gener_hosts $DIR/cluster/hosts || true
