FROM neo4j:3.5.13

ENV BOTO3 1.17.102
ENV AWSCLI 1.19.102
ENV NEO4J 4.3.1

COPY . /opt/awspx
COPY startup.sh /
WORKDIR /opt/awspx

ENV NEO4J_AUTH=neo4j/password
ENV EXTENSION_SCRIPT=/opt/awspx/INSTALL

RUN apt -y update && apt install -y \
        awscli \
        nodejs \
        npm \
        python3-pip \
        procps \
        nano \
        git \ 
    && rm -rf /var/lib/apt/lists/* \
    && pip3 install --upgrade \
        argparse \
        awscli==${AWSCLI} \
        boto3==${BOTO3} \
        configparser \
        git-python \
        neo4j==${NEO4J} \
        rich \
    && npm install -g npm@latest 

RUN cd /opt/awspx/www && npm install 

VOLUME /opt/awspx/data
EXPOSE 7373 7474 7687 80

# Disgusting hack - because i cant see where else to change the `lib/aws/ingestor.py` code...
RUN sed -i '260s@endpoint_url=endpoint_url@endpoint_url="http://localstack:4566"@' /usr/local/lib/python3.7/dist-packages/boto3/session.py

ENTRYPOINT [ "/startup.sh" ]
