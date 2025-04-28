FROM alpine:3.21

ARG KIOSK_USERNAME
ARG KIOSK_PASSWORD
ARG CONTAINER_NAME

ENV USER=${KIOSK_USERNAME}
ENV PASS=${KIOSK_PASSWORD}
ENV HOME_DIR="/mount/kiosks/${CONTAINER_NAME}/${KIOSK_USERNAME}"

RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.21/main" > /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.21/community" >> /etc/apk/repositories

RUN apk update && apk add --no-cache \
    openbox \
    xrdp \
    xorg-server \
    xorgxrdp \
    xinit \
    dbus \
    ttf-dejavu \
    bash \
    sudo \
    feh \
    shadow \
    supervisor \
    chromium \
    wget \
    unzip

# Openbox menu with only Chromium
RUN mkdir -p /etc/xdg/openbox && \
    cat > /etc/xdg/openbox/menu.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<openbox_menu xmlns="http://openbox.org/3.4/menu">
  <menu id="root-menu" label="Openbox Menu">
    <item label="Chromium Browser">
      <action name="Execute">
        <command>chromium-browser --no-sandbox --disable-dev-shm-usage --disable-gpu</command>
      </action>
    </item>
  </menu>
</openbox_menu>
EOF

RUN cat > /etc/xdg/openbox/autostart <<EOF
feh --bg-scale /usr/share/backgrounds/wallpaper.jpeg &
EOF

# xrdp start script
RUN cat > /etc/xrdp/startwm.sh <<EOF
#!/bin/sh
exec openbox-session
EOF
RUN chmod +x /etc/xrdp/startwm.sh

COPY wallpaper.jpeg /usr/share/backgrounds/wallpaper.jpeg
# Assets & Entrypoint
COPY entrypoint.sh /entrypoint.sh
COPY supervisord.conf /etc/supervisord.conf
RUN chmod +x /entrypoint.sh

EXPOSE 3389

ENTRYPOINT ["/entrypoint.sh"]
