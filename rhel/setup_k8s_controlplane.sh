#!/bin/bash

IP_NW=$1
TOKEN="$2"
CERT_KEY="$3"

# Preparing kubemaster variable
# kubemaster = node01,node02 ... etc
IP_ADDR="$(ip addr | grep $IP_NW | awk '{print $2}' | sed -E 's,\/.*,,g')"

# if i'm master n°1 --> kubeadm init
if [[ "$(hostname)" =~ "01" ]]; then
    # Copy custom certificates
    mkdir -pv /etc/kubernetes/pki/etcd
    cp -v /vagrant/certificates/ca.*                    /etc/kubernetes/pki/
    cp -v /vagrant/certificates/apiserver-etcd-client.* /etc/kubernetes/pki/
    cp -v /vagrant/certificates/etcd/ca.*               /etc/kubernetes/pki/etcd

    #Kubeadm config file generation
    cat << EOF > /tmp/kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1beta3
kind: InitConfiguration
bootstrapTokens:
- token: "$TOKEN"
  description: "kubeadm bootstrap token"
  ttl: "2h"
localAPIEndpoint:
  advertiseAddress: $IP_ADDR
  bindPort: 6443
certificateKey: "$CERT_KEY"
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
kubernetesVersion: stable
controlPlaneEndpoint: kubebalancer01
etcd:
  external:
    endpoints:
      - https://etcdnode01:2379
      - https://etcdnode02:2379
      - https://etcdnode03:2379
    caFile: /etc/kubernetes/pki/etcd/ca.crt
    certFile: /etc/kubernetes/pki/apiserver-etcd-client.crt
    keyFile: /etc/kubernetes/pki/apiserver-etcd-client.key
networking:
  podSubnet: "10.244.0.0/16"
EOF
    
    # Waiting etcd servers to be online
    yum install -y nc
    while true
    do

    CHECK=0
        for i in {1..3}
        do
        echo -en "\r$(hostname): Waiting for etcdservers.."
        sleep 0.5
        CHECK=$(( $(nc -z -w 1 etcdnode0$i 2379; echo $?) +$CHECK ))
        nc -z -w 1 etcdnode0$i 2379; echo $?
        done
  
        if [[ $CHECK == 0 ]]; then break; fi # If $CHECK = 0 --> all etcd servers are online
    done

    # Initialize K8S Cluster
    kubeadm init --config /tmp/kubeadm-config.yaml --upload-certs

else
    # if i'm not master n°1 --> waiting for master01
    while true
    do
        echo -en "\r$(hostname): Waiting first master node."
        sleep 0.5
        echo -en "\r$(hostname): Waiting first master node.."
        sleep 0.5

        curlResult="$(curl -s -k --connect-timeout 2 https://kubebalancer01:6443)"
        if [[ "$curlResult" =~ "apiVersion" ]]; then break; fi

        echo -en "\r$(hostname): Waiting first master node..."
        sleep 0.5
    done

    # ca hash calculation is needed for --discovery-token-ca-cert-hash
    CaHASH="$(openssl x509 -in /vagrant/certificates/ca.crt -noout -pubkey | \
    openssl rsa -pubin -outform DER 2>/dev/null | sha256sum | cut -d' ' -f1)"
    # Join to K8S Cluster
    kubeadm join kubebalancer01:6443 \
          --token $TOKEN \
          --certificate-key=$CERT_KEY \
          --discovery-token-ca-cert-hash sha256:$CaHASH \
          --control-plane

fi
