# =============================================================================
# Zsh Environment Configuration
# =============================================================================
# This file is sourced on all invocations of the shell.
# It should contain commands to set the environment and should not produce
# any output or assume the shell is attached to a TTY.

# =============================================================================
# Environment Setup
# =============================================================================

# Ensure that a non-login, non-interactive shell has a defined environment
if [[ ( "$SHLVL" -eq 1 && ! -o LOGIN ) && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprofile"
fi

# =============================================================================
# Tool-specific Environment
# =============================================================================

# Rust/Cargo environment
if [[ -s "$HOME/.cargo/env" ]]; then
  source "$HOME/.cargo/env"
fi