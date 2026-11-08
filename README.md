# Eggs

Eggs for [Pterodactyl](https://pterodactyl.io) and [Pelican](https://pelican.dev) panels that run scripts and
apps, built on the images from [ArtiomsHosting/yolks](https://github.com/ArtiomsHosting/yolks). Free to use on
your own panel.

| Egg | Images | Import |
| --- | --- | --- |
| Node.js | Node.js 26, 24, 22, 20 (end of life) | [`nodejs/egg-nodejs.json`](nodejs/egg-nodejs.json) |
| Python | Python 3.15, 3.14, 3.13, 3.12, 3.11, 3.10 (end of life) | [`python/egg-python.json`](python/egg-python.json) |
| PostgreSQL | PostgreSQL 18, 17, 16, with pgvector | [`postgres/egg-postgres.json`](postgres/egg-postgres.json) |
| Nginx | Nginx static; Nginx with PHP 8.5, 8.4, 8.3 | [`nginx/egg-nginx.json`](nginx/egg-nginx.json) |

## Importing

Download the egg's JSON file, then import it in the panel's admin area under **Eggs**. The eggs use the
`PTDL_v2` format.

## Node.js

The server starts with `start-app` from the image. On every start it can pull the latest commit from a Git
repository, installs dependencies with npm, pnpm or Yarn when they changed, prints `[System] App starting`
and starts the app. With no main file or start command set, it runs the project's `start` script, then the
`main` file from `package.json`, then `index.js` (or `.mjs`, `.cjs`, `.ts`). See the
[yolks README](https://github.com/ArtiomsHosting/yolks#start-app-nodejs-images) for the details.

On install the egg clones the Git repository if one is set; otherwise the server starts empty and you upload
your files. A reinstall never deletes files: it fast-forwards an existing checkout and leaves other files
alone.

| Variable | Default | Description |
| --- | --- | --- |
| Git repository (`GIT_ADDRESS`) | empty | HTTPS repository to clone on install |
| Git branch (`BRANCH`) | empty | Branch to clone, or the default branch |
| Git username, access token (`GIT_USERNAME`, `GIT_TOKEN`) | empty | Credentials for private repositories, never written to `.git/config` |
| Auto update (`AUTO_UPDATE`) | off | Pull the latest commit on every start |
| Install dependencies (`INSTALL_DEPS`) | on | Install from `package.json` on start, skipped when nothing changed |
| Package manager (`PACKAGE_MANAGER`) | auto | `npm`, `pnpm` or `yarn`; auto uses `packageManager` in `package.json`, then the lockfile |
| Main file (`MAIN_FILE`) | empty | File started with Node.js; empty = zero-config start; `.ts` works through Node's type stripping on Node.js 22 and newer |
| Node.js arguments (`NODE_ARGS`) | empty | Extra arguments for Node.js |
| Start command (`START_COMMAND`) | empty | Runs instead of the main file, for example `npm run build && npm start` |

The app gets `PORT` (the server's port), `HOST=0.0.0.0` and `NODE_ENV=production` unless its own `.env`
defines them, and a Node.js heap limit of 75% of the server's memory. Apps should listen on `HOST:PORT`.

## Python

The server starts with `start-app` from the Python image. On every start it can pull the latest commit,
installs dependencies into `.venv` with uv when they changed (from `uv.lock`, `requirements.txt` or
`pyproject.toml`), prints `[System] App starting` and starts the app: the main file, or `main.py`, `app.py`
or `bot.py`. Install and reinstall work like the Node.js egg. See the
[yolks README](https://github.com/ArtiomsHosting/yolks#start-app-python-images) for the details.

| Variable | Default | Description |
| --- | --- | --- |
| Git repository, branch, username, access token, auto update | | The same as the Node.js egg |
| Install dependencies (`INSTALL_DEPS`) | on | Install into `.venv` on start, skipped when nothing changed |
| Main file (`MAIN_FILE`) | empty | File started with Python; empty = `main.py`, `app.py` or `bot.py` |
| Python arguments (`PYTHON_ARGS`) | empty | Extra arguments for Python |
| Start command (`START_COMMAND`) | empty | Runs instead of the main file, for example `uvicorn app:app --host 0.0.0.0 --port $PORT` |

The app gets `PORT` (the server's port) and `HOST=0.0.0.0` unless its own `.env` defines them. `python` and
`pip` in a start command use the server's `.venv` (with a `uv.lock`, use `uv pip` instead of `pip`).

## PostgreSQL

The server starts with `start-postgres` from the image. The database is created on the first start, and the
console is a `psql` session, so SQL typed into it runs directly. pgvector is included: run
`CREATE EXTENSION vector;` in a database to use it. Connect from apps with the server's address and port, the
user and the password. See the [yolks README](https://github.com/ArtiomsHosting/yolks#start-postgres-postgresql-images)
for the details.

| Variable | Default | Description |
| --- | --- | --- |
| Database user (`POSTGRES_USER`) | `postgres` | Superuser created with the database; changing it later doesn't rename it |
| Database password (`POSTGRES_PASSWORD`) | required | Applied on every start, so it can be changed here |
| Database name (`POSTGRES_DB`) | `postgres` | Database the console opens, created when missing |

SSL is set up automatically with a self-signed certificate. Clients can connect with `sslmode=require` for
encryption or without SSL; replace `postgres_db/server.crt` and `server.key` with your own certificate if
clients need to verify it.

The data lives in `postgres_db`. Reinstalling keeps it. A server can't switch to another major version
in place: export with `pg_dumpall` and import into a server on the new version.

## Nginx

The server starts with `start-nginx` from the image and serves the files in `www`, at the server's address
and port. The static image is for HTML sites, built single-page apps and reverse proxies; the PHP images add
PHP-FPM and Composer for WordPress, Laravel and plain PHP sites (the database runs in a separate server, such
as the PostgreSQL egg or a panel database). Users can switch between the images at any time. See the
[yolks README](https://github.com/ArtiomsHosting/yolks#start-nginx-nginx-images) for the details.

On the first start the server gets `nginx/default.conf` (the site configuration) and, on the PHP images,
`php/php.ini` (PHP settings). Both are the user's to edit; type `reload` in the console to apply changes
without a restart, or `test` to check them. Keep `include server-port.conf;` in the `server` block: it
listens on the server's port, whatever it is.

On install the egg clones the Git repository into `www` if one is set; otherwise the server starts empty and
you upload your site to `www`. A reinstall never deletes files.

| Variable | Default | Description |
| --- | --- | --- |
| Git repository, branch, username, access token, auto update | | The same as the Node.js egg, with the repository in `www` |
| Install Composer dependencies (`INSTALL_DEPS`) | on | PHP images: `composer install --no-dev` from `www/composer.json` on start, skipped when nothing changed |

For a single-page app, change `try_files` in `nginx/default.conf` to `try_files $uri $uri/ /index.html;`. For a
Laravel app, set `root /home/container/www/public;`.

## Contributing

Install scripts live next to their egg (`nodejs/install.sh`). After changing one, run `scripts/build.sh` to
copy it into the egg's JSON, and `scripts/validate.sh` to check the egg against the panel's import rules. CI
runs both.

## Credits

Inspired by [pterodactyl/generic-eggs](https://github.com/pterodactyl/generic-eggs) and
[pelican-eggs/generic](https://github.com/pelican-eggs/generic).
