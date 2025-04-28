FROM alpine:latest

# Add edge repositories
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

# Set up build-time arguments and runtime env vars
ARG KIOSK_USERNAME
ARG KIOSK_PASSWORD
ARG CONTAINER_NAME

ENV USER=${KIOSK_USERNAME}
ENV PASS=${KIOSK_PASSWORD}
ENV HOME_DIR="/mount/kiosks/${CONTAINER_NAME}/${KIOSK_USERNAME}"

# Install required packages
RUN apk update && apk add --no-cache \
    openbox \
    simdutf \
    xrdp \
    xorg-server \
    xorgxrdp \
    xinit \
    dbus \
    dbus-x11 \
    ttf-dejavu \
    bash \
    sudo \
    shadow \
    supervisor \
    zotero

# Global Openbox menu config
RUN mkdir -p /etc/xdg/openbox && \
    cat > /etc/xdg/openbox/menu.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<openbox_menu xmlns="http://openbox.org/3.4/menu">
  <menu id="root-menu" label="Openbox Quick Menu">
    <item label="Zotero">
      <action name="Execute">
        <command>zotero</command>
      </action>
    </item>
  </menu>
</openbox_menu>
EOF

# Ensure <applications> section exists in rc.xml
RUN grep -q '<applications>' /etc/xdg/openbox/rc.xml || \
    sed -i 's|</openbox_config>|<applications>\n</applications>\n</openbox_config>|' /etc/xdg/openbox/rc.xml

# Insert Zotero window rule before </applications>
RUN sed -i '/<\/applications>/i \
  <application class="zotero" name="zotero">\
    <decor>no</decor>\
    <maximized>yes</maximized>\
    <fullscreen>yes</fullscreen>\
    <focus>yes</focus>\
    <layer>above</layer>\
  </application>' /etc/xdg/openbox/rc.xml

# UI Tweaks
RUN sed -i 's|<size>9</size>|<size>18</size>|g' /etc/xdg/openbox/rc.xml || true && \
    sed -i 's|<size>8</size>|<size>12</size>|g' /etc/xdg/openbox/rc.xml || true

# Autostart Zotero
RUN cat > /etc/xdg/openbox/autostart <<EOF
zotero &
EOF

# Set XRDP session
RUN cat > /etc/xrdp/startwm.sh <<EOF
#!/bin/sh
exec openbox-session
EOF
RUN chmod +x /etc/xrdp/startwm.sh

# Copy entrypoint and config
COPY entrypoint.sh /entrypoint.sh
COPY supervisord.conf /etc/supervisord.conf
RUN chmod +x /entrypoint.sh

EXPOSE 3389

# Clean ENTRYPOINT
ENTRYPOINT ["/entrypoint.sh"]
