## Message syntax

    COMMAND ARG_1 [ARG_2 ... [ARG_N]]

## Supported commands

- run TAG
- service-update SERVICE_NAME IMAGE[:TAG]

    Both SERVICE_NAME and IMAGE must be specified. If TAG is not set, `latest` is used.
