FROM node:10-alpine
LABEL maintainer="Andrey Andreev <andyceo@yandex.ru> (@andyceo)"
LABEL run="docker run --rm -p 8130:8130 -v /data/stacks:/data/stacks -v /path/to/config.json:/app/config.json andyceo/dockerhub-webhooks"
RUN sed -i 's/3.7/3.8/g' /etc/apk/repositories && \
    apk add --update --no-cache docker && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*
WORKDIR /app
COPY index.js config-sample.json package.json /app/
EXPOSE 8130
CMD ["node", "/app/index.js"]
