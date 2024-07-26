#!/bin/bash

# load key value pairs from config file
source ../config/remote.properties
source ../.env

PUBLIC_KEY=$(cat $HOME/.ssh/id_rsa.pub)

# ask for user input to avoid password exposure in git
read -p "Please provide password for new user $SERVICE_USER_2: " SERVICE_USER_PW 

ssh $ROOT_USER@$REMOTE_ADDRESS_2 <<EOF
# reset prior user and the respective home folder
userdel -r $SERVICE_USER_2

#create new user
useradd -m $SERVICE_USER_2

# add sudo privileges to service user
sudo cat /etc/sudoers | grep $SERVICE_USER_2

if [ -z "\$( sudo cat /etc/sudoers | grep $SERVICE_USER_2 )" ]
then
  echo "$SERVICE_USER_2 ALL=(ALL:ALL) ALL" | sudo EDITOR="tee -a" visudo
  echo "$SERVICE_USER_2 added to sudoers file."
else 
  echo "$SERVICE_USER_2 found in sudoers file."
fi

echo "$SERVICE_USER_2:$SERVICE_USER_2_PW" | chpasswd

# switch to new user
su - $SERVICE_USER_2

# add public key to new user's authorized keys
mkdir .ssh
cd .ssh
touch authorized_keys
echo "created .ssh/authorized keys file"
echo "$PUBLIC_KEY" > authorized_keys
echo "added public key to authorized_keys file of new user."
EOF

# ssh into remote with newly created user to download and install NVM
ssh $SERVICE_USER_2@$REMOTE_ADDRESS_2 <<EOF
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
EOF

# restart ssh shell so newly added nvm command can be found
ssh $SERVICE_USER_2@$REMOTE_ADDRESS_2 <<EOF
#install node and npm
nvm install 22
echo "installed node in directory: 
\$(which node)"
echo "installed npm in directory:
\$(which npm)"

echo "npm version: \$(npm -v)"
echo "node version \$(node -v)"

NPM_PACKAGE_URL=\$(curl -s -u $NEXUS_USER_3_ID:$NEXUS_USER_3_PWD -X GET 'http://$REMOTE_ADDRESS:8081/service/rest/v1/components?repository=npm-hosted&sort=version' | jq --raw-output '.items[0].assets[0].downloadUrl' )

if [ -d deployment ]
then
  rm -Rf deployment
fi

mkdir deployment
cd deployment

# Download remote npm package
echo "Downloading \$NPM_PACKAGE_URL"
curl -O \$NPM_PACKAGE_URL
FILE_NAME=\$(ls)

# Extract Package
echo "Extracting \$FILE_NAME"
tar -xzvf \$FILE_NAME


if [ -d package ]
then 
  cd package
  echo "Installing Node dependencies."
  npm install
  echo "starting server.js"
  node server.js &
else 
  echo "Error downloading and unpacking node archive."
fi

# sleep so server can startup
sleep 3

# log running node process
echo "
RUNNING NODE PROCESS:"
ps aux | head -n 1
ps aux | grep server.js | grep node | grep -v grep

echo "
to shutdown the node server run 'kill PID'"

# log whatever is running on port 3000
echo "
PORT 3000 IS RUNNING:"
netstat -ltnp | grep 3000


EOF


