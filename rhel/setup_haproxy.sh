#Load balancer installation
yum install -y haproxy

cp -fv /vagrant/haproxy/haproxy.cfg /etc/haproxy/
systemctl enable --now haproxy 
