# DevOps

To setup an xApp we have to setup the Near-RT RIC first, which is an O-RAN component that the xApp communicates with to make changes to the network 
and to receive updates, and metrics. To setup [Near-RT RIC we first have to have a k8s cluster](https://openaicellular.github.io/oaic/oran_installation.html) because this component consists of some pods working together. I have chosen to create three actual VMs using terraform with multipass to make it 
reproducible. 


## Terraform
To make this guide repducible, I used [Terraform](https://developer.hashicorp.com/terraform) along with [Multipass](https://canonical.com/multipass) to 
create 3 Ubuntu VMs. These three nodes were used to deploy a K8s cluster with one master and two worker nodes. Check the terraform's [main.tf](DevOps/k8s-multipass-terraform/main.tf) file to see how each node is configured. The whole cluster requires around 
6 vCPUs, 7-8 GB RAM, and 35 GB storage. 

Terraform's execution flow is roughly as such: 
1- Create the VMs as described in `locals.nodes` and wait until `cloud-init` steps finishes:
    1.1- Update, upgrade and install important packages
    1.2- Turn swap off (required by k8s)
    1.3- Make some network configurations (ip_forward = 1, bridge-nf-call-iptables etc.)
    1.4- Install container runtime and configure
    1.5- Install kubelet, kubectl, kubeadm
2- To initialize the cluster, **k8s-master** runs `kubeadm init`, and then adds some basic config files
3- **k8s-master** installs a CNI (here flannel is used) to manage networking
4- Each worker node runs `kubeadm join` and joins the cluster


To spin up this cluster, first you have to install the dependencies: 

```
cd DevOps
chmod +x install_prequisities.sh
./install_prequisities.sh

cd k8s-multipass-terraform
terraform init
terraform apply

```
Done! we now have a working Kuberenetes cluster. 


## Resources 
- [O-RAN Near-Real Time RIC Installation Guide](https://openaicellular.github.io/oaic/oran_installation.html)
