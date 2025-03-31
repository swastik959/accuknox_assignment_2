#!/bin/bash


CPU_THRESHOLD=80
MEMORY_THRESHOLD=80
DISK_THRESHOLD=90

LOG_FILE="./system_health.log"
touch "$LOG_FILE"

log_message() {
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$TIMESTAMP] $1" | tee -a "$LOG_FILE"
}

log_message "Starting system health check..."


CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}' | cut -d. -f1)
if [ "$CPU_USAGE" -gt "$CPU_THRESHOLD" ]; then
    log_message "🚨 ALERT: CPU usage is high at ${CPU_USAGE}% (threshold: ${CPU_THRESHOLD}%)"
else
    log_message "✅ INFO: CPU usage is normal at ${CPU_USAGE}% (threshold: ${CPU_THRESHOLD}%)"
fi

MEMORY_USAGE=$(free | awk '/Mem/ {printf "%.0f", $3/$2 * 100}')
if [ "$MEMORY_USAGE" -gt "$MEMORY_THRESHOLD" ]; then
    log_message "🚨 ALERT: Memory usage is high at ${MEMORY_USAGE}% (threshold: ${MEMORY_THRESHOLD}%)"
else
    log_message "✅ INFO: Memory usage is normal at ${MEMORY_USAGE}% (threshold: ${MEMORY_THRESHOLD}%)"
fi

DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
    log_message "🚨 ALERT: Disk usage is high at ${DISK_USAGE}% (threshold: ${DISK_THRESHOLD}%)"
else
    log_message "✅ INFO: Disk usage is normal at ${DISK_USAGE}% (threshold: ${DISK_THRESHOLD}%)"
fi

log_message "INFO: Top 5 CPU-intensive processes:"
ps aux --sort=-%cpu | head -6 | awk '{printf "  %-5s %-6s %s\n", $3"%", $2, $11}' | tee -a "$LOG_FILE"

log_message "✅ System health check completed."

