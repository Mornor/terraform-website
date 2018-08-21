PACKER_CONFIG_FILE=variables-prod.json

ami:
	cd packer; packer build -var-file=${PACKER_CONFIG_FILE} template.json | tee build.log; cd ..;
fetchami:
	echo "$(tail -2 build.log | head -2 | awk 'match($0, /ami-.*/) { print substr($0, RSTART, RLENGTH) }')" > ami_id
