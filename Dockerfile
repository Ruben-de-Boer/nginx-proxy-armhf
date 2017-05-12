FROM resin/armv7hf-debian-qemu:latest
# Default configuration
RUN [ "cross-build-start" ]

ENV GOPATH /opt/go
ENV DOCKER_GEN_VERSION 0.7.3

RUN echo "deb http://ftp.debian.org/debian jessie-backports main" > /etc/apt/sources.list.d/jessie-backports.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y git golang wget && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y -t jessie-backports nginx && \
    go get -u github.com/ddollar/forego && \
    cp $GOPATH/bin/* /usr/local/bin/ && \
    rm -rf $GOPATH && \
    wget https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-linux-armhf-$DOCKER_GEN_VERSION.tar.gz && \
    tar -C /usr/local/bin -xvzf docker-gen-linux-armhf-$DOCKER_GEN_VERSION.tar.gz && \
    rm /docker-gen-linux-armhf-$DOCKER_GEN_VERSION.tar.gz && \
    apt-get purge --auto-remove -y git golang wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /etc/apt/sources.list.d/jessie-backports.list

RUN echo "daemon off;" >>/etc/nginx/nginx.conf

RUN [ "cross-build-end" ]

COPY . /app/
WORKDIR /app/

ENV DOCKER_HOST unix:///tmp/docker.sock

VOLUME ["/etc/nginx/certs"]

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["forego", "start", "-r"]
