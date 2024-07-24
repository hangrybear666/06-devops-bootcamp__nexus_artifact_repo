#!/bin/bash

# load key value pairs from config file
source "../config/local.properties"

if [ -z "$( which node )" ]
then
  echo "Please install node and npm."
  exit 1
fi


cd $GIT_DIRECTORY
cd cloud-basics-exercises/app
npm pack

# check if file was created
if [ ! -f bootcamp-node-project-1.0.0.tgz ]
then
  echo "Packed file not found locally. Something went wrong."
  exit 1
fi

ls

