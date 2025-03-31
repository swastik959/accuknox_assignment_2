#!/bin/bash

# Set URL to check (replace with your application URL)
URL="https://www.google.com"

TIMEOUT=10
LOG_FILE="./app_health.log"

touch "$LOG_FILE"

log_message() {
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$TIMESTAMP] $1" | tee -a "$LOG_FILE"
}

log_message "Checking health of application at $URL"

# Check application status
RESPONSE_CODE=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout "$TIMEOUT" "$URL")

if [[ "$RESPONSE_CODE" =~ ^2[0-9][0-9]$ ]]; then
    log_message "✅ Application status: UP (HTTP $RESPONSE_CODE)"
else
    log_message "⚠️ Received HTTP status code $RESPONSE_CODE, retrying in 5 seconds..."
    sleep 5
    
    RESPONSE_CODE=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout "$TIMEOUT" "$URL")
    
    if [[ "$RESPONSE_CODE" =~ ^2[0-9][0-9]$ ]]; then
        log_message "✅ Application status: UP after retry (HTTP $RESPONSE_CODE)"
    else
        log_message "❌ Application status: DOWN (HTTP $RESPONSE_CODE)"
    fi
fi

