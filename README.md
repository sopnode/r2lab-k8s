# Extend a SophiaNode Kubernetes cluster with R2lab worker nodes

The *[join-cluster.py](./join-cluster.py)* script aims to demonstrate how to use R2lab nodes as workers in a SophiaNode k8s cluster. 

This script uses the [SLICES blueprint](https://github.com/dsaucez/SLICES/), developed by Damien Saucez, which automates the k8s worker node setup using Ansible playbooks.

Two different R2lab images will be used by this script: 
- *slices-docker-bp-vlan100* : Ubuntu 22.04 r2lab image with docker installed and that already include the SLICES repo used to launch the Ansible playbooks.
- *slices-worker* : Ubuntu 20.04 r2lab image with performance profile (no C-states) and UHD 4.5 library installed that can be used with USRP B210 devices.

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
                        name of the k8s master node (default: sopnode-w1-v100)
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

- a k8s cluster is up and running on the SophiaNode; the default k8s master node is *sopnode-w1-v100*. 
- and of course a valid R2lab slice reserved...

### An example...

Assume that you want to deploy a scenario on the default SophiaNode cluster (i.e., with k8s master sopnode-w1-v100) that requires the two following R2lab worker nodes:
- *fit01* used to launch the deployment of OAI5G pods in the k8s cluster
- *pc01* used to host the oai-gnb pod with a USRP B210 attached.

This can be done as follows:

``` bash
your-host:r2lab-k8s $ ./join-cluster.py -s my_slicename -N1 -P1 -l
```

This command will load the r2lab *slices-docker-bp-vlan100* image on *fit11* node, will load the r2lab *slices-worker* image on *fit01* node, switch on *pc02* node that already has docker installed with the SLICES repo. Then it will configure the SLICES Ansible playbook to use *fit01* and *pc02* nodes as k8s workers and will launch the playbook to realize the task.

Note that it takes about 3mn to load the r2lab images on r2lab nodes and another about 3 minutes to let Ansible playbooks complete.

``` bash
your-host:r2lab-k8s $ ./join-cluster.py -N1 -P2 -l
join-cluster: Please ensure that k8s master is running fine and that:
 - worker fit01 not already part of the k8s cluster on sopnode-w1-v100
 - worker pc02 not already part of the k8s cluster on sopnode-w1-v100
Ansible playbooks will run on node fit11
********** See main scheduler in join-cluster.svg
INFO:asyncssh:Opening SSH connection to faraday.inria.fr, port 22
INFO:asyncssh:[conn=0] Connected to SSH server at faraday.inria.fr, port 22
INFO:asyncssh:[conn=0]   Local address: 10.5.166.199, port 65324
INFO:asyncssh:[conn=0]   Peer address: 138.96.16.97, port 22
INFO:asyncssh:[conn=0] Beginning auth for user inria_sopnode
INFO:asyncssh:[conn=0] Auth for user inria_sopnode succeeded
INFO:asyncssh:[conn=0, chan=0] Requesting new SSH session
INFO:asyncssh:[conn=0, chan=0]   Command: rhubarbe leases --check
19-34-00:faraday:Checking current reservation for inria_sopnode : OK
INFO:asyncssh:[conn=0, chan=0] Received exit status 0
INFO:asyncssh:[conn=0, chan=0] Received channel close
INFO:asyncssh:[conn=0, chan=0] Channel closed
INFO:asyncssh:[conn=0, chan=1] Requesting new SSH session
INFO:asyncssh:[conn=0, chan=2] Requesting new SSH session
INFO:asyncssh:[conn=0, chan=3] Requesting new SSH session
INFO:asyncssh:[conn=0, chan=1]   Command: rhubarbe-pdu on pc02
INFO:asyncssh:[conn=0, chan=2]   Command: rhubarbe load 11 -i slices-docker-bp-vlan100
INFO:asyncssh:[conn=0, chan=3]   Command: rhubarbe load 1 -i slices-worker
19-34-02:faraday:Found binary frisbeed as /usr/sbin/frisbeed
19-34-02:faraday:Found binary nc as /usr/bin/nc
19-34-02:faraday:19:34:02 - +000s: Selection: fit01
19-34-02:faraday:19:34:02 - +000s: Loading image /var/lib/rhubarbe-images/slices-worker.ndz
19-34-02:faraday:Found binary frisbeed as /usr/sbin/frisbeed
19-34-02:faraday:Found binary nc as /usr/bin/nc
19-34-02:faraday:19:34:02 - +000s: AUTH: checking for a valid lease
19-34-02:faraday:19:34:02 - +000s: AUTH: access granted
19-34-02:faraday:19:34:02 - +000s: fit01 reboot = Sending message 'on' to CMC reboot01
19-34-02:faraday:19:34:02 - +000s: Selection: fit11
19-34-02:faraday:19:34:02 - +000s: Loading image /var/lib/rhubarbe-images/slices-docker-bp-vlan100.ndz
19-34-02:faraday:19:34:02 - +000s: AUTH: checking for a valid lease
19-34-02:faraday:19:34:02 - +000s: AUTH: access granted
19-34-02:faraday:19:34:02 - +000s: fit11 reboot = Sending message 'on' to CMC reboot11
INFO:asyncssh:[conn=0, chan=1] Received exit status 0
INFO:asyncssh:[conn=0, chan=1] Received channel close
INFO:asyncssh:[conn=0, chan=1] Channel closed
INFO:asyncssh:[conn=0, chan=4] Requesting new SSH session
INFO:asyncssh:[conn=0, chan=4]   Command: ping -c 60 -q pc02
19-34-04:faraday:19:34:03 - +001s: fit01 reboot = idling for 30s
19-34-04:faraday:19:34:03 - +001s: fit11 reboot = idling for 30s
19-34-20:faraday:PING pc02 (192.168.3.62) 56(84) bytes of data.
19-34-35:faraday:19:34:34 - +032s: started <frisbeed@234.5.6.1:10001 on slices-worker.ndz at 500 Mibps>
19-34-35:faraday:19:34:34 - +032s: fit01 frisbee_status = trying to telnet..
19-34-35:faraday:19:34:35 - +032s: fit01 frisbee_status = backing off for 4.31s
19-34-36:faraday:19:34:35 - +033s: started <frisbeed@234.5.6.2:10002 on slices-docker-bp-vlan100.ndz at 500 Mibps>
19-34-36:faraday:19:34:35 - +033s: fit11 frisbee_status = trying to telnet..
19-34-36:faraday:19:34:36 - +033s: fit11 frisbee_status = backing off for 1.65s
19-34-38:faraday:19:34:37 - +035s: fit11 frisbee_status = trying to telnet..
19-34-38:faraday:19:34:38 - +035s: fit11 frisbee_status = backing off for 2.47s
19-34-39:faraday:19:34:39 - +037s: fit01 frisbee_status = trying to telnet..
19-34-39:faraday:INFO:telnetlib3.client:Connected to <Peer 192.168.3.1 23>
19-34-40:faraday:19:34:39 - +037s: fit01 frisbee_status = starting frisbee client
19-34-41:faraday:19:34:40 - +038s: fit11 frisbee_status = trying to telnet..
19-34-41:faraday:INFO:telnetlib3.client:Connected to <Peer 192.168.3.11 23>
19-34-41:faraday:19:34:41 - +038s: fit11 frisbee_status = starting frisbee client
19-35-04:faraday:
19-35-04:faraday:--- pc02 ping statistics ---
19-35-04:faraday:60 packets transmitted, 44 received, +12 errors, 26.6667% packet loss, time 60327ms
19-35-04:faraday:rtt min/avg/max/mdev = 0.082/11.358/488.376/72.745 ms, pipe 3
INFO:asyncssh:[conn=0, chan=4] Received exit status 0
INFO:asyncssh:[conn=0, chan=4] Received channel close
INFO:asyncssh:[conn=0, chan=4] Channel closed
|##################################################|100% |119.38s|Time: 0:01:590s|ETA:  --:--:--
19-36-41:faraday:INFO:telnetlib3.client:Connection closed to <Peer 192.168.3.11 23>
19-36-41:faraday:19:36:40 - +158s: fit11 reboot = Sending message 'reset' to CMC reboot11
19-36-43:faraday:19:36:42 - +160s: stopped <frisbeed@234.5.6.2:10002 on slices-docker-bp-vlan100.ndz at 500 Mibps>
INFO:asyncssh:[conn=0, chan=2] Received exit status 0
INFO:asyncssh:[conn=0, chan=2] Received channel close
INFO:asyncssh:[conn=0, chan=2] Channel closed
INFO:asyncssh:[conn=0, chan=5] Requesting new SSH session
INFO:asyncssh:[conn=0, chan=5]   Command: rhubarbe wait 11
|##################################################|100% |154.50s|Time: 0:02:340s|ETA:  --:--:--
19-37-14:faraday:INFO:telnetlib3.client:Connection closed to <Peer 192.168.3.1 23>
19-37-14:faraday:19:37:14 - +191s: fit01 reboot = Sending message 'reset' to CMC reboot01
19-37-16:faraday:19:37:16 - +193s: stopped <frisbeed@234.5.6.1:10001 on slices-worker.ndz at 500 Mibps>
INFO:asyncssh:[conn=0, chan=3] Received exit status 0
INFO:asyncssh:[conn=0, chan=3] Received channel close
INFO:asyncssh:[conn=0, chan=3] Channel closed
INFO:asyncssh:[conn=0, chan=6] Requesting new SSH session
INFO:asyncssh:[conn=0, chan=6]   Command: rhubarbe wait 1
19-37-19:faraday:<Node fit11>:ssh OK
INFO:asyncssh:[conn=0, chan=5] Received exit status 0
INFO:asyncssh:[conn=0, chan=5] Received channel close
INFO:asyncssh:[conn=0, chan=5] Channel closed
19-37-53:faraday:<Node fit01>:ssh OK
INFO:asyncssh:[conn=0, chan=6] Received exit status 0
INFO:asyncssh:[conn=0, chan=6] Received channel close
INFO:asyncssh:[conn=0, chan=6] Channel closed
INFO:asyncssh:[conn=0] Opening SSH connection to fit01, port 22 via SSH tunnel
INFO:asyncssh:[conn=0] Opening direct TCP connection to fit01, port 22
INFO:asyncssh:[conn=0]   Client address: dynamic port
INFO:asyncssh:[conn=0] Opening SSH connection to pc02, port 22 via SSH tunnel
INFO:asyncssh:[conn=0] Opening direct TCP connection to pc02, port 22
INFO:asyncssh:[conn=0]   Client address: dynamic port
INFO:asyncssh:[conn=0] Opening SSH connection to fit11, port 22 via SSH tunnel
INFO:asyncssh:[conn=0] Opening direct TCP connection to fit11, port 22
INFO:asyncssh:[conn=0]   Client address: dynamic port
INFO:asyncssh:[conn=1] Connected to SSH server at fit01, port 22
INFO:asyncssh:[conn=1]   Proxy command: ssh '${SSH_SOP_OPTS:--q}' onelab.inria.oai.oai_build@faraday.inria.fr nc fit01 22
INFO:asyncssh:[conn=2] Connected to SSH server at pc02, port 22
INFO:asyncssh:[conn=2]   Local address: 10.5.166.199, port 65324
INFO:asyncssh:[conn=2]   Peer address: dynamic port
INFO:asyncssh:[conn=3] Connected to SSH server at fit11, port 22
INFO:asyncssh:[conn=3]   Proxy command: ssh '${SSH_SOP_OPTS:--q}' onelab.inria.oai.oai_build@faraday.inria.fr nc fit11 22
INFO:asyncssh:[conn=1] Beginning auth for user root
INFO:asyncssh:[conn=2] Beginning auth for user root
INFO:asyncssh:[conn=3] Beginning auth for user root
INFO:asyncssh:[conn=1] Auth for user root succeeded
INFO:asyncssh:[conn=1, chan=0] Requesting new SSH session
INFO:asyncssh:[conn=2] Auth for user root succeeded
INFO:asyncssh:[conn=3] Auth for user root succeeded
INFO:asyncssh:[conn=2, chan=0] Requesting new SSH session
INFO:asyncssh:[conn=3, chan=0] Requesting new SSH session
INFO:asyncssh:[conn=2, chan=0]   Subsystem: sftp
INFO:asyncssh:[conn=3, chan=0]   Subsystem: sftp
INFO:asyncssh:[conn=1, chan=0]   Subsystem: sftp
INFO:asyncssh.sftp:[conn=2, chan=0] Starting SFTP client
INFO:asyncssh.sftp:[conn=3, chan=0] Starting SFTP client
INFO:asyncssh.sftp:[conn=1, chan=0] Starting SFTP client
INFO:asyncssh.sftp:[conn=2, chan=0] Starting SFTP put of config-vlan100.sh to .apssh-remote/config-vlan100.sh-ivjscbll
INFO:asyncssh.sftp:[conn=3, chan=0] Starting SFTP put of config-vlan100.sh to .apssh-remote/config-vlan100.sh-nrmphupx
INFO:asyncssh.sftp:[conn=1, chan=0] Starting SFTP put of config-vlan100.sh to .apssh-remote/config-vlan100.sh-rttpscgc
INFO:asyncssh.sftp:[conn=2, chan=0]   Copying file config-vlan100.sh to .apssh-remote/config-vlan100.sh-ivjscbll
INFO:asyncssh.sftp:[conn=3, chan=0]   Copying file config-vlan100.sh to .apssh-remote/config-vlan100.sh-nrmphupx
INFO:asyncssh.sftp:[conn=1, chan=0]   Copying file config-vlan100.sh to .apssh-remote/config-vlan100.sh-rttpscgc
INFO:asyncssh:[conn=2, chan=1] Requesting new SSH session
INFO:asyncssh:[conn=2, chan=1]   Command: .apssh-remote/config-vlan100.sh-ivjscbll pc02-v100 eno1 162
INFO:asyncssh:[conn=1, chan=1] Requesting new SSH session
INFO:asyncssh:[conn=3, chan=1] Requesting new SSH session
INFO:asyncssh:[conn=1, chan=1]   Command: .apssh-remote/config-vlan100.sh-rttpscgc fit01-v100 control 101
INFO:asyncssh:[conn=3, chan=1]   Command: .apssh-remote/config-vlan100.sh-nrmphupx fit11-v100 control 111
19-37-55:pc02:ip link add link eno1 name eno1.100 type vlan id 100
19-37-55:pc02:ip link set up dev eno1.100
19-37-55:pc02:ip addr flush dev eno1.100
19-37-55:pc02:ip addr add 192.168.100.162/24 dev eno1.100
19-37-55:pc02:ensure that pc02-v100 is present in /etc/hosts
INFO:asyncssh:[conn=2, chan=1] Received exit status 0
INFO:asyncssh:[conn=2, chan=1] Received channel close
INFO:asyncssh:[conn=2, chan=1] Channel closed
19-37-55:fit01:ip link add link control name control.100 type vlan id 100
19-37-55:fit11:ip link add link control name control.100 type vlan id 100
19-37-55:fit01:ip link set up dev control.100
19-37-55:fit11:ip link set up dev control.100
19-37-55:fit01:ip addr flush dev control.100
19-37-55:fit01:ip addr add 192.168.100.101/24 dev control.100
19-37-55:fit01:ensure that fit01-v100 is present in /etc/hosts
19-37-55:fit11:ip addr flush dev control.100
INFO:asyncssh:[conn=1, chan=1] Received exit status 0
INFO:asyncssh:[conn=1, chan=1] Received channel close
INFO:asyncssh:[conn=1, chan=1] Channel closed
19-37-55:fit11:ip addr add 192.168.100.111/24 dev control.100
19-37-55:fit11:ensure that fit11-v100 is present in /etc/hosts
INFO:asyncssh:[conn=3, chan=1] Received exit status 0
INFO:asyncssh:[conn=3, chan=1] Received channel close
INFO:asyncssh:[conn=3, chan=1] Channel closed
INFO:asyncssh.sftp:[conn=3, chan=0] Starting SFTP put of config-playbook.sh to .apssh-remote/config-playbook.sh-fhqkyiue
INFO:asyncssh.sftp:[conn=3, chan=0]   Copying file config-playbook.sh to .apssh-remote/config-playbook.sh-fhqkyiue
INFO:asyncssh:[conn=3, chan=2] Requesting new SSH session
INFO:asyncssh:[conn=3, chan=2]   Command: .apssh-remote/config-playbook.sh-fhqkyiue fit01-v100 pc02-v100
19-37-55:fit11:handling fit01-v100 192.168.100.101
19-37-55:fit11:handling pc02-v100 IP: 192.168.100.162
19-37-55:fit11:Configuring Ansible playbook /root/SLICES/sopnode/ansible/inventories/sopnode_r2lab/hosts:
19-37-55:fit11:5c5,10
19-37-55:fit11:< WORKER_ITEMS
19-37-55:fit11:---
19-37-55:fit11:>         192.168.100.101:
19-37-55:fit11:>           xx-name: fit01-v100
19-37-55:fit11:>           xx-local-ip: 192.168.100.101
19-37-55:fit11:>         192.168.100.162:
19-37-55:fit11:>           xx-name: pc02-v100
19-37-55:fit11:>           xx-local-ip: 192.168.100.162
INFO:asyncssh:[conn=3, chan=2] Received exit status 0
INFO:asyncssh:[conn=3, chan=2] Received channel close
INFO:asyncssh:[conn=3, chan=2] Channel closed
INFO:asyncssh:[conn=3, chan=3] Requesting new SSH session
INFO:asyncssh:[conn=3, chan=3]   Command: docker run -t -v /root/SLICES/sopnode/ansible:/blueprint -v /root/.ssh/ssh_r2lab_key:/id_rsa_blueprint -v /etc/hosts:/etc/hosts blueprint /root/.local/bin/ansible-playbook  -i inventories/sopnode_r2lab/cluster k8s-node.yaml --extra-vars @params.sopnode_r2lab.yaml
19-37-57:fit11:
19-37-57:fit11:PLAY [Get cluster infos] *******************************************************
19-37-57:fit11:
19-37-57:fit11:TASK [Gathering Facts] *********************************************************
19-37-59:fit11:ok: [192.168.100.92]
19-37-59:fit11:
19-37-59:fit11:TASK [k8s-infos : Create temporary build directory] ****************************
19-37-59:fit11:changed: [192.168.100.92 -> localhost]
19-37-59:fit11:
19-37-59:fit11:TASK [k8s-infos : Set temporary directory permissions] *************************
19-37-59:fit11:changed: [192.168.100.92 -> localhost]
19-37-59:fit11:
19-37-59:fit11:TASK [k8s-infos : Get configuration] *******************************************
19-37-59:fit11:changed: [192.168.100.92]
19-37-59:fit11:
19-37-59:fit11:TASK [k8s-infos : Create the token] ********************************************
19-38-00:fit11:changed: [192.168.100.92]
19-38-00:fit11:
19-38-00:fit11:TASK [k8s-infos : Get certificate key] *****************************************
19-38-00:fit11:changed: [192.168.100.92]
19-38-00:fit11:
19-38-00:fit11:TASK [k8s-infos : Compute CA certificate hash] *********************************
19-38-00:fit11:changed: [192.168.100.92]
19-38-00:fit11:
19-38-00:fit11:TASK [k8s-infos : Save information to a dummy host] ****************************
19-38-01:fit11:changed: [192.168.100.92]
19-38-01:fit11:
19-38-01:fit11:PLAY [Prepare k8s nodes] *******************************************************
19-38-01:fit11:
19-38-01:fit11:TASK [Gathering Facts] *********************************************************
19-38-03:fit11:ok: [192.168.100.162]
19-38-06:fit11:ok: [192.168.100.101]
19-38-06:fit11:
19-38-06:fit11:TASK [Create ~/.kube] **********************************************************
19-38-07:fit11:ok: [192.168.100.101]
19-38-07:fit11:ok: [192.168.100.162]
19-38-07:fit11:
19-38-07:fit11:TASK [Enable and start kubelet service] ****************************************
19-38-08:fit11:ok: [192.168.100.101]
19-38-08:fit11:ok: [192.168.100.162]
19-38-08:fit11:
19-38-08:fit11:TASK [Reset k8s] ***************************************************************
19-38-09:fit11:changed: [192.168.100.101]
19-38-09:fit11:changed: [192.168.100.162]
19-38-09:fit11:
19-38-09:fit11:TASK [Copy Kube config] ********************************************************
19-38-11:fit11:changed: [192.168.100.101]
19-38-11:fit11:changed: [192.168.100.162]
19-38-11:fit11:
19-38-11:fit11:TASK [Disable swap] ************************************************************
19-38-12:fit11:changed: [192.168.100.101]
19-38-12:fit11:changed: [192.168.100.162]
19-38-12:fit11:
19-38-12:fit11:TASK [Create kubeadm configuration] ********************************************
19-38-14:fit11:changed: [192.168.100.101]
19-38-14:fit11:changed: [192.168.100.162]
19-38-14:fit11:
19-38-14:fit11:TASK [Join k8s cluster] ********************************************************
19-38-21:fit11:changed: [192.168.100.162]
19-38-21:fit11:changed: [192.168.100.101]
19-38-21:fit11:
19-38-21:fit11:TASK [Wait for the node to be ready] *******************************************
19-38-26:fit11:changed: [192.168.100.162]
19-38-26:fit11:changed: [192.168.100.101]
19-38-26:fit11:
19-38-26:fit11:TASK [Wait for the pods to be ready] *******************************************
19-38-28:fit11:changed: [192.168.100.162]
19-38-28:fit11:changed: [192.168.100.101]
19-38-28:fit11:
19-38-28:fit11:PLAY [Allow scheduling on FIT worker nodes only for oai-gnb pods] **************
19-38-28:fit11:
19-38-28:fit11:TASK [Gathering Facts] *********************************************************
19-38-30:fit11:ok: [192.168.100.101]
19-38-31:fit11:ok: [192.168.100.162]
19-38-31:fit11:
19-38-31:fit11:TASK [Add NoSchedule] **********************************************************
19-38-32:fit11:changed: [192.168.100.101]
19-38-32:fit11:changed: [192.168.100.162]
19-38-32:fit11:
19-38-32:fit11:PLAY RECAP *********************************************************************
19-38-32:fit11:192.168.100.101            : ok=12   changed=8    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
19-38-32:fit11:192.168.100.162            : ok=12   changed=8    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
19-38-32:fit11:192.168.100.92             : ok=8    changed=7    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
19-38-32:fit11:
INFO:asyncssh:[conn=3, chan=3] Received exit status 0
INFO:asyncssh:[conn=3, chan=3] Received channel close
INFO:asyncssh:[conn=3, chan=3] Channel closed
RUN OK
********************************************************************************

```

When the command returns, usually after 3-4 minutes, two new worker nodes should be available on the k8s cluster.

``` bash
root@fit01:~# kubectl get no
NAME              STATUS   ROLES           AGE    VERSION
fit01-v100        Ready    <none>          17m    v1.25.2
pc02-v100         Ready    <none>          17m    v1.25.2
sopnode-w1-v100   Ready    control-plane   102m   v1.25.4
```

### Extras

The *slices-docker-bp-vlan100* R2lab image loaded in the node that launches the ansible playbook uses the *sopnode-r2lab* branch of the [SLICES blueprint](https://github.com/dsaucez/SLICES/).

In particular, this branch includes:

- **params.sopnode_r2lab.yaml** config:

```bash
root@fit11:~/SLICES/sopnode/ansible# cat params.sopnode_r2lab.yaml
---
# k8s config
k8s:
  runtime: docker
  podSubnet: 10.244.0.0/16
  serviceSubnet: 10.96.0.0/16
  dnsDomain: cluster.local
  #apiserver_advertise_address: 192.168.100.92
  calico:
    nodeAddressAutodetectionV4:
      cidrs:
        - 192.168.100.0/24
  encapsulation: VXLAN
```

and in the case of fit02 used as k8s worker node:

- **hosts** config:

``` bash
root@fit11:~/SLICES/sopnode/ansible# cat inventories/sopnode_r2lab/cluster/hosts
all:
  children:
    computes:
      hosts:
        192.168.100.102:
          xx-name: fit02-v100
          xx-local-ip: 192.168.100.102
        192.168.100.92:
          xx-name: sopnode-w1-v100
          xx-local-ip: 192.168.100.92
    masters:
      hosts:
        192.168.100.92:
          xx-name: sopnode-w1-v100
          xx-local-ip: 192.168.100.92
    openvpn:
```

You can observe that both the master **sopnode-w1** and the worker **fit02** are defined with the **-v100** suffix, which means that we use the vlan 100 to interconnect the nodes in the R2lab testbed and the **sopnode** servers.


Following files have also been modified compared to the original **main** branch:

- **kubeadm_config.yaml.j2** chart:

``` bash
root@fit11:~/SLICES/sopnode/ansible# cat kubeadm_config.yaml.j2
apiVersion: kubeadm.k8s.io/v1beta3
kind: JoinConfiguration
nodeRegistration:
  name: "{{ hostvars[inventory_hostname]['xx-name'] }}"
  criSocket: "unix:///var/run/cri-dockerd.sock"
  kubeletExtraArgs:
    enable-controller-attach-detach: "false"
discovery:
  bootstrapToken:
    apiServerEndpoint: "{{ hostvars[groups['masters'][0]]['xx-local-ip'] }}:6443"
    token: '{{ token }}'
    caCertHashes:
    - '{{ ca_cert_hash }}'
```

- **k8s-master** playbook:

``` bash
root@fit11:~/SLICES/sopnode/ansible# cat k8s-master.yaml
---
- name: Initialize k8s cluster
  hosts: masters[0]
  become: yes
  environment:
    PATH: '{{ansible_env.PATH }}:/usr/local/bin/'

  roles:
    - role: k8s-master
    - role: k8s-ca-certificate
    - role: k8s-infos

  post_tasks:
    - name: Wait for the node to be ready
      ansible.builtin.include_tasks: k8s-ready.yaml

- name: Attach masters
  hosts: masters[1:]
  become: yes
  vars:
    token: "{{ hostvars['ansible_dummy_host']['_token'] }}"
    ca_cert_hash: "{{ hostvars['ansible_dummy_host']['_ca_cert_hash'] }}"
    certificate_key: "{{ hostvars['ansible_dummy_host']['_certificate_key'] }}"
    kube_config_local_path: "{{ hostvars['ansible_dummy_host']['_kube_config'] }}"
    master: "{{ k8s['apiserver_advertise_address'] | default(hostvars['ansible_dummy_host']['_master']) }}"
    control_plane_node: true
  environment:
    PATH: '{{ansible_env.PATH }}:/usr/local/bin/'

  roles:
    - role: k8s-node
    - role: k8s-ca-certificate

  post_tasks:
    - name: Wait for the node to be ready
      ansible.builtin.include_tasks: k8s-ready.yaml

```

- **k8s-node** playbook:

``` bash
root@fit11:~/SLICES/sopnode/ansible# cat k8s-node.yaml

- name: Get cluster infos
  hosts: masters
  run_once: true
  become: yes
  roles:
    - role: k8s-infos

- name: Prepare k8s nodes
  hosts: computes:!masters
  become: yes
  vars:
    token: "{{ hostvars['ansible_dummy_host']['_token'] }}"
    ca_cert_hash: "{{ hostvars['ansible_dummy_host']['_ca_cert_hash'] }}"
    kube_config_local_path: "{{ hostvars['ansible_dummy_host']['_kube_config'] }}"
    master: "{{ k8s['apiserver_advertise_address'] | default(hostvars['ansible_dummy_host']['_master']) }}"
  environment:
    PATH: '{{ansible_env.PATH }}:/usr/local/bin/'
  tasks:

  # Prepare k8s
  - name: Create ~/.kube
    ansible.builtin.file:
      path: ~/.kube/
      state: directory

  - name: Enable and start kubelet service
    ansible.builtin.systemd:
      name: kubelet
      state: started
      enabled: yes

  - name: Reset k8s
    shell: "kubeadm reset -f --cri-socket unix:///var/run/cri-dockerd.sock --force"

  - name: Copy Kube config
    ansible.builtin.copy:
      src: '{{ kube_config_local_path }}'
      dest: ~/.kube/config
      mode: 0600

  - name: Disable swap
    shell: swapoff -a

  - name: Create kubeadm configuration
    ansible.builtin.template:
      src: kubeadm_config.yaml.j2
      dest: ./kubeadm_config.yaml

  - name: Join k8s cluster
    ansible.builtin.shell: 'kubeadm join --config ./kubeadm_config.yaml'

  - name: Wait for the node to be ready
    ansible.builtin.shell: 'kubectl wait --timeout=300s --all-namespaces --for=condition=Ready nodes {{ hostvars[inventory_hostname]["xx-name"] }}'
    register: node_wait
    retries: 10
    until: node_wait is succeeded

  - name: Wait for the pods to be ready
    ansible.builtin.shell: 'kubectl wait --timeout=300s --all-namespaces --for=condition=Ready pods --field-selector spec.nodeName={{ hostvars[inventory_hostname]["xx-name"] }}'

- name: Allow scheduling on FIT worker nodes only for oai-gnb pods
  hosts: computes:!masters
  become: yes
  tasks:
  - name: Add NoSchedule
    shell: 'kubectl taint nodes {{ hostvars[inventory_hostname]["xx-name"] }} app.kubernetes.io/name=oai-gnb:NoSchedule --overwrite'
```
