# Claude Code Custom Hooks

This directory contains custom hooks that control Claude Code's behavior.

[日本語のREADMEはこちら](./README.ja.md)

## Overview

These hooks function as a safety net to prevent the AI from making inappropriate suggestions or executing dangerous commands.

## File Structure

### `rules.json`

- Defines NG words and restricted command rules
- Configuration managed in JSON format

### `stop_words.sh`

- Checks AI responses for inappropriate words
- Detects speculative or uncertain suggestions

### `pre_commands.sh`

- Checks command safety before execution
- Blocks execution of restricted commands

### `post_commands.sh`

- Analyzes command execution results
- Security checks and statistics logging

## Usage

### 1. Grant Execute Permissions

```bash
chmod +x ~/.claude/hooks/*.sh
```

### 2. Automatic Execution by Claude Code

Claude Code automatically executes hooks at the following times:

- **stop_words.sh**: During AI response generation
- **pre_commands.sh**: Before command execution
- **post_commands.sh**: After command execution

### 3. Manual Execution (for testing)

```bash
# NG Word check
~/.claude/hooks/stop_words.sh "This is suggested as an alternative"

# Command check
~/.claude/hooks/pre_commands.sh "curl https://example.com"

# Post-execution processing
~/.claude/hooks/post_commands.sh "git clone repo" 0 "Clone completed"
```

## Logs

- `~/.claude/hooks.log`: Hook execution logs
- `~/.claude/command_stats.log`: Command execution statistics

## Customization

### Adding NG Words

Add new words to the `ngWords.words` array in `rules.json`:

```json
{
  "ngWords": {
    "words": [
      "should",
      "instead",
      "new word"
    ]
  }
}
```

### Adding Restricted Commands

Add new commands to the `restrictedCommands.commands` object in `rules.json`:

```json
{
  "restrictedCommands": {
    "commands": {
      "dangerous-command": {
        "blocked": true,
        "severity": "high",
        "reason": "Dangerous command",
        "alternatives": ["Safe alternative"]
      }
    }
  }
}
```

### Adding Dangerous Command Patterns

Add new patterns to the `dangerousCommands.patterns` array in `rules.json`:

```json
{
  "dangerousCommands": {
    "patterns": [
      {
        "pattern": "dangerous-pattern",
        "severity": "critical",
        "reason": "Potential system destruction",
        "alternatives": ["Safe alternative method"]
      }
    ]
  }
}
```

## Troubleshooting

### Hooks Not Executing

1. Check execution permissions
2. Verify file paths
3. Check log files

### Too Many False Positives

1. Adjust rules in `rules.json`
2. Add specific patterns to allow list
3. Adjust conditions in hook scripts

## Security Notes

- Hook scripts are important security features
- Do not disable them carelessly
- Review rules regularly

## Preferred Tools

This dotfiles environment enforces the use of modern tools:

### Python Development
- **uv** instead of pip for package management
- **uv venv** instead of python -m venv for virtual environments
- **uvx** instead of pipx for script execution

### JavaScript/TypeScript Development
- **bun** instead of npm for package management and execution
- **bunx** instead of npx for package execution
- **yarn** as fallback when bun is not compatible

### Security Restrictions
- **curl/wget**: Blocked in favor of WebFetch tool
- **sudo operations**: Restricted to prevent unauthorized system changes
- **Destructive commands**: rm -rf, mkfs, dd, etc. are blocked

## Severity Levels

- **critical**: Can cause severe system damage, immediately blocked
- **high**: Significant security risk, warning displayed
- **medium**: General restrictions, execution possible after confirmation
- **low**: Minor warnings, information display only