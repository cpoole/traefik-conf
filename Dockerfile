FROM alpine:3.4
MAINTAINER Connor Poole <connor.poole@daqri.com>

ENV CONFD_VERSION=v0.12.0-alpha3 \
    CONFD_HOME=/opt/tools/confd \
    GOMAXPROCS=2 \
    GOROOT=/usr/lib/go \
    GOPATH=/opt/src \
    GOBIN=/gopath/bin \
    BASE_DIR=/opt/tools \
    PATH=$PATH:/opt/tools/confd/bin

RUN apk add --update go git bash fping gcc musl-dev make openssl-dev \
  && mkdir -p /opt/src; cd /opt/src \
  && mkdir -p ${BASE_DIR}/monit/conf.d ${BASE_DIR}/scripts ${CONFD_HOME}/etc/templates ${CONFD_HOME}/etc/conf.d ${CONFD_HOME}/bin ${CONFD_HOME}/log \
  && git clone -b "$CONFD_VERSION" https://github.com/kelseyhightower/confd.git \
  && cd $GOPATH/confd \
  && ln -s vendor src \
  && ln -s $GOPATH/confd $GOPATH/confd/src/github.com/kelseyhightower/confd \
  && GOPATH=$GOPATH/confd/vendor:$GOPATH/confd CGO_ENABLED=0 go build -v -installsuffix cgo -ldflags '-extld ld -extldflags -static' -a -x . \
  && mv ./confd ${CONFD_HOME}/bin/ \
  && chmod +x ${CONFD_HOME}/bin/confd \
  && cd ${BASE_DIR} && tar czvf ../tools.tgz * \
  && apk del go git gcc musl-dev make openssl-dev \
  && rm -rf /var/cache/apk/* /opt/src 
  
 # $BASE_DIR/*

COPY ./opt /opt/
ADD ./traefikfiles /etc/traefik/
ADD ./init /init
VOLUME /etc/traefik
ENTRYPOINT ["/init"]
