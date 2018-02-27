#!/bin/sh

##Halyard Installation
curl -O https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh

sudo bash InstallHalyard.sh

## Environment selecion
hal config deploy edit --type localdebian

## Installing  Minio for storage
wget https://dl.minio.io/server/minio/release/linux-amd64/minio

chmod +x minio
sudo mkdir -p /minio/data
sudo ./minio server --address 0.0.0.0:9001  /minio/data/ &

##Need to fetch credentials from .minio/config.json
accessKey=`cat .minio/config.json  |  grep accessKey | cut -d\" -f4`
secretKey=`cat .minio/config.json  |  grep secretKey | cut -d\" -f4`

## configuring storage
hal config storage edit --type s3

echo $secretKey | hal config provider aws edit --access-key-id $accessKey   --secret-access-key 
##version seletion
hal config version edit --version 1.6.0
##configure jenkins

hal config ci jenkins enable

echo $4 | hal config ci jenkins master add my-jenkins-master \
    --address http://jenkins.$2:8000 \
    --username $3 \
    --password

##
hal deploy apply

hal deploy connect


