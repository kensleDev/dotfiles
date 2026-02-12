# Worktree CLI Command Reference

## Core Commands

### `wt add [options] <branch>`
Create a new worktree for a branch

**Arguments:**
- `branch` - Branch name to create or checkout

**Options:**
- `-p, --path <path>` - Custom path for the worktree
- `-b, --base <branch>` - Base branch to create from (default: current branch)
- `-f, --force` - Force creation even if worktree already exists
- `--checkout` - Checkout the branch after creating (default: true)
- `--no-checkout` - Create worktree without checking out
- `-h, --help` - Display help for command

**Examples:**
```bash
# Create a new feature branch worktree
wt add -b main feature/new-feature features/new-feature

# Create from current branch
wt add feature/quick-fix

# Create without checkout
wt add --no-checkout feature/large-change features/large-change
```

### `wt list|ls [options]`
List all worktrees

**Options:**
- `-j, --json` - Output in JSON format
- `-v, --verbose` - Show detailed information
- `-h, --help` - Display help for command

**Examples:**
```bash
# Simple list
wt ls

# Detailed list
wt ls -v

# JSON output for scripting
wt ls -j
```

### `wt remove|rm [options] <path>`
Remove a worktree

**Arguments:**
- `path` - Path to the worktree to remove

**Options:**
- `-f, --force` - Force removal even if there are uncommitted changes
- `-h, --help` - Display help for command

**Examples:**
```bash
# Remove a worktree
wt rm features/old-feature

# Force remove with uncommitted changes
wt rm -f features/experimental
```

### `wt prune [options]`
Remove worktree administrative files for deleted worktrees

**Options:**
- `-h, --help` - Display help for command

**Examples:**
```bash
# Clean up orphaned worktree metadata
wt prune
```

### `wt move|mv [options] <source> <destination>`
Move a worktree to a new location

**Arguments:**
- `source` - Source path of the worktree
- `destination` - Destination path

**Options:**
- `-h, --help` - Display help for command

**Examples:**
```bash
# Move a worktree to a new location
wt mv features/old-path features/new-path

# Reorganize worktree structure
wt mv experiment-1 experiments/experiment-1
```

### `wt init [options]`
Initialize worktree CLI configuration

**Options:**
- `-h, --help` - Display help for command

**Examples:**
```bash
# Set up worktree CLI for the first time
wt init
```

### `wt switch|sw [options] <path>`
Switch to a worktree directory

**Arguments:**
- `path` - Worktree path to switch to

**Options:**
- `-s, --shell` - Open a new shell in the worktree directory
- `-h, --help` - Display help for command

**Examples:**
```bash
# Switch to a worktree (changes directory)
wt sw features/authentication

# Switch and open new shell
wt sw -s features/api-v2
```

### `wt merge [options]`
Merge the current worktree branch into a target branch

**Options:**
- `-t, --target <branch>` - Target branch to merge into
- `--dry-run` - Preview merge without executing
- `-h, --help` - Display help for command

**Examples:**
```bash
# Preview merge to main
wt merge --dry-run -t main

# Merge current worktree branch to main
wt merge -t main

# Merge to specific branch
wt merge -t develop
```

### `wt pr [options]`
Create a GitHub pull request for the current worktree branch

**Options:**
- `-b, --base <branch>` - Base branch for the pull request (default: main)
- `-t, --title <title>` - Pull request title
- `--body <body>` - Pull request body/description
- `-d, --draft` - Create as a draft PR
- `--web` - Open the PR in a browser after creation
- `--fill` - Auto-fill title and body from commit messages
- `-h, --help` - Display help for command

**Examples:**
```bash
# Create PR with auto-generated title and body
wt pr --fill

# Create draft PR
wt pr -d --fill

# Create PR and open in browser
wt pr --fill --web

# Create PR with custom base branch
wt pr --fill -b develop

# Create PR with custom title and body
wt pr -t "Add user authentication" --body "Implements OAuth2 login flow"
```

### `wt help [command]`
Display help for command

**Arguments:**
- `command` - Command to get help for

## Global Options

These options can be used with any command:

- `-V, --version` - Output the version number
- `-y, --yes` - Automatically answer "yes" to all prompts
- `-q, --quiet` - Suppress non-error output
- `-d, --debug` - Enable debug mode
- `-h, --help` - Display help for command

**Examples:**
```bash
# Run without prompts
wt -y add feature/new-feature features/new-feature

# Quiet mode
wt -q ls

# Debug mode for troubleshooting
wt -d add feature/test features/test
```

## Command Aliases

| Full Command | Short Alias |
|--------------|-------------|
| `wt list`    | `wt ls`     |
| `wt remove`  | `wt rm`     |
| `wt switch`  | `wt sw`     |
| `wt move`    | `wt mv`     |

## Legacy Command

The `worktree` command is still supported but deprecated. Use `wt` instead:

```bash
# Deprecated
worktree add feature/test

# Preferred
wt add feature/test
```
