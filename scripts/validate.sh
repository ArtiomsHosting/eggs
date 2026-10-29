#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

read -r -d '' checks <<'JQ' || true
def reserved: ["SERVER_MEMORY", "SERVER_IP", "SERVER_PORT", "ENV", "HOME", "USER", "STARTUP", "SERVER_UUID", "UUID"];
def json_string: type == "string" and ((try fromjson catch null) != null);

[
    (if .meta.version == "PTDL_v2" then empty else "meta.version must be PTDL_v2" end),
    (if (.name | type) == "string" and (.name | length) > 0 and (.name | length) <= 191 then empty else "name must be 1-191 characters" end),
    (if (.author | type) == "string" and (.author | test("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")) then empty else "author must be an email address" end),
    (if (.docker_images | type) == "object" and (.docker_images | length) > 0 then empty else "docker_images must list at least one image" end),
    (.docker_images | to_entries[] | select((.value | length) > 191) | "docker image \(.key) is longer than 191 characters"),
    (if (.startup | type) == "string" and (.startup | length) > 0 then empty else "startup must be set" end),
    (.config | to_entries[] | select(.key != "stop") | select((.value | json_string) | not) | "config.\(.key) must be a JSON-encoded string"),
    (if (.config.stop | type) == "string" and (.config.stop | length) <= 191 then empty else "config.stop must be a string of at most 191 characters" end),
    (if (.scripts.installation.container | type) == "string" and (.scripts.installation.entrypoint | type) == "string" then empty else "scripts.installation needs a container and an entrypoint" end),
    (.variables[] | select((.default_value | type) != "string") | "\(.env_variable): default_value must be a string"),
    (.variables[] | select((.user_viewable | type) != "boolean" or (.user_editable | type) != "boolean") | "\(.env_variable): user_viewable and user_editable must be booleans"),
    (.variables[] | select((.rules | type) != "string" or (.rules | length) == 0) | "\(.env_variable): rules must be set"),
    (.variables[] | select((.env_variable | test("^\\w{1,191}$")) | not) | "\(.env_variable): env_variable may only use letters, numbers and underscores"),
    (.variables[] | select(.env_variable as $name | reserved | index($name)) | "\(.env_variable): env_variable is reserved by the panel"),
    ([.variables[].env_variable] | group_by(.)[] | select(length > 1) | "\(.[0]): env_variable is used more than once")
] | .[]
JQ

status=0

for egg in */egg-*.json; do
    if ! errors="$(jq -r "$checks" "$egg")"; then
        printf '%s: not valid JSON\n' "$egg"
        status=1
        continue
    fi

    if [[ -n "$errors" ]]; then
        printf '%s\n' "$errors" | sed "s|^|${egg}: |"
        status=1
    else
        printf '%s: ok\n' "$egg"
    fi
done

exit "$status"
