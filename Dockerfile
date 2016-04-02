FROM ubuntu:14.04
MAINTAINER V Lall
LABEL Description="Dockerfile for bitcoin blockchain" Version="0.2"

RUN apt-get update && apt-get install -y 
    curl \
    python-dev \
    python-pip \
    python-yaml \
    python-software-properties \
    software-properties-common \
    postgresql-9.3 \
    postgresql-client-9.3 \
    postgresql-contrib-9.3

RUN pip install \
    flask \
    flask-api

#  Ingest to Postgres
USER postgres
RUN    /etc/init.d/postgresql start &&\
    psql --command "CREATE USER docker WITH SUPERUSER PASSWORD 'docker';" &&\
    createdb -O docker blockchain
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.3/main/pg_hba.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.3/main/postgresql.conf
RUN gzip ~/Downloads/bitcoin_2014-02-28.sql.gz | psql -U docker blockchain

#  Get API
RUN useradd -ms /bin/bash ubuntu
USER ubuntu
WORKDIR /home/ubuntu/Downloads
RUN git clone https://github.com/vlall/dockchain

EXPOSE 5432
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]
CMD ["/usr/lib/postgresql/9.3/bin/postgres", "-D", "/var/lib/postgresql/9.3/main", "-c", "config_file=/etc/postgresql/9.3/main/postgresql.conf"]
WORKDIR /home/ubuntu
