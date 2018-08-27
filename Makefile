PACKER_CONFIG_FILE=variables.json

ami:
	cd packer; packer build -var-file=${PACKER_CONFIG_FILE} template.json | tee build.log; cd ..;
fetchami:
	awk 'match($$0, /ami-.*/) { x = substr($$0, RSTART, RLENGTH) } END { print x }' build.log > ami_id
