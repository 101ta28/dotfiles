#!/usr/bin/env bash

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
  printf "${BLUE}[INFO]${NC} %s\n" "$1"
}

log_success() {
  printf "${GREEN}[SUCCESS]${NC} %s\n" "$1"
}

log_error() {
  printf "${RED}[ERROR]${NC} %s\n" "$1" >&2
}

show_help() {
  cat <<'EOF'
Usage: update.sh [OPTIONS]

Fast-forward the current dotfiles checkout and reapply its configuration.
The update stops without changing files when the checkout has local changes.
Colocated Jujutsu workspaces fetch with jj and advance an empty working copy
to trunk() only when its parent can be fast-forwarded.

Options:
  --gpu     Install or refresh optional GPU/CUDA tooling
  -h, --help
            Show this help message
EOF
}

update_jj_checkout() {
  local working_copy_ready base target
  local jj_cmd=(jj --repository "$DFILE_PATH" --no-pager --color never)

  if ! command -v jj >/dev/null 2>&1; then
    log_error "This checkout uses Jujutsu, but jj is not installed."
    exit 1
  fi

  working_copy_ready="$("${jj_cmd[@]}" log --no-graph -r @ \
    -T 'empty && !conflict && parents.len() == 1')"
  if [ "$working_copy_ready" != true ]; then
    log_error "Jujutsu updates require an empty, conflict-free working copy with one parent."
    log_error "Preserve your work and switch to an empty change before updating."
    exit 1
  fi
  base="$("${jj_cmd[@]}" log --no-graph -r '@-' -T commit_id)"

  log_info "Updating Jujutsu checkout in $DFILE_PATH..."
  # Keep local history intact if the remote has deleted or rewritten commits.
  "${jj_cmd[@]}" --config git.abandon-unreachable-commits=false git fetch
  if ! target="$("${jj_cmd[@]}" log --no-graph \
    -r 'exactly(trunk() ~ root() ~ conflicts(), 1)' -T commit_id)"; then
    log_error "Jujutsu trunk() must resolve to one conflict-free update target."
    exit 1
  fi

  # Match git pull --ff-only when local commits are already ahead of the remote.
  if git -C "$DFILE_PATH" merge-base --is-ancestor "$target" "$base"; then
    return
  fi

  if ! git -C "$DFILE_PATH" merge-base --is-ancestor "$base" "$target"; then
    log_error "The Jujutsu working-copy parent cannot be fast-forwarded to trunk()."
    log_error "Reconcile local commits with trunk() before updating; the checkout was not advanced."
    exit 1
  fi

  "${jj_cmd[@]}" new "commit_id($target)"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DFILE_PATH="${DOTFILES_DIR:-$SCRIPT_DIR}"
INSTALL_GPU=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --gpu)
      INSTALL_GPU=true
      shift
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      log_error "Unknown option: $1"
      show_help >&2
      exit 1
      ;;
  esac
done

if ! git -C "$DFILE_PATH" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  log_error "Not a Git checkout: $DFILE_PATH"
  exit 1
fi

if [ -n "$(git -C "$DFILE_PATH" status --porcelain --untracked-files=normal)" ]; then
  log_error "Local changes detected in $DFILE_PATH"
  log_error "Commit or stash them before updating; no files were changed."
  exit 1
fi

if [ -d "$DFILE_PATH/.jj" ]; then
  update_jj_checkout
else
  if ! git -C "$DFILE_PATH" symbolic-ref --quiet HEAD >/dev/null; then
    log_error "This Git checkout has a detached HEAD. Switch to a branch before updating."
    exit 1
  fi

  if ! git -C "$DFILE_PATH" rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' >/dev/null 2>&1; then
    log_error "The current branch has no upstream branch."
    log_error "Set its upstream with git branch --set-upstream-to=<remote>/<branch> before updating."
    exit 1
  fi

  log_info "Updating dotfiles in $DFILE_PATH..."
  git -C "$DFILE_PATH" pull --ff-only
fi

if [ ! -x "$DFILE_PATH/installer.sh" ]; then
  log_error "Installer is not executable: $DFILE_PATH/installer.sh"
  exit 1
fi

installer_args=(--dotfiles-dir "$DFILE_PATH")
if [ "$INSTALL_GPU" = true ]; then
  installer_args+=(--gpu)
fi

log_info "Reapplying links and required tools..."
"$DFILE_PATH/installer.sh" "${installer_args[@]}"
log_success "Dotfiles update complete."
