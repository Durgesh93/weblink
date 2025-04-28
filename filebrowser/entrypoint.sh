#!/bin/sh

echo "🚀 Starting FileBrowser..."

# Ensure mount points exist
if [ "$RESET_STORAGE_PROXY" = "1" ] && [ "$DRY_RUN" = "0" ]; then
  echo "🔁 Creating /mount/storage_proxy directory..."
  rm -rf /mount/storage_proxy/*
elif [ "$DRY_RUN" = "1" ]; then
  echo "[DRY RUN] Would create /mount/storage_proxy"
else
  echo "➡️  No reset requested for storage proxy"
fi

mkdir -p /mount/storage_proxy
mkdir -p /mount/desktop/shared

# Start FileBrowser with the mounted database path
exec filebrowser  -a 0.0.0.0  -p 8080 -r /mount/desktop/shared -d /mount/storage_proxy/filebrowser.db
