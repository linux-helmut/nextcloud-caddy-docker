#!/usr/bin/env bash
set -uo pipefail

CONTAINER="nc_cloud"
OCC="/var/www/nextcloud/occ"
LOG="/docker/nc/maintenance-$(date +%F_%H-%M-%S).log"

mkdir -p "$(dirname "$LOG")"
exec > >(tee -a "$LOG") 2>&1

FAILED=0

run_occ() {
    echo
    echo "===== $(date '+%F %T') | $* ====="

    if docker exec -u www-data "$CONTAINER" \
        php "$OCC" "$@"; then
        echo "OK: $*"
    else
        echo "FEHLER (Exit-Code $?): $*"
        FAILED=1
    fi
}

echo "Nextcloud-Wartung gestartet: $(date)"

run_occ preview:cleanup
run_occ files:cleanup
run_occ files:repair-tree
run_occ maintenance:repair
run_occ trashbin:cleanup --all-users
run_occ files:scan-app-data
run_occ db:add-missing-indices
run_occ files:scan --all

echo
if (( FAILED )); then
    echo "Wartung mit Fehlern beendet. Bitte Log prüfen: $LOG"
    exit 1
else
    echo "Wartung erfolgreich beendet."
    echo "Log: $LOG"
fi
