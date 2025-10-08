#!/bin/bash

METRIC_FILE="/var/lib/node_exporter/textfile_collector/logs_rotated_status.prom"
BASE_DIR="/data_log/logs_rotated"
YESTERDAY=$(date -d "yesterday" +%F)
TARGET_DIR="${BASE_DIR}/${YESTERDAY}"

# Clear previous metrics
> "$METRIC_FILE"

# Check if directory exists
if [ -d "$TARGET_DIR" ]; then
  echo "logs_rotated_exists{date=\"${YESTERDAY}\"} 1" >> "$METRIC_FILE"

  # Get directory size in bytes
  SIZE_BYTES=$(du -sB1 "$TARGET_DIR" | awk '{print $1}')
  SIZE_GB=$((SIZE_BYTES / 1024 / 1024 / 1024))

  # Write size as a separate metric
  echo "logs_rotated_size_gb{date=\"${YESTERDAY}\"} $SIZE_GB" >> "$METRIC_FILE"

  # If directory size is above 1GB
  if [ "$SIZE_BYTES" -gt $((1 * 1024 * 1024 * 1024)) ]; then
    echo "logs_rotated_above_1gb{date=\"${YESTERDAY}\"} 1" >> "$METRIC_FILE"
  else
    echo "logs_rotated_above_1gb{date=\"${YESTERDAY}\"} 0" >> "$METRIC_FILE"
  fi
else
  echo "logs_rotated_exists{date=\"${YESTERDAY}\"} 0" >> "$METRIC_FILE"
  echo "logs_rotated_size_gb{date=\"${YESTERDAY}\"} 0" >> "$METRIC_FILE"
  echo "logs_rotated_above_1gb{date=\"${YESTERDAY}\"} 0" >> "$METRIC_FILE"
fi
