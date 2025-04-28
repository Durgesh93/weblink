#!/bin/sh

PORTAINER_DATA_DIR="/mount/portainer"
mkdir -p $PORTAINER_DATA_DIR
if [ "$RESET_PORTAINER" = "1" ]; then
  echo "Resetting Portainer data at $PORTAINER_DATA_DIR..."
  rm -rf "${PORTAINER_DATA_DIR:?}/"*
fi

ln -sf $PORTAINER_DATA_DIR /data
exec /portainer "$@"
