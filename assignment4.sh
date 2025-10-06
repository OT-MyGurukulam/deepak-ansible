[amazon]
51.21.253.249 ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/my-key.pem

[all:vars]
ansible_python_interpreter=/usr/bin/python3

# Install git, vim, curl
ansible amazon -i inventory.ini -b -m yum -a "name=git,vim,curl state=present"
# Create a user "devuser" with bash shell and wheel group
ansible amazon -i inventory.ini -b -m user -a "name=devuser groups=wheel shell=/bin/bash state=present"
ansible amazon -i inventory.ini -b -m authorized_key \
  -a "user=devuser key='{{ lookup('file', '~/.ssh/id_rsa.pub') }}'"
  
#folder structure
# Create required directories
ansible amazon -i inventory.ini -b -m file -a "path=/opt/tools state=directory mode=0755"
ansible amazon -i inventory.ini -b -m file -a "path=/var/log/customapp state=directory mode=0755"
ansible amazon -i inventory.ini -b -m file -a "path=/home/ec2-user/projects state=directory mode=0755"

#git clone 
# Clone or update a repo
ansible amazon -i inventory.ini -b -m git \
  -a "repo=https://github.com/opstree/spring3hibernate.git dest=/home/ec2-user/projects/spring3hibernate version=master update=yes"
# Set timezone
ansible amazon -i inventory.ini -b -m command -a "timedatectl set-timezone Asia/Kolkata"

# Set hostname
ansible amazon -i inventory.ini -b -m hostname -a "name=my-ansible-managed-vm"

# Ensure httpd is enabled & started (if installed)
ansible amazon -i inventory.ini -b -m service -a "name=httpd state=started enabled=yes"

#runnning 
ansible amazon -i inventory.ini -b -m yum -a "name=git state=present"



