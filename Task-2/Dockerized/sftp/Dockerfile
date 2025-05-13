FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y openssh-server curl cron dos2unix rkhunter

COPY basic.sh send-logs.sh /usr/local/bin/
COPY peers.conf /home/sftp/peers.conf

ADD Keys/authorized_keys /home/sftp/.ssh/authorized_keys
ADD Keys/private-key /home/sftp/.ssh/id_ed25519

RUN chmod +x /usr/local/bin/basic.sh /usr/local/bin/send-logs.sh && \
    dos2unix /usr/local/bin/basic.sh && \
    dos2unix /usr/local/bin/send-logs.sh

RUN bash /usr/local/bin/basic.sh

RUN echo "*/5 * * * * /usr/local/bin/send-logs.sh >> /var/log/send-logs.log 2>&1" > /etc/cron.d/send-logs && \
    chmod 0644 /etc/cron.d/send-logs && crontab /etc/cron.d/send-logs

EXPOSE 22

CMD service cron start && /usr/sbin/sshd -D
