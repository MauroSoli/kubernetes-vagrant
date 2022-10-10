#!/bin/bash
set -e

IP_NW=$1

# Remove hostname on hosts file
sudo awk -v HOSTNAME="$(hostname)" -i inplace  \
'{
  if ( ($0 ~ /127.0.1.1/) && ($0 ~ HOSTNAME) )
      print "#"$0;
  else 
      print;
}' /etc/hosts

# Update /etc/hosts about other hosts
cat >> /etc/hosts <<EOF
${1}2  kubemaster01
${1}3  kubemaster02
${1}4  kubemaster03
${1}5  kubemaster04
${1}6  kubemaster05

${1}22 kubeworker01
${1}23 kubeworker02
${1}24 kubeworker03
${1}25 kubeworker04
${1}26 kubeworker05
${1}27 kubeworker06
${1}28 kubeworker07
${1}29 kubeworker08

${1}11 etcdnode01
${1}12 etcdnode02
${1}13 etcdnode03
${1}15 kubebalancer01 lb

${1}15 kubebalancer01
${1}15 kubebalancer01.default
${1}15 kubebalancer01.default.svc
${1}15 kubebalancer01.default.svc.cluster
${1}15 kubebalancer01.default.svc.cluster.local

EOF

# Disable Selinux and firewalld
setenforce 0
sed -e 's,SELINUX=enforcing,SELINUX=permissive,g' -i /etc/selinux/config
systemctl disable --now firewalld

# add network to environment
echo IP_NW="$IP_NW" | sudo tee -a /etc/environment
source /etc/environment

# Install wget
yum install wget -y

