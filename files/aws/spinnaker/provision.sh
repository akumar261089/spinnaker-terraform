	#!/bin/sh

   ## Installing  Minio for storage
	wget https://dl.minio.io/server/minio/release/linux-amd64/minio

	chmod +x minio
	sudo mkdir -p /minio/data
	sudo ./minio server --address 0.0.0.0:9001  /minio/data/ &
    wget https://dl.minio.io/client/mc/release/linux-amd64/mc
    chmod +x mc
	##Need to fetch credentials from .minio/config.json
	export accessKey=`sudo cat .minio/config.json  |  grep accessKey | cut -d\" -f4`
	export secretKey=`sudo cat .minio/config.json  |  grep secretKey | cut -d\" -f4`
    ./mc config host add minio http://127.0.0.1:9001 $accessKey $secretKey
    ./mc mb minio/spinnaker


	##Halyard Installation
	curl -O https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh

	sudo bash InstallHalyard.sh

	## Environment selecion
	hal config deploy edit --type localdebian
    ## configure version
    hal config version edit --version 1.6.0	
	## configuring storage

	echo $secretKey | hal config storage  s3 edit --bucket minio/spinnaker --endpoint http://127.0.0.1:9001 --access-key-id $accessKey   --secret-access-key 
	hal config storage edit --type s3

    ## config  AWS
	echo $6 | hal config provider aws edit --access-key-id $5   --secret-access-key 
    hal config provider aws enable
	##configure jenkins

	hal config ci jenkins enable

	echo $4 | hal config ci jenkins master add my-jenkins-master \
	    --address http://jenkins.$2:8000 \
	    --username $3 \
	    --password

	##
	sudo hal deploy apply

	hal deploy connect


