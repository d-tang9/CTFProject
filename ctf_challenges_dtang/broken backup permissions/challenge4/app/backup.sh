#!/usr/bin/env bash
set -euo pipefail
mkdir -p /var/backups
# Intentionally create a world-readable copy of the root flag
install -m 0644 /root/flag.txt /var/backups/flag_backup.txt
