## About

This utility can listen webhooks from Docker Hub and (re)deploy services and stacks on webhook call.


## Configuration

See `config-sample.json` to view sample configuration.

See Dockerfile label `run` to view example docker run command.


## Volumes

- config.json
- docker stacks directory (if you use stack deploys)
- docker.sock
