#!/bin/bash

# Kubernetes Docs: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

# Disable swap
awk '{if ($0 ~ swap) {print "#"$0 } else {print}}' /etc/fstab  > /tmp/fstab && mv -f /tmp/fstab /etc/
swapoff -a

# kubelet kubeadm and kubectl installation
sudo apt -y install curl apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | \
sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update
sudo apt -y install vim git curl wget kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# cgroups driver kubelet config
sudo mkdir -p /var/lib/kubelet/
cat <<EOF | sudo tee /var/lib/kubelet/config.yaml
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: systemd
EOF

# Kubelet systemd config
sudo sed -e 's,ExecStart=/usr/bin/kubelet,ExecStart=/usr/bin/kubelet --config /var/lib/kubelet/config.yaml,g' \
         -i /usr/lib/systemd/system/kubelet.service

sudo systemctl daemon-reload
sudo systemctl enable --now kubelet
