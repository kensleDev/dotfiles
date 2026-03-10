# Prompt Helper Scripts

This directory contains utility functions and templates for the optimized prompt commands.

## Files

- `prompt-helpers.sh` - Main utility functions library
- `templates/` - Prompt templates for reuse
  - `research-task.md` - Research task template
  - `implementation-prompt.md` - Implementation prompt template
  - `direct-implementation.md` - Direct implementation template

## Usage

Source the helper script to make functions available:

```bash
source scripts/prompt-helpers.sh
```

## Functions

### Branch Management
- `get_branch` - Get current git branch (fallback: "main")
- `validate_branch <branch>` - Check if branch folder exists

### File Operations
- `get_next_number <branch>` - Get next sequential number (001, 002...)
- `ensure_prompt_dirs <branch>` - Create .agent/prompts/[branch]/ structure

### Filename Generation
- `sanitize_filename <name>` - Convert string to kebab-case
- `make_research_filename <num> <topic>` - Generate research task filename
- `make_impl_filename <num> <name>` - Generate implementation filename

### Prompt Resolution
- `list_prompts <branch>` - List all prompts in branch
- `find_recent_prompt <branch>` - Get most recently modified prompt
- `resolve_prompt <id> <branch>` - Resolve identifier to full path

### File Management
- `write_prompt_file <path> <content>` - Write content to file
- `archive_prompt <file> <branch>` - Move prompt to completed/

### Template Operations
- `load_template <path> <vars>` - Load and substitute template placeholders

### Utilities
- `check_dependencies` - Verify required tools available
- `show_help` - Display help information

## Examples

```bash
# Get branch and next prompt number
BRANCH=$(get_branch)
NEXT_NUM=$(get_next_number "$BRANCH")

# Generate filenames
RESEARCH_FILE=$(make_research_filename "$NEXT_NUM" "websocket auth")
IMPL_FILE=$(make_impl_filename "$NEXT_NUM" "implement websocket auth")

# Create prompt directory structure
ensure_prompt_dirs "$BRANCH"

# Write prompt file
write_prompt_file ".agent/prompts/$BRANCH/$RESEARCH_FILE" "$CONTENT"

# Archive completed prompt
archive_prompt ".agent/prompts/$BRANCH/$RESEARCH_FILE" "$BRANCH"
```

## Templates

Templates use placeholder syntax `{{VARIABLE_NAME}}`. Use `load_template` to substitute:

```bash
VARS="TASK:websocket auth|BRANCH:$BRANCH|NEXT_NUMBER:002|FILENAME:implement"
load_template "scripts/templates/research-task.md" "$VARS"
```

## Testing

Test individual functions:

```bash
source scripts/prompt-helpers.sh

# Test each function
get_branch
get_next_number "main"
sanitize_filename "Build WebSocket Authentication"
make_research_filename "001" "WebSocket Auth"
```
