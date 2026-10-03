#!/bin/sh
# ShipDesk — first install on Linux, per user, no admin rights.
#   curl -fsSL https://duckdivelab.github.io/tembry-shipdesk-releases/install.sh | sh -s -- --site-code CY-PAPHOS --site-name "Paphos" [--channel beta]
# Downloads the version the channel names, checks its signature with the
# launcher, installs it (the launcher's `install`: ~/.local/lib/shipdesk, the
# menu and login entries), and writes the site and the channel into the data
# folder the desk reads.
set -eu
channel=stable; code=""; name=""
while [ $# -gt 0 ]; do case "$1" in
  --site-code) code="$2"; shift 2 ;; --site-name) name="$2"; shift 2 ;; --channel) channel="$2"; shift 2 ;;
  *) echo "unknown option $1" >&2; exit 2 ;; esac; done
[ -n "$code" ] && [ -n "$name" ] || { echo "usage: install.sh --site-code CODE --site-name NAME [--channel beta|stable]" >&2; exit 2; }
case "$channel" in beta|stable) ;; *) echo "the channel is beta or stable, not $channel" >&2; exit 2 ;; esac
# site.toml holds them as TOML strings, written as they are.
case "$code$name" in *\"*|*\\*) echo "the site code and name cannot contain \" or \\" >&2; exit 2 ;; esac
# x86_64 only for now: no aarch64 build is made yet (the release workflow
# says why).
arch="$(uname -m)"; case "$arch" in x86_64) a=amd64 ;; aarch64) echo "no build for aarch64 yet" >&2; exit 1 ;; *) echo "no build for $arch" >&2; exit 1 ;; esac
base="https://duckdivelab.github.io/tembry-shipdesk-releases"
version="$(curl -fsSL "$base/$channel/latest.json" | sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' | head -1)"
[ -n "$version" ] || { echo "cannot read $base/$channel/latest.json" >&2; exit 1; }
# The asset names: Tauri's AppImage name (<productName>_<version>_<arch>),
# and what the release workflow uploads (.github/workflows/release.yml).
dl="https://github.com/DuckDiveLab/tembry-shipdesk-releases/releases/download/v$version"
# Under the user's cache, not /tmp: a noexec /tmp would refuse to run the launcher.
cache="${XDG_CACHE_HOME:-$HOME/.cache}"; mkdir -p "$cache"
tmp="$(mktemp -d "$cache/shipdesk-install.XXXXXX")"; trap 'rm -rf "$tmp"' EXIT
curl -fsSL -o "$tmp/ShipDesk.AppImage" "$dl/ShipDesk_${version}_${a}.AppImage"
curl -fsSL -o "$tmp/ShipDesk.AppImage.sig" "$dl/ShipDesk_${version}_${a}.AppImage.sig"
curl -fsSL -o "$tmp/shipdesk-launcher" "$dl/shipdesk-launcher-$a"
curl -fsSL -o "$tmp/shipdesk.png" "$dl/shipdesk.png"
chmod +x "$tmp/shipdesk-launcher" "$tmp/ShipDesk.AppImage"
"$tmp/shipdesk-launcher" verify "$tmp/ShipDesk.AppImage" "$tmp/ShipDesk.AppImage.sig"
"$tmp/shipdesk-launcher" install "$tmp/ShipDesk.AppImage" --version "$version"
# The menu entry's Icon=shipdesk (the AppImage run by hand writes the same file).
icons="${XDG_DATA_HOME:-$HOME/.local/share}/icons/hicolor/128x128/apps"
mkdir -p "$icons"; cp "$tmp/shipdesk.png" "$icons/shipdesk.png"
# The service's data folder: `directories` lowercases the name on Linux
# (crates/service/tests/install_script.rs pins this line).
data="${XDG_DATA_HOME:-$HOME/.local/share}/shipdesk"
mkdir -p "$data/config"; chmod 700 "$data"
printf 'code = "%s"\nname = "%s"\n' "$code" "$name" > "$data/config/site.toml"
printf '%s\n' "$channel" > "$data/config/channel"
echo "ShipDesk $version installed. Start it from the applications menu, or: ~/.local/bin/shipdesk run"
