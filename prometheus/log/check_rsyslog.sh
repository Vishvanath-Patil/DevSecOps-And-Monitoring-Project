#!/bin/bash
METRIC_FILE="/var/lib/node_exporter/textfile_collector/rsyslog.prom"
STATUS=$(systemctl is-active rsyslog)
if [ "$STATUS" = "active" ]; then
  echo "rsyslog_service_running 1" > "$METRIC_FILE"
else
  echo "rsyslog_service_running 0" > "$METRIC_FILE"
fi
