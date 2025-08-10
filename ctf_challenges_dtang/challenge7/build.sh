#!/bin/bash
set -euo pipefail

CHAL_NAME="challenge7"
IMG_TAG="ctf-${CHAL_NAME}"

rm -rf "${CHAL_NAME}"
mkdir -p "${CHAL_NAME}/app"

cat > "${CHAL_NAME}/app/check_flag.sh" <<'EOF'
#!/bin/bash
set -euo pipefail

UNLOCK_HHMM="04:00"
SELF="/opt/check_flag.sh"
SIG="/opt/check_flag.sha256"
READER="/usr/local/bin/readflag"

if [[ ! -r "$SIG" ]]; then
  echo "Integrity signature missing. Aborting."
  exit 1
fi

self_sum="$(sha256sum "$SELF" | awk '{print $1}')"
expected_sum="$(tr -d '\r\n' < "$SIG")"
if [[ "$self_sum" != "$expected_sum" ]]; then
  echo "Tampering detected. Aborting."
  exit 1
fi

now="$(date +%H:%M)"
if [[ "$now" != "$UNLOCK_HHMM" ]]; then
  echo "Access denied: window locked (now=$now, need=$UNLOCK_HHMM)."
  exit 1
fi

exec "$READER"
EOF
chmod +x "${CHAL_NAME}/app/check_flag.sh"

cat > "${CHAL_NAME}/app/flag.txt" <<'EOF'
flag{time_and_integrity_ftw}
EOF

cat > "${CHAL_NAME}/app/README.txt" <<'EOF'
Welcome to Challenge 7.

Notes from support:
- Unlock window for verification is at exactly 04:00 (HH:MM).
- Ops sometimes use wrapper scripts located in $HOME/bin which take precedence over system binaries.
- Integrity matters here; unexpected changes will be rejected.

Good luck!
EOF

# Bash config: .bashrc (breadcrumb) + .bash_profile to source it for login shells
cat > "${CHAL_NAME}/app/ctfuser.bashrc" <<'EOF'
mkdir -p "$HOME/bin"
export PATH="$HOME/bin:$PATH"
PS1='[ctf7:\w]\$ '
EOF

cat > "${CHAL_NAME}/app/ctfuser.bash_profile" <<'EOF'
# Ensure login shells also load our breadcrumbs
if [ -f "$HOME/.bashrc" ]; then
  . "$HOME/.bashrc"
fi
EOF

cat > "${CHAL_NAME}/app/readflag.c" <<'EOF'
#include <stdio.h>
int main(void) {
    FILE *f = fopen("/root/flag.txt", "r");
    if (!f) return 1;
    int c; while ((c = fgetc(f)) != EOF) putchar(c
