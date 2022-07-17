FROM ghcr.io/k8s-at-home/transmission:rolling
USER root
RUN apt-get -qq update && \
    apt-get install -y \
    bash \
    traceroute \
    transmission-cli && apt-get clean
USER kah