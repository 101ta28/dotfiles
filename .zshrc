# ============================================================================
# Zsh Configuration
# ============================================================================

# Source Prezto
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# ============================================================================
# Configuration Variables
# ============================================================================
CUDA_VERSION="12.9"
CUDA_PATH="/usr/local/cuda-${CUDA_VERSION}"

# ============================================================================
# Aliases
# ============================================================================
alias ls="lsd"
alias claude="~/.claude/local/claude"

# ============================================================================
# Environment Variables
# ============================================================================

# Input Method
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

# Bun
export BUN_INSTALL="${HOME}/.bun"

# Path Configuration
typeset -U path
path=(
  "${BUN_INSTALL}/bin"
  "${HOME}/.local/bin/env"
  "${HOME}/.cargo/bin"
  "${CUDA_PATH}/bin"
  "/usr/local/go/bin"
  "${HOME}/.deno/bin"
  $path
)
export PATH

# CUDA Library Path
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${CUDA_PATH}/lib64"

# NVM
export NVM_DIR="${HOME}/.nvm"

# ============================================================================
# Tool Completions and Configurations
# ============================================================================

# Function to load tool-specific completions
load_tool_completions() {
  # Bun completions
  [[ -s "${BUN_INSTALL}/_bun" ]] && source "${BUN_INSTALL}/_bun"
  
  # UV completions
  if command -v uv >/dev/null 2>&1; then
    eval "$(uv generate-shell-completion zsh)"
    eval "$(uvx --generate-shell-completion zsh)"
  fi
  
  # NVM
  [[ -s "${NVM_DIR}/nvm.sh" ]] && source "${NVM_DIR}/nvm.sh"
  [[ -s "${NVM_DIR}/bash_completion" ]] && source "${NVM_DIR}/bash_completion"
}

# Load completions
load_tool_completions

# ============================================================================
# Custom Functions and Completions
# ============================================================================

# UV run completion modifier
_uv_run_mod() {
  if [[ "$words[2]" == "run" && "$words[CURRENT]" != -* ]]; then
    _arguments '*:filename:_files'
  else
    _uv "$@"
  fi
}
compdef _uv_run_mod uv

# ============================================================================
# Claude Code Development Container Helper
# ============================================================================

# Claude Code開発コンテナのセットアップ
claude-devcontainer() {
  if [[ -f "$HOME/.config/.claude/setup-devcontainer.sh" ]]; then
    "$HOME/.config/.claude/setup-devcontainer.sh" "$@"
  else
    echo "❌ Claude Code設定が見つかりません"
    echo "dotfilesが正しくインストールされているか確認してください"
    return 1
  fi
}

# bun completions
[ -s "/home/tatsuya/.bun/_bun" ] && source "/home/tatsuya/.bun/_bun"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/tatsuya/.lmstudio/bin"
# End of LM Studio CLI section

