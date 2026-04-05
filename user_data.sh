#!/bin/bash
# Set hostname
hostnamectl set-hostname ${hostname}
echo "127.0.0.1 ${hostname}" >> /etc/hosts

# Configure swap (4GB for 8GB RAM server)
SWAP_SIZE=4G
if [ ! -f /swapfile ]; then
    # Create swap file
    fallocate -l $SWAP_SIZE /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    
    # Make swap permanent
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
    
    # Optimize swap usage (swappiness)
    echo 'vm.swappiness=10' >> /etc/sysctl.conf
    sysctl -p
fi

# Update all packages
dnf update -y

# Install Docker
dnf install -y docker

# Start Docker service
systemctl start docker
systemctl enable docker

# Add ec2-user to docker group (allows using docker without sudo)
usermod -aG docker ec2-user

# Verify Docker installation
docker --version

# Log hostname change
echo "Hostname set to ${hostname}" >> /var/log/user-data.log

