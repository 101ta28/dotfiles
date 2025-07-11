# =============================================================================
# Zsh Logout Configuration
# =============================================================================
# Executes commands at logout.

# Execute code only if STDERR is bound to a TTY
[[ -o INTERACTIVE && -t 2 ]] && {

# =============================================================================
# Farewell Messages
# =============================================================================

SAYINGS=(
    "So long and thanks for all the fish.\n  -- Douglas Adams"
    "Good morning! And in case I don't see ya, good afternoon, good evening and goodnight.\n  -- Truman Burbank"
)

# Print a randomly-chosen message
# Fix: Use ${#SAYINGS[@]} instead of ${#SAYINGS} to get array length
echo $SAYINGS[$(($RANDOM % ${#SAYINGS[@]} + 1))]

} >&2