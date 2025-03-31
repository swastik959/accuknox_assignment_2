#!/bin/bash


CPU_THRESHOLD=80
MEMORY_THRESHOLD=80
DISK_THRESHOLD=90

LOG_FILE="./system_health.log"
touch "$LOG_FILE"

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

echo "[$TIMESTAMP] Starting system health check..." | tee -a "$LOG_FILE"

CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}' | cut -d. -f1)
if [ "$CPU_USAGE" -gt "$CPU_THRESHOLD" ]; then
    echo "[$TIMESTAMP] ALERT: CPU usage is high at ${CPU_USAGE}% (threshold: ${CPU_THRESHOLD}%)" | tee -a "$LOG_FILE"
else
    echo "[$TIMESTAMP] INFO: CPU usage is normal at ${CPU_USAGE}% (threshold: ${CPU_THRESHOLD}%)" | tee -a "$LOG_FILE"
fi

MEMORY_USAGE=$(free | grep Mem | awk '{print int($3/$2 * 100)}')
if [ "$MEMORY_USAGE" -gt "$MEMORY_THRESHOLD" ]; then
    echo "[$TIMESTAMP] ALERT: Memory usage is high at ${MEMORY_USAGE}% (threshold: ${MEMORY_THRESHOLD}%)" | tee -a "$LOG_FILE"
else
    echo "[$TIMESTAMP] INFO: Memory usage is normal at ${MEMORY_USAGE}% (threshold: ${MEMORY_THRESHOLD}%)" | tee -a "$LOG_FILE"
fi

DISK_USAGE=$(df -h / | grep / | awk '{print $5}' | cut -d% -f1)
if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
    echo "[$TIMESTAMP] ALERT: Disk usage is high at ${DISK_USAGE}% (threshold: ${DISK_THRESHOLD}%)" | tee -a "$LOG_FILE"
else
    echo "[$TIMESTAMP] INFO: Disk usage is normal at ${DISK_USAGE}% (threshold: ${DISK_THRESHOLD}%)" | tee -a "$LOG_FILE"
fi

echo "[$TIMESTAMP] INFO: Top 5 CPU-intensive processes:" | tee -a "$LOG_FILE"
top -bn1 | head -n 12 | tail -n 6 | awk '{print "  " $9 "% CPU: " $12}' | tee -a "$LOG_FILE"

echo "[$TIMESTAMP] System health check completed." | tee -a "$LOG_FILE"
