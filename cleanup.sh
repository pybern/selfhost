#!/bin/bash

# Warning: This script is destructive and will remove Docker, Nginx, the app directory, swap space, and related configurations.
# Back up any important data (e.g., ~/toiapp/.env) before running.
# Run as the user who executed the original script, with sudo privileges.

# 1. Stop and remove Docker containers, volumes, and images
if [ -d ~/toiapp ]; then
  cd ~/toiapp
  sudo docker-compose down -v --rmi all --remove-orphans
  cd ~
fi

# 2. Remove the app directory
rm -rf ~/toiapp

# 3. Uninstall Docker Compose
sudo rm -f /usr/local/bin/docker-compose /usr/bin/docker-compose

# 4. Uninstall Docker
sudo systemctl stop docker || true
sudo systemctl disable docker || true
sudo apt purge -y docker-ce docker-ce-cli containerd.io || true
sudo rm -rf /var/lib/docker /etc/docker
sudo rm -f /etc/apt/sources.list.d/docker.list
sudo apt-key del 0EBFCD88 || true  # Remove Docker GPG key (fingerprint suffix)
sudo apt update
sudo apt autoremove -y

# 5. Remove swap space
sudo swapoff /swapfile || true
sudo rm -f /swapfile
sudo sed -i '/\/swapfile none swap sw 0 0/d' /etc/fstab

# 6. Uninstall Nginx
sudo systemctl stop nginx || true
sudo apt purge -y nginx nginx-common || true
sudo rm -rf /etc/nginx/sites-available/toiapp /etc/nginx/sites-enabled/toiapp
sudo apt autoremove -y

# 7. General system cleanup
sudo apt autoremove -y
sudo apt autoclean
sudo apt clean

echo "Cleanup complete. Reboot recommended: sudo reboot"