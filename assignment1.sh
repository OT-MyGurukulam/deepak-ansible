# ====================================================
# TEAM STRUCTURE
# ====================================================
ansible -i assignment1 all -m group -a "name=dev-team state=present"
ansible -i assignment1 all -m group -a "name=devops-team state=present"
ansible -i assignment1 all -m group -a "name=admin-group state=present"

# ====================================================
# USERS WITH CUSTOM UID & SHELLS
# ====================================================
# dev-team users
ansible -i assignment1 all -m user -a "name=devuser1 uid=2000 group=dev-team shell=/bin/bash password_expire_max=30"
ansible -i assignment1 all -m user -a "name=devuser2 uid=2001 group=dev-team shell=/bin/bash password_expire_max=30"
ansible -i assignment1 all -m user -a "name=devuser3 uid=2002 group=dev-team shell=/bin/bash password_expire_max=30"

# devops-team users
ansible -i assignment1 all -m user -a "name=devopsuser1 uid=2003 group=devops-team shell=/bin/zsh password_expire_max=30"
ansible -i assignment1 all -m user -a "name=devopsuser2 uid=2004 group=devops-team shell=/bin/zsh password_expire_max=30"
ansible -i assignment1 all -m user -a "name=devopsuser3 uid=2005 group=devops-team shell=/bin/zsh password_expire_max=30"

# admin-group users
ansible -i assignment1 all -m user -a "name=adminuser1 uid=2006 group=admin-group shell=/bin/sh password_expire_max=30"
ansible -i assignment1 all -m user -a "name=adminuser2 uid=2007 group=admin-group shell=/bin/sh password_expire_max=30"
ansible -i assignment1 all -m user -a "name=adminuser3 uid=2008 group=admin-group shell=/bin/sh password_expire_max=30"

# ====================================================
# SUDO ACCESS
# ====================================================
ansible -i assignment1 all -m copy -a "dest=/etc/sudoers.d/dev-team content='%dev-team ALL=(ALL) NOPASSWD:ALL'"
ansible -i assignment1 all -m copy -a "dest=/etc/sudoers.d/devops-team content='%devops-team ALL=(ALL) NOPASSWD:ALL'"

# ====================================================
# PERSONAL WORKSPACES
# ====================================================
ansible -i assignment1 all -m file -a "path=/home/devuser1/workspace state=directory owner=devuser1 group=dev-team mode=0750"
ansible -i assignment1 all -m file -a "path=/home/devuser2/workspace state=directory owner=devuser2 group=dev-team mode=0750"
ansible -i assignment1 all -m file -a "path=/home/devuser3/workspace state=directory owner=devuser3 group=dev-team mode=0750"
ansible -i assignment1 all -m file -a "path=/home/devopsuser1/workspace state=directory owner=devopsuser1 group=devops-team mode=0750"
ansible -i assignment1 all -m file -a "path=/home/devopsuser2/workspace state=directory owner=devopsuser2 group=devops-team mode=0750"
ansible -i assignment1 all -m file -a "path=/home/devopsuser3/workspace state=directory owner=devopsuser3 group=devops-team mode=0750"
ansible -i assignment1 all -m file -a "path=/home/adminuser1/workspace state=directory owner=adminuser1 group=admin-group mode=0750"
ansible -i assignment1 all -m file -a "path=/home/adminuser2/workspace state=directory owner=adminuser2 group=admin-group mode=0750"
ansible -i assignment1 all -m file -a "path=/home/adminuser3/workspace state=directory owner=adminuser3 group=admin-group mode=0750"

# ====================================================
# TEAM COLLABORATION DIRECTORIES
# ====================================================
ansible -i assignment1 all -m file -a "path=/srv/dev-team state=directory owner=root group=dev-team mode=2775"
ansible -i assignment1 all -m file -a "path=/srv/devops-team state=directory owner=root group=devops-team mode=2775"
ansible -i assignment1 all -m file -a "path=/srv/admin-group state=directory owner=root group=admin-group mode=2770"

# ====================================================
# PROJECT DIRECTORIES
# ====================================================
ansible -i assignment1 all -m file -a "path=/srv/projects/WebApp state=directory owner=devuser1 group=dev-team mode=2775"
ansible -i assignment1 all -m file -a "path=/srv/projects/API state=directory owner=devopsuser1 group=devops-team mode=2775"
ansible -i assignment1 all -m file -a "path=/srv/projects/Mobile state=directory owner=adminuser1 group=admin-group mode=2775"

# ====================================================
# SHARED & ARCHIVE
# ====================================================
ansible -i assignment1 all -m file -a "path=/srv/shared-resources state=directory owner=root group=root mode=0777"
ansible -i assignment1 all -m file -a "path=/srv/archive state=directory owner=root group=root mode=0555"

# ====================================================
# ADMIN AREAS
# ====================================================
ansible -i assignment1 all -m file -a "path=/srv/admin-areas state=directory owner=root group=admin-group mode=2770"

# ====================================================
# ACL CONFIGURATION FOR SECURITY MATRIX
# ====================================================
# Personal Workspaces: Owner full, team read
ansible -i assignment1 all -m acl -a "path=/home/devuser1/workspace entity=dev-team etype=group permissions=rX state=present"
ansible -i assignment1 all -m acl -a "path=/home/devuser2/workspace entity=dev-team etype=group permissions=rX state=present"
ansible -i assignment1 all -m acl -a "path=/home/devuser3/workspace entity=dev-team etype=group permissions=rX state=present"
ansible -i assignment1 all -m acl -a "path=/home/devopsuser1/workspace entity=devops-team etype=group permissions=rX state=present"
ansible -i assignment1 all -m acl -a "path=/home/devopsuser2/workspace entity=devops-team etype=group permissions=rX state=present"
ansible -i assignment1 all -m acl -a "path=/home/devopsuser3/workspace entity=devops-team etype=group permissions=rX state=present"
ansible -i assignment1 all -m acl -a "path=/home/adminuser1/workspace entity=admin-group etype=group permissions=rX state=present"
ansible -i assignment1 all -m acl -a "path=/home/adminuser2/workspace entity=admin-group etype=group permissions=rX state=present"
ansible -i assignment1 all -m acl -a "path=/home/adminuser3/workspace entity=admin-group etype=group permissions=rX state=present"

# Team Directories: Team full, others read-only
ansible -i assignment1 all -m acl -a "path=/srv/dev-team entity=devops-team etype=group permissions=rX state=present"
ansible -i assignment1 all -m acl -a "path=/srv/dev-team entity=admin-group etype=group permissions=rX state=present"
ansible -i assignment1 all -m acl -a "path=/srv/devops-team entity=dev-team etype=group permissions=rX state=present"
ansible -i assignment1 all -m acl -a "path=/srv/devops-team entity=admin-group etype=group permissions=rX state=present"
ansible -i assignment1 all -m acl -a "path=/srv/admin-group entity=dev-team etype=group permissions=rX state=present"
ansible -i assignment1 all -m acl -a "path=/srv/admin-group entity=devops-team etype=group permissions=rX state=present"

# Project Directories: leads full, assigned teams rw, others r
ansible -i assignment1 all -m acl -a "path=/srv/projects/WebApp entity=dev-team etype=group permissions=rwX state=present"
ansible -i assignment1 all -m acl -a "path=/srv/projects/WebApp entity=devops-team etype=group permissions=rX state=present"
ansible -i assignment1 all -m acl -a "path=/srv/projects/WebApp entity=admin-group etype=group permissions=rX state=present"

ansible -i assignment1 all -m acl -a "path=/srv/projects/API entity=devops-team etype=group permissions=rwX state=present"
ansible -i assignment1 all -m acl -a "path=/srv/projects/API entity=dev-team etype=group permissions=rX state=present"
ansible -i assignment1 all -m acl -a "path=/srv/projects/API entity=admin-group etype=group permissions=rX state=present"

ansible -i assignment1 all -m acl -a "path=/srv/projects/Mobile entity=admin-group etype=group permissions=rwX state=present"
ansible -i assignment1 all -m acl -a "path=/srv/projects/Mobile entity=dev-team etype=group permissions=rX state=present"
ansible -i assignment1 all -m acl -a "path=/srv/projects/Mobile entity=devops-team etype=group permissions=rX state=present"

# Shared Resources: all teams rw
ansible -i assignment1 all -m acl -a "path=/srv/shared-resources entity=dev-team etype=group permissions=rwX state=present"
ansible -i assignment1 all -m acl -a "path=/srv/shared-resources entity=devops-team etype=group permissions=rwX state=present"
ansible -i assignment1 all -m acl -a "path=/srv/shared-resources entity=admin-group etype=group permissions=rwX state=present"

# Archive: read-only for all
ansible -i assignment1 all -m acl -a "path=/srv/archive entity=dev-team etype=group permissions=rX state=present"
ansible -i assignment1 all -m acl -a "path=/srv/archive entity=devops-team etype=group permissions=rX state=present"
ansible -i assignment1 all -m acl -a "path=/srv/archive entity=admin-group etype=group permissions=rX state=present"

