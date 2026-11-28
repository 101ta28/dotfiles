#!/usr/bin/env bash

# Run in a fresh Ubuntu container with git, uv and Python 3.11+ installed.
set -euo pipefail
if [[ ! -f /.dockerenv || -e "$HOME/.codex" ]]; then
  printf 'Run in a fresh container without an existing Codex configuration.\n' >&2
  exit 1
fi

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_dir="$(mktemp -d)"
upstream="$test_dir/upstream"
checkout="$test_dir/checkout"
target="$HOME/.codex/config.toml"
git init -q -b main "$upstream"

# Exercise update.sh and the installer's real sync call without provisioning the host.
sed '/^sudo apt update$/,$ { /^sync_codex_config$/!d; }' "$repo_dir/installer.sh" > "$upstream/installer.sh"
chmod +x "$upstream/installer.sh"
cp "$repo_dir/update.sh" "$repo_dir/sync-codex-config.py" "$upstream/"
mkdir "$upstream/.config"
cp -R "$repo_dir/.config/.codex" "$upstream/.config/"
git -C "$upstream" add .
git -C "$upstream" -c user.name=Test -c user.email=test@example.org commit -qm fixture
git clone -q "$upstream" "$checkout"

"$checkout/update.sh"
cmp "$checkout/.config/.codex/config.toml" "$target"
[[ "$(stat -c %a "$target")" == 600 ]]

cat > "$target" <<'EOF'
# Personal settings
model = "local-model"
[tui]
status_line = [
  "old-item",
]
[tui.keymap.chat]
next_permission_mode = "f6"
[[skills.config]]
path = "first"
[projects."/my project"]
trust_level = "trusted"
[[skills.config]]
path = "second"
EOF
mv "$target" "$test_dir/personal.toml"
ln -s "$test_dir/personal.toml" "$target"
"$checkout/update.sh"
[[ -L "$target" ]]
grep -Fxq '# Personal settings' "$target"
/usr/bin/python3 - "$checkout/.config/.codex/config.toml" "$target" <<'PY'
import sys
from pathlib import Path
import tomllib

managed, actual = (tomllib.loads(Path(path).read_text()) for path in sys.argv[1:])
assert actual["tui"].pop("status_line") == managed["tui"]["status_line"]
assert actual == {
    "model": "local-model",
    "tui": {"keymap": {"chat": {"next_permission_mode": "f6"}}},
    "projects": {"/my project": {"trust_level": "trusted"}},
    "skills": {"config": [{"path": "first"}, {"path": "second"}]},
}
PY
inode="$(stat -Lc %i "$target")"
"$checkout/update.sh"
[[ "$(stat -Lc %i "$target")" == "$inode" ]]

printf '[broken\n' > "$target"
if "$checkout/update.sh"; then
  printf 'Invalid user configuration was accepted.\n' >&2
  exit 1
fi
cmp <(printf '[broken\n') "$target"
printf 'PASS: update.sh syncs Codex settings and preserves personal configuration\n'
