#!/bin/bash
# Prompt Helper Functions
# Centralized utilities for prompt management and operations
# Usage: source scripts/prompt-helpers.sh

set -euo pipefail

# Default branch fallback
DEFAULT_BRANCH="main"

# Colors for output (optional, can be disabled)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# =============================================================================
# Branch Detection
# =============================================================================

# Get current git branch name
# Returns: Branch name or DEFAULT_BRANCH if not in git repo
get_branch() {
    local branch
    if branch=$(git branch --show-current 2>/dev/null); then
        echo "$branch"
    else
        echo "$DEFAULT_BRANCH"
    fi
}

# Validate that a branch folder exists
# Args: branch_name
# Returns: 0 if valid, 1 otherwise
validate_branch() {
    local branch="$1"
    local prompts_dir=".agent/prompts/$branch"

    if [[ ! -d "$prompts_dir" ]]; then
        return 1
    fi
    return 0
}

# =============================================================================
# Directory Management
# =============================================================================

# Ensure prompt directory structure exists for a branch
# Creates: .agent/prompts/[branch]/ and .agent/prompts/[branch]/completed/
# Args: branch_name
ensure_prompt_dirs() {
    local branch="$1"
    local base_dir=".agent/prompts/$branch"
    local completed_dir="$base_dir/completed"

    mkdir -p "$base_dir" 2>/dev/null || return 1
    mkdir -p "$completed_dir" 2>/dev/null || return 0

    return 0
}

# =============================================================================
# File Numbering
# =============================================================================

# Get the next sequential prompt number
# Args: branch_name
# Returns: Next number in format "001", "002", etc.
get_next_number() {
    local branch="$1"
    local prompts_dir=".agent/prompts/$branch"

    # If directory doesn't exist, start at 001
    if [[ ! -d "$prompts_dir" ]]; then
        echo "001"
        return 0
    fi

    # Find highest number in existing files
    local highest=0
    local filename

    for filename in "$prompts_dir"/*.md; do
        if [[ -f "$filename" ]]; then
            local basename=$(basename "$filename")
            if [[ "$basename" =~ ^([0-9]{3})- ]]; then
                local num="${BASH_REMATCH[1]}"
                if (( num > highest )); then
                    highest=$num
                fi
            fi
        fi
    done

    # Format next number with leading zeros
    printf "%03d\n" $((highest + 1))
}

# Validate a prompt number is in correct format
# Args: number
# Returns: 0 if valid (001-999), 1 otherwise
validate_prompt_number() {
    local num="$1"

    if [[ "$num" =~ ^[0-9]{3}$ ]]; then
        return 0
    fi
    return 1
}

# =============================================================================
# Filename Generation
# =============================================================================

# Sanitize a string to be filename-safe (kebab-case)
# Args: name_string
# Returns: Sanitized filename
sanitize_filename() {
    local name="$1"
    # Convert to lowercase
    name=$(echo "$name" | tr '[:upper:]' '[:lower:]')
    # Replace spaces and underscores with hyphens
    name=$(echo "$name" | tr ' _' '-')
    # Remove non-alphanumeric characters except hyphens
    name=$(echo "$name" | sed 's/[^a-z0-9-]//g')
    # Remove consecutive hyphens
    name=$(echo "$name" | sed 's/--*/-/g')
    # Remove leading/trailing hyphens
    name=$(echo "$name" | sed 's/^-\|-$//g')

    echo "$name"
}

# Generate research task filename
# Args: number, topic
# Returns: "001-research-topic-name.md"
make_research_filename() {
    local number="$1"
    local topic="$2"
    local sanitized=$(sanitize_filename "$topic")

    printf "%s-research-%s.md\n" "$number" "$sanitized"
}

# Generate implementation prompt filename
# Args: number, name
# Returns: "002-implement-feature-name.md" or "002-feature-name.md"
make_impl_filename() {
    local number="$1"
    local name="$2"
    local sanitized=$(sanitize_filename "$name")

    printf "%s-%s.md\n" "$number" "$sanitized"
}

# =============================================================================
# File Operations
# =============================================================================

# Write content to a file
# Args: filepath, content
# Returns: 0 on success, 1 on failure
write_prompt_file() {
    local filepath="$1"
    local content="$2"

    # Create directory if needed
    local dir=$(dirname "$filepath")
    mkdir -p "$dir" 2>/dev/null || return 1

    # Write content
    echo "$content" > "$filepath" 2>/dev/null || return 1

    return 0
}

# Archive a prompt to the completed folder
# Args: source_file, branch
# Returns: 0 on success, 1 on failure
archive_prompt() {
    local source_file="$1"
    local branch="$2"
    local completed_dir=".agent/prompts/$branch/completed"

    # Ensure completed directory exists
    mkdir -p "$completed_dir" 2>/dev/null || return 0

    # Get filename
    local filename=$(basename "$source_file")
    local dest_file="$completed_dir/$filename"

    # Move file
    mv "$source_file" "$dest_file" 2>/dev/null || return 1

    return 0
}

# =============================================================================
# Prompt Listing and Resolution
# =============================================================================

# List all prompts in a branch folder
# Args: branch
# Returns: List of .md filenames (one per line)
list_prompts() {
    local branch="$1"
    local prompts_dir=".agent/prompts/$branch"

    if [[ ! -d "$prompts_dir" ]]; then
        return 1
    fi

    # List .md files, sorted by number (macOS compatible)
    find "$prompts_dir" -maxdepth 1 -name "*.md" -type f -exec basename {} \; | sort
}

# Find the most recently modified prompt
# Args: branch
# Returns: Full path to most recent prompt
find_recent_prompt() {
    local branch="$1"
    local prompts_dir=".agent/prompts/$branch"

    if [[ ! -d "$prompts_dir" ]]; then
        return 1
    fi

    # Find most recently modified .md file (macOS compatible)
    find "$prompts_dir" -maxdepth 1 -name "*.md" -type f -exec stat -f "%m %N" {} \; | \
        sort -rn | head -1 | cut -d' ' -f2-
}

# Resolve a prompt identifier to a full path
# Handles:
#   - Empty/blank: most recent
#   - "last": most recent
#   - Number: "001", "5" → zero-padded match
#   - Text: matches partial filename
#   - Branch path: "feature/001" or "feature/auth"
# Args: identifier, branch
# Returns: Full path to prompt file
resolve_prompt() {
    local identifier="$1"
    local branch="$2"
    local prompts_dir=".agent/prompts/$branch"

    # Handle empty or "last" - return most recent
    if [[ -z "$identifier" || "$identifier" == "last" ]]; then
        local recent=$(find_recent_prompt "$branch")
        if [[ -n "$recent" && -f "$recent" ]]; then
            echo "$recent"
            return 0
        fi
        return 1
    fi

    # Handle explicit branch path (contains "/")
    if [[ "$identifier" == */* ]]; then
        local explicit_branch=$(dirname "$identifier")
        local search_term=$(basename "$identifier")
        local explicit_dir=".agent/prompts/$explicit_branch"

        if [[ -d "$explicit_dir" ]]; then
            local match=$(find "$explicit_dir" -maxdepth 1 -name "*$search_term*.md" -type f | head -1)
            if [[ -n "$match" && -f "$match" ]]; then
                echo "$match"
                return 0
            fi
        fi
        return 1
    fi

    # Handle pure number
    if [[ "$identifier" =~ ^[0-9]+$ ]]; then
        local padded=$(printf "%03d" "$identifier")
        local match=$(find "$prompts_dir" -maxdepth 1 -name "${padded}-*.md" -type f | head -1)
        if [[ -n "$match" && -f "$match" ]]; then
            echo "$match"
            return 0
        fi
        return 1
    fi

    # Handle text search (partial filename match)
    local matches=$(find "$prompts_dir" -maxdepth 1 -name "*$identifier*.md" -type f | wc -l | tr -d ' ')

    if [[ "$matches" -eq 1 ]]; then
        find "$prompts_dir" -maxdepth 1 -name "*$identifier*.md" -type f | head -1
        return 0
    elif [[ "$matches" -gt 1 ]]; then
        # Multiple matches - return list for user to choose (macOS compatible)
        find "$prompts_dir" -maxdepth 1 -name "*$identifier*.md" -type f -exec basename {} \; | sort
        return 2  # Special return code for multiple matches
    fi

    return 1
}

# =============================================================================
# Template Loading
# =============================================================================

# Load a template file and substitute placeholders
# Args: template_path, variable_map (associative array format: "KEY1|VALUE1|KEY2|VALUE2")
# Returns: Template with placeholders replaced
load_template() {
    local template_path="$1"
    local variable_map="$2"

    if [[ ! -f "$template_path" ]]; then
        echo "Error: Template not found: $template_path" >&2
        return 1
    fi

    local content=$(cat "$template_path")

    # Parse and replace placeholders
    local IFS='|'
    read -ra pairs <<< "$variable_map"

    for pair in "${pairs[@]}"; do
        local key="${pair%%:*}"
        local value="${pair#*:}"
        content=$(echo "$content" | sed "s|{{$key}}|$value|g")
    done

    echo "$content"
}

# =============================================================================
# Utility Functions
# =============================================================================

# Check if required dependencies are available
check_dependencies() {
    local missing=()

    command -v git >/dev/null 2>&1 || missing+=("git")
    command -v find >/dev/null 2>&1 || missing+=("find")
    command -v sed >/dev/null 2>&1 || missing+=("sed")
    command -v sort >/dev/null 2>&1 || missing+=("sort")

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "Error: Missing required dependencies: ${missing[*]}" >&2
        return 1
    fi

    return 0
}

# Display help information
show_help() {
    cat <<EOF
Prompt Helper Functions

Branch Management:
  get_branch                    Get current git branch
  validate_branch <branch>      Check if branch folder exists

File Operations:
  get_next_number <branch>      Get next sequential number (001, 002...)
  ensure_prompt_dirs <branch>   Create .agent/prompts/[branch]/ structure

Filename Generation:
  sanitize_filename <name>       Convert to kebab-case
  make_research_filename <num> <topic>    Generate research task filename
  make_impl_filename <num> <name>        Generate implementation filename

Prompt Resolution:
  list_prompts <branch>         List all prompts in branch
  find_recent_prompt <branch>   Get most recently modified prompt
  resolve_prompt <id> <branch>  Resolve identifier to full path

File Management:
  write_prompt_file <path> <content>    Write content to file
  archive_prompt <file> <branch>        Move prompt to completed/

Template Operations:
  load_template <path> <vars>  Load and substitute template

Utilities:
  check_dependencies            Verify required tools available
  show_help                     Display this help message

Example Usage:
  source scripts/prompt-helpers.sh
  BRANCH=\$(get_branch)
  NEXT_NUM=\$(get_next_number "\$BRANCH")
  FILENAME=\$(make_research_filename "\$NEXT_NUM" "websocket auth")
EOF
}

# Auto-check dependencies on source
if [[ "${PROMPT_HELPERS_SKIP_DEPS:-}" != "1" ]]; then
    check_dependencies
fi

# Export functions so they can be used in subshells
export -f get_branch
export -f validate_branch
export -f get_next_number
export -f ensure_prompt_dirs
export -f sanitize_filename
export -f make_research_filename
export -f make_impl_filename
export -f write_prompt_file
export -f archive_prompt
export -f list_prompts
export -f find_recent_prompt
export -f resolve_prompt
export -f load_template
export -f check_dependencies
export -f show_help
