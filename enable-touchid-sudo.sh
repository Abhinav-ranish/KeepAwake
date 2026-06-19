#!/usr/bin/env bash
# Optional: make ALL sudo prompts (and KeepAwake's fallback dialog) accept Touch ID.
# Uses the Apple-supported /etc/pam.d/sudo_local mechanism (survives macOS updates).
# Run once:  sudo bash enable-touchid-sudo.sh
set -euo pipefail

LOCAL="/etc/pam.d/sudo_local"

if [ -f "$LOCAL" ] && grep -q "pam_tid.so" "$LOCAL"; then
    echo "Touch ID for sudo already enabled."
    exit 0
fi

# pam_tid must come first so Touch ID is offered before password.
{
    echo "# Added by KeepAwake enable-touchid-sudo.sh"
    echo "auth       sufficient     pam_tid.so"
    [ -f "$LOCAL" ] && cat "$LOCAL"
} > "${LOCAL}.new"

install -m 0444 -o root -g wheel "${LOCAL}.new" "$LOCAL"
rm -f "${LOCAL}.new"
echo "Touch ID for sudo enabled. Open a new terminal and try 'sudo -v' to test."
