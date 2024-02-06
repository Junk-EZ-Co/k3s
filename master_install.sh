#!/bin/bash

# Define the path to the k3s binary and air-gap image tarball
K3S_BINARY_PATH="/root/k3s"
K3S_AIRGAP_IMAGES_PATH="/root/k3s-airgap-images-amd64.tar"

# Step 1: Check for SELinux
echo "Checking for SELinux..."
if ! command -v sestatus &> /dev/null; then
    echo "SELinux not found. Installing..."
    yum install -y selinux-policy selinux-policy-targeted
    selinuxenabled
    if [ $? -ne 0 ]; then
        echo "SELinux is not enabled. Enabling..."
        sed -i 's/SELINUX=disabled/SELINUX=enforcing/' /etc/selinux/config
        setenforce 1
    fi
else
    echo "SELinux is installed."
fi

# Ensure SELinux is in permissive mode for k3s installation
setenforce 0

# Step 2: Disable FAPolicyd
echo "Disabling FAPolicyd..."
systemctl stop fapolicyd
systemctl disable fapolicyd

# Step 3: Install k3s in Air-Gapped Mode
echo "Loading k3s air-gapped images..."
docker load < $K3S_AIRGAP_IMAGES_PATH

echo "Installing k3s from the binary..."
cp $K3S_BINARY_PATH /usr/local/bin/k3s
chmod +x /usr/local/bin/k3s

# Install k3s without starting it
K3S_KUBECONFIG_MODE="644" /usr/local/bin/k3s server --docker --air-gap-install

echo "k3s installation completed."

# Reminder to set SELinux mode back to enforcing if desired
echo "Remember to set SELinux back to enforcing mode after verifying the k3s installation."

