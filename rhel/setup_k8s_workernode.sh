IP_NW=$1
TOKEN="$2"
CERT_KEY="$3"

#####To DELETE
#IP_NW="192.168.56."
#TOKEN="9vr73a.a8uxyaju799qwdjv"
##############

# Preparing kubemaster variable
# kubemaster = node01,node02 ... etc
IP_ADDR=$(ip addr | grep $IP_NW | awk '{print $2}' | sed -E 's,\/.*,,g')


# if i'm master n°1 --> kubeadm init
if [[ "$(hostname)" =~ "01" ]]; then
    # Copy custom certificates
    mkdir -v /etc/kubernetes/pki
    cp -v /vagrant/certificates/ca.* /etc/kubernetes/pki/
    # Initialize K8S Cluster
    kubeadm init --pod-network-cidr 10.244.0.0/16 \
                 --apiserver-advertise-address $IP_ADDR \
                 --control-plane-endpoint kubebalancer01 \
                 --token $TOKEN \
                 --certificate-key=$CERT_KEY \
                 --upload-certs
else
# if i'm not master n°1 --> waiting for master01
    while true
    do
        echo -en "\rWaiting for first master node."
        sleep 0.5
        echo -en "\rWaiting for first master node.."
        sleep 0.5

        curlResult="$(curl -s -k --connect-timeout 2 https://kubebalancer01:6443)"
        if [[ "$curlResult" =~ "apiVersion" ]]; then break; fi

        echo -en "\rWaiting for first master node..."
        sleep 0.5
    done
    # calculation ca hash need for --discovery-token-ca-cert-hash
    CaHASH="$(openssl x509 -in /vagrant/certificates/ca.crt -noout -pubkey | \
    openssl rsa -pubin -outform DER 2>/dev/null | sha256sum | cut -d' ' -f1)"
    # Join to K8S Cluster
    kubeadm join kubebalancer01:6443 \
          --token $TOKEN \
          --certificate-key=$CERT_KEY \
          --discovery-token-ca-cert-hash sha256:$CaHASH \
          --control-plane
fi
