#!/bin/bash

# Set URL to check (replace with your application URL)
URL="www.google.com"

TIMEOUT=10
LOG_FILE="./app_health.log"

touch "$LOG_FILE"

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

echo "[$TIMESTAMP] Checking health of application at $URL" | tee -a "$LOG_FILE"

RESPONSE_CODE=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout "$TIMEOUT" "$URL")


if [[ "$RESPONSE_CODE" =~ ^2[0-9][0-9]$ ]]; then
    echo "[$TIMESTAMP] Application status: UP (HTTP $RESPONSE_CODE)" | tee -a "$LOG_FILE"
else
    # Try one more time before marking as down
    echo "[$TIMESTAMP] Received HTTP status code $RESPONSE_CODE, trying again..." | tee -a "$LOG_FILE"
    sleep 5
    
    RESPONSE_CODE=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout "$TIMEOUT" "$URL")
    
    if [[ "$RESPONSE_CODE" =~ ^2[0-9][0-9]$ ]]; then
        echo "[$TIMESTAMP] Application status: UP (HTTP $RESPONSE_CODE)" | tee -a "$LOG_FILE"
    else
        echo "[$TIMESTAMP] Application status: DOWN (HTTP $RESPONSE_CODE)" | tee -a "$LOG_FILE"
    fi
fi
