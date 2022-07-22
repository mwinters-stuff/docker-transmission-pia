FROM ghcr.io/k8s-at-home/wireguard:rolling
USER 0
RUN apt-get update && \
  apt-get upgrade -y && \
  apt-get -y install \
    unzip \
    wget \
    sudo \
    traceroute && \ 
    apt-get clean
    
WORKDIR /
#COPY manual-connections/* /manual-connections/ 
RUN wget https://github.com/pia-foss/manual-connections/archive/refs/heads/master.zip && unzip master.zip && mv manual-connections-master manual-connections
RUN echo "kah  ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

ADD patch.sh .
RUN ./patch.sh

RUN mv entrypoint.sh entrypoint-original.sh
ADD entrypoint.sh .
ENTRYPOINT [ "/entrypoint.sh" ]