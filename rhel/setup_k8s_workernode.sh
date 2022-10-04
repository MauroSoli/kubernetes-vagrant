TOKEN="$1"
CERT_KEY="$2"

#####To DELETE
#IP_NW="192.168.56."
#TOKEN="9vr73a.a8uxyaju799qwdjv"
##############

# Calculation ca hash need for --discovery-token-ca-cert-hash
CaHASH="$(openssl x509 -in /vagrant/certificates/ca.crt -noout -pubkey | \
openssl rsa -pubin -outform DER 2>/dev/null | sha256sum | cut -d' ' -f1)"
# Join to K8S Cluster as a workernode
kubeadm join kubebalancer01:6443 \
      --token $TOKEN \
      --discovery-token-ca-cert-hash sha256:$CaHASH \

