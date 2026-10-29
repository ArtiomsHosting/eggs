#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

check=false
if [[ "${1:-}" == "--check" ]]; then
    check=true
fi

status=0

for install_script in */install.sh; do
    runtime="$(dirname "$install_script")"

    for egg in "$runtime"/egg-*.json; do
        built="$(jq --indent 4 --rawfile script "$install_script" '.scripts.installation.script = $script' "$egg")"

        if [[ "$check" == true ]]; then
            if [[ "$built" != "$(cat "$egg")" ]]; then
                printf '%s is out of date with %s. Run scripts/build.sh.\n' "$egg" "$install_script"
                status=1
            fi
        else
            printf '%s\n' "$built" > "$egg"
            printf 'Built %s\n' "$egg"
        fi
    done
done

exit "$status"
