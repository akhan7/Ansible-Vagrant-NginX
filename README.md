DevOps project
----------------------------------

The goal of this project is to demonstrate how to use some tools to aid with the creation of virtual machines and configure software on them.

![image](https://cloud.githubusercontent.com/assets/742934/22233647/b26951a4-e1bf-11e6-9bff-0a168a8dc66b.png)

## Creating Virtual Machine

* Installed [vagrant](https://www.vagrantup.com/downloads.html).
* Installed [VirtualBox](https://www.virtualbox.org/wiki/Downloads).
  Other [virtual machine providers](https://docs.vagrantup.com/v2/providers/) do exist.

When creating a VM with vagrant, it will create a Vagrantfile in the current directory as well as a hidden directory (.vagrant).
Vagrant only allows one virtual machine configuration per directory, so to organize your VMs:

* `mkdir -p /boxes/ansible`; `cd /boxes/ansible`

Initialized a virtual machine. `ubuntu/trusty64` is one default image. A list of other virtual machine images can be found [here](https://atlas.hashicorp.com/boxes/search).

    vagrant init ubuntu/trusty64

Started up the virtual machine.

    vagrant up

Then    

    vagrant ssh

Connection with the machine established.

## Vagrantfile

The Vagrantfile will contain some settings to adjust for memory, networking, etc. The Vagrantfile for this project can be found [here](https://github.com/akhan7/Ansible-Vagrant-NginX/blob/master/boxes/ansible/Vagrantfile)

```ruby
  config.vm.provider :virtualbox do |vb|
     # fix crappy dns
     # https://serverfault.com/questions/453185/vagrant-virtualbox-dns-10-0-2-3-not-working
     vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  end
```

## Virtualbox Networking
In virtualbox, VMs typically have [four ways](http://catlingmindswipe.blogspot.com/2012/06/how-to-virtualbox-networking-part-two.html) to set up the network:
- Network Address Translation (NAT), *which is the default*,
- Bridged,
- Internal network
- Host Only (Recommended).

Unlike the first virtual machine, we cannot use the default mode, because there will be no way for the ansible VM to talk to the node VM. Instead, choose between bridged or host-only.
Private networking (Host-only) is the recommended setting for Linux/Mac/Windows 10. 

Uncommented the following line in Vagrantfile:

```ruby
config.vm.network "private_network", ip: "192.168.33.10"
```

Then ran, `vagrant reload`. 

# Ansible
Ansible is a tool for configuring and coordinating software on multiple machines.
In general, Ansible (like Salt, Chef, and Puppet), use a central server that controls other nodes.  Unlike the other tools, Ansible does not require a client service to run on the nodes. It's a "push" type CM tool rather than a "pull" type.

![image](https://cloud.githubusercontent.com/assets/742934/22233647/b26951a4-e1bf-11e6-9bff-0a168a8dc66b.png)

## Setting up Ansible

Followed these steps to install Ansible on your configuration server.

```bash
ansible-box> $ sudo apt-add-repository ppa:ansible/ansible
ansible-box> $ sudo apt-get update
ansible-box> $ sudo apt-get install ansible
```

## Setting up inventory file and ssh keys

An inventory file allows ansible to define, group, and coordinate configuration management of multiple machines. At the most basic level, it basically lists the names of an asset and details about how to connect to it.

Created a `inventory` file that contains something like the following:

```ini    
[nodes]
192.168.33.100 ansible_ssh_user=vagrant ansible_ssh_private_key_file=./keys/node0.key
```

Inventory file can be found [here](https://github.com/akhan7/Ansible-Vagrant-NginX/blob/master/ansible/inventory).

#### Setting up ssh keys

To automatically connect to our server without having to manually authenicate each connection, use a public/private key for ssh, ssh into our node VM from the Ansible Server automatically.

On the host machine, `cd /boxes/node0`. Then ran `vagrant ssh-config` to get path of the private_key of node0, opened it up and copied contents into textfile.

Inside the configuration server, created a `keys/node0.key` file that contained the private_key previously copied. Set the correct permissions by `chmod 500 keys/node0.key`.

Tested the connection between ansible and node0:

    ssh -i keys/node0.key vagrant@192.168.1.100

## Ansible in action

Now, run the ping test again to make sure you can actually talk to the node!

    ansible all -m ping -i inventory -vvvv

## Ansible Playbook


