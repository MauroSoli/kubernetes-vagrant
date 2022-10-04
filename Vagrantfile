# -*- mode: ruby -*-
# vi:set ft=ruby sw=2 ts=2 sts=2:

# Define the number of master and worker nodes
# If this number is changed, remember to update setup-hosts.sh script with the new hosts IP details in /etc/hosts of each VM.
NUM_MASTER_NODE = 2
NUM_WORKER_NODE = 2
NUM_ETCD_NODE = 3

IP_NW = "192.168.56." # Change setup-hosts.sh if change this value
MASTER_IP_START = 1
NODE_IP_START = 20
ETCD_IP_START = 10
BALANCER_IP_START = 15
TOKEN = "9vr73a.a8uxfaju879qwdjv" # first token controlplane
CERT_KEY = "8d277ccc50a612b5de3b758f47181a09a8270ca2f1c8716090562f08fbcab286" # cert key for add 

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  # config.vm.box = "base"
  #config.vm.box = "ubuntu/bionic64"
  config.vm.box = "almalinux/8"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  config.vm.box_check_update = false

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"
    config.vm.synced_folder "./", "/vagrant", type: "rsync", rsync__auto: true, rsync__exclude: ['./.git']

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.


  # Provision Load balancer
  config.vm.define "kubebalancer01" do |node|
    # KVM Section
    node.vm.provider "libvirt" do |libvirt|
        libvirt.default_prefix = ""
        libvirt.driver = "kvm"
        libvirt.connect_via_ssh = false
        libvirt.username = "linux"
        libvirt.memory = 1024
        libvirt.cpus = 2
    end
    # VirtualBox section
    node.vm.provider "virtualbox" do |vb|
        vb.name = "kubebalancer01"
        vb.memory = 1024
        vb.cpus = 2
    end
    node.vm.hostname = "kubebalancer01"
    node.vm.network :private_network, ip: IP_NW + "#{BALANCER_IP_START}"
    node.vm.network "forwarded_port", guest: 22, host: 2740
    node.vm.provision "setup-hosts", :type => "shell", :path => "rhel/setup-hosts.sh" do |s|
      s.args = [IP_NW]
    end
    node.vm.provision "setup-dns", type: "shell", :path => "rhel/update-dns.sh"
    # Only Loadbalancer
    node.vm.provision "setup-haproxy", type: "shell", :path => "rhel/setup_haproxy.sh"
  end


  # Provision Master Nodes
  (1..NUM_MASTER_NODE).each do |i|
      config.vm.define "kubemaster0#{i}" do |node|
        # KVM Section
        node.vm.provider "libvirt" do |libvirt|
            libvirt.default_prefix = ""
            libvirt.driver = "kvm"
            libvirt.connect_via_ssh = false
            libvirt.username = "linux"
            libvirt.memory = 2048
            libvirt.cpus = 2
        end
        # VirtualBox section
        node.vm.provider "virtualbox" do |vb|
            vb.name = "kubemaster0#{i}"
            vb.memory = 2048
            vb.cpus = 2
        end
        node.vm.hostname = "kubemaster0#{i}"
        node.vm.network :private_network, ip: IP_NW + "#{MASTER_IP_START + i}"
        node.vm.network "forwarded_port", guest: 22, host: "#{2710 + i}"
        node.vm.provision "setup-hosts", :type => "shell", :path => "rhel/setup-hosts.sh" do |s|
          s.args = [IP_NW]
        end
        node.vm.provision "setup-container-daemon", :type => "shell", :path => "rhel/setup_container_deamon.sh"
        node.vm.provision "setup-dns", type: "shell", :path => "rhel/update-dns.sh"
        node.vm.provision "setup-k8s-components", :type => "shell", :path => "rhel/setup_k8s_components.sh"
        # Only MasterNode
        node.vm.provision "setup-k8s-controlplane", :type => "shell", :path => "rhel/setup_k8s_controlplane.sh" do |s|
          s.args = [IP_NW, TOKEN, CERT_KEY]
        end
      end
  end

  # Provision Worker Nodes
  (1..NUM_WORKER_NODE).each do |i|
    config.vm.define "kubeworker0#{i}" do |node|
        # KVM Section
        node.vm.provider "libvirt" do |libvirt|
            libvirt.default_prefix = ""
            libvirt.driver = "kvm"
            libvirt.connect_via_ssh = false
            libvirt.username = "linux"
            libvirt.memory = 1024
            libvirt.cpus = 2
        end
        # VirtualBox Section
        node.vm.provider "virtualbox" do |vb|
            vb.name = "kubenode0#{i}"
            vb.memory = 2048
            vb.cpus = 2
        end
        node.vm.hostname = "kubeworker0#{i}"
        node.vm.network :private_network, ip: IP_NW + "#{NODE_IP_START + i}"
        node.vm.network "forwarded_port", guest: 22, host: "#{2720 + i}"
        node.vm.provision "setup-hosts", :type => "shell", :path => "rhel/setup-hosts.sh" do |s|
          s.args = [IP_NW]
        end
        node.vm.provision "setup-container-daemon", :type => "shell", :path => "rhel/setup_container_deamon.sh"
        node.vm.provision "setup-dns", type: "shell", :path => "rhel/update-dns.sh"
        node.vm.provision "setup-k8s-components", :type => "shell", :path => "rhel/setup_k8s_components.sh"
        # Only WorkerNode
        node.vm.provision "setup-k8s-workernode", :type => "shell", :path => "rhel/setup_k8s_workernode.sh" do |s|
          s.args = [TOKEN, CERT_KEY]
        end
    end
  end
  
  # Provision ETCD Nodes
  (1..NUM_ETCD_NODE).each do |i|
    config.vm.define "etcdnode0#{i}" do |node|
        # KVM Section
        node.vm.provider "libvirt" do |libvirt|
            libvirt.default_prefix = ""
            libvirt.driver = "kvm"
            libvirt.connect_via_ssh = false
            libvirt.username = "linux"
            libvirt.memory = 1024
            libvirt.cpus = 2
        end
        # VirtualBox Section
        node.vm.provider "virtualbox" do |vb|
            vb.name = "etcdnode0#{i}"
            vb.memory = 1024
            vb.cpus = 2
        end
        node.vm.hostname = "etcdnode0#{i}"
        node.vm.network :private_network, ip: IP_NW + "#{ETCD_IP_START + i}"
                node.vm.network "forwarded_port", guest: 22, host: "#{2720 + i}"
        node.vm.provision "setup-hosts", :type => "shell", :path => "rhel/setup-hosts.sh" do |s|
          #s.args = ["enp0s8"]
        end
        node.vm.provision "setup-containerd", :type => "shell", :path => "rhel/containerd_install.sh"
        node.vm.provision "setup-dns", type: "shell", :path => "rhel/update-dns.sh"
    end
  end
  
end
