# Quick Start: Optimized Prompt Commands

## Overview

This is a quick reference for using the optimized prompt commands. Full documentation is available in `OPTIMIZATION_SUMMARY.md` and `OPTIMIZATION_COMPARISON.md`.

## Files

- `command/create-prompt-optimised.md` - Optimized prompt creation command
- `command/run-prompt-optimised.md` - Optimized prompt execution command
- `scripts/prompt-helpers.sh` - Helper functions library
- `scripts/README.md` - Full documentation

## Quick Reference

### Using Helper Functions

```bash
# Source the helper script
source scripts/prompt-helpers.sh

# Get current branch
BRANCH=$(get_branch)

# Get next prompt number
NEXT_NUM=$(get_next_number "$BRANCH")

# Generate filenames
RESEARCH_FILE=$(make_research_filename "$NEXT_NUM" "your topic")
IMPL_FILE=$(make_impl_filename "$NEXT_NUM" "implement your feature")

# Create directory structure
ensure_prompt_dirs "$BRANCH"

# Write a prompt
write_prompt_file ".agent/prompts/$BRANCH/$RESEARCH_FILE" "content"

# Archive completed prompt
archive_prompt ".agent/prompts/$BRANCH/$RESEARCH_FILE" "$BRANCH"
```

### Using Optimized Commands

**Create a prompt:**
```
/create-prompt-optimised Add WebSocket authentication
```

**Run a prompt:**
```
/run-prompt-optimised 001
```

**Run multiple prompts (parallel):**
```
/run-prompt-optimised 001 002 003 --parallel
```

**Run multiple prompts (sequential):**
```
/run-prompt-optimised 001 002 003 --sequential
```

**Run most recent prompt:**
```
/run-prompt-optimised
```

**Run prompt by partial name:**
```
/run-prompt-optimised websocket
```

**Run prompt from different branch:**
```
/run-prompt-optimised feature-auth/001
```

## Helper Function Reference

### Branch Management
```bash
get_branch                    # Get current git branch
validate_branch <branch>      # Check if branch folder exists
```

### File Operations
```bash
get_next_number <branch>      # Get next sequential number (001, 002...)
ensure_prompt_dirs <branch>   # Create .agent/prompts/[branch]/ structure
```

### Filename Generation
```bash
sanitize_filename <name>       # Convert to kebab-case
make_research_filename <num> <topic>    # Generate research filename
make_impl_filename <num> <name>        # Generate implementation filename
```

### Prompt Resolution
```bash
list_prompts <branch>         # List all prompts in branch
find_recent_prompt <branch>   # Get most recently modified prompt
resolve_prompt <id> <branch>  # Resolve identifier to full path
```

### File Management
```bash
write_prompt_file <path> <content>    # Write content to file
archive_prompt <file> <branch>        # Move prompt to completed/
```

### Template Operations
```bash
load_template <path> <vars>  # Load and substitute template
```

## Examples

### Example 1: Create a research task manually

```bash
source scripts/prompt-helpers.sh

# Get branch and next number
BRANCH=$(get_branch)
NEXT_NUM=$(get_next_number "$BRANCH")

# Generate filename
FILENAME=$(make_research_filename "$NEXT_NUM" "WebSocket Auth")

# Ensure directories exist
ensure_prompt_dirs "$BRANCH"

# Write the file
write_prompt_file ".agent/prompts/$BRANCH/$FILENAME" "$(cat << 'EOF'
<agent_allocation>
Primary: research-agent-lite
Output: structured implementation prompt
Workflow: research-to-prompt
</agent_allocation>

<objective>
Research WebSocket authentication implementation
</objective>
...
EOF
)"
```

### Example 2: List and resolve prompts

```bash
source scripts/prompt-helpers.sh

# List all prompts in current branch
BRANCH=$(get_branch)
list_prompts "$BRANCH"

# Find most recent prompt
RECENT=$(find_recent_prompt "$BRANCH")
echo "Most recent: $RECENT"

# Resolve a specific prompt
PROMPT=$(resolve_prompt "001" "$BRANCH")
echo "Resolved: $PROMPT"
```

### Example 3: Archive completed prompts

```bash
source scripts/prompt-helpers.sh

BRANCH=$(get_branch)

# Archive a completed prompt
archive_prompt ".agent/prompts/$BRANCH/001-research-websocket.md" "$BRANCH"
```

## Testing Helper Functions

```bash
# Test all functions
source scripts/prompt-helpers.sh

echo "Branch: $(get_branch)"
echo "Next number: $(get_next_number "main")"
echo "Sanitized: $(sanitize_filename 'Build WebSocket Auth')"
echo "Research filename: $(make_research_filename "001" "WebSocket Auth")"
echo "Impl filename: $(make_impl_filename "002" "Implement Auth")"
```

## Troubleshooting

### Script not found
```bash
# Make sure you're in the correct directory
cd /Users/kd/dotfiles/opencode/.config/opencode

# Source the script
source scripts/prompt-helpers.sh
```

### Dependencies missing
```bash
# Check dependencies
source scripts/prompt-helpers.sh
check_dependencies
```

### Show help
```bash
source scripts/prompt-helpers.sh
show_help
```

## A/B Testing

### Test original version
```
/create-prompt Add WebSocket authentication
/run-prompt 001
```

### Test optimized version
```
/create-prompt-optimised Add WebSocket authentication
/run-prompt-optimised 001
```

### Compare results
1. Check token usage in opencode output
2. Measure execution time
3. Verify identical output
4. Note any differences in behavior

## More Information

- `OPTIMIZATION_SUMMARY.md` - Full implementation summary
- `OPTIMIZATION_COMPARISON.md` - Detailed A/B testing guide
- `scripts/README.md` - Complete helper script documentation
- `scripts/prompt-helpers.sh` - Inline documentation and examples
