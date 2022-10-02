# Distributed deployment

The distributed deployment is split into two parts: first, the GlusterFS which 
provides distrinuted file system that can be accessed by all containers and a docker 
swarm stack.

The GlusterFS must be installed in the hosts where the containers are deployed.
That is, the containers mount the local mountpoint just like any local volume.
The host will be in charge of providing distributed access to the content of the FS.

On the other hand, the docker swarm distributes the spark workers across all the
hosts available. 

## Preliminaries - Ansible
The deployment can be automatically done using Ansible playbooks available.
Make sure you are using python 3.8.10 and ansible 2.10.17. Other versions are not guaranteed to work as ansible versions breaks backward compatibility. 

To install the specific version of Python, use ASDF. Instructions
can be found in https://asdf-vm.com/guide/getting-started.html#_1-install-dependencies

To force ansible installation, ensure to remove the version installed with the 
distro package system `sudo apt remove --purge ansible`, and then run:

```
sudo python3 -m pip install --upgrade pip
sudo python3 -m pip install ansible==2.10.17
```

### Lab environment
We assume a testbed with a deployment machine, from which the commands are issued
and at least two other machines that are targets of the remote configurations.
On the deployment machine, install ansible:
```
$ sudo apt install -y ansible
```
Additionally, install 2 plugins required by the playbooks:
```
ansible-galaxy install geerlingguy.firewall 
ansible-galaxy install geerlingguy.glusterfs
```
### Ansible configuration
The rest of the configuration is simple. The requirements are: A list of machines (at least 2)
running Debian/Ubuntu Linux with ssh server enabled.

Configure ssh credentials to these machines and update the `inventory.ini` 
file. The credentials must have with sudo access to the remote nodes.

### Test the connection
Optionally, ensure that the machines are recheable.
```
$ ansible all -m ping
```


Once you're done, run the playbook to update the /etc/hosts and include the 
IP addresses of the hosts composing the swarm.
```
$ ansible-playbook etchosts-update.yml
```

If the command is successful you can move to the next step.

## Quick start to GlusterFS

We assume that there is no other Gluster volume. 
Running these playbooks in a environment that already have another GFS can
cause problems and potential data loss.

To install Gluster, simply run the playbook:

```
$ ansible-playbook glusterfs-provision
```

If the command ends successfully, you end up with a mount point corresponding to 
GFS. You can test by adding a file in one server and veryfing the content of the file
in the other server.


## Quick start to docker swarm
The stack is also deployed with playbooks. 
Similar to GFS, we assume no other stack is deployed as the operations performed by
the playbooks are potentially disruptive. We also assume docker is available in 
all remote nodes.

To deploy the network stack run the playbooks:

```
$ ansible-playbook stack-network-deploy.yml
```

When the network is up, deploy the service stack:

```
$ ansible-playbook stack-deploy.yml
```

## Accessing the services

> NOTE: you can use ssh and firefox as proxy to a remote node where the stack is deployed:
>```
> $ ssh -D 1080 user@machine
>```
> Where **machine is the host where the swarm master is deployed**.
> Then, configure Firefox with SOCK5s proxy, to all URLs (you can use foxyproxy addon to make it easier switching on/off). With this configuration you can use  URLs to access the services.


## Cleanup
In case of problems or when you're done with the deployment the following
playbooks completely eliminate both GlusterFS, the Service stack and the Swarm configuration (and possible start fresh with a clean environment):

```
$ ansible-playbook stack-undeploy.yml
$ ansible-playbook glusterfs-decomission.yml
$ ansible-playbook etchosts-clean.yml
```





