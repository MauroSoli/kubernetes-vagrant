# Kubernetes provisioning with Vagrant

The goal of this project is provisioning a Kubernetes Cluster, following all the best practies specified in kubernetes.io docs (at least 2 master node, 2 worker node and 3 external etcd cluster).

<br/>

You can specify the number of desired nodes modifying some variables on the first section of VagrantFile ( NUM_MASTER_NODE, NUM_WORKER_NODE, NUM_ETCD_NODE )


>Certificates must be present on ./certificate folder. <br/>
>The current certificates are present for testing purposes only. <br/>
>You can create it using the following guide: 
>https://kubernetes.io/docs/tasks/administer-cluster/certificates/ <br/>
>or
>https://phoenixnap.com/kb/kubernetes-ssl-certificates


---

## Prerequisites
You need Vagrant software https://www.vagrantup.com/ and 
at least 10GB of RAM. <br/>
For detail about minium requirements in Kubernetes see https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

---

## How it works
1. git clone git@github.com:MauroSoli/kubernetes-vagrant.git
1. cd ./kubernetes-vagrant
1. vagrant up
