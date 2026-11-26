#!/usr/bin/env bash

set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
tui_source="$repo_dir/.config/herdr/config.toml"
tui_target="${HERDR_CONFIG_PATH:-${XDG_CONFIG_HOME:-$HOME/.config}/herdr/config.toml}"
app_dir="${HERDR_APP_HOME:-$HOME/.config/herdr-app}"
keys_source="$repo_dir/.config/herdr-app/keys.json"
keys_target="$app_dir/keys.json"

for source_file in "$tui_source" "$keys_source"; do
  if [[ ! -f "$source_file" ]]; then
    printf 'Missing Herdr configuration: %s\n' "$source_file" >&2
    exit 1
  fi
done
for target in "$tui_target" "$keys_target"; do
  if [[ -e "$target" && ! -f "$target" ]]; then
    printf 'Expected a Herdr configuration file at %s\n' "$target" >&2
    exit 1
  fi
done

mkdir -p -- "$(dirname -- "$tui_target")" "$app_dir"
if [[ "$(realpath -m -- "$tui_target")" != "$tui_source" ]]; then
  ln -svfT --backup=numbered -- "$tui_source" "$tui_target"
fi

if ! cmp -s -- "$keys_source" "$keys_target"; then
  # Stage a complete file in the watched directory before replacing keys.json.
  temp_keys="$(mktemp -- "$app_dir/.keys.XXXXXXXX")"
  trap 'rm -f -- "$temp_keys"' EXIT
  cp -- "$keys_source" "$temp_keys"
  mv -vT --backup=numbered -- "$temp_keys" "$keys_target"
fi
