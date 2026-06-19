#!/usr/bin/env bash
# Gives KeepAwake passwordless permission for ONLY the two pmset commands it needs.
# Nothing else gets elevated. Run once:  sudo bash grant-admin.sh
set -euo pipefail

USER_NAME="${SUDO_USER:-$(id -un)}"
RULE="$USER_NAME ALL=(root) NOPASSWD: /usr/bin/pmset -a disablesleep 1, /usr/bin/pmset -a disablesleep 0"

TMP="$(mktemp)"
printf '%s\n' "$RULE" > "$TMP"

# Validate syntax before installing — a bad sudoers file can lock you out, so never skip this.
if visudo -cf "$TMP" >/dev/null; then
    install -m 0440 -o root -g wheel "$TMP" /etc/sudoers.d/keepawake
    rm -f "$TMP"
    echo "Installed /etc/sudoers.d/keepawake for user '$USER_NAME'."
    echo "KeepAwake will now toggle lid-closed mode with no prompt."
else
    rm -f "$TMP"
    echo "Validation FAILED — nothing was changed." >&2
    exit 1
fi
