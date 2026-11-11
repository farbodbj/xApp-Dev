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
# Open a terminal in project root
cd DevOps
chmod +x install_prequisities.sh
./install_prequisities.sh

cd k8s-multipass-terraform
terraform init
terraform apply

```
Done! we now have a working Kuberenetes cluster. to test it: 

- Get the list of nodes: 
```
multipass exec k8s-master -- kubectl get nodes                  
```
Expected output: 
```
NAME          STATUS   ROLES           AGE     VERSION
k8s-master    Ready    control-plane   4h54m   v1.37.2
k8s-worker1   Ready    <none>          4h54m   v1.37.2
k8s-worker2   Ready    <none>          4h54m   v1.37.2
```

- Get the list of pods: 
```
multipass exec k8s-master -- kubectl get pods -A                  
```
Expected output:
```
NAMESPACE      NAME                                 READY   STATUS    RESTARTS   AGE
kube-flannel   kube-flannel-ds-42c9g                1/1     Running   0          4h56m
kube-flannel   kube-flannel-ds-bmvzc                1/1     Running   0          4h56m
kube-flannel   kube-flannel-ds-zk6nr                1/1     Running   0          4h56m
kube-system    coredns-559f6c778d-j85rn             1/1     Running   0          4h56m
kube-system    coredns-559f6c778d-jkstf             1/1     Running   0          4h56m
kube-system    etcd-k8s-master                      1/1     Running   0          4h56m
kube-system    kube-apiserver-k8s-master            1/1     Running   0          4h56m
kube-system    kube-controller-manager-k8s-master   1/1     Running   0          4h56m
kube-system    kube-proxy-8dzks                     1/1     Running   0          4h56m
kube-system    kube-proxy-qrgwt                     1/1     Running   0          4h56m
kube-system    kube-proxy-vjkn8                     1/1     Running   0          4h56m
kube-system    kube-scheduler-k8s-master            1/1     Running   0          4h56m
```

## Ansible
Now we have to deploy Near-RT RIC. To make it reproducible and to avoid a bloated bash file to perform its deployment, I decided to use Ansible. I did 
not find any ready Ansible playbook to deploy Near-RT RIC, so I decided to learn enough ansible to write it myself. 

Having the k8s cluster running, to run the playbook you just have to run the following commands:

```
# Open a terminal in project root
cd Devops/k8s-multipass-terraform

# Generates k8s nodes ip mappings
terraform output -raw ansible_inventory > ../ansible-near-rt-ric/inventory.yaml


cd ../ansible-near-rt-ric
ansible-playbook -i inventory.yaml playbook.yaml
```
 
I have not yet completed this part so you will have a chartmuseum server running in your k8s cluster after this command

## Resources 
- [O-RAN Near-Real Time RIC Installation Guide](https://openaicellular.github.io/oaic/oran_installation.html)
- [Multipass + Terraform guide](https://dev.to/todoroff/multipass-terraform-modern-vm-automation-guide-129l)
- [Ansible Basics: Play, Role, Task, Playbook](www.baeldung.com/ops/ansible-task-role-play-playbook)
