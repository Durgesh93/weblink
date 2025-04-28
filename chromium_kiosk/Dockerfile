FROM alpine:3.21

ARG KIOSK_USERNAME
ARG KIOSK_PASSWORD
ARG CONTAINER_NAME

ENV USER=${KIOSK_USERNAME}
ENV PASS=${KIOSK_PASSWORD}
ENV HOME_DIR="/mount/kiosks/${CONTAINER_NAME}/${KIOSK_USERNAME}"
ENV XDG_RUNTIME_DIR="/tmp/runtime-${KIOSK_USERNAME}"
ENV CHROME_URL="https://www.lumi.csc.fi/public"

RUN apk update && apk add --no-cache \
    openbox \
    xorg-server \
    xorgxrdp \
    xrdp \
    xinit \
    chromium \
    dbus \
    bash \
    sudo \
    shadow \
    ttf-dejavu \
    supervisor

COPY entrypoint.sh /entrypoint.sh
COPY supervisord.conf /etc/supervisord.conf
RUN chmod +x /entrypoint.sh

EXPOSE 3389

ENTRYPOINT ["/entrypoint.sh"]
