"""OpenAPI Checker classes"""
from urllib.parse import urlparse, parse_qsl
from openapi_core.wrappers.base import BaseOpenAPIRequest, BaseOpenAPIResponse
from werkzeug.datastructures import ImmutableMultiDict


class RequestsOpenAPIRequest(BaseOpenAPIRequest):
    def __init__(self, request, path_pattern=None, path_params=None):
        self.request = request
        self.url = urlparse(request.url)
        self._path_pattern = path_pattern
        self._path_params = {} if path_params is None else path_params

    @property
    def host_url(self):
        return self.url.scheme + '://' + self.url.netloc

    @property
    def path(self):
        return self.url.path

    @property
    def method(self):
        return self.request.method.lower()

    @property
    def path_pattern(self):
        if self._path_pattern is None:
            return self.url.path

        return self._path_pattern

    @property
    def parameters(self):
        return {
            'path': self._path_params,
            'query': ImmutableMultiDict(parse_qsl(self.url.query)),
            'headers': self.request.headers,
            'cookies': self.request.cookies,
        }

    @property
    def body(self):
        return self.request.data

    @property
    def mimetype(self):
        return self.request.headers.get('content-type')


class RequestsOpenAPIResponse(BaseOpenAPIResponse):

    def __init__(self, response):
        self.response = response

    @property
    def data(self):
        return self.response.text

    @property
    def status_code(self):
        return self.response.status_code

    @property
    def mimetype(self):
        return self.response.headers.get('content-type')
