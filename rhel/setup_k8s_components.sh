#!/bin/bash

# Kubernetes Docs: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

# Disable swap
awk '{if ($0 ~ swap) {print "#"$0 } else {print}}' /etc/fstab  > /tmp/fstab && mv -f /tmp/fstab /etc/
swapoff -a

# kubelet kubeadm and kubectl installation
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

sudo yum install -y kubelet kubeadm kubectl iproute-tc --disableexcludes=kubernetes

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
