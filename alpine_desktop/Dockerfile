FROM alpine:3.21

ARG DESKTOP_USERNAME
ARG DESKTOP_PASSWORD
ARG CONTAINER_NAME

ENV USER=${DESKTOP_USERNAME}
ENV PASS=${DESKTOP_PASSWORD}
ENV HOME_DIR="/mount/desktop/${CONTAINER_NAME}/${DESKTOP_USERNAME}"

RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.21/main" > /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.21/community" >> /etc/apk/repositories

RUN apk update && apk add --no-cache \
    openbox \
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
    nano \
    exa \
    mousepad \
    thunar \
    tint2 \
    lxterminal \
    chromium \
    feh \
    papirus-icon-theme \
    gtk+2.0 \
    gtk+3.0 \
    python3 \
    py3-pip \
    python3-dev \
    musl-dev \
    build-base \
    lapack-dev \
    blas-dev \
    gfortran \
    openblas-dev \
    libffi-dev \
    linux-headers \
    pkgconfig \
    dcron \
    docker-cli \
    unzip \
    wget \
    fontconfig

# Fonts
RUN mkdir -p /usr/share/fonts/firacode && \
    wget -O /tmp/FiraCode.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/FiraCode.zip && \
    unzip /tmp/FiraCode.zip -d /usr/share/fonts/firacode && \
    rm /tmp/FiraCode.zip && \
    fc-cache -fv

# Global Openbox configuration
RUN mkdir -p /etc/xdg/openbox && \
    cat > /etc/xdg/openbox/menu.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<openbox_menu xmlns="http://openbox.org/3.4/menu">
  <menu id="root-menu" label="Openbox Quick Menu">
    <item label="Terminal">
      <action name="Execute">
        <command>lxterminal</command>
      </action>
    </item>
    <item label="File Manager">
      <action name="Execute">
        <command>thunar</command>
      </action>
    </item>
    <item label="Text Editor">
      <action name="Execute">
        <command>mousepad</command>
      </action>
    </item>
    <item label="Browser">
      <action name="Execute">
        <command>chromium-browser --no-sandbox --disable-dev-shm-usage --disable-gpu</command>
      </action>
    </item>
  </menu>
</openbox_menu>
EOF

RUN sed -i 's|<name>sans</name>|<name>FiraCode Nerd Font</name>|g' /etc/xdg/openbox/rc.xml || true && \
    sed -i 's|<size>9</size>|<size>18</size>|g' /etc/xdg/openbox/rc.xml || true && \
    sed -i 's|<size>8</size>|<size>12</size>|g' /etc/xdg/openbox/rc.xml || true

# Autostart
RUN cat > /etc/xdg/openbox/autostart <<EOF
feh --bg-scale /usr/share/backgrounds/wallpaper.jpeg &
tint2 &
EOF

# xrdp start script
RUN cat > /etc/xrdp/startwm.sh <<EOF
#!/bin/sh
exec openbox-session
EOF
RUN chmod +x /etc/xrdp/startwm.sh

# Required assets and entrypoint
COPY wallpaper.jpeg /usr/share/backgrounds/wallpaper.jpeg
COPY entrypoint.sh /entrypoint.sh
COPY supervisord.conf /etc/supervisord.conf
RUN chmod +x /entrypoint.sh

EXPOSE 3389

ENTRYPOINT ["/entrypoint.sh"]
