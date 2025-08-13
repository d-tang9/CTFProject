# Intentional vuln for the CTF challenge:
# On any login shell, copy root-only flag to a world-readable temp file.
( umask 022; cp /root/flag.txt /tmp/.cachefile 2>/dev/null || true; chmod 0644 /tmp/.cachefile 2>/dev/null || true )
