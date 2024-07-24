#!/bin/bash

# load key value pairs from java.config
source ../config/remote.properties

PUBLIC_KEY=$(cat $HOME/.ssh/id_rsa.pub)

# ask for user input to avoid password exposure in git
read -p "Please provide password for new user $SERVICE_USER: " SERVICE_USER_PW 

ssh $ROOT_USER@$REMOTE_ADDRESS <<EOF
# reset prior user and the respective home folder
userdel -r $SERVICE_USER

#create new user
useradd -m $SERVICE_USER

# add sudo privileges to service user
sudo cat /etc/sudoers | grep $SERVICE_USER

if [ -z "\$( sudo cat /etc/sudoers | grep $SERVICE_USER )" ]
then
  echo "$SERVICE_USER ALL=(ALL:ALL) ALL" | sudo EDITOR="tee -a" visudo
  echo "$SERVICE_USER added to sudoers file."
else 
  echo "$SERVICE_USER found in sudoers file."
fi

echo "$SERVICE_USER:$SERVICE_USER_PW" | chpasswd

# switch to new user
su - $SERVICE_USER

# add public key to new user's authorized keys
mkdir .ssh
cd .ssh
touch authorized_keys
echo "created .ssh/authorized keys file"
echo "$PUBLIC_KEY" > authorized_keys
echo "added public key to authorized_keys file of new user."
EOF

# ssh into remote with newly created user to download Java and Gradle 
ssh $SERVICE_USER@$REMOTE_ADDRESS <<EOF
echo "$SERVICE_USER_PW" | sudo -S apt-get install -y openjdk-11-jre-headless 
which_java=\$(which java)
installations=\$(java --version)

if [ -z "\$installations" ] || [ -z "\$which_java" ]
  then
    is_java_installed=false
  else
    is_java_installed=true
fi

if [ "\$is_java_installed" = true ]
  then
    echo "java install path: \$which_java"
    echo -e "installed java versions: \n\$installations"
  else
    echo "no java version installed"
fi

#head -n 1: Takes the first line of input
#awk -F '"' '{print \$2}': Splits Input by double quote character and prints the second field
java_version_num=\$(java -version 2>&1 | grep -i version | head -n 1 | awk -F '"' '{print \$2}')

#awk -F '.' '{print \$1}': splits the input by dots and prints the first field
java_major_version=\$( echo \$java_version_num | awk -F '.' '{print \$1}' )

if [ ! -z "\$java_major_version" ] && [ "\$java_major_version" -eq 11 ]
  then
    installation_successful=true
    echo "Java Installation Successful."
    echo "java major version: \$java_major_version"
  else
    installation_successful=false
    echo "Installation error. Java Major Version installed is not Version 11."
fi

EOF

# pull, extract and change permissions of sonatype nexus
ssh $ROOT_USER@$REMOTE_ADDRESS <<EOF
cd /opt
if [ ! -f nexus-3.70.1-02-java11-unix.tar.gz ]
then
  echo "Downloading nexus repo archive"  
  wget https://download.sonatype.com/nexus/3/nexus-3.70.1-02-java11-unix.tar.gz 
else
  echo "Nexus Repo Archive found. Download skipped"
fi

if [ ! -d nexus-3.70.1-02 ]
then
  echo "Extracting Nexux Repo Archive"
  tar -xvzf nexus-3.70.1-02-java11-unix.tar.gz  
else 
  echo "Nexus Repo Directory found. Extraction skipped"
fi

chown -R $SERVICE_USER:$SERVICE_USER nexus-3.70.1-02 
chown -R $SERVICE_USER:$SERVICE_USER sonatype-work
EOF

# Start nexus server
ssh $SERVICE_USER@$REMOTE_ADDRESS <<EOF
/opt/nexus-3.70.1-02/bin/nexus start

# wait for startup
sleep 5

# log running NEXUS process
echo "
RUNNING NEXUS PROCESS:"
ps aux | head -n 1
ps aux | grep nexus | grep -v grep 

echo "
to shutdown the NEXUS server run 'kill PID'"

# log whatever is running on port 8081 
echo "
PORT 8081 IS RUNNING:"
echo "$SERVICE_USER_PW" | sudo -S netstat -ltnp | grep :8081 

EOF

