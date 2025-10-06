ansible db -i hosts.ini -u ec2-user -b -m yum -a "name=mariadb-server state=present"
ansible db -i hosts.ini -u ec2-user -b -m service -a "name=mariadb state=started enabled=yes"

#db for app 
ansible db -i hosts.ini -u ec2-user -b -m shell -a "mysql -e 'CREATE DATABASE IF NOT EXISTS springdb;'"

#jdk for app server
ansible app -i hosts.ini -u ec2-user -b -m yum -a "name=java-11-openjdk-devel state=present"

#maven installlation 
ansible app -i hosts.ini -u ec2-user -b -m yum -a "name=maven state=present"

#war file 
git clone https://github.com/opstree/spring3hibernate.git /tmp/spring3hibernate
cd /tmp/spring3hibernate
mvn clean package -DskipTests

#tom cat installation on server 
ansible app -i hosts.ini -u ec2-user -b -m yum -a "name=wget,tar state=present"

ansible app -i hosts.ini -u ec2-user -b -m shell -a "mkdir -p /opt/tomcat && cd /opt/tomcat && wget https://archive.apache.org/dist/tomcat/tomcat-7/v7.0.108/bin/apache-tomcat-7.0.108.tar.gz && tar xzf apache-tomcat-7.0.108.tar.gz"

ansible app -i hosts.ini -u ec2-user -b -m user -a "name=tomcat system=yes shell=/bin/false"

ansible app -i hosts.ini -u ec2-user -b -m file -a "path=/opt/tomcat/apache-tomcat-7.0.108 owner=tomcat group=tomcat recurse=yes state=directory"

#war copy to server 
ansible app -i hosts.ini -u ec2-user -b -m copy -a "src=/tmp/spring3hibernate/target/spring3hibernate.war dest=/opt/tomcat/apache-tomcat-7.0.108/webapps/spring3hibernate.war owner=tomcat group=tomcat mode=0644"




#system file for tomcat to control node 
[Unit]
Description=Apache Tomcat 7
After=network.target

[Service]
Type=forking
Environment=JAVA_HOME=/usr/lib/jvm/java-11-openjdk
Environment=CATALINA_PID=/opt/tomcat/apache-tomcat-7.0.108/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat/apache-tomcat-7.0.108
Environment=CATALINA_BASE=/opt/tomcat/apache-tomcat-7.0.108
ExecStart=/opt/tomcat/apache-tomcat-7.0.108/bin/startup.sh
ExecStop=/opt/tomcat/apache-tomcat-7.0.108/bin/shutdown.sh
User=tomcat
Group=tomcat
Restart=on-failure

[Install]
WantedBy=multi-user.target

#copy to server 
ansible app -i hosts.ini -u ec2-user -b -m copy -a "src=./tomcat.service dest=/etc/systemd/system/tomcat.service mode=0644"
ansible app -i hosts.ini -u ec2-user -b -m systemd -a "daemon_reload=yes"

#start and stop tomcat
ansible app -i hosts.ini -u ec2-user -b -m service -a "name=tomcat state=started enabled=yes"

#war update 
ansible app -i hosts.ini -u ec2-user -b -m service -a "name=tomcat state=restarted"

# app is available on http://<app-ec2-public-ip>:8080/spring3hibernate 
