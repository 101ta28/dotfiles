#!/bin/bash

# =============================================================================
# User Configuration Setup Script
# =============================================================================
# This script helps users configure their personal Git settings after 
# installing the dotfiles.

set -e

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
# Git設定のセットアップ
# =============================================================================

log_info "Setting up Git configuration..."
echo

# ユーザー名の入力
read -p "Enter your full name for Git: " git_name
while [ -z "$git_name" ]; do
  log_warn "Name cannot be empty."
  read -p "Enter your full name for Git: " git_name
done

# メールアドレスの入力
read -p "Enter your email for Git: " git_email
while [ -z "$git_email" ]; do
  log_warn "Email cannot be empty."
  read -p "Enter your email for Git: " git_email
done

# GPGキーの入力（オプション）
echo
log_info "GPG signing is enabled by default in this configuration."
log_info "If you want to use GPG signing, you'll need to set up a GPG key."
log_info "Leave empty if you don't want to use GPG signing for now."
read -p "Enter your GPG signing key ID (optional): " gpg_key

# Git設定の適用
log_info "Applying Git configuration..."
git config --global user.name "$git_name"
git config --global user.email "$git_email"

if [ -n "$gpg_key" ]; then
  git config --global user.signingkey "$gpg_key"
  log_success "Git configuration with GPG signing applied successfully!"
else
  # GPG署名を無効にする
  git config --global commit.gpgSign false
  log_success "Git configuration applied successfully! (GPG signing disabled)"
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