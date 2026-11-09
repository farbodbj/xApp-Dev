#!/bin/bash

# First we have to install terraform to define the VMs using terraform config files (Infra as code)

if ! command -v terraform >/dev/null 2>&1; then
    sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
    wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

    gpg --no-default-keyring \
    --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    --fingerprint

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

    sudo apt update

    sudo apt-get install -y terraform
else
    echo "terraform already installed, skipping"
fi

terraform version


# Next we install multipass, we will use it to spin up the Ububntu server VMs

if ! command -v multipass >/dev/null 2>&1; then
    # What if user does not have snap?
    sudo snap install multipass
else
    echo "multipass already installed, skipping"
fi

multipass version