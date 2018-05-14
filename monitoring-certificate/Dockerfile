FROM andyceo/pylibs
COPY ["monitoring-certificate.py", "requirements.txt", "/app/"]
RUN pip3 install -r requirements.txt && rm requirements.txt
ENTRYPOINT ["/app/monitoring-certificate.py"]
CMD []
