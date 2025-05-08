#!/bin/bash

SFTP_USER="sftp"
KEY_PATH="/home/vagrant/.ssh/ed25519"
sudo dos2unix /home/vagrant/peers.conf
PEERS=$(grep -Ev '^\s*#|^\s*$' /home/vagrant/peers.conf)
REMOTE_UPLOAD_DIR="uploads"
LOCAL_UPLOAD_DIR="/data/store/uploads"
HOSTNAME=$(hostname)
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")

LOCAL_IP=$(hostname -I | awk '{print $2}')

for PEER in $PEERS; do
    LOG_FILE=$(mktemp)
    echo "$TIMESTAMP $HOSTNAME $LOCAL_IP $PEER" > "$LOG_FILE"

    echo "Transfer to: $PEER"

    #If its local ip then copy to local directory
    if [[ "$PEER" == "$LOCAL_IP" ]]; then
        echo "Local: $LOCAL_UPLOAD_DIR/$HOSTNAME-$TIMESTAMP.log"
        cp "$LOG_FILE" "$LOCAL_UPLOAD_DIR/$HOSTNAME-$TIMESTAMP.log"
    #Sending to another VM's
    else
        sftp -i "$KEY_PATH" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$SFTP_USER@$PEER" <<EOF
put "$LOG_FILE" "/$REMOTE_UPLOAD_DIR/$HOSTNAME-$TIMESTAMP.log"
bye
EOF
    rm -f "$LOG_FILE"
    fi
done