terraform {

  # By default TF does not know how to use multipass, this tells it how to 
  required_providers {
    multipass = {
      # This source has less downloads than larstobi/multipass but I found this one is much easier to work with 
      # I go various errors with that one, although it might have been a skill issue :)

      source = "todoroff/multipass"
    }
  }
}

locals {
  ansible_ssh_public_key = trimspace(file(pathexpand("~/.ssh/xapp-ansible-k8s-key.pub")))
  
  nodes = {
    # Master nodes has many pods, let's give it a little more resources 
    k8s-master = {
      name   = "k8s-master"
      cpus   = 2
      memory = "4G"
      disk   = "15G"
      
      cloud_init = templatefile(pathexpand("~/cloud-init-master.yaml.tftpl"), {
        ssh_public_key = local.ansible_ssh_public_key
      })
    }

    k8s-worker1 = {
      name   = "k8s-worker1"
      cpus   = 2
      memory = "2G"
      disk   = "10G"

      cloud_init = templatefile(pathexpand("~/cloud-init-worker.yaml.tftpl"), {
        ssh_public_key = local.ansible_ssh_public_key
      })
    }

    k8s-worker2 = {
      name   = "k8s-worker2"
      cpus   = 2
      memory = "2G"
      disk   = "10G"


      cloud_init = templatefile(pathexpand("~/cloud-init-worker.yaml.tftpl"), {
        ssh_public_key = local.ansible_ssh_public_key
      })
    }
  }
}

resource "multipass_instance" "nodes" {
  for_each = local.nodes

  name   = each.value.name
  image  = "24.04"
  cpus   = each.value.cpus
  memory = each.value.memory

  disk   = each.value.disk
  resize_policy = "in_place"
  wait_for_cloud_init = true

  # when multipass is installed with snapd, the confinement mechanism does not allow it to access anything other than /home/USER
  # therefore, you should put the cloud-init file there. If you know a workaround for this submitt a PR
  cloud_init = each.value.cloud_init

}

# Initialize the master after all VMs are ready
resource "terraform_data" "kubeadm_init" {
  depends_on = [multipass_instance.nodes]

  provisioner "local-exec" {
    command = <<-EOT
      multipass exec k8s-master -- sudo kubeadm init --pod-network-cidr=10.244.0.0/16
      multipass exec k8s-master -- mkdir -p /home/ubuntu/.kube
      multipass exec k8s-master -- sudo cp /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
      multipass exec k8s-master -- sudo chown $(id -u):$(id -g) /home/ubuntu/.kube/config
      multipass exec k8s-master -- sudo systemctl restart kubelet
      multipass exec k8s-master -- kubectl create ns kube-flannel
      multipass exec k8s-master -- kubectl label --overwrite ns kube-flannel pod-security.kubernetes.io/enforce=privileged
      multipass exec k8s-master -- helm repo add flannel https://flannel-io.github.io/flannel/
      multipass exec k8s-master -- helm install flannel --set podCidr="10.244.0.0/16" --namespace kube-flannel flannel/flannel
    EOT
  }
}

# join each worker after the master is initialized
resource "terraform_data" "kubeadm_join" {
  for_each   = toset(["k8s-worker1", "k8s-worker2"])
  depends_on = [terraform_data.kubeadm_init]

  provisioner "local-exec" {
    command = <<-EOT
      JOIN=$(multipass exec k8s-master -- sudo kubeadm token create --print-join-command)
      multipass exec ${each.key} -- sudo $JOIN
    EOT
  }
}


output "ansible_inventory" {
  description = "Ansible inventory for the Kubernetes cluster"

  value = yamlencode({
    all = {
      children = {
        k8s_master = {
          hosts = {
            "k8s-master" = {
              ansible_host = multipass_instance.nodes["k8s-master"].ipv4[0]
            }
          }
        }

        k8s_workers = {
          hosts = {
            for name in ["k8s-worker1", "k8s-worker2"] :
            name => {
              ansible_host = multipass_instance.nodes[name].ipv4[0]
            }
          }
        }
      }

      vars = {
        kubeconfig_path              = "/home/ubuntu/.kube/config"
        ansible_user                 = "ubuntu"
        ansible_ssh_private_key_file = pathexpand("~/.ssh/xapp-ansible-k8s-key")
        ansible_python_interpreter  = "/usr/bin/python3"
      }
    }
  })
}