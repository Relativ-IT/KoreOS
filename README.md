# KoreOS

The name come from ... CoreOS and the fact that every things relative to kubernetes contains a K :D so, it's not a clever name

## Prerequisites

You should know FedoraCoreOS quite well and how to write `*.bu` files and convert them to `*.ign` files : see <https://docs.fedoraproject.org/en-US/fedora-coreos/producing-ign/>

I'm used to rely on a PXE boot server and a Http server for provisioning and everything here is more or less based on this in mind.

You should have some k8s/kubeadm basics in your bag !

## Feel free to contribute

As the first readme file everything needs to be done

This is a real WIP, I did promise it on <https://discussion.fedoraproject.org/t/the-right-way-to-deploy-kubernetes-on-coreos-virtual-machines/117779/1> so I deliver my work as is

This work has been possible thanks to GOAT <https://github.com/poseidon/typhoon> and his great idea <https://quay.io/repository/poseidon/kubelet?tab=tags&tag=latest>

## How to use it ?

### ./KoreOS/environment.conf

Contains some variables used for provisionning, change it with you favorite values, typîcally :

```ini
[Service]
Environment=KOREOS_CRIO_VERSION=v1.31.1
# https://github.com/cri-o/packaging/issues/150
Environment=LIBEXECDIR=/usr/local
Environment=KOREOS_KUBERNETES_VERSION=v1.31.2
Environment=KOREOS_CLUSTER_NAME=MyCLuster
Environment=KOREOS_DNS_DOMAIN=MyCluster.MyDomain
Environment=KOREOS_POD_SUBNET_CIDR=10.0.0.0/16
Environment=KOREOS_SERVICE_SUBNET_CIDR=10.96.0.0/12
Environment=KOREOS_HOSTNAME=%l
Environment=KOREOS_CONTROL_PLANE_ENDPOINT=mycluster.mydomain:6443
```

`KOREOS_POD_SUBNET_CIDR` and `KOREOS_SERVICE_SUBNET_CIDR` are default values from Kubernetes documentation.

### ./merge/KoreOS-dependencies-xxx.bu

These 2 files contain some other dependencies not linked to `environment.conf` but you should set same version numbers.

### controller.bu and worker.bu

These files contain some node specific informations like `storage` or `hostname file` and the links to you http(s) server where ign files are stored/published

I don't know how to manage multiple master nodes ... feel free to contribute
You will have to duplicate worker.bu for each worker node

## updateignitions.sh

A small script that will convert `*.bu` files in `*.ign` files and if you want can publish them via ssh on your web server.

## The right way ...

You should start your cluster with the master/controller node and wait for `koreos-installer.service` (from KoreOS-installer.ign) to finish.
Then you can check the logs with `journalctl -eu koreos-installer.service` and get the token like `kzh5ow.k7658m9zlmec5cni` and the caCertHashes: like `sha256:e46b74d087a9b14ebb03f7f65d75944a8dead52d0dddc654aa9878985ff9b0be`

You can boot your worker nodes and then connect them via ssh and `cd /opt/koreos` and update the `join.config.yaml` with token and caCertHashes taken from master node and then run `sudo kubeadm join --config join.config.yaml`
