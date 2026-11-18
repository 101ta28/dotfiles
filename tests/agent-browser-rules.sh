#!/usr/bin/env bash
# docker run --rm --network none -v "$PWD:/repo:ro" ubuntu:24.04 bash /repo/tests/agent-browser-rules.sh
set -euo pipefail

if [[ ! -f /.dockerenv || -e "$HOME/.codex" ]]; then
  printf 'Run the sync test in a fresh container without Codex configuration.\n' >&2
  exit 1
fi

repo_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source <(sed '/^# オプション解析/,$d' "$repo_dir/installer.sh")
DFILE_PATH=$repo_dir
sync_codex_config
export PATH="$HOME/.local/bin:$PATH"
cmp "$repo_dir/.config/.codex/rules/agent-browser.rules" "$HOME/.codex/rules/agent-browser.rules"

# Print each argument on a separate line so that accidental word splitting is visible.
cat > "$HOME/.local/bin/agent-browser" <<'EOF'
#!/bin/bash
printf '%s\n' "$@"
EOF
chmod +x "$HOME/.local/bin/agent-browser"

check_forwarded() {
  diff -u <(printf '%s\n' "$@") <(agent-browser-inspect "$@")
}
check_forwarded --session work --json snapshot -i -s '#main article'
check_forwarded read https://example.test/docs
check_forwarded skills get core --ref commands
check_forwarded get attr @e1 href
check_forwarded wait --text 'Load complete'
check_forwarded screenshot --full
check_forwarded tab list
check_forwarded is visible @e1

check_rejected() {
  local status=0 output
  output=$(agent-browser-inspect "$@" 2>/dev/null) || status=$?
  if [[ $status != 2 || -n $output ]]; then
    printf 'Expected rejection before browser execution: %s\n' "$*" >&2
    exit 1
  fi
}
check_rejected click @e1
check_rejected upload @e1 file.txt
check_rejected eval 'document.title'
check_rejected wait --fn 'document.title'
check_rejected snapshot -i --config custom.json
check_rejected get text @e1 --executable-path /bin/false
check_rejected --session --auto-connect snapshot
check_rejected snapshot -s --cdp
check_rejected screenshot result.png
check_rejected open file:///etc/hosts
check_rejected tab close
check_rejected batch snapshot
printf 'PASS: Codex rule sync, inspection argument forwarding, and approval boundaries\n'
