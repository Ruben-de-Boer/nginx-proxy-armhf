FROM resin/armv7hf-debian-qemu:latest
# Default configuration
RUN [ "cross-build-start" ]

ENV GOPATH /opt/go
ENV PATH $PATH:$GOPATH/bin
ENV DOCKER_GEN_VERSION 0.7.3

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y git golang nginx wget && \
    wget http://nginx.org/keys/nginx_signing.key && \
    apt-key add nginx_signing.key && \
    rm nginx_signing.key && \
    echo "deb http://nginx.org/packages/debian/ jessie nginx" > /etc/apt/sources.list.d/nginx.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y nginx && \
    go get -u github.com/ddollar/forego && \
    wget https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-linux-armhf-$DOCKER_GEN_VERSION.tar.gz && \
    tar -C /usr/local/bin -xvzf docker-gen-linux-armhf-$DOCKER_GEN_VERSION.tar.gz && \
    rm /docker-gen-linux-armhf-$DOCKER_GEN_VERSION.tar.gz && \
    apt-get purge --auto-remove -y git golang wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /etc/apt/sources.list.d/nginx.list

RUN echo "daemon off;" >>/etc/nginx/nginx.conf

RUN [ "cross-build-end" ]

COPY . /app/
WORKDIR /app/

ENV DOCKER_HOST unix:///tmp/docker.sock

VOLUME ["/etc/nginx/certs"]

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["forego", "start", "-r"]
