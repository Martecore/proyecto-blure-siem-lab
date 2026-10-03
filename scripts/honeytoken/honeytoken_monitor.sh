#!/bin/bash
# Ruta del archivo log de auditoria del sistema
LOG_FILE="/var/log/audit/audit.log"
HONEYTOKEN_KEY="honeytoken_pan_access"
SIEM_SYSLOG_SERVER="127.0.0.1"

# Monitorizacion continua del archivo de auditoria
tail -F "$LOG_FILE" | grep --line-buffered "$HONEYTOKEN_KEY" | while read -r line; do
    # Extraccion de datos clave
    USER_ID=$(echo "$line" | grep -o 'auid=[0-9]*' | cut -d'=' -f2)
    PROCESS_NAME=$(echo "$line" | grep -o 'exe="[^"]*"' | cut -d'=' -f2)
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Formato de evento normalizado JSON
    JSON_PAYLOAD="{\"event_type\": \"HONEYTOKEN_ACCESS\", \"timestamp\": \"$TIMESTAMP\", \"severity\": \"CRITICAL\", \"file\": \"pan_customers_export.csv\", \"user_id\": \"$USER_ID\", \"process\": \"$PROCESS_NAME\"}"

    # Envio directo al motor SIEM via Syslog UDP (Puerto 514)
    echo "$JSON_PAYLOAD" | nc -u -w 1 "$SIEM_SYSLOG_SERVER" 514
done
