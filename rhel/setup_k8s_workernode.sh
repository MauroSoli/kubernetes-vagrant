#!/bin/bash

TOKEN="$1"
CERT_KEY="$2"
IP_NW="$3"

# Preparing kubemaster variable
IP_ADDR="$(ip addr | grep $IP_NW | awk '{print $2}' | sed -E 's,\/.*,,g')"

# At least one master node must running before running kubeadm join
while true
do
    echo -en "\r$(hostname): Waiting for first master node."
    sleep 0.5
    echo -en "\r$(hostname): Waiting for first master node.."
    sleep 0.5
    curlResult="$(curl -s -k --connect-timeout 2 https://kubebalancer01:6443)"
    if [[ "$curlResult" =~ "apiVersion" ]]; then break; fi
    echo -en "\r$(hostname): Waiting for first master node..."
    sleep 0.5
done

# Calculation ca hash need for --discovery-token-ca-cert-hash
CaHASH="$(openssl x509 -in /vagrant/certificates/ca.crt -noout -pubkey | \
openssl rsa -pubin -outform DER 2>/dev/null | sha256sum | cut -d' ' -f1)"
# Join to K8S Cluster as a workernode
kubeadm join kubebalancer01:6443 \
      --token $TOKEN \
      --discovery-token-ca-cert-hash sha256:$CaHASH \
      --apiserver-advertise-address:$IP_ADDR

