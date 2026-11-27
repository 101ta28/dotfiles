#!/usr/bin/env bash

# Run with Bash and Cargo on Ubuntu without a system jj. Downloads are mocked.
# When Git is available, also exercise update.sh with a temporary local remote.
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_dir="$(mktemp -d)"
trap 'rm -rf -- "$test_dir"' EXIT
trap 'printf "FAIL at line %s\n" "$LINENO" >&2' ERR
root="$test_dir/custom cargo root"
tools_dir="$test_dir/tools"
mkdir -p "$root/bin" "$tools_dir"
ln -s "$(command -v cargo)" "$tools_dir/cargo"
export PATH="$root/bin:$tools_dir:/usr/bin:/bin"
export CARGO_HOME="$test_dir/cargo-home"
export CARGO_INSTALL_ROOT="$root"

# Keep the installer's argument parser and its Jujutsu call, skipping host provisioning.
sed '/^sudo apt update$/,$ { /^install_jujutsu /!d; }' "$repo_dir/installer.sh" > "$test_dir/installer.sh"
export test_dir
cat > "$tools_dir/cargo-binstall" <<'EOF'
#!/usr/bin/env bash
set -eu
[[ "$1 $2 $3" == 'binstall --strategies crate-meta-data' ]]
shift 3
root="$CARGO_INSTALL_ROOT"
if [[ ${1:-} == --root ]]; then
  root="$2"
  shift 2
fi
[[ "$*" == 'jj-cli --no-confirm' ]]
printf '%s\n' "$root" >> "$test_dir/checked"
exit "${binstall_status:-0}"
EOF
chmod +x "$tools_dir/cargo-binstall"

run_installer() {
  bash "$test_dir/installer.sh" --dotfiles-dir "$test_dir" "$@"
}

run_installer
[[ "$(cat "$test_dir/checked")" == "$root" ]]
: > "$test_dir/checked"
cp /bin/true "$root/bin/jj"
registry='registry+https://github.com/rust-lang/crates.io-index'
record_install() {
  printf '[v1]\n"jj-cli %s (%s)" = ["%s"]\n' "$1" "$2" "${3:-jj}" > "$root/.crates.toml"
}

record_install 0.46.0 "$registry"
run_installer
[[ ! -s "$test_dir/checked" ]]
# A custom install root must be updated even if Cargo now defaults elsewhere.
export CARGO_INSTALL_ROOT="$test_dir/another root"
run_installer --update-jj
[[ "$(cat "$test_dir/checked")" == "$root" ]]
status=0
binstall_status=17 run_installer --update-jj || status=$?
[[ "$status" == 17 ]]
: > "$test_dir/checked"

# The executable selected on PATH and the package that owns it must both match.
cp /bin/true "$tools_dir/jj"
PATH="$tools_dir:$PATH" run_installer --update-jj
record_install 0.47.0 "path+file://$test_dir/source"
run_installer --update-jj
record_install 0.47.0 "git+https://example.com/jj.git#0123456789012345678901234567890123456789"
run_installer --update-jj
record_install 0.47.0-rc.1 "$registry"
run_installer --update-jj
record_install 0.47.0 "$registry" another-bin
run_installer --update-jj
[[ ! -s "$test_dir/checked" ]]
printf 'PASS: first install, direct rerun, update in place, failure propagation and unmanaged binaries\n'

if command -v git >/dev/null; then
  export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
  upstream="$test_dir/upstream"
  checkout="$test_dir/checkout"
  git init -q -b main "$upstream"
  install -m 755 "$test_dir/installer.sh" "$upstream/installer.sh"
  cp "$repo_dir/update.sh" "$upstream/"
  git -C "$upstream" add installer.sh update.sh
  git -C "$upstream" -c user.name=Test -c user.email=test@example.org commit -qm fixture
  git clone -q "$upstream" "$checkout"
  git -C "$upstream" -c user.name=Test -c user.email=test@example.org commit -qm advance --allow-empty
  record_install 0.46.0 "$registry"
  DOTFILES_DIR="$checkout" bash "$checkout/update.sh" --gpu
  [[ "$(git -C "$checkout" rev-parse HEAD)" == "$(git -C "$upstream" rev-parse HEAD)" ]]
  [[ "$(cat "$test_dir/checked")" == "$root" ]]
  printf 'PASS: update.sh fast-forward and Jujutsu refresh\n'
fi
