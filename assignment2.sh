###############################
# 0. Check connectivity
###############################
ansible web01 -i inventory -m ping
ansible web02 -i inventory -m ping

###############################
# 1. Install Nginx + Apache
###############################
ansible web01,web02 -i inventory -b -m yum -a "name=nginx state=present"
ansible web01,web02 -i inventory -b -m yum -a "name=httpd state=present"
ansible web01,web02 -i inventory -b -m service -a "name=nginx state=started enabled=yes"
ansible web01,web02 -i inventory -b -m service -a "name=httpd state=started enabled=yes"

###############################
# 2. Nginx log rotation (1 GB)
###############################
ansible web01,web02 -i inventory -b -m copy -a "dest=/etc/logrotate.d/nginx content='/var/log/nginx/*.log {\n size 1G\n rotate 5\n compress\n missingok\n notifempty\n create 0640 nginx adm\n sharedscripts\n postrotate\n systemctl reload nginx > /dev/null 2>&1 || true\n endscript\n}\n'"

###############################
# 3. Create websites
###############################
ansible web01,web02 -i inventory -b -m copy -a "dest=/var/www/tanya/index.html content='<h1>Tanya Website</h1>'"
ansible web01,web02 -i inventory -b -m copy -a "dest=/var/www/heena/index.html content='<h1>Heena Website</h1>'"

###############################
# 4. Setup site switching every 2 hrs
###############################
ansible web01,web02 -i inventory -b -m cron -a "name='Switch to Tanya site' minute=0 hour='*/4' job='ln -sf /var/www/tanya/index.html /var/www/html/index.html && systemctl reload nginx'"
ansible web01,web02 -i inventory -b -m cron -a "name='Switch to Heena site' minute=0 hour='2-23/4' job='ln -sf /var/www/heena/index.html /var/www/html/index.html && systemctl reload nginx'"

###############################
# 5. Nginx reverse proxy config
###############################
ansible web01,web02 -i inventory -b -m copy -a "dest=/etc/nginx/conf.d/opstree.conf content='server {\n listen 80;\n server_name team.opstree.com;\n root /var/www/html;\n index index.html;\n location /Spring3HibernateApp {\n proxy_pass http://127.0.0.1:8080/Spring3HibernateApp;\n proxy_set_header Host \$host;\n proxy_set_header X-Real-IP \$remote_addr;\n }\n location / {\n root /var/www/html;\n index index.html;\n }\n}'"
ansible web01,web02 -i inventory -b -m service -a "name=nginx state=reloaded"

###############################
# 6. Install MySQL + JDK 11 + Maven + Git
###############################
ansible web01 -i inventory -b -m yum -a "name=mysql-server state=present"
ansible web01 -i inventory -b -m yum -a "name=git state=present"
ansible web01 -i inventory -b -m yum -a "name=maven state=present"
ansible web01 -i inventory -b -m amazon-linux-extras -a "name=java-openjdk11 enable=yes"
ansible web01 -i inventory -b -m yum -a "name=java-11-openjdk-devel state=present"
ansible web01 -i inventory -b -m service -a "name=mysqld state=started enabled=yes"

###############################
# 7. MySQL DB + user for app
###############################
ansible web01 -i inventory -b -m mysql_db -a "name=spring3hibernate state=present"
ansible web01 -i inventory -b -m mysql_user -a "name=springuser password=Password123 priv='spring3hibernate.*:ALL' state=present"

###############################
# 8. Clone + Build Spring3HibernateApp
###############################
ansible web01 -i inventory -b -m git -a "repo=https://github.com/opstree/spring3hibernate.git dest=/opt/spring3hibernate"
ansible web01 -i inventory -b -m shell -a "cd /opt/spring3hibernate && mvn clean package"

###############################
# 9. Install Tomcat 7
###############################
ansible web01 -i inventory -b -m get_url -a "url=https://dlcdn.apache.org/tomcat/tomcat-7/v7.0.108/bin/apache-tomcat-7.0.108.tar.gz dest=/tmp/tomcat7.tar.gz"
ansible web01 -i inventory -b -m unarchive -a "src=/tmp/tomcat7.tar.gz dest=/opt/ remote_src=yes"
ansible web01 -i inventory -b -m file -a "src=/opt/apache-tomcat-7.0.108 path=/opt/tomcat state=link"

###############################
# 10. Create systemd service for Tomcat
###############################
ansible web01 -i inventory -b -m copy -a "dest=/etc/systemd/system/tomcat.service content='[Unit]\nDescription=Apache Tomcat Web Application Container\nAfter=network.target\n\n[Service]\nType=forking\nExecStart=/opt/tomcat/bin/startup.sh\nExecStop=/opt/tomcat/bin/shutdown.sh\nUser=root\nGroup=root\nRestart=on-failure\n\n[Install]\nWantedBy=multi-user.target\n'"
ansible web01 -i inventory -b -m shell -a "systemctl daemon-reload"
ansible web01 -i inventory -b -m service -a "name=tomcat state=started enabled=yes"

###############################
# 11. Deploy WAR
###############################
ansible web01 -i inventory -b -m copy -a "src=/opt/spring3hibernate/target/Spring3HibernateApp.war dest=/opt/tomcat/webapps/Spring3HibernateApp.war remote_src=yes"
ansible web01 -i inventory -b -m service -a "name=tomcat state=restarted"

###############################
# 12. Validation
###############################
ansible web01 -i inventory -m uri -a "url=http://localhost:8080/Spring3HibernateApp return_content=yes"
ansible web01 -i inventory -m uri -a "url=http://team.opstree.com/Spring3HibernateApp return_content=yes"
