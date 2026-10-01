#!/bin/bash

# =============================================================================
# User Configuration Setup Script
# =============================================================================
# This script helps users configure their personal Git and Jujutsu settings after
# installing the dotfiles.

set -e

case "${1:-}" in
  --help|-h)
    printf 'Usage: %s\n\nConfigure a shared name, email, and optional GPG key for Git and Jujutsu.\n' "$0"
    exit 0
    ;;
  "") ;;
  *)
    printf 'Unknown option: %s\n' "$1" >&2
    exit 1
    ;;
esac

# Make newly installed Cargo tools available before the next shell restart.
export PATH="$HOME/.cargo/bin:$PATH"

# カラー出力用
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log_info() {
  printf "${BLUE}[INFO]${NC} %s\n" "$1"
}

log_success() {
  printf "${GREEN}[SUCCESS]${NC} %s\n" "$1"
}

log_warn() {
  printf "${YELLOW}[WARN]${NC} %s\n" "$1"
}

log_error() {
  printf "${RED}[ERROR]${NC} %s\n" "$1" >&2
}

# =============================================================================
# Git・Jujutsu設定のセットアップ
# =============================================================================

# jj config set parses TOML values, so quote input as a string explicitly.
set_jj_string() {
  local value="$2"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  value="${value//$'\t'/\\t}"
  value="${value//$'\r'/\\r}"
  value="${value//$'\n'/\\n}"
  jj config set --user "$1" "\"$value\""
}

log_info "Setting up Git and Jujutsu configuration..."
echo

# ユーザー名の入力
read -r -p "Enter your full name for Git and Jujutsu: " git_name
while [ -z "$git_name" ]; do
  log_warn "Name cannot be empty."
  read -r -p "Enter your full name for Git and Jujutsu: " git_name
done

# メールアドレスの入力
read -r -p "Enter your email for Git and Jujutsu: " git_email
while [ -z "$git_email" ]; do
  log_warn "Email cannot be empty."
  read -r -p "Enter your email for Git and Jujutsu: " git_email
done

# GPGキーの入力（オプション）
echo
log_info "Enter a GPG key to enable commit signing in Git and Jujutsu."
log_info "Leave empty to disable automatic signing in both tools."
read -r -p "Enter your GPG signing key ID (optional): " gpg_key

# Git設定の適用
log_info "Applying Git configuration..."
git config --global user.name "$git_name"
git config --global user.email "$git_email"

if [ -n "$gpg_key" ]; then
  git config --global user.signingkey "$gpg_key"
  git config --global commit.gpgSign true
  log_success "Git configuration with GPG signing applied successfully!"
else
  # GPG署名を無効にする
  git config --global commit.gpgSign false
  log_success "Git configuration applied successfully! (GPG signing disabled)"
fi

# Jujutsu設定の適用（Gitと同じ個人情報を使用）
if command -v jj >/dev/null 2>&1; then
  log_info "Applying Jujutsu configuration..."
  set_jj_string user.name "$git_name"
  set_jj_string user.email "$git_email"
  if [ -n "$gpg_key" ]; then
    jj config set --user signing.backend gpg
    set_jj_string signing.key "$gpg_key"
    jj config set --user signing.behavior own
    log_success "Jujutsu configuration with GPG signing applied successfully!"
  else
    jj config set --user signing.behavior drop
    log_success "Jujutsu configuration applied successfully! (automatic signing disabled)"
  fi
else
  log_warn "jj not found; Git configured only. Install Jujutsu and rerun ./setup-user.sh."
fi

echo
log_info "Git configuration summary:"
echo "  Name: $git_name"
echo "  Email: $git_email"
if [ -n "$gpg_key" ]; then
  echo "  GPG Key: $gpg_key"
  echo "  GPG Signing: Enabled"
else
  echo "  GPG Signing: Disabled"
fi

echo
log_success "User configuration setup complete!"
echo
log_info "To set up GPG signing later, run:"
echo "  gpg --full-generate-key"
echo "  git config --global user.signingkey <your-key-id>"
echo "  git config --global commit.gpgSign true"
echo "  jj config set --user signing.backend gpg"
echo "  jj config set --user signing.key <your-key-id>"
echo "  jj config set --user signing.behavior own"
