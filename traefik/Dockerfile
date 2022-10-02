ARG TRAEFIK_BASE=v2.6.1
# build and install dockerize to the current proper architecture
FROM golang:1.17.5-alpine3.15 AS dependencies
RUN apk add --no-cache --upgrade git openssl

WORKDIR /go/src/github.com/jwilder/dockerize
ENV GO111MODULE=on

RUN set -ex; \
    git clone https://github.com/jwilder/dockerize.git . ;\
    go mod tidy ;\
    go install


FROM traefik:${TRAEFIK_BASE}
LABEL maintainer="daniel.porto@gmail.com"

# install dockerize
COPY --from=dependencies /go/bin/dockerize /usr/local/bin

# fix vulnerability  https://snyk.io/vuln/SNYK-ALPINE311-APKTOOLS-1534687
RUN apk add --no-cache --upgrade apk-tools

COPY ./entrypoint-dockerize.sh /entrypoint-dockerize.sh
RUN chmod +x entrypoint-dockerize.sh

COPY ./traefik.tmpl /etc/traefik/traefik.tmpl
COPY ./dynamic.tmpl /etc/traefik/dynamic.tmpl

ENTRYPOINT ["/entrypoint-dockerize.sh"]