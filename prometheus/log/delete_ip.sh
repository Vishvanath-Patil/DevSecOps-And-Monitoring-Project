#!/bin/bash

# Directory containing the log file
LOG_DIR="/rotate_logs"

# Target log file name
TARGET_FILE="ip-172-29-12-171.af-south-1.compute.internal"

# Full path to the file
FILE_PATH="$LOG_DIR/$TARGET_FILE"

# Log file for tracking deletions
LOGFILE="/var/log/ip_log_cleanup.log"

# Check and delete if exists
if [ -f "$FILE_PATH" ]; then
    rm -f "$FILE_PATH"
    echo "$(date): Deleted $TARGET_FILE" >> "$LOGFILE"

    # Restart rsyslog service
    systemctl restart rsyslog
    echo "$(date): rsyslog service restarted" >> "$LOGFILE"
fi
