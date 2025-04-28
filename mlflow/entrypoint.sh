#!/bin/sh
set -e


# ====== Create Artifact Directory If Needed ======
mkdir -p /mount/mlflow
mkdir -p /mount/mlflow/artifacts
chown -R $USER:$USER /mount/mlflow

if [ "$RESET_MLFLOW" = "1" ]; then
  echo "⚠️  RESET: Removing all contents from $MLFLOW_DATA_DIR"
  rm -rf "/mount/mlflow/"*
fi

if [ ! -f "/mount/mlflow/mlflow.db" ]; then
  touch "/mount/mlflow/mlflow.db"
fi


exec mlflow server \
  --backend-store-uri "sqlite:////mount/mlflow/mlflow.db" \
  --default-artifact-root "/mount/mlflow/artifacts" \
  --host "0.0.0.0" \
  --port "5000"
