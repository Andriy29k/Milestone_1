#!/bin/bash

#Update and install packages
sudo DEBIAN_FRONTEND=noninteractive apt-get install postfix curl -y
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install rkhunter openssh-server dos2unix -y
rkhunter --propupd
rkhunter --check

#Configure SSH
cat /vagrant/Keys/authorized_keys >> /home/vagrant/.ssh/authorized_keys
cat /vagrant/Keys/private-key > /home/vagrant/.ssh/ed25519
sudo chown vagrant:vagrant /home/vagrant/.ssh/ed25519
sudo chmod 600 /home/vagrant/.ssh/ed25519
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd

#Chroot
sudo mkdir -p /data/store

#Add SFTP user and directory
sudo addgroup sftp
sudo chown root:root /data/store
sudo chmod 755 /data/store
sudo mkdir -p /data/store/uploads
sudo chown root:sftp /data/store/uploads
sudo chmod 770 /data/store/uploads
sudo useradd -m sftp -g sftp
echo sftp:"123qweasd" | sudo chpasswd
sudo usermod -aG sftp vagrant



#Setup SFTP
sudo tee -a /etc/ssh/sshd_config <<EOF
Match Group sftp
    ChrootDirectory /data/store
    ForceCommand internal-sftp
    AllowTcpForwarding no
    X11Forwarding no
    PasswordAuthentication no
EOF
sudo systemctl restart sshd

#Setup SSH keys for SFTP user
sudo mkdir -p /home/sftp/.ssh
sudo chown sftp:sftp /home/sftp/.ssh
sudo chmod 700 /home/sftp/.ssh
sudo cat /home/vagrant/.ssh/authorized_keys >> /home/sftp/.ssh/authorized_keys
sudo chown sftp:sftp /home/sftp/.ssh/authorized_keys
sudo chmod 600 /home/sftp/.ssh/authorized_keys
sudo systemctl restart sshd


#ssh -i /home/vagrant/.ssh/ed25519 vagrant@192.168.33.n0
#sftp -i /home/vagrant/.ssh/ed25519 sftp@192.168.33.n0