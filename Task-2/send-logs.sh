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
HOST_API=$(grep '^#HOST_API=' /home/vagrant/peers.conf | cut -d '=' -f2-)
FLASK_ENDPOINT="$HOST_API/upload"
FLASK_ENDPOINT_DEBUG="$HOST_API/debug-log"


for PEER in $PEERS; do
    LOG_FILE=$(mktemp)
    echo "$TIMESTAMP $HOSTNAME $LOCAL_IP $PEER" > "$LOG_FILE"
    LOG_NAME="${HOSTNAME}-${TIMESTAMP}.log"

    echo "Transfer to: $PEER"

    if [[ "$PEER" == "$LOCAL_IP" ]]; then
        echo "Local: $LOCAL_UPLOAD_DIR/$LOG_NAME"
        cp "$LOG_FILE" "$LOCAL_UPLOAD_DIR/$LOG_NAME"
    else
         sftp -i "$KEY_PATH" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$SFTP_USER@$PEER" <<EOF
put "$LOG_FILE" "/$REMOTE_UPLOAD_DIR/$HOSTNAME-$TIMESTAMP.log"
bye
EOF
        echo "Uploading log to Flask..."
        curl -X POST -F "file=@$LOG_FILE" -F "filename=$LOG_NAME" "$FLASK_ENDPOINT"
        curl -X POST \
        -F "file=@/home/vagrant/send-logs.log" \
        -F "filename=${HOSTNAME}-send-logs.log" \
        "$FLASK_ENDPOINT_DEBUG"
    
    fi

    rm -f "$LOG_FILE"
done
