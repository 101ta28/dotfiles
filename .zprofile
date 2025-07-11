# =============================================================================
# Zsh Profile Configuration
# =============================================================================
# Executes commands at login pre-zshrc.

# =============================================================================
# Browser Configuration
# =============================================================================

if [[ -z "$BROWSER" && "$OSTYPE" == darwin* ]]; then
  export BROWSER='open'
fi

# =============================================================================
# Editor Configuration
# =============================================================================

# Set default editors, preferring Neovim if available
if command -v nvim >/dev/null 2>&1; then
  export EDITOR='nvim'
  export VISUAL='nvim'
elif command -v vim >/dev/null 2>&1; then
  export EDITOR='vim'
  export VISUAL='vim'
else
  export EDITOR='vi'
  export VISUAL='vi'
fi

# Set default pager
if [[ -z "$PAGER" ]]; then
  export PAGER='less'
fi

# =============================================================================
# Language Configuration
# =============================================================================

if [[ -z "$LANG" ]]; then
  export LANG='en_US.UTF-8'
fi

# =============================================================================
# Path Configuration
# =============================================================================

# Ensure path arrays do not contain duplicates
typeset -gU cdpath fpath mailpath path

# Set the list of directories that Zsh searches for programs
path=(
  $HOME/{,s}bin(N)
  /opt/{homebrew,local}/{,s}bin(N)
  /usr/local/{,s}bin(N)
  $path
)

# =============================================================================
# Less Configuration
# =============================================================================

# Set the default Less options
# -g: Highlight only last match for searches
# -i: Case insensitive search
# -M: Verbose prompt
# -R: Raw ANSI color escape sequences
# -S: Don't wrap long lines
# -w: Highlight first new line after forward movement
# -X: Disable screen clearing
# -z-4: Scroll window size is 4 lines less than terminal height
if [[ -z "$LESS" ]]; then
  export LESS='-g -i -M -R -S -w -X -z-4'
fi

# Set the Less input preprocessor
if [[ -z "$LESSOPEN" ]] && (( $#commands[(i)lesspipe(|.sh)] )); then
  export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"
fi