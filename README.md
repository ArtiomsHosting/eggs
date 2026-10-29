# Eggs

Eggs for [Pterodactyl](https://pterodactyl.io) and [Pelican](https://pelican.dev) panels that run scripts and
apps, built on the images from [ArtiomsHosting/yolks](https://github.com/ArtiomsHosting/yolks). Free to use on
your own panel.

| Egg | Images | Import |
| --- | --- | --- |
| Node.js | Node.js 26 | [`nodejs/egg-nodejs.json`](nodejs/egg-nodejs.json) |

## Importing

Download the egg's JSON file, then import it in the panel's admin area under **Eggs**. The eggs use the
`PTDL_v2` format.

## Node.js

The server starts with `start-app` from the image. On every start it can pull the latest commit from a Git
repository, installs dependencies with npm, pnpm or Yarn (picked from the lockfile), prints
`[System] App starting` and runs the main file or a custom start command.

On install the egg clones the Git repository if one is set, or writes a starter `index.js` that serves a page
on the server's port. A reinstall never deletes files: it fast-forwards an existing checkout and leaves other
files alone.

| Variable | Default | Description |
| --- | --- | --- |
| Git repository (`GIT_ADDRESS`) | empty | HTTPS repository to clone on install |
| Git branch (`BRANCH`) | empty | Branch to clone, or the default branch |
| Git username, access token (`GIT_USERNAME`, `GIT_TOKEN`) | empty | Credentials for private repositories, never written to `.git/config` |
| Auto update (`AUTO_UPDATE`) | off | Pull the latest commit on every start |
| Install dependencies (`INSTALL_DEPS`) | on | Install from `package.json` on every start |
| Package manager (`PACKAGE_MANAGER`) | auto | `npm`, `pnpm` or `yarn`; auto picks from the lockfile |
| Main file (`MAIN_FILE`) | `index.js` | File started with Node.js; `.ts` files work through Node's type stripping |
| Node.js arguments (`NODE_ARGS`) | empty | Extra arguments for Node.js |
| Start command (`START_COMMAND`) | empty | Runs instead of the main file, for example `npm run start` |

Apps should listen on `0.0.0.0` and the port in the `SERVER_PORT` environment variable.

## Contributing

Install scripts live next to their egg (`nodejs/install.sh`). After changing one, run `scripts/build.sh` to
copy it into the egg's JSON, and `scripts/validate.sh` to check the egg against the panel's import rules. CI
runs both.

## Credits

Inspired by [pterodactyl/generic-eggs](https://github.com/pterodactyl/generic-eggs) and
[pelican-eggs/generic](https://github.com/pelican-eggs/generic).
