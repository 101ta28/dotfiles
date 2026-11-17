# Add deno completions to search path
if [[ ":$FPATH:" != *":/home/tatsuya/.zsh/completions:"* ]]; then export FPATH="/home/tatsuya/.zsh/completions:$FPATH"; fi
# Add deno completions to search path
ZSH_COMPLETIONS_DIR="${HOME}/.zsh/completions"
if [[ ":${FPATH}:" != *":${ZSH_COMPLETIONS_DIR}:"* ]]; then
  export FPATH="${ZSH_COMPLETIONS_DIR}:${FPATH}"
fi
# ============================================================================
# Zsh Configuration
# ============================================================================

# Source Prezto
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Use the short commit ID for detached HEAD instead of refs such as jj/keep/*.
zstyle ':prezto:module:git:info:position' format ''

# ============================================================================
# Aliases
# ============================================================================
alias ls="lsd"
alias vim="nvim"

# ============================================================================
# Environment Variables
# ============================================================================

# Input Method
# export GTK_IM_MODULE=fcitx
# export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

# Bun
export BUN_INSTALL="${HOME}/.bun"

# Path Configuration
typeset -U path
path=(
  "${BUN_INSTALL}/bin"
  "${HOME}/.local/bin"
  "${HOME}/.cargo/bin"
  "/usr/local/go/bin"
  "${HOME}/.deno/bin"
  $path
)
export PATH

# Optional CUDA configuration, linked only by installer.sh --gpu.
if [[ -s "$HOME/.zshrc.gpu" ]]; then
  source "$HOME/.zshrc.gpu"
fi

# NVM
export NVM_DIR="${HOME}/.nvm"

# ============================================================================
# Tool Completions and Configurations
# ============================================================================

# Function to load tool-specific completions
load_tool_completions() {
  # Jujutsu standard and dynamic completions (Prezto normally initializes compinit)
  if command -v jj >/dev/null 2>&1; then
    if (( ! $+functions[compdef] )); then
      autoload -U compinit
      compinit
    fi
    source <(jj util completion zsh)
    source <(COMPLETE=zsh jj)
  fi

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

# bun completions
[ -s "${HOME}/.bun/_bun" ] && source "${HOME}/.bun/_bun"

# Added by LM Studio CLI (lms)
export PATH="${PATH}:${HOME}/.lmstudio/bin"
# End of LM Studio CLI section


. "$HOME/.local/bin/env"
. "${HOME}/.deno/env"

# GnuPG signing from terminal
export GPG_TTY=$(tty)
gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1

# pnpm
export PNPM_HOME="${HOME}/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
. "/home/tatsuya/.deno/env"

# pnpm
export PNPM_HOME='/home/tatsuya/.local/share/pnpm'
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end
