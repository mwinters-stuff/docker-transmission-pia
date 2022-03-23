FROM  ghcr.io/linuxserver/transmission:latest

RUN apk update && \
    apk add --no-cache \
    bash \
    ca-certificates \
    curl \
    iptables \
    jq \
    git \
    openssl \
    wireguard-tools \
    iproute2 \
    ncurses \
    net-tools \
    py3-pip 
    

RUN \
  pip install https://github.com/mwinters-stuff/mnamer/archive/refs/heads/master.zip

RUN \  
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    /var/tmp/* 

WORKDIR /
#COPY manual-connections/* /manual-connections/ 
RUN git clone --depth=1 https://github.com/pia-foss/manual-connections.git
ADD patch.sh .
RUN ./patch.sh
WORKDIR /manual-connections
COPY root/ /

