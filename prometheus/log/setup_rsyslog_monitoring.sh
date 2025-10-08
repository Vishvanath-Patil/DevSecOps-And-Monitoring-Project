#!/bin/bash

# 1. Create textfile collector directory
mkdir -p /var/lib/node_exporter/textfile_collector
chown -R marigold:marigold /var/lib/node_exporter/textfile_collector

# 2. Update node_exporter systemd service to include textfile collector
sed -i '/ExecStart=/c\ExecStart=/usr/local/bin/node_exporter --collector.textfile.directory=/var/lib/node_exporter/textfile_collector' /etc/systemd/system/node_exporter.service

# 3. Reload and restart node_exporter
systemctl daemon-reexec
systemctl daemon-reload
systemctl restart node_exporter
systemctl enable node_exporter

# 4. Create rsyslog monitoring script
cat << 'EOF' > /usr/local/bin/check_rsyslog.sh
#!/bin/bash
METRIC_FILE="/var/lib/node_exporter/textfile_collector/rsyslog.prom"
STATUS=$(systemctl is-active rsyslog)
if [ "$STATUS" = "active" ]; then
  echo "rsyslog_service_running 1" > "$METRIC_FILE"
else
  echo "rsyslog_service_running 0" > "$METRIC_FILE"
fi
EOF

chmod +x /usr/local/bin/check_rsyslog.sh

# 5. Create systemd service unit
cat << EOF > /etc/systemd/system/rsyslog_monitor.service
[Unit]
Description=Check rsyslog and write to node_exporter textfile

[Service]
Type=oneshot
ExecStart=/usr/local/bin/check_rsyslog.sh
EOF

# 6. Create systemd timer unit
cat << EOF > /etc/systemd/system/rsyslog_monitor.timer
[Unit]
Description=Run rsyslog monitoring every minute

[Timer]
OnBootSec=1min
OnUnitActiveSec=60s
Unit=rsyslog_monitor.service

[Install]
WantedBy=timers.target
EOF

# 7. Enable and start the timer
systemctl daemon-reload
systemctl enable --now rsyslog_monitor.timer

# 8. Run the script once immediately
/usr/local/bin/check_rsyslog.sh

echo "✅ rsyslog monitoring is now active via Node Exporter's textfile collector!"

