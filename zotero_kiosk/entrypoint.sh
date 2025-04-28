#!/bin/bash
set -e

export XDG_RUNTIME_DIR="/tmp/runtime-${USER}"

# Prepare runtime dir
mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"

# === Reset Zotero Data ===
if [ "$RESET_ZOTERO" = "1" ]; then
  echo "[INFO] Resetting user data in $HOME_DIR" | tee -a /var/log/kiosk_setup.log
  rm -rf "$HOME_DIR/.cache" "$HOME_DIR/.config/Zotero" "$HOME_DIR/Downloads" "$HOME_DIR/Desktop"
  mkdir -p "$HOME_DIR"
fi

# === Create User If Missing ===
if ! id "$USER" &>/dev/null; then
  echo "[INFO] Creating user: $USER"
  adduser -h "$HOME_DIR" -s /bin/bash -D "$USER"
  echo "$USER:$PASS" | chpasswd
  addgroup "$USER" wheel
  echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel
  chmod 440 /etc/sudoers.d/wheel
fi

# Prepare directories
mkdir -p /mount/desktop/shared
mkdir -p "$HOME_DIR/.config/Zotero" "$HOME_DIR/.cache"
ln -sf /mount/desktop/shared "$HOME_DIR"

# .xinitrc if missing
if [ ! -f "$HOME_DIR/.xinitrc" ]; then
  echo "exec openbox-session" > "$HOME_DIR/.xinitrc"
  chown "$USER:$USER" "$HOME_DIR/.xinitrc"
fi

# Ownership
chown -R "$USER:$USER" "$HOME_DIR" "$XDG_RUNTIME_DIR"

# Start supervisor
exec /usr/bin/supervisord -c /etc/supervisord.conf
