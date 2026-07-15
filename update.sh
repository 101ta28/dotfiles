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

Options:
  --gpu     Install or refresh optional GPU/CUDA tooling
  -h, --help
            Show this help message
EOF
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

if ! git -C "$DFILE_PATH" rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' >/dev/null 2>&1; then
  log_error "The current branch has no upstream branch."
  exit 1
fi

log_info "Updating dotfiles in $DFILE_PATH..."
git -C "$DFILE_PATH" pull --ff-only

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
