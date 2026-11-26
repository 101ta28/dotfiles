#!/usr/bin/env bash

# docker run --rm --network none -v "$PWD:/repo:ro" ubuntu:24.04 bash /repo/tests/herdr-config.sh
set -euo pipefail

if [[ ! -f /.dockerenv || -e "$HOME/.config/herdr" || -e "$HOME/.config/herdr-app" ]]; then
  printf 'Run this test in a fresh Ubuntu container.\n' >&2
  exit 1
fi

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tui="$HOME/.config/herdr/config.toml"
keys="$HOME/.config/herdr-app/keys.json"
unset HERDR_CONFIG_PATH HERDR_APP_HOME XDG_CONFIG_HOME
mkdir -p -- "$(dirname "$tui")" "$(dirname "$keys")"
printf 'kitty_graphics = true\n' > "$tui"
printf '{}\n' > "$keys"

bash "$repo_dir/sync-herdr.sh"
[[ "$(readlink "$tui")" == "$repo_dir/.config/herdr/config.toml" ]]
cmp "$keys" "$repo_dir/.config/herdr-app/keys.json"
[[ "$(cat "$tui.~1~")" == 'kitty_graphics = true' ]]
[[ "$(cat "$keys.~1~")" == '{}' ]]

keys_inode="$(stat -c %i "$keys")"
bash "$repo_dir/sync-herdr.sh"
[[ "$(stat -c %i "$keys")" == "$keys_inode" ]]
[[ ! -e "$tui.~2~" && ! -e "$keys.~2~" ]]

export XDG_CONFIG_HOME="$HOME/custom config"
export HERDR_APP_HOME="$HOME/custom app"
bash "$repo_dir/sync-herdr.sh"
[[ "$XDG_CONFIG_HOME/herdr/config.toml" -ef "$tui" ]]
cmp "$HERDR_APP_HOME/keys.json" "$keys"

export HERDR_CONFIG_PATH="$HOME/custom tui/config.toml"
bash "$repo_dir/sync-herdr.sh"
[[ "$HERDR_CONFIG_PATH" -ef "$tui" ]]

mkdir "$HOME/config-directory"
if HERDR_CONFIG_PATH="$HOME/config-directory" bash "$repo_dir/sync-herdr.sh"; then
  printf 'Unexpectedly replaced a directory.\n' >&2
  exit 1
fi
[[ -d "$HOME/config-directory" ]]
printf 'PASS: both Herdr configurations, backups, repeated sync and custom paths\n'
