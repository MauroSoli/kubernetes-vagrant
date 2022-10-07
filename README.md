# Kubernetes provisioning with Vagrant

The goal of this project is provisioning locally a Kubernetes Cluster, following all the best practies specified in kubernetes.io docs (at least 2 master node, 2 worker node and 3 external etcd cluster). Anyway you can choose a lower number of master and worker nodes.

<br/>

## How managing the desire state
You can specify the number of desired nodes and desired ammount of CPU,RAM for each nodes, modifying some variables on the first section of the VagrantFile (NUM_MASTER_NODE, NUM_WORKER_NODE, NUM_ETCD_NODE):

<br/>

```ruby
# default variables
NUM_MASTER_NODE = 2
NUM_WORKER_NODE = 2
NUM_ETCD_NODE = 3 # Currently it cannot be changed

IP_NW = "192.168.56."
MASTER_IP_START = 1
NODE_IP_START = 20
ETCD_IP_START = 10
BALANCER_IP_START = 15

BALANCER_CPU = 2
BALANCER_RAM = 1024
MASTER_CPU   = 2
MASTER_RAM   = 2048
WORKER_CPU   = 2
WORKER_RAM   = 1024
ETCD_CPU     = 2
ETCD_RAM     = 1024
```

<br/>

>Certificates must be present on ./certificate folder. <br/>
>The current certificates are present for testing purposes only. <br/>
>You can create it using the following guide: 
>https://kubernetes.io/docs/tasks/administer-cluster/certificates/ <br/>
>or
>https://phoenixnap.com/kb/kubernetes-ssl-certificates

<br/>

---
## Prerequisites
1. Vagrant software https://www.vagrantup.com/
1. At least 10GB of RAM (using default variables value).
For detail about minium requirements in Kubernetes see https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
1. An hypervisor to choise from KVM, Hyper-v or VirtualBox (Using KVM or Hyper-v for better performance).

<br/>

---
## How it works
```bash
git clone git@github.com:MauroSoli/kubernetes-vagrant.git
cd ./kubernetes-vagrant
vagrant up
```
