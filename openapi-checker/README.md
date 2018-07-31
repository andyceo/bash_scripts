This project aimed to validate OpenAPI 3+ specification file and also check and validate REST API requests and responses that must fit given specification file.


## Installation and usage

### Usage on raw system

You should have Python 3 and `pip` utility installed on your system.

To be able to execute `openapi-checker.py` script on your system, just install needed packages with pip:

    pip install -r requirements.txt

And after that you can check your OpenAPI:

    /path/to/openapi-checker https://raw.githubusercontent.com/OAI/OpenAPI-Specification/master/examples/v3.0/petstore.yaml --api http://127.0.0.1:8080


### Usage with Docker

#### Build Docker image

    sudo docker build -t openapi-checker:latest .

You can use this image from Docker Hub: [andyceo/openapi-checker](https://hub.docker.com/r/andyceo/openapi-checker)

#### Use OpenAPI checker with Docker

Check specification integrity only, specification located on URL:

    sudo docker run --rm andyceo/openapi-checker https://raw.githubusercontent.com/OAI/OpenAPI-Specification/master/examples/v3.0/petstore.yaml

Check specification integrity (local file) and requests and responses of implemented API (URL):

    sudo docker run --rm -v /path/to/openapi.yaml:/app/openapi.yaml andyceo/openapi-checker openapi.yaml --api http://127.0.0.1:81
