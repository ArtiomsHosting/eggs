#!/bin/bash
set -euo pipefail

log() {
    printf '[System] %s\n' "$1"
}

mkdir -p /mnt/server

if [[ -f /mnt/server/postgres_db/PG_VERSION ]]; then
    log 'The server already has a database. Reinstalling keeps it as it is.'
    exit 0
fi

log 'The database is created on the first start with the user, password and database name from the startup settings.'
