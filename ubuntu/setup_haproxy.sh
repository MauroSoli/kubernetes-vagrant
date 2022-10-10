#!/bin/bash

#Load balancer installation
sudo apt install -y haproxy

cp -fv /vagrant/haproxy/haproxy.cfg /etc/haproxy/
systemctl enable --now haproxy 
