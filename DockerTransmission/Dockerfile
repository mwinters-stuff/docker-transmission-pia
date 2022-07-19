FROM ghcr.io/k8s-at-home/transmission:rolling
USER root
RUN apt-get -qq update && \
    apt-get upgrade -y && \
    apt-get install -y \
    bash \
    traceroute \
    curl \
    transmission-cli && apt-get clean
USER kah