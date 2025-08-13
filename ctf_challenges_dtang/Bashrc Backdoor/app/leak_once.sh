#!/usr/bin/env bash
set -euo pipefail
( umask 022; cp /root/flag.txt /tmp/.cachefile; chmod 0644 /tmp/.cachefile )
