# ShipDesk releases

ShipDesk is the fulfilment desk for one micro distribution centre. This
repository only publishes its Linux builds; nothing here is edited by hand.
Every file on its `main` branch is written by the release pipeline of the
(private) ShipDesk repository.

## Install on a site machine

Linux, x86_64 or aarch64, per user, no admin rights:

    curl -fsSL https://duckdivelab.github.io/tembry-shipdesk-releases/install.sh | sh -s -- --site-code CY-PAPHOS --site-name "Paphos"

Add `--channel beta` to follow the beta channel instead of stable. The script
downloads the version the channel names, checks its signature, installs it
under `~/.local/lib/shipdesk` with a menu entry and a login entry, and writes
the site into `~/.local/share/shipdesk/config/`. Start ShipDesk from the
applications menu, or run `~/.local/bin/shipdesk run`.

What is trusted how: the script, the launcher and the icon come over HTTPS
from GitHub; the AppImage is then verified against its signature by that
launcher, which carries the release key, before anything is installed.

After that the desk updates itself: every four hours it checks its channel,
downloads the next version, verifies its signature and switches to it. A
version that fails to start is rolled back to the one before.

## What is here

- `stable/latest.json`, `beta/latest.json`: the channels. Each names one
  version and, per platform (`linux-x86_64`, `linux-aarch64`), the AppImage to download and its signature.
- `install.sh`: the first install, above.
- [Releases](https://github.com/DuckDiveLab/tembry-shipdesk-releases/releases):
  every version, with its AppImage (`ShipDesk_<version>_amd64.AppImage`),
  its `.sig` signature, the launcher (`shipdesk-launcher-amd64`), the
  icon and the version's `latest.json`. A version is published as a
  pre-release on beta first, and becomes a full release when it is promoted
  to stable.
