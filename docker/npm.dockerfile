FROM node:18-alpine

ENV NPMUSER=laravel
ENV NPMGROUP=laravel

RUN apk add --update python3 make libtool gcc g++
RUN adduser -g ${NPMGROUP} -s /bin/sh/ -D ${NPMUSER}

ENTRYPOINT ["/usr/local/bin/npm"]
