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

# Keep loopback services (including local MCP servers) off upstream proxies.
# Merge both spellings because HTTP clients differ in which one they honor.
() {
  local -aU proxy_bypass_hosts
  proxy_bypass_hosts=(
    "${(@s:,:)NO_PROXY}"
    "${(@s:,:)no_proxy}"
    localhost 127.0.0.1 ::1
  )
  proxy_bypass_hosts=("${(@)proxy_bypass_hosts:#}")
  export NO_PROXY="${(j:,:)proxy_bypass_hosts}"
  export no_proxy="$NO_PROXY"
}

# =============================================================================
# Tool-specific Environment
# =============================================================================

# Rust/Cargo environment
if [[ -s "$HOME/.cargo/env" ]]; then
  source "$HOME/.cargo/env"
fi
. "$HOME/.cargo/env"
