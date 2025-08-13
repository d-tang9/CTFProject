#!/usr/bin/env bash
set -euo pipefail
# Leak once as root via tightly-scoped sudo permission, then keep a login shell
sudo /usr/local/bin/leak_once.sh || true
exec bash -lc "sleep infinity"
