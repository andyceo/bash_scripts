## Message syntax

    COMMAND ARG_1 [ARG_2 ... [ARG_N]]


## Supported commands

- `run TAG`

    Need redesign and fixes, so no implemented by now.

- `service-update SERVICE_NAME IMAGE[:TAG]`

    Not implemented by now.

    Both SERVICE_NAME and IMAGE must be specified. If TAG is not set, `latest` is used.

- `stack-deploy STACK FILEPATH`

    (Re)deploy stack STACK with given `.yml` stack definition.
