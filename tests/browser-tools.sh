#!/usr/bin/env bash

# docker run --rm --network none -v "$PWD:/repo:ro" ubuntu:24.04 bash /repo/tests/browser-tools.sh
set -euo pipefail

if [ ! -f /.dockerenv ] || command -v agent-browser >/dev/null 2>&1 ||
   command -v terminal-browser >/dev/null 2>&1; then
  printf 'Run this test in a fresh Ubuntu container without browser tools.\n' >&2
  exit 1
fi

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_root="$(mktemp -d)"
trap 'printf "FAIL at line %s\n" "$LINENO" >&2' ERR
source <(sed '/^# オプション解析/,$d' "$repo_dir/installer.sh")

export XDG_BIN_HOME="$test_root/bin with spaces"
export PATH="$XDG_BIN_HOME:$PATH"
export browser_test_log="$test_root/commands.log"
mkdir -p "$XDG_BIN_HOME"

npm() {
  printf 'npm %s\n' "$*" >> "$browser_test_log"
  if [ "${browser_test_npm_status:-0}" -ne 0 ]; then
    return "$browser_test_npm_status"
  fi
  cat > "$XDG_BIN_HOME/agent-browser" <<'EOF'
#!/bin/bash
printf 'agent-browser %s\n' "$*" >> "$browser_test_log"
exit "${browser_test_install_status:-0}"
EOF
  chmod +x "$XDG_BIN_HOME/agent-browser"
}

curl() {
  printf 'curl %s\n' "$*" >> "$browser_test_log"
  if [ "${browser_test_curl_status:-0}" -ne 0 ]; then
    return "$browser_test_curl_status"
  fi
  cat <<'EOF'
set -e
cat > "$XDG_BIN_HOME/terminal-browser" <<'CLI'
#!/bin/bash
printf 'terminal-browser %s\n' "$*" >> "$browser_test_log"
printf 'terminal-browser test\n'
CLI
chmod +x "$XDG_BIN_HOME/terminal-browser"
EOF
}

install_browser_tools > "$test_root/first.log"
cat > "$test_root/expected.log" <<'EOF'
npm install --global agent-browser
agent-browser install --with-deps
curl -fsSL https://terminal-browser.sh/install
terminal-browser --version
EOF
cmp "$test_root/expected.log" "$browser_test_log"
printf 'PASS: CLI installation, Linux dependencies, terminal-browser download, custom bin path\n'

: > "$browser_test_log"
install_browser_tools > "$test_root/repeated.log"
printf 'agent-browser install --with-deps\n' > "$test_root/expected.log"
cmp "$test_root/expected.log" "$browser_test_log"
printf 'PASS: existing CLIs preserved and browser installation retried\n'

expect_failure() {
  local expected_status="$1"
  local status=0
  : > "$browser_test_log"
  install_browser_tools > "$test_root/failure.log" 2>&1 || status=$?
  [ "$status" -eq "$expected_status" ]
  ! grep -q 'terminal-browser installed' "$test_root/failure.log"
}

rm "$XDG_BIN_HOME/terminal-browser"
export browser_test_install_status=23
expect_failure 23
! grep -q '^curl ' "$browser_test_log"
unset browser_test_install_status
printf 'PASS: browser/library installation failure stops subsequent work\n'

browser_test_curl_status=22
expect_failure 22
[ ! -e "$XDG_BIN_HOME/terminal-browser" ]
browser_test_curl_status=0
printf 'PASS: failed download is not reported as a successful installation\n'

rm "$XDG_BIN_HOME/agent-browser"
browser_test_npm_status=17
expect_failure 17
! grep -q '^agent-browser\|^curl ' "$browser_test_log"
browser_test_npm_status=0
printf 'PASS: npm failure is propagated\n'

unset -f npm
expect_failure 1
grep -q 'npm is required' "$test_root/failure.log"
[ ! -s "$browser_test_log" ]
printf 'PASS: missing npm fails before installation\n'
