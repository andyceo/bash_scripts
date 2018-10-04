This project aimed to validate [OpenAPI 3+](https://github.com/OAI/OpenAPI-Specification) specification file and also check and validate REST API requests and responses that must fit given specification file.

Base used core library is Python 3 [openapi-core](https://github.com/p1c2u/openapi-core).

## Features

- Validate OpenAPI specification file by passed url or file path (with [openapi-spec-validator](https://github.com/p1c2u/openapi-spec-validator) library)
- Inspect given OpenAPI specification file, find routes and create request on this routes (with [Requests](http://docs.python-requests.org/) library)
- If optional `--parameters` is given, then substitute path parameters (path parts in {curly} brackets), GET parameters (url part after `?` sign), POST payload (request body) in requests and test specific url with given parameters. Multiple sets of parameters for one path are supported, please see [openapi-checker](openapi-checker/parameters-sample.yaml) file for examples and description
- Send constructed requests to given API (`--api` cli parameter), receive responses and validate that both requests and responses are fits with given OpenAPI specification file
- @todo: add support for responses - test that specific API route either returns correct data, not only some data of correct structure


## Installation and usage

### Usage with Docker

#### Use OpenAPI checker with Docker

Check specification integrity only, specification located on URL:

    sudo docker run --rm andyceo/openapi-checker https://raw.githubusercontent.com/OAI/OpenAPI-Specification/master/examples/v3.0/petstore.yaml

Check specification integrity (local file) and requests and responses of implemented API (URL):

    sudo docker run --rm -v /path/to/openapi.yaml:/app/openapi.yaml andyceo/openapi-checker openapi.yaml --api http://127.0.0.1:81

Check specification integrity (local file) and requests and responses of an implemented API (URL), substitute parameters in specification with values given in `parameters.yml` local file:

    sudo docker run --rm \
        -v /path/to/openapi.yaml:/app/openapi.yaml \
        -v /path/to/parameters.yaml:/app/parameters.yaml \
        andyceo/openapi-checker openapi.yaml --api http://127.0.0.1:81 --parameters parameters.yaml

#### Build Docker image

    sudo docker build -t openapi-checker:latest .

You can use this image from Docker Hub: [andyceo/openapi-checker](https://hub.docker.com/r/andyceo/openapi-checker)


### Usage on raw system

You should have Python 3 and `pip` utility installed on your system.

To be able to execute `openapi-checker.py` script on your system, just install needed packages with pip:

    pip install -r requirements.txt

And after that you can check your OpenAPI:

    /path/to/openapi-checker https://raw.githubusercontent.com/OAI/OpenAPI-Specification/master/examples/v3.0/petstore.yaml --api http://127.0.0.1:8080
