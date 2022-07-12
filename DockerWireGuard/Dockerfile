FROM ghcr.io/k8s-at-home/wireguard:rolling
USER 0
RUN apt-get update && apt-get install unzip wget sudo && apt-get clean
WORKDIR /
#COPY manual-connections/* /manual-connections/ 
RUN wget https://github.com/pia-foss/manual-connections/archive/refs/heads/master.zip && unzip master.zip && mv manual-connections-master manual-connections

ADD patch.sh .
RUN ./patch.sh
RUN mv entrypoint.sh entrypoint-original.sh
ADD entrypoint.sh .
USER 0
ENTRYPOINT [ "/entrypoint.sh" ]