FROM ubuntu:20.04

RUN apt-get update && apt-get upgrade -y

RUN mkdir -p pwd/logs

COPY softaculous.log /logs/softaculous.log

WORKDIR /logs