FROM ubuntu:20.04

RUN apt-get update && apt-get upgrade -y && apt-get install -y nano
RUN mkdir -p pwd/logs

COPY . /logs/

WORKDIR /logs