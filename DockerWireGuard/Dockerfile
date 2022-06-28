FROM ghcr.io/k8s-at-home/wireguard:rolling
USER root
RUN apt-get update && apt-get install unzip wget && apt-get clean
WORKDIR /
#COPY manual-connections/* /manual-connections/ 
RUN wget https://github.com/pia-foss/manual-connections/archive/refs/heads/master.zip && unzip master.zip && mv manual-connections-master manual-connections

ADD patch.sh .
RUN ./patch.sh
WORKDIR /manual-connections
USER kah