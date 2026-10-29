#!/bin/bash
set -euo pipefail

log() {
    printf '[System] %s\n' "$1"
}

git_with_credentials() {
    local -a options=(-c safe.directory=/mnt/server)

    if [[ -n "${GIT_TOKEN:-}" ]]; then
        options+=(
            -c credential.helper=
            -c 'credential.helper=!f() { echo "username=${GIT_USERNAME:-x-access-token}"; echo "password=${GIT_TOKEN}"; }; f'
        )
    fi

    git "${options[@]}" "$@"
}

write_starter_app() {
    cat > index.js <<'EOF'
const http = require('node:http');

const port = Number(process.env.SERVER_PORT) || 3000;

http.createServer((request, response) => {
    response.end('Your Node.js server is running. Upload your files or set a Git repository to replace this page.\n');
}).listen(port, '0.0.0.0', () => {
    console.log(`Listening on port ${port}`);
});
EOF
}

mkdir -p /mnt/server
cd /mnt/server

if [[ -z "${GIT_ADDRESS:-}" ]]; then
    if [[ -z "$(ls -A)" ]]; then
        write_starter_app
        log 'Created a starter index.js. Upload your files or set a Git repository and reinstall.'
    else
        log 'No Git repository set, keeping the existing files.'
    fi
    exit 0
fi

if [[ -d .git ]]; then
    log "Updating the existing checkout of ${GIT_ADDRESS}"
    if ! git_with_credentials pull --ff-only; then
        log 'Could not update the checkout, keeping the existing files.'
    fi
    exit 0
fi

if [[ -n "$(ls -A)" ]]; then
    log 'The server already has files but no Git checkout, so nothing was cloned. Delete the files and reinstall to clone the repository.'
    exit 0
fi

clone_args=(clone --depth 1)
if [[ -n "${BRANCH:-}" ]]; then
    clone_args+=(--branch "$BRANCH")
fi

log "Cloning ${GIT_ADDRESS}"
if ! git_with_credentials "${clone_args[@]}" "$GIT_ADDRESS" .; then
    log 'Cloning failed. Check the repository address, the branch and the access token.'
    exit 1
fi

log 'Repository cloned. Dependencies are installed when the server starts.'
