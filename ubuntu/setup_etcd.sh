#!/bin/bash
# Kubernetes Docs - https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/setup-ha-etcd-with-kubeadm/

IP_NW=$1
ETCD_IP_START=$2

####TODELETE
IP_NW="192.168.56."
ETCD_IP_START=10
############

# Copy custom certificates
mkdir -pv /etc/kubernetes/pki/etcd
cp -v /vagrant/certificates/ca.*                    /etc/kubernetes/pki/
cp -v /vagrant/certificates/apiserver-etcd-client.* /etc/kubernetes/pki/
cp -v /vagrant/certificates/etcd/ca.*               /etc/kubernetes/pki/etcd


# Custom kubelet for etcd service configuration 
mkdir -pv /etc/systemd/system/kubelet.service.d/
cat << EOF > /etc/systemd/system/kubelet.service.d/20-etcd-service-manager.conf
[Service]
ExecStart=
# Replace "systemd" with the cgroup driver of your container runtime. The default value in the kubelet is "cgroupfs".
# Replace the value of "--container-runtime-endpoint" for a different container runtime if needed.
ExecStart=/usr/bin/kubelet --address=127.0.0.1 --pod-manifest-path=/etc/kubernetes/manifests --cgroup-driver=systemd --container-runtime=remote --container-runtime-endpoint=unix:///var/run/crio/crio.sock --runtime-request-timeout=10m
Restart=always
EOF

systemctl daemon-reload
systemctl restart kubelet

# Update HOST0, HOST1 and HOST2 with the IPs of your hosts
for i in {0..2}
do
    n=$((i + 1))
    HOSTS[$i]="$IP_NW$(($ETCD_IP_START + $n))"
    # Create temp directories to store files that will end up on other hosts.
    mkdir -vp /tmp/${HOSTS[$i]}/
done


# Update NAME0, NAME1 and NAME2 with the hostnames of your hosts
export NAME0="etcdnode01"
export NAME1="etcdnode02"
export NAME2="etcdnode03"

#HOSTS=(${HOST0} ${HOST1} ${HOST2})
NAMES=(${NAME0} ${NAME1} ${NAME2})

# Generation of kubeadm config
for i in "${!HOSTS[@]}"; do
HOST=${HOSTS[$i]}
NAME=${NAMES[$i]}
cat << EOF > /tmp/${HOST}/kubeadmcfg.yaml
---
apiVersion: "kubeadm.k8s.io/v1beta3"
kind: InitConfiguration
nodeRegistration:
    name: ${NAME}
localAPIEndpoint:
    advertiseAddress: ${HOST}
---
apiVersion: "kubeadm.k8s.io/v1beta3"
kind: ClusterConfiguration
etcd:
    local:
        serverCertSANs:
        - "${HOST}"
        peerCertSANs:
        - "${HOST}"
        extraArgs:
            initial-cluster: ${NAMES[0]}=https://${HOSTS[0]}:2380,${NAMES[1]}=https://${HOSTS[1]}:2380,${NAMES[2]}=https://${HOSTS[2]}:2380
            initial-cluster-state: new
            name: ${NAME}
            listen-peer-urls: https://${HOST}:2380
            listen-client-urls: https://${HOST}:2379
            advertise-client-urls: https://${HOST}:2379
            initial-advertise-peer-urls: https://${HOST}:2380
EOF
done

selectNode=$(( $(hostname | sed 's,etcdnode,,g') -1 ))

# Certificates generation
kubeadm init phase certs etcd-server --config=/tmp/${HOSTS[$selectNode]}/kubeadmcfg.yaml
kubeadm init phase certs etcd-peer --config=/tmp/${HOSTS[$selectNode]}/kubeadmcfg.yaml
kubeadm init phase certs etcd-healthcheck-client --config=/tmp/${HOSTS[$selectNode]}/kubeadmcfg.yaml
kubeadm init phase certs apiserver-etcd-client --config=/tmp/${HOSTS[$selectNode]}/kubeadmcfg.yaml

# Static pod manifest creation
kubeadm init phase etcd local --config=/tmp/${HOSTS[$selectNode]}/kubeadmcfg.yaml
