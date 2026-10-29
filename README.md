# Eggs

Eggs for [Pterodactyl](https://pterodactyl.io) and [Pelican](https://pelican.dev) panels that run scripts and
apps, built on the images from [ArtiomsHosting/yolks](https://github.com/ArtiomsHosting/yolks). Free to use on
your own panel.

| Egg | Images | Import |
| --- | --- | --- |
| Node.js | Node.js 26, 24, 22, 20 (end of life) | [`nodejs/egg-nodejs.json`](nodejs/egg-nodejs.json) |

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

## Contributing

Install scripts live next to their egg (`nodejs/install.sh`). After changing one, run `scripts/build.sh` to
copy it into the egg's JSON, and `scripts/validate.sh` to check the egg against the panel's import rules. CI
runs both.

## Credits

Inspired by [pterodactyl/generic-eggs](https://github.com/pterodactyl/generic-eggs) and
[pelican-eggs/generic](https://github.com/pelican-eggs/generic).
