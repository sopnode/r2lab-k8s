# Extend a SophiaNode Kubernetes cluster with R2lab worker nodes

The *[join-cluster.py](./join-cluster.py)* script aims to demonstrate how to use R2lab nodes as workers in a SophiaNode k8s cluster. 

This script uses the [SLICES blueprint](https://github.com/dsaucez/SLICES/), developed by Damien Saucez, which automates the k8s worker node setup using Ansible playbooks.

Two different R2lab images will be used by this script: 
- *slices-docker-bp-vlan100* : Ubuntu 22.04 r2lab image with docker installed and that already include the SLICES repo used to launch the Ansible playbooks.
- *slices-worker* : Ubuntu 20.04 r2lab image with performance profile (no C-states) and UHD 4.5 library installed to be used with USRP B210 devices.

The former image will be deployed on one of the R2lab nodes (*fit11* node by default) and will not be part of the k8s cluster.  


### Software dependencies

Before you can run the script in this directory, you need to install its dependencies

    pip install -r requirements.txt

### Usage:

``` bash
your-host:r2lab-k8s $ ./join-cluster.py --help
usage: join-cluster.py [-h] [-s SLICENAME] [-B BP] [-N {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37}] [-P {0,1,2}] [-M MASTER] [-v] [-n] [-l] [--image IMAGE] [--image-bp IMAGE_BP]

options:
  -h, --help            show this help message and exit
  -s SLICENAME, --slicename SLICENAME
                        specify an alternate slicename (default: inria_sopnode)
  -B BP, --node-ansible BP
                        specify ansible id node (default: 11)
  -N {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37}, --node-id {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37}
                        specify as many node ids as you want,2 by default, use 0 not to use fit nodes (default: ['2'])
  -P {0,1,2}, --pc-id {0,1,2}
                        specify as many pc ids as you want,{default_pc_worker_node} by default, no pc nodes used (default: ['0'])
  -M MASTER, --master MASTER
                        name of the k8s master node (default: sopnode-w1.inria.fr)
  -v, --verbose         run script in verbose mode (default: False)
  -n, --dry-run         only pretend to run, don't do anything (default: False)
  -l, --load-images     use this for loading images on used nodes (default: False)
  --image IMAGE         image to load in k8s worker nodes (default: slices-worker)
  --image-bp IMAGE_BP   image to load in ansible blueprint node (default: slices-docker-bp)
```


### References

* [SLICES blueprint](https://github.com/dsaucez/SLICES/ , checkout branch sopnode-r2lab)
* [R2lab welcome page](https://r2lab.inria.fr/)
* [R2lab run page (requires login)](https://r2lab.inria.fr/run.md)
* [github repo for this page](https://github.com/sopnode/r2lab-k8s)


### Prerequisites:

- a k8s cluster is up and running on the SophiaNode; the default k8s master node is *sopnode-w1.inria.fr*. 
- and of course a valid R2lab slice reserved...

### An example...

Assume that you want to deploy a scenario on the default SophiaNode cluster (i.e., with k8s master sopnode-w1.inria.fr) that requires the two following R2lab worker nodes:
- *fit01* used to launch the deployment of OAI5G pods in the k8s cluster
- *pc01* used to host the oai-gnb pod with a USRP B210 attached.

This can be done as follows:

``` bash
your-host:r2lab-k8s $ ./join-cluster.py -s my_slicename -N1 -P1 -l
```

This command will load the r2lab *slices-docker-bp* image on *fit11* node, will load the r2lab *slices-worker* image on *fit02* node, switch on *pc01* node that already has docker installed with the SLICES repo. Then it will configure the SLICES Ansible playbook to use *fit11* and *pc01* nodes as k8s workers and will launch the playbook to realize the task.

Note that it takes about 3mn to load the r2lab images on r2lab nodes and another about 3 minutes to let Ansible playbooks complete.

``` bash
your-host:r2lab-k8s $ ./join-cluster.py -s my_slicename -N1 -P1 -l
join-cluster: Please ensure that k8s master is running fine and that:
 - worker fit01 not already part of the k8s cluster on sopnode-w1.inria.fr
 - worker pc01 not already part of the k8s cluster on sopnode-w1.inria.fr
Ansible playbook will run on node fit11
********** See main scheduler in join-cluster.svg
INFO:asyncssh:Opening SSH connection to faraday.inria.fr, port 22
INFO:asyncssh:[conn=0] Connected to SSH server at faraday.inria.fr, port 22
INFO:asyncssh:[conn=0]   Local address: 138.96.206.9, port 64034
INFO:asyncssh:[conn=0]   Peer address: 138.96.16.97, port 22
INFO:asyncssh:[conn=0] Beginning auth for user inria_sopnode
INFO:asyncssh:[conn=0] Auth for user inria_sopnode succeeded
INFO:asyncssh:[conn=0, chan=0] Requesting new SSH session
INFO:asyncssh:[conn=0, chan=0]   Command: rhubarbe leases --check
15-36-27:faraday:Checking current reservation for inria_sopnode : OK
INFO:asyncssh:[conn=0, chan=0] Received exit status 0
INFO:asyncssh:[conn=0, chan=0] Received channel close
INFO:asyncssh:[conn=0, chan=0] Channel closed
INFO:asyncssh:[conn=0, chan=1] Requesting new SSH session
INFO:asyncssh:[conn=0, chan=2] Requesting new SSH session
INFO:asyncssh:[conn=0, chan=3] Requesting new SSH session
INFO:asyncssh:[conn=0, chan=1]   Command: rhubarbe load 11 -i slices-docker-bp
INFO:asyncssh:[conn=0, chan=2]   Command: rhubarbe load 1 -i slices-worker
INFO:asyncssh:[conn=0, chan=3]   Command: rhubarbe-pdu on pc01
15-36-28:faraday:Found binary frisbeed as /usr/sbin/frisbeed
15-36-28:faraday:Found binary nc as /usr/bin/nc
15-36-29:faraday:Found binary frisbeed as /usr/sbin/frisbeed
15-36-29:faraday:Found binary nc as /usr/bin/nc
15-36-29:faraday:15:36:29 - +000s: Selection: fit11
15-36-29:faraday:15:36:29 - +000s: Loading image /var/lib/rhubarbe-images/slices-docker-bp.ndz
15-36-29:faraday:15:36:29 - +000s: AUTH: checking for a valid lease
15-36-29:faraday:15:36:29 - +000s: AUTH: access granted
15-36-29:faraday:15:36:29 - +000s: fit11 reboot = Sending message 'on' to CMC reboot11
15-36-29:faraday:15:36:29 - +000s: Selection: fit01
15-36-29:faraday:15:36:29 - +000s: Loading image /var/lib/rhubarbe-images/slices-worker.ndz
15-36-29:faraday:15:36:29 - +000s: AUTH: checking for a valid lease
15-36-29:faraday:15:36:29 - +000s: AUTH: access granted
15-36-29:faraday:15:36:29 - +000s: fit01 reboot = Sending message 'on' to CMC reboot01
INFO:asyncssh:[conn=0, chan=3] Received exit status 0
INFO:asyncssh:[conn=0, chan=3] Received channel close
INFO:asyncssh:[conn=0, chan=3] Channel closed
INFO:asyncssh:[conn=0, chan=4] Requesting new SSH session
INFO:asyncssh:[conn=0, chan=4]   Command: ping -c 30 pc01
15-36-30:faraday:15:36:30 - +001s: fit11 reboot = idling for 30s
15-36-30:faraday:15:36:30 - +001s: fit01 reboot = idling for 30s
15-36-32:faraday:PING pc01 (192.168.3.61) 56(84) bytes of data.
15-36-32:faraday:From rhubarbe-control (192.168.3.100) icmp_seq=1 Destination Host Unreachable
15-36-32:faraday:From rhubarbe-control (192.168.3.100) icmp_seq=2 Destination Host Unreachable
15-36-32:faraday:From rhubarbe-control (192.168.3.100) icmp_seq=3 Destination Host Unreachable
15-36-35:faraday:From rhubarbe-control (192.168.3.100) icmp_seq=4 Destination Host Unreachable
15-36-35:faraday:ping: sendmsg: No route to host
15-36-35:faraday:From rhubarbe-control (192.168.3.100) icmp_seq=5 Destination Host Unreachable
15-36-35:faraday:From rhubarbe-control (192.168.3.100) icmp_seq=6 Destination Host Unreachable
15-36-39:faraday:From rhubarbe-control (192.168.3.100) icmp_seq=8 Destination Host Unreachable
15-36-39:faraday:ping: sendmsg: No route to host
15-36-39:faraday:From rhubarbe-control (192.168.3.100) icmp_seq=9 Destination Host Unreachable
15-36-39:faraday:From rhubarbe-control (192.168.3.100) icmp_seq=10 Destination Host Unreachable
15-36-43:faraday:From rhubarbe-control (192.168.3.100) icmp_seq=12 Destination Host Unreachable
15-36-43:faraday:From rhubarbe-control (192.168.3.100) icmp_seq=13 Destination Host Unreachable
15-36-43:faraday:From rhubarbe-control (192.168.3.100) icmp_seq=14 Destination Host Unreachable
15-36-46:faraday:64 bytes from pc01 (192.168.3.61): icmp_seq=15 ttl=64 time=2804 ms
15-36-46:faraday:64 bytes from pc01 (192.168.3.61): icmp_seq=16 ttl=64 time=1780 ms
15-36-46:faraday:64 bytes from pc01 (192.168.3.61): icmp_seq=17 ttl=64 time=756 ms
15-36-46:faraday:64 bytes from pc01 (192.168.3.61): icmp_seq=18 ttl=64 time=0.138 ms
15-36-48:faraday:64 bytes from pc01 (192.168.3.61): icmp_seq=19 ttl=64 time=0.158 ms
15-36-49:faraday:64 bytes from pc01 (192.168.3.61): icmp_seq=20 ttl=64 time=0.153 ms
15-36-50:faraday:64 bytes from pc01 (192.168.3.61): icmp_seq=21 ttl=64 time=0.158 ms
15-36-51:faraday:64 bytes from pc01 (192.168.3.61): icmp_seq=22 ttl=64 time=0.143 ms
15-36-52:faraday:64 bytes from pc01 (192.168.3.61): icmp_seq=23 ttl=64 time=0.176 ms
15-36-53:faraday:64 bytes from pc01 (192.168.3.61): icmp_seq=24 ttl=64 time=0.148 ms
15-36-54:faraday:64 bytes from pc01 (192.168.3.61): icmp_seq=25 ttl=64 time=0.170 ms
15-36-55:faraday:64 bytes from pc01 (192.168.3.61): icmp_seq=26 ttl=64 time=0.143 ms
15-36-56:faraday:64 bytes from pc01 (192.168.3.61): icmp_seq=27 ttl=64 time=0.181 ms
15-36-57:faraday:64 bytes from pc01 (192.168.3.61): icmp_seq=28 ttl=64 time=0.174 ms
15-36-58:faraday:64 bytes from pc01 (192.168.3.61): icmp_seq=29 ttl=64 time=0.182 ms
15-36-59:faraday:64 bytes from pc01 (192.168.3.61): icmp_seq=30 ttl=64 time=0.185 ms
15-37-01:faraday:15:37:01 - +032s: started <frisbeed@234.5.6.1:10001 on slices-docker-bp.ndz at 500 Mibps>
15-37-01:faraday:15:37:01 - +032s: fit11 frisbee_status = trying to telnet..
15-37-01:faraday:15:37:01 - +032s: fit11 frisbee_status = backing off for 1.96s
15-37-02:faraday:15:37:02 - +033s: started <frisbeed@234.5.6.2:10002 on slices-worker.ndz at 500 Mibps>
15-37-02:faraday:15:37:02 - +033s: fit01 frisbee_status = trying to telnet..
15-37-02:faraday:INFO:telnetlib3.client:Connected to <Peer 192.168.3.1 23>
15-37-02:faraday:15:37:02 - +033s: fit01 frisbee_status = starting frisbee client
15-37-03:faraday:15:37:03 - +034s: fit11 frisbee_status = trying to telnet..
15-37-03:faraday:INFO:telnetlib3.client:Connected to <Peer 192.168.3.11 23>
15-37-03:faraday:15:37:04 - +034s: fit11 frisbee_status = starting frisbee client
15-37-04:faraday:
15-37-04:faraday:--- pc01 ping statistics ---
15-37-04:faraday:30 packets transmitted, 16 received, +12 errors, 46.6667% packet loss, time 29734ms
15-37-04:faraday:rtt min/avg/max/mdev = 0.138/333.868/2803.638/783.311 ms, pipe 3
INFO:asyncssh:[conn=0, chan=4] Received exit status 0
INFO:asyncssh:[conn=0, chan=4] Received channel close
INFO:asyncssh:[conn=0, chan=4] Channel closed
|##################################################|100% |121.55s|Time: 0:02:010s|ETA:  --:--:--
15-39-05:faraday:INFO:telnetlib3.client:Connection closed to <Peer 192.168.3.11 23>
15-39-05:faraday:15:39:05 - +156s: fit11 reboot = Sending message 'reset' to CMC reboot11
15-39-07:faraday:15:39:07 - +158s: stopped <frisbeed@234.5.6.1:10001 on slices-docker-bp.ndz at 500 Mibps>
INFO:asyncssh:[conn=0, chan=1] Received exit status 0
INFO:asyncssh:[conn=0, chan=1] Received channel close
INFO:asyncssh:[conn=0, chan=1] Channel closed
INFO:asyncssh:[conn=0, chan=5] Requesting new SSH session
INFO:asyncssh:[conn=0, chan=5]   Command: rhubarbe wait 11
|##################################################|100% |153.60s|Time: 0:02:330s|ETA:  --:--:--
15-39-36:faraday:INFO:telnetlib3.client:Connection closed to <Peer 192.168.3.1 23>
15-39-36:faraday:15:39:36 - +187s: fit01 reboot = Sending message 'reset' to CMC reboot01
15-39-38:faraday:15:39:38 - +189s: stopped <frisbeed@234.5.6.2:10002 on slices-worker.ndz at 500 Mibps>
15-39-38:faraday:<Node fit11>:ssh OK
INFO:asyncssh:[conn=0, chan=2] Received exit status 0
INFO:asyncssh:[conn=0, chan=2] Received channel close
INFO:asyncssh:[conn=0, chan=2] Channel closed
INFO:asyncssh:[conn=0, chan=6] Requesting new SSH session
INFO:asyncssh:[conn=0, chan=6]   Command: rhubarbe wait 1
INFO:asyncssh:[conn=0, chan=5] Received exit status 0
INFO:asyncssh:[conn=0, chan=5] Received channel close
INFO:asyncssh:[conn=0, chan=5] Channel closed
15-40-12:faraday:<Node fit01>:ssh OK
INFO:asyncssh:[conn=0, chan=6] Received exit status 0
INFO:asyncssh:[conn=0, chan=6] Received channel close
INFO:asyncssh:[conn=0, chan=6] Channel closed
INFO:asyncssh:[conn=0] Opening SSH connection to pc01, port 22 via SSH tunnel
INFO:asyncssh:[conn=0] Opening direct TCP connection to pc01, port 22
INFO:asyncssh:[conn=0]   Client address: dynamic port
INFO:asyncssh:[conn=0] Opening SSH connection to fit01, port 22 via SSH tunnel
INFO:asyncssh:[conn=0] Opening direct TCP connection to fit01, port 22
INFO:asyncssh:[conn=0]   Client address: dynamic port
INFO:asyncssh:[conn=1] Connected to SSH server at pc01, port 22
INFO:asyncssh:[conn=1]   Local address: 138.96.206.9, port 64034
INFO:asyncssh:[conn=1]   Peer address: dynamic port
INFO:asyncssh:[conn=2] Connected to SSH server at fit01, port 22
INFO:asyncssh:[conn=2]   Local address: 138.96.206.9, port 64034
INFO:asyncssh:[conn=2]   Peer address: dynamic port
INFO:asyncssh:[conn=1] Beginning auth for user root
INFO:asyncssh:[conn=2] Beginning auth for user root
INFO:asyncssh:[conn=1] Auth for user root succeeded
INFO:asyncssh:[conn=1, chan=0] Requesting new SSH session
INFO:asyncssh:[conn=2] Auth for user root succeeded
INFO:asyncssh:[conn=2, chan=0] Requesting new SSH session
INFO:asyncssh:[conn=1, chan=0]   Command: ip route replace 10.3.1.0/24 dev eno1 via 192.168.3.100
INFO:asyncssh:[conn=2, chan=0]   Command: ip route replace 10.3.1.0/24 dev control via 192.168.3.100
INFO:asyncssh:[conn=2, chan=0] Received exit status 0
INFO:asyncssh:[conn=2, chan=0] Received channel close
INFO:asyncssh:[conn=2, chan=0] Channel closed
INFO:asyncssh:[conn=2, chan=1] Requesting new SSH session
INFO:asyncssh:[conn=2, chan=1]   Command: ip route replace 138.96.245.0/24 dev control via 192.168.3.100
INFO:asyncssh:[conn=1, chan=0] Received exit status 0
INFO:asyncssh:[conn=1, chan=0] Received channel close
INFO:asyncssh:[conn=1, chan=0] Channel closed
INFO:asyncssh:[conn=1, chan=1] Requesting new SSH session
INFO:asyncssh:[conn=1, chan=1]   Command: ip route replace 138.96.245.0/24 dev eno1 via 192.168.3.100
INFO:asyncssh:[conn=2, chan=1] Received exit status 0
INFO:asyncssh:[conn=2, chan=1] Received channel close
INFO:asyncssh:[conn=2, chan=1] Channel closed
INFO:asyncssh:[conn=1, chan=1] Received exit status 0
INFO:asyncssh:[conn=1, chan=1] Received channel close
INFO:asyncssh:[conn=1, chan=1] Channel closed
INFO:asyncssh:[conn=0] Opening SSH connection to fit11, port 22 via SSH tunnel
INFO:asyncssh:[conn=0] Opening direct TCP connection to fit11, port 22
INFO:asyncssh:[conn=0]   Client address: dynamic port
INFO:asyncssh:[conn=3] Connected to SSH server at fit11, port 22
INFO:asyncssh:[conn=3]   Local address: 138.96.206.9, port 64034
INFO:asyncssh:[conn=3]   Peer address: dynamic port
INFO:asyncssh:[conn=3] Beginning auth for user root
INFO:asyncssh:[conn=3] Auth for user root succeeded
INFO:asyncssh:[conn=3, chan=0] Requesting new SSH session
INFO:asyncssh:[conn=3, chan=0]   Subsystem: sftp
INFO:asyncssh.sftp:[conn=3, chan=0] Starting SFTP client
INFO:asyncssh.sftp:[conn=3, chan=0] Starting SFTP put of config-playbook.sh to .apssh-remote/config-playbook.sh-fjguzfss
INFO:asyncssh.sftp:[conn=3, chan=0]   Copying file config-playbook.sh to .apssh-remote/config-playbook.sh-fjguzfss
INFO:asyncssh:[conn=3, chan=1] Requesting new SSH session
INFO:asyncssh:[conn=3, chan=1]   Command: .apssh-remote/config-playbook.sh-fjguzfss fit01 pc01
15-40-13:fit11:handling fit01 192.168.3.1
15-40-13:fit11:handling pc01 IP: 192.168.3.61
15-40-13:fit11:Configuring Ansible playbook /root/SLICES/sopnode/ansible/inventories/sopnode_r2lab/hosts:
15-40-13:fit11:5c5,8
15-40-13:fit11:< WORKER_ITEMS
15-40-13:fit11:---
15-40-13:fit11:>         192.168.3.1:
15-40-13:fit11:>           xx-name: fit01
15-40-13:fit11:>         192.168.3.61:
15-40-13:fit11:>           xx-name: pc01
INFO:asyncssh:[conn=3, chan=1] Received exit status 1
INFO:asyncssh:[conn=3, chan=1] Received channel close
INFO:asyncssh:[conn=3, chan=1] Channel closed
INFO:asyncssh:[conn=3, chan=2] Requesting new SSH session
INFO:asyncssh:[conn=3, chan=2]   Command: docker run -t -v /root/SLICES/sopnode/ansible:/blueprint -v /root/.ssh/ssh_r2lab_key:/id_rsa_blueprint blueprint /root/.local/bin/ansible-playbook  -i inventories/sopnode_r2lab/cluster k8s-node.yaml --extra-vars @params.sopnode_r2lab.yaml
15-40-15:fit11:
15-40-15:fit11:PLAY [Create a token on k8s master] ********************************************
15-40-15:fit11:
15-40-15:fit11:TASK [Gathering Facts] *********************************************************
15-40-16:fit11:ok: [138.96.245.51]
15-40-16:fit11:
15-40-16:fit11:TASK [Create temporary build directory] ****************************************
15-40-17:fit11:changed: [138.96.245.51 -> localhost]
15-40-17:fit11:
15-40-17:fit11:TASK [Set temporary directory permissions] *************************************
15-40-17:fit11:changed: [138.96.245.51 -> localhost]
15-40-17:fit11:
15-40-17:fit11:TASK [Get configuration] *******************************************************
15-40-18:fit11:changed: [138.96.245.51]
15-40-18:fit11:
15-40-18:fit11:TASK [Create the token] ********************************************************
15-40-18:fit11:changed: [138.96.245.51]
15-40-18:fit11:
15-40-18:fit11:TASK [Compute CA certificate hash] *********************************************
15-40-18:fit11:changed: [138.96.245.51]
15-40-18:fit11:
15-40-18:fit11:TASK [Save information to a dummy host] ****************************************
15-40-18:fit11:changed: [138.96.245.51]
15-40-19:fit11:
15-40-19:fit11:PLAY [Prepare k8s nodes] *******************************************************
15-40-19:fit11:
15-40-19:fit11:TASK [Gathering Facts] *********************************************************
15-40-21:fit11:ok: [192.168.3.61]
15-40-29:fit11:ok: [192.168.3.1]
15-40-29:fit11:
15-40-29:fit11:TASK [Create ~/.kube] **********************************************************
15-40-30:fit11:ok: [192.168.3.61]
15-40-30:fit11:ok: [192.168.3.1]
15-40-30:fit11:
15-40-30:fit11:TASK [Enable and start kubelet service] ****************************************
15-40-31:fit11:ok: [192.168.3.61]
15-40-31:fit11:ok: [192.168.3.1]
15-40-31:fit11:
15-40-31:fit11:TASK [Reset k8s] ***************************************************************
15-40-43:fit11:changed: [192.168.3.61]
15-41-04:fit11:changed: [192.168.3.1]
15-41-04:fit11:
15-41-04:fit11:TASK [Copy Kube config] ********************************************************
15-41-06:fit11:ok: [192.168.3.61]
15-41-07:fit11:changed: [192.168.3.1]
15-41-07:fit11:
15-41-07:fit11:TASK [Disable swap] ************************************************************
15-41-08:fit11:changed: [192.168.3.1]
15-41-08:fit11:changed: [192.168.3.61]
15-41-08:fit11:
15-41-08:fit11:TASK [Create kubeadm configuration] ********************************************
15-41-10:fit11:changed: [192.168.3.1]
15-41-10:fit11:changed: [192.168.3.61]
15-41-10:fit11:
15-41-10:fit11:TASK [Join k8s cluster] ********************************************************
15-41-17:fit11:changed: [192.168.3.61]
15-41-20:fit11:changed: [192.168.3.1]
15-41-20:fit11:
15-41-20:fit11:TASK [Wait for the node to be ready] *******************************************
15-41-22:fit11:changed: [192.168.3.61]
15-41-38:fit11:changed: [192.168.3.1]
15-41-39:fit11:
15-41-39:fit11:TASK [Wait for the pods to be ready] *******************************************
15-42-48:fit11:changed: [192.168.3.1]
15-43-33:fit11:changed: [192.168.3.61]
15-43-33:fit11:
15-43-33:fit11:PLAY [Allow scheduling on FIT worker nodes only for oai-gnb pods] **************
15-43-33:fit11:
15-43-33:fit11:TASK [Gathering Facts] *********************************************************
15-43-35:fit11:ok: [192.168.3.1]
15-43-35:fit11:ok: [192.168.3.61]
15-43-35:fit11:
15-43-35:fit11:TASK [Add NoSchedule] **********************************************************
15-43-36:fit11:changed: [192.168.3.1]
15-43-36:fit11:changed: [192.168.3.61]
15-43-37:fit11:
15-43-37:fit11:PLAY RECAP *********************************************************************
15-43-37:fit11:138.96.245.51              : ok=7    changed=6    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
15-43-37:fit11:192.168.3.1                : ok=12   changed=8    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
15-43-37:fit11:192.168.3.61               : ok=12   changed=7    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
15-43-37:fit11:
INFO:asyncssh:[conn=3, chan=2] Received exit status 0
INFO:asyncssh:[conn=3, chan=2] Received channel close
INFO:asyncssh:[conn=3, chan=2] Channel closed
RUN OK
********************************************************************************

```

When the command returns, usually after 3-4 minutes, two new worker nodes should be available on the k8s cluster.

``` bash
root@fit01:~# kubectl get no
NAME                  STATUS   ROLES           AGE     VERSION
fit01                 Ready    <none>          4m19s   v1.25.2
pc01                  Ready    <none>          4m22s   v1.25.2
sopnode-w1.inria.fr   Ready    control-plane   19d     v1.25.4
```

### Extras

The *slices-docker-bp-vlan100* R2lab image loaded in the node that launches the ansible playbook uses the *sopnode-r2lab* branch of the [SLICES blueprint](https://github.com/dsaucez/SLICES/).

In particular, this branch defines the following two files:

```bash
root@fit11:~/SLICES/sopnode/ansible# cat params.sopnode_r2lab.yaml
---
# k8s config
k8s:
  runtime: docker
  podSubnet: 10.244.0.0/16
  serviceSubnet: 10.96.0.0/16
  dnsDomain: cluster.local
  apiserver_advertise_address: 192.168.100.92
  calico:
    nodeAddressAutodetectionV4:
      cidrs:
        - 192.168.100.0/24
  encapsulation: VXLAN
```

and in the case of fit02 worker node:

``` bash
root@fit11:~/SLICES/sopnode/ansible# cat inventories/sopnode_r2lab/cluster/hosts
all:
  children:
    computes:
      hosts:
        192.168.100.102:
          xx-name: fit02
          xx-local-ip: 192.168.100.102
        192.168.100.92:
          xx-name: sopnode-w1.inria.fr
          xx-local-ip: 192.168.100.92
    masters:
      hosts:
        192.168.100.92:
          xx-name: sopnode-w1.inria.fr
          xx-local-ip: 192.168.100.92
    openvpn:
      hosts:
```
