# Kubernetes Docs: https://kubernetes.io/docs/setup/production-environment/container-runtimes/

# Config IPtables forward
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

## containerd installation
#sudo yum install -y yum-utils
#sudo yum-config-manager \
#   --add-repo \
#   https://download.docker.com/linux/centos/docker-ce.repo
#sudo yum install -y containerd.io

# cri-o installation
export VERSION=1.21
curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable.repo https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/CentOS_8/devel:kubic:libcontainers:stable.repo
curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.repo https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$VERSION/CentOS_8/devel:kubic:libcontainers:stable:cri-o:$VERSION.repo
yum install -y cri-o

## config.toml configuration
#sudo sed -E 's,\"cri\",,g' -i /etc/containerd/config.toml
#cat <<EOF | sudo tee -a /etc/containerd/config.toml
#
#version = 2
#[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
#  SystemdCgroup = true
#EOF

sudo systemctl enable --now cri-o
