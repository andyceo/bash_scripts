#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
import sys
import json
import yaml
import requests
from urllib.parse import urlparse
from colors import color
from jsonschema.exceptions import RefResolutionError
from openapi_spec_validator import openapi_v3_spec_validator
from openapi_spec_validator.handlers import UrlHandler

from openapi_core import create_spec
from openapi_core.validators import RequestValidator, ResponseValidator

from classes import RequestsOpenAPIRequest, RequestsOpenAPIResponse


def validate_specification(url):
    """This function validates specification file (usually openapi.yaml) or url"""

    counter = 0

    try:
        handler = UrlHandler('http', 'https', 'file')

        if not urlparse(url).scheme:
            url = 'file://' + os.path.join(os.getcwd(), url)

        spec = handler(url)

        for i in openapi_v3_spec_validator.iter_errors(spec, spec_url=url):
            counter += 1
            print_error(counter, ':'.join(i.absolute_path), i.message, i.instance)

    except RefResolutionError as e:
        counter += 1
        print_error(counter, '', 'Unable to resolve {} in {}'.format(e.__context__.args[0], e.args[0]), '')

    except BaseException:
        counter += 1
        print_error(counter, '', sys.exc_info()[0], '')

    finally:
        if counter > 0:
            print()
            print(color(' [FAIL] {:d} errors found '.format(counter), fg='white', bg='red', style='bold'))
            return 1
        else:
            print(color(' [PASS] No errors found ', fg='white', bg='green', style='bold'))
            return 0


def validate_requests_and_responses(openapi_file):
    with open(openapi_file, 'r') as myfile:
        spec_dict = yaml.safe_load(myfile)
        spec = create_spec(spec_dict)
        server_url = 'http://127.0.0.1:8080'
        total_errors_count = 0

        parameters = {
            'get': {
                'count': 2,
                'length': 123,
                'blockHeight': 20,
                'headerId': 'Ebo1riBazi8JpvmtqFnkbyhK29P8KXPawiTVyVFgAqhY',
            },
            'post': {
                # '/blocks': None,
                # '/transactions': None,
                '/peers/connect': '127.0.0.1:5673',
                # '/utils/hash/blake2b': '123qwe'
            }
        }

        for path, path_object in spec.paths.items():
            for method, operation in path_object.operations.items():

                if '{' not in path:
                    print('{} {}'.format(method.upper(), path))
                    new_path = path
                    path_pattern = None
                    path_params = {}
                else:
                    parameter_start = path.find('{')
                    parameter_end = path.find('}')
                    parameter = path[parameter_start + 1:parameter_end]
                    new_path = path[:parameter_start] + str(parameters['get'][parameter]) + path[parameter_end + 1:]
                    print('{} {} -> {}'.format(method.upper(), path, new_path))
                    path_pattern = path
                    path_params = {parameter: parameters['get'][parameter]}

                if method == 'get':
                    req = requests.Request('GET', server_url + new_path)
                elif method == 'post':
                    if new_path in parameters['post'] and parameters['post'][new_path]:
                        req = requests.Request('POST', server_url + new_path,
                                               data=json.dumps(parameters['post'][new_path]),
                                               headers={'content-type': 'application/json'})
                    else:
                        print('Skipping, POST method has no example payload to test')
                        print()
                        continue
                else:
                    print('Skipping, no GET or POST methods for this path')
                    print()
                    continue

                openapi_request = RequestsOpenAPIRequest(req, path_pattern, path_params)
                validator = RequestValidator(spec)
                result = validator.validate(openapi_request)
                request_errors = result.errors

                r = req.prepare()
                s = requests.Session()
                res = s.send(r)

                openapi_response = RequestsOpenAPIResponse(res)
                validator = ResponseValidator(spec)
                result = validator.validate(openapi_request, openapi_response)
                response_errors = result.errors

                print('Request errors: {} Response errors: {}'.format(request_errors, response_errors))
                if request_errors or response_errors:
                    errors_count = len(request_errors) + len(response_errors)
                    total_errors_count += errors_count
                    print(color(' [FAIL] {:d} errors found '.format(errors_count), fg='white', bg='red', style='bold'))
                    print("Response body: {}".format(res.text))
                else:
                    print(color(' [PASS] No errors found ', fg='white', bg='green', style='bold'))
                print()

        if total_errors_count:
            print()
            print(color(' [FAIL] Total {:d} errors found '.format(total_errors_count), fg='white', bg='red',
                        style='bold'))
            return 1
        else:
            return 0


def print_error(count, path, message, instance):
    print()
    print(color('Error #{:d} in [{}]:'.format(count, path or 'unknown'), style='bold'))
    print("    {}".format(message))
    print("    {}".format(instance))


def help():
    print('usage: ' + os.path.basename(__file__) + ' <spec_url_or_path>')


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print('Invalid usage!')
        print("Specify path to openapi.yaml file!")
        help()
        exit(10)
    else:
        print(color('Validating specification file...', style='bold', bg='cyan', fg='white'))
        spec_errors_count = validate_specification(sys.argv[1])

        print()
        print()
        print(color('Validating requests and responses...', style='bold', bg='cyan', fg='white'))
        rr_errors_count = validate_requests_and_responses(sys.argv[1])

        exit(spec_errors_count + rr_errors_count)
