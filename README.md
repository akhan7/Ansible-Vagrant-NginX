DevOps project
----------------------------------

The goal of this workshop is to demonstrate how to use some tools to aid with the creation of virtual machines and configure software on them.  At the end of this workshop, you should be able to automatically create a virtual machine and configure it to run a simple web server.

![image](https://cloud.githubusercontent.com/assets/742934/22233647/b26951a4-e1bf-11e6-9bff-0a168a8dc66b.png)

## Creating Virtual Machine

* Install [vagrant](https://www.vagrantup.com/downloads.html).
* Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads) is a recommended provider.
  Other [virtual machine providers](https://docs.vagrantup.com/v2/providers/) do exist.

When you create a VM with vagrant, it will create a Vagrantfile in your current directory as well as a hidden directory (.vagrant).
Vagrant only allows one virtual machine configuration per directory. You will want to organize your VMs:

* `mkdir -p /boxes/ansible`; `cd /boxes/ansible`

Initialize a virtual machine. `ubuntu/trusty64` is one default image. A list of other virtual machine images can be found [here](https://atlas.hashicorp.com/boxes/search).

    vagrant init ubuntu/trusty64

Start up the virtual machine.

    vagrant up

Then    

    vagrant ssh

You should be able to connect to the machine.

## Vagrantfile

The Vagrantfile will contain some settings you can adjust for memory, networking, etc.
Two customizations you may consider making if working with your VM long-term:

* 1) Enable a synced folder. This will allow you to edit code/files from editors in your host OS.
* 2) Fix DNS to use the same as your host OS instead of its own.

```ruby
  # Important, you must run vagrant in an admin shell if you want symlinks to work correctly.
  # i.e., for npm install to work properly, you must have vagrant provision the machine in admin cmd prompt.
  config.vm.synced_folder "C:/dev", "/vol/dev"
  config.vm.synced_folder "C:/projects", "/vol/projects"

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

Unlike the first virtual machine, you cannot use the default mode, because there will be no way for the ansible VM to talk to the node VM. Instead, you much choose between bridged or host-only.
Private networking (Host-only) is the recommended setting for Linux/Mac/Windows 10. 

Uncomment the following line in Vagrantfile:

```ruby
config.vm.network "private_network", ip: "192.168.33.10"
```

Then run, `vagrant reload`. 

# Ansible
Ansible is a tool for configuring and coordinating software on multiple machines.
In general, Ansible (like Salt, Chef, and Puppet), use a central server that controls other nodes.  Unlike the other tools, Ansible does not require a client service to run on the nodes.

![image](https://cloud.githubusercontent.com/assets/742934/22233647/b26951a4-e1bf-11e6-9bff-0a168a8dc66b.png)

## Setting up Ansible

Follow these steps to install Ansible on your configuration server.

```bash
ansible-box> $ sudo apt-add-repository ppa:ansible/ansible
ansible-box> $ sudo apt-get update
ansible-box> $ sudo apt-get install ansible
```

## Setting up inventory file and ssh keys

An inventory file allows ansible to define, group, and coordinate configuration management of multiple machines. At the most basic level, it basically lists the names of an asset and details about how to connect to it.

Create a `inventory` file that contains something like the following.  **Note use your ip address and private_key**:

```ini    
[nodes]
192.168.33.100 ansible_ssh_user=vagrant ansible_ssh_private_key_file=./keys/node0.key
```

#### Setting up ssh keys

You need a way to automatically connect to your server without having to manually authenicate each connection. Using a public/private key for ssh, you can ssh into your node VM from the Ansible Server automatically.

Note, you actually don't have a keys directory yet.

On the host machine, `cd /boxes/node0`. Then run `vagrant ssh-config` to get path of the private_key of node0, open it up and copy contents into textfile. In mac os, you can run `pbcopy < path/private_key` to copy contents into clipboard.

Inside the configuration server, create a `keys/node0.key` file that contains the private_key you previously copied.  You may need to `chmod 500 keys/node0.key`.

Test your connection between ansible and node0:

    ssh -i keys/node0.key vagrant@192.168.1.100

If you see an error or prompt for a password, you have a problem with your key setup.

## Ansible in action

Now, run the ping test again to make sure you can actually talk to the node!

    ansible all -m ping -i inventory -vvvv

## Ansible Playbook


