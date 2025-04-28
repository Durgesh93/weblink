#!/bin/bash
set -e

LOG_FILE="/var/log/postgres-reset.log"
mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"

log() {
  echo "$1" | tee -a "$LOG_FILE"
}

export PGPASSWORD="$POSTGRES_PASSWORD"
export PGDATA="/mount/postgres"
mkdir -p $PGDATA

# Start Postgres in background
docker-entrypoint.sh postgres &

log "[INFO] Waiting for Postgres to start..."
until psql -U "$POSTGRES_USER" -c "SELECT 1" >/dev/null 2>&1; do
  sleep 1
done
log "[INFO] Postgres is up!"

# ===========================
# Ensure POSTGRES_USER exists
# ===========================
USER_EXISTS=$(psql -U "$POSTGRES_USER" -tAc "SELECT 1 FROM pg_roles WHERE rolname='${POSTGRES_USER}'")
if [ "$USER_EXISTS" != "1" ]; then
  if [ "$DRY_RUN" = "1" ]; then
    log "[DRY RUN] Would create admin user: ${POSTGRES_USER}"
  else
    log "[INFO] Creating admin user ${POSTGRES_USER}..."
    psql -U postgres -c "CREATE ROLE ${POSTGRES_USER} WITH LOGIN SUPERUSER PASSWORD '${POSTGRES_PASSWORD}';"
  fi
else
  log "[INFO] Admin user '${POSTGRES_USER}' already exists."
fi

# ===========================
# Reset Guacamole DB
# ===========================
DB_EXISTS_GUAC=$(psql -U "$POSTGRES_USER" -tAc "SELECT 1 FROM pg_database WHERE datname='${GUACAMOLE_DATABASE}'")
if [ "$RESET_GUACAMOLE_DB" = "1" ]; then
  if [ "$DRY_RUN" = "1" ]; then
    log "[DRY RUN] Would drop and recreate database: ${GUACAMOLE_DATABASE}"
  else
    log "[INFO] Resetting Guacamole DB: ${GUACAMOLE_DATABASE}..."
    psql -U "$POSTGRES_USER" -d postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '${GUACAMOLE_DATABASE}';" || true
    psql -U "$POSTGRES_USER" -d postgres -c "DROP DATABASE IF EXISTS ${GUACAMOLE_DATABASE};"
    psql -U "$POSTGRES_USER" -c "CREATE DATABASE ${GUACAMOLE_DATABASE};"
    DB_EXISTS_GUAC="0"
  fi
else
  log "[INFO] RESET_GUACAMOLE_DB not set — leaving database as is."
fi

# Run init SQL for Guacamole
if [ "$DB_EXISTS_GUAC" != "1" ] && [ "$DRY_RUN" != "1" ]; then
  log "[INFO] Running /tmp/01-init.sql for Guacamole..."
  psql -U "$POSTGRES_USER" -d "${GUACAMOLE_DATABASE}" -f /tmp/01-init.sql
fi

# Ensure GUACAMOLE_USER
USER_EXISTS=$(psql -U "$POSTGRES_USER" -tAc "SELECT 1 FROM pg_roles WHERE rolname='${GUACAMOLE_USER}'")
if [ "$USER_EXISTS" != "1" ]; then
  if [ "$DRY_RUN" = "1" ]; then
    log "[DRY RUN] Would create user: ${GUACAMOLE_USER}"
  else
    log "[INFO] Creating user ${GUACAMOLE_USER}..."
    psql -U "$POSTGRES_USER" -c "CREATE USER ${GUACAMOLE_USER} WITH PASSWORD '${GUACAMOLE_PASSWORD}';"
  fi
else
  log "[INFO] User '${GUACAMOLE_USER}' already exists."
fi

# Grant privileges to GUACAMOLE_USER
if [ "$DRY_RUN" = "1" ]; then
  log "[DRY RUN] Would grant permissions to ${GUACAMOLE_USER} on ${GUACAMOLE_DATABASE}"
else
  log "[INFO] Granting permissions to ${GUACAMOLE_USER}..."
  psql -U "$POSTGRES_USER" -d "${GUACAMOLE_DATABASE}" <<-EOSQL
    GRANT CONNECT ON DATABASE ${GUACAMOLE_DATABASE} TO ${GUACAMOLE_USER};
    GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO ${GUACAMOLE_USER};
    GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO ${GUACAMOLE_USER};
EOSQL
fi

# ===========================
# Reset HedgeDoc DB
# ===========================
DB_EXISTS_HEDGEDOC=$(psql -U "$POSTGRES_USER" -tAc "SELECT 1 FROM pg_database WHERE datname='${HEDGEDOC_DATABASE}'")
if [ "$RESET_HEDGEDOC_DB" = "1" ]; then
  if [ "$DRY_RUN" = "1" ]; then
    log "[DRY RUN] Would drop and recreate database: ${HEDGEDOC_DATABASE}"
  else
    log "[INFO] Resetting HedgeDoc DB: ${HEDGEDOC_DATABASE}..."
    psql -U "$POSTGRES_USER" -d postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '${HEDGEDOC_DATABASE}';" || true
    psql -U "$POSTGRES_USER" -d postgres -c "DROP DATABASE IF EXISTS ${HEDGEDOC_DATABASE};"
    psql -U "$POSTGRES_USER" -c "CREATE DATABASE ${HEDGEDOC_DATABASE};"
    DB_EXISTS_HEDGEDOC="0"
  fi
else
  log "[INFO] RESET_HEDGEDOC_DB not set — leaving database as is."
fi

# Ensure HEDGEDOC_USER
USER_EXISTS=$(psql -U "$POSTGRES_USER" -tAc "SELECT 1 FROM pg_roles WHERE rolname='${HEDGEDOC_USER}'")
if [ "$USER_EXISTS" != "1" ]; then
  if [ "$DRY_RUN" = "1" ]; then
    log "[DRY RUN] Would create user: ${HEDGEDOC_USER}"
  else
    log "[INFO] Creating user ${HEDGEDOC_USER}..."
    psql -U "$POSTGRES_USER" -c "CREATE USER ${HEDGEDOC_USER} WITH PASSWORD '${HEDGEDOC_PASSWORD}';"
  fi
else
  log "[INFO] User '${HEDGEDOC_USER}' already exists."
fi

# Grant privileges to HEDGEDOC_USER
if [ "$DRY_RUN" = "1" ]; then
  log "[DRY RUN] Would grant permissions to ${HEDGEDOC_USER} on ${HEDGEDOC_DATABASE}"
else
  log "[INFO] Granting permissions to ${HEDGEDOC_USER}..."
  psql -U "$POSTGRES_USER" -d "${HEDGEDOC_DATABASE}" <<-EOSQL
    GRANT CONNECT ON DATABASE ${HEDGEDOC_DATABASE} TO ${HEDGEDOC_USER};
    GRANT CREATE, USAGE ON SCHEMA public TO ${HEDGEDOC_USER};
    GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO ${HEDGEDOC_USER};
    GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO ${HEDGEDOC_USER};
EOSQL
fi
wait