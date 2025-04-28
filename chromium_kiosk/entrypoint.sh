#!/bin/bash
set -e

echo "[INFO] Entrypoint starting..."

CHROME_FLAGS="--no-first-run --no-sandbox --disable-dev-shm-usage --user-data-dir=${HOME_DIR}/.config/chromium --start-fullscreen ${CHROME_URL}"

# Setup runtime
export XDG_RUNTIME_DIR="/tmp/runtime-${USER}"
mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"

# Create user if missing
if ! id "$USER" &>/dev/null; then
  echo "[INFO] Creating user: $USER"
  adduser -D -h "$HOME_DIR" -s /bin/bash "$USER"
  echo "$USER:$PASS" | chpasswd
  addgroup "$USER" wheel
  echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel
  chmod 440 /etc/sudoers.d/wheel
fi

# Chromium config dirs
mkdir -p "$HOME_DIR/.config/chromium" "$HOME_DIR/.cache"
chown -R "$USER:$USER" "$HOME_DIR" "$XDG_RUNTIME_DIR"

# Create .xinitrc
if [ ! -f "$HOME_DIR/.xinitrc" ]; then
  echo "exec openbox-session" > "$HOME_DIR/.xinitrc"
  chown "$USER:$USER" "$HOME_DIR/.xinitrc"
fi

# Configure Openbox autostart
mkdir -p /etc/xdg/openbox
echo "chromium ${CHROME_FLAGS}" > /etc/xdg/openbox/autostart

# Configure Openbox menu
cat > /etc/xdg/openbox/menu.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<openbox_menu xmlns="http://openbox.org/3.4/menu">
  <menu id="root-menu" label="Openbox Menu">
    <item label="Browser">
      <action name="Execute">
        <command>chromium ${CHROME_FLAGS}</command>
      </action>
    </item>
  </menu>
</openbox_menu>
EOF

# Configure XRDP to start Openbox
cat > /etc/xrdp/startwm.sh <<EOF
#!/bin/sh
exec openbox-session
EOF
chmod +x /etc/xrdp/startwm.sh

echo "[INFO] Starting supervisord..."
exec /usr/bin/supervisord -c /etc/supervisord.conf
