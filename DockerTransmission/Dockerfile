FROM ghcr.io/k8s-at-home/transmission:rolling
USER root
RUN apt-get -qq update && \
    apt-get install -y \
    bash \
    ca-certificates \
    curl \
    jq \
    python3-pip \
    traceroute
    

RUN \
  pip install https://github.com/mwinters-stuff/mnamer/archive/refs/heads/master.zip

RUN \  
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    /var/tmp/* 

USER kah