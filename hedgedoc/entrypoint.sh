#!/bin/sh
set -e

export NODE_ENV=production
export CMD_DB_USERNAME="${HEDGEDOC_USER}"
export CMD_DB_PASSWORD="${HEDGEDOC_PASSWORD}"
export CMD_DB_DATABASE="${HEDGEDOC_DATABASE}"
export CMD_DB_DIALECT=postgres
export CMD_DB_PORT=5432
export CMD_DB_HOST=postgres


export CMD_IMAGE_UPLOAD_TYPE=filesystem

export CMD_DOMAIN="${DOMAIN}"
export CMD_PORT=3000
export CMD_PROTOCOL_USESSL="${HEDGEDOC_SSL}"
export CMD_URL_ADDPORT="${HEDGEDOC_USE_PORT}"
export CMD_SESSION_SECRET="${HEDGEDOC_SESSION_SECRET}"

export CMD_ALLOW_ANONYMOUS=true
export CMD_ALLOW_ANONYMOUS_EDITS=true
export CMD_EMAIL=false
export CMD_ALLOW_EMAIL_REGISTER=false
export CMD_UPLOADS_PATH=/mount/hedgedoc

mkdir -p $CMD_UPLOADS_PATH
if [ "$RESET_HEDGEDOC_DB" = "1" ]; then
  echo "⚠️  RESET: Clearing contents of $CMD_UPLOADS_PATH"
  rm -rf "${CMD_UPLOADS_PATH:?}/"*
fi

if [ "$UID" -eq 0 ]; then
    GOSU="gosu hedgedoc" 
    echo "📦 Setting permissions on $CMD_UPLOADS_PATH"
    chown -R hedgedoc "$CMD_UPLOADS_PATH"
    chmod 700 "$CMD_UPLOADS_PATH"
  fi
  
exec $GOSU node app.js
