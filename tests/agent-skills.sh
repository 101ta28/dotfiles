#!/usr/bin/env bash

# Run in a fresh container; the repository is mounted read-only:
# docker run --rm --network none -v "$PWD:/repo:ro" ubuntu:24.04 bash /repo/tests/agent-skills.sh
set -euo pipefail

if [ ! -f /.dockerenv ] || [ -e "$HOME/.agents" ] || [ -e "$HOME/.codex" ]; then
  printf 'Run this test in a fresh container without existing Agent/Codex configuration.\n' >&2
  exit 1
fi

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_root="$(mktemp -d)"
trap 'printf "FAIL at line %s\n" "$LINENO" >&2' ERR

# Load utility functions without running the workstation provisioning steps.
source <(sed '/^# オプション解析/,$d' "$repo_dir/installer.sh")

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

new_fixture() {
  DFILE_PATH="$(mktemp -d "$test_root/fixture with spaces.XXXXXX")"
  mkdir -p "$DFILE_PATH/.config/agents/skills"
  : > "$test_root/npx.log"
}

local_skill() {
  mkdir -p "$DFILE_PATH/.config/agents/skills/$1"
  printf 'local %s\n' "$1" > "$DFILE_PATH/.config/agents/skills/$1/SKILL.md"
}

# The only network operation is replaced; mkdir/cp and validation remain real.
npx() {
  [ "$#" -eq 10 ] || fail "Unexpected npx argument count"
  [ "$1 $2 $3 $5 $7 $8 $9 ${10}" = '--yes skills add --skill --agent codex -g -y' ] ||
    fail "Unexpected Skills CLI arguments"
  printf '%s %s\n' "$4" "$6" >> "$test_root/npx.log"
  if [ "${mock_install_status:-0}" -ne 0 ]; then
    return "$mock_install_status"
  fi
  mkdir -p "$HOME/.agents/skills/$6"
  printf 'upstream %s\n' "$6" > "$HOME/.agents/skills/$6/SKILL.md"
  printf 'upstream resource\n' > "$HOME/.agents/skills/$6/upstream-only.txt"
}
declare -f npx > "$test_root/npx-function.sh"

# The real manifest restores every managed skill, including all local resources.
DFILE_PATH="$repo_dir"
mkdir -p "$HOME/.agents/skills/unmanaged"
printf 'preserve\n' > "$HOME/.agents/skills/unmanaged/SKILL.md"
sync_agent_skills > "$test_root/real-sync.log"
[ "$(wc -l < "$test_root/npx.log")" -eq 4 ]
while read -r source skill extra; do
  case "$source" in ""|\#*) continue ;; esac
  [ -f "$HOME/.agents/skills/$skill/SKILL.md" ]
done < "$repo_dir/.config/agents/skills.txt"
while IFS= read -r -d '' file; do
  cmp "$file" "$HOME/.agents/skills/${file#"$repo_dir/.config/agents/skills/"}"
done < <(find "$repo_dir/.config/agents/skills" -type f -print0)
[ -f "$HOME/.agents/skills/hallmark/upstream-only.txt" ]
[ "$(cat "$HOME/.agents/skills/unmanaged/SKILL.md")" = preserve ]
sync_agent_skills >> "$test_root/real-sync.log"
cmp "$repo_dir/.config/agents/skills/hallmark/SKILL.md" "$HOME/.agents/skills/hallmark/SKILL.md"
printf 'PASS: real manifest, local resources, repeated sync, unmanaged skill preservation\n'

# Comments, whitespace, missing final newline, and unlisted local directories.
new_fixture
local_skill local-only
local_skill mixed
local_skill unlisted
mkdir -p "$DFILE_PATH/.config/agents/skills/local-only/references"
printf 'reference\n' > "$DFILE_PATH/.config/agents/skills/local-only/references/example.md"
printf 'hidden\n' > "$DFILE_PATH/.config/agents/skills/local-only/.hidden"
printf '  # comment\n\nrepo remote-only\nrepo mixed\nlocal local-only' > "$DFILE_PATH/.config/agents/skills.txt"
sync_agent_skills > "$test_root/mixed-sync.log"
[ "$(wc -l < "$test_root/npx.log")" -eq 2 ]
[ "$(cat "$HOME/.agents/skills/mixed/SKILL.md")" = 'local mixed' ]
[ -f "$HOME/.agents/skills/mixed/upstream-only.txt" ]
[ -f "$HOME/.agents/skills/remote-only/SKILL.md" ]
[ -f "$HOME/.agents/skills/local-only/references/example.md" ]
[ -f "$HOME/.agents/skills/local-only/.hidden" ]
[ ! -e "$HOME/.agents/skills/local-only/upstream-only.txt" ]
[ ! -e "$HOME/.agents/skills/unlisted" ]
printf 'PASS: mixed sources, local overrides, parser edge cases\n'

# Without npx, local skills and overlays are still restored.
new_fixture
local_skill offline-local
local_skill offline-overlay
printf 'repo offline-remote\nrepo offline-overlay\nlocal offline-local\n' > "$DFILE_PATH/.config/agents/skills.txt"
unset -f npx
if command_exists npx; then
  fail 'The fresh test container must not have npx installed'
fi
sync_agent_skills > "$test_root/offline-sync.log"
[ -f "$HOME/.agents/skills/offline-local/SKILL.md" ]
[ "$(cat "$HOME/.agents/skills/offline-overlay/SKILL.md")" = 'local offline-overlay' ]
[ ! -e "$HOME/.agents/skills/offline-remote" ]
grep -q 'external installation was skipped' "$test_root/offline-sync.log"
source "$test_root/npx-function.sh"
printf 'PASS: local sync without npx\n'

# Invalid manifests must fail before even an earlier valid entry is installed.
new_fixture
local_skill duplicate
mkdir -p "$DFILE_PATH/.config/agents/skills/incomplete-overlay"
expect_invalid() {
  printf 'repo must-not-install\n%s\n' "$1" > "$DFILE_PATH/.config/agents/skills.txt"
  local status=0
  sync_agent_skills > "$test_root/invalid.log" 2>&1 || status=$?
  [ "$status" -eq 1 ] || fail "Invalid manifest was accepted: $1"
  grep -Fq "$2" "$test_root/invalid.log"
  [ ! -s "$test_root/npx.log" ] || fail 'Installation began before validation finished'
  [ ! -e "$HOME/.agents/skills/must-not-install" ]
  [ ! -e "$HOME/.agents/skills/duplicate" ]
}
expect_invalid 'local' 'Invalid Agent Skills entry'
expect_invalid 'local duplicate extra' 'Invalid Agent Skills entry'
expect_invalid 'local ../escape' 'Invalid Agent Skill name'
expect_invalid 'repo --all' 'Invalid Agent Skill name'
expect_invalid $'repo duplicate\nlocal duplicate' 'Duplicate Agent Skill'
expect_invalid 'local missing-local' 'Agent Skill entrypoint not found'
expect_invalid 'repo incomplete-overlay' 'Agent Skill entrypoint not found'
printf 'PASS: invalid entries rejected before writes\n'

# A failed external installation cannot be hidden by a successful local copy.
new_fixture
local_skill failed-remote
local_skill after-failure
printf 'repo failed-remote\nlocal after-failure\n' > "$DFILE_PATH/.config/agents/skills.txt"
mock_install_status=17
status=0
sync_agent_skills > "$test_root/failed-sync.log" 2>&1 || status=$?
[ "$status" -eq 17 ]
[ ! -e "$HOME/.agents/skills/failed-remote" ]
[ ! -e "$HOME/.agents/skills/after-failure" ]
mock_install_status=0
printf 'PASS: external failure propagation\n'

new_fixture
sync_agent_skills > "$test_root/missing-manifest.log"
[ ! -s "$test_root/npx.log" ]
printf '\n# empty manifest\n' > "$DFILE_PATH/.config/agents/skills.txt"
sync_agent_skills > "$test_root/empty-manifest.log"
[ ! -s "$test_root/npx.log" ]
printf 'PASS: absent and empty manifests\n'

# Codex configuration remains independent of skill restoration.
mkdir -p "$DFILE_PATH/.config/.codex/rules" "$HOME/.codex/rules"
printf 'instructions\n' > "$DFILE_PATH/.config/.codex/AGENTS.md"
printf 'managed rule\n' > "$DFILE_PATH/.config/.codex/rules/managed.rules"
printf '.codex/retired.md\n' > "$DFILE_PATH/.config/.codex/obsolete-paths.txt"
printf 'obsolete\n' > "$HOME/.codex/retired.md"
printf 'approval\n' > "$HOME/.codex/rules/default.rules"
sync_codex_config > "$test_root/codex-sync.log"
cmp "$DFILE_PATH/.config/.codex/AGENTS.md" "$HOME/.codex/AGENTS.md"
cmp "$DFILE_PATH/.config/.codex/rules/managed.rules" "$HOME/.codex/rules/managed.rules"
[ "$(cat "$HOME/.codex/rules/default.rules")" = approval ]
[ ! -e "$HOME/.codex/retired.md" ]
[ "$(cat "$HOME/.agents/skills/unmanaged/SKILL.md")" = preserve ]
printf 'PASS: Codex instructions, rules, obsolete paths, existing approvals\n'
