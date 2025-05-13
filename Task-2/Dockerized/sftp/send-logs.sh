#!/bin/bash

SFTP_USER="sftp"
PEERS=$(grep -Ev '^\s*#|^\s*$' /home/sftp/peers.conf)
REMOTE_UPLOAD_DIR="uploads"
LOCAL_UPLOAD_DIR="/data/store/uploads"
HOSTNAME=$(hostname)
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")
LOCAL_IP=$(hostname -I | awk '{print $1}')
FLASK_ENDPOINT="http://flask-app:5000/upload"
FLASK_ENDPOINT_DEBUG="http://flask-app:5000/debug-log"

for PEER in $PEERS; do
    LOG_FILE=$(mktemp)
    echo "$TIMESTAMP $HOSTNAME $LOCAL_IP -> $PEER" > "$LOG_FILE"

    if [[ "$PEER" == "$LOCAL_IP" ]]; then
        cp "$LOG_FILE" "$LOCAL_UPLOAD_DIR/$HOSTNAME-$TIMESTAMP.log"
    else
        sftp "$SFTP_USER@$PEER" <<< $'put '"$LOG_FILE $REMOTE_UPLOAD_DIR/$HOSTNAME-$TIMESTAMP.log"$'\nbye'
    fi

    curl -X POST -F "file=@$LOG_FILE" -F "filename=$HOSTNAME-$TIMESTAMP.log" "$FLASK_ENDPOINT"
    curl -X POST -F "file=@/var/log/send-logs.log" \
    -F "filename=$HOSTNAME-send-logs.log" \
    "$FLASK_ENDPOINT_DEBUG"
    rm -f "$LOG_FILE"
done

