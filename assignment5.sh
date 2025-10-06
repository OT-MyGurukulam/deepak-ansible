[amazon]
51.21.253.249 ansible_user=ec2-user ansible_ssh_private_key_file=/home/deepakkumartiwari/Downloads/ping.pem

[all:vars]
ansible_python_interpreter=/usr/bin/python3

#jinja
# Apache Config managed by Ansible

Listen {{ apache_port }}

<VirtualHost *:{{ apache_port }}>
    DocumentRoot {{ apache_docroot }}
    <Directory {{ apache_docroot }}>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>

#playbook
- name: Install & Configure Apache on Amazon Linux
  hosts: amazon
  become: yes
  vars:
    apache_version: "{{ apache_version | default('latest') }}"
    apache_port: "{{ apache_port | default(8080) }}"
    apache_docroot: /var/www/html

  tasks:
    - name: Install Apache
      yum:
        name: "{{ 'httpd-' + apache_version if apache_version != 'latest' else 'httpd' }}"
        state: present
      notify: restart apache

    - name: Ensure docroot exists
      file:
        path: "{{ apache_docroot }}"
        state: directory
        mode: '0755'

    - name: Deploy Apache configuration
      template:
        src: apache.conf.j2
        dest: /etc/httpd/conf/httpd.conf
      notify: restart apache

  handlers:
    - name: restart apache
      service:
        name: httpd
        state: restarted
        enabled: yes


#playbook running 
ansible-playbook -i inventory.ini site.yml -e "apache_port=9090"

#http://51.21.253.249:8080

