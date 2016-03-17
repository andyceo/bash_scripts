#!/usr/bin/env bash

# Do not forget to add your private registry address to the docker daemon start options, if your docker registry is
# unsecure! See: https://docs.docker.com/registry/insecure/
# Do not forget to change your registry address and images list!

REGISTRY=example.com:5000
IMAGES="private_image:1.1 another_private_image:1.1 some_project/some_private_image:1.7"

for IMAGE in $IMAGES
do
    docker push $REGISTRY/$IMAGE
done
