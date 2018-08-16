#!/bin/bash

# Startup Docker daemon
sudo service docker start

# Run the Docker image
"sudo docker run -d -p 80:${docker_container_port} ${docker_container_name}"
