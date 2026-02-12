---
name: worktree-cli-skill
description: Comprehensive guide for managing Git worktrees with the worktree-cli tool. Use when Claude needs to work with multiple branches simultaneously, create isolated development environments, manage feature branches, or organize parallel development workflows. Supports all worktree-cli commands including add, list, remove, prune, move, init, switch, merge, pr, and provides best practices, command reference, and workflow examples.
---

# Worktree CLI Skill

## Overview

This skill provides comprehensive guidance for using the worktree-cli tool to efficiently manage Git worktrees. Worktrees enable you to work on multiple branches simultaneously with isolated working directories, making it ideal for parallel development, feature branches, environment management, and keeping your main branch clean.

**Note:** The modern `wt` command is the preferred interface. The legacy `worktree` command is still supported but deprecated.

## Quick Start

The worktree-cli tool enhances standard Git worktree functionality with a user-friendly interface:

```bash
# List all worktrees
wt ls

# Create a new worktree for a feature branch
wt add -b main feature/new-feature features/new-feature

# Switch between worktrees
wt sw features/new-feature

# Merge current worktree branch to target
wt merge -t main

# Create a pull request for current worktree
wt pr --fill --web

# Remove a completed worktree
wt rm features/new-feature
```

## Core Commands

### Creating Worktrees
- **`wt add [options] <branch>`** - Create a new worktree for a branch
  - Use `-b` to specify base branch (defaults to current branch)
  - Use `-p` to set custom path
  - Use `--force` to overwrite existing worktrees

### Managing Worktrees
- **`wt list|ls [options]`** - List all worktrees
  - Add `-v` for detailed information
  - Add `-j` for JSON output (scripting)
- **`wt remove|rm [options] <path>`** - Remove a worktree
- **`wt prune`** - Clean up administrative files for deleted worktrees
- **`wt move|mv [options] <source> <destination>`** - Move a worktree

### Working with Worktrees
- **`wt switch|sw [options] <path>`** - Switch to a worktree directory
  - Use `-s` to open a new shell in the worktree directory
- **`wt init`** - Initialize worktree CLI configuration

### Integration Commands
- **`wt merge [options]`** - Merge the current worktree branch into a target branch
  - Use `-t` to specify target branch
  - Use `--dry-run` to preview merge without executing
- **`wt pr [options]`** - Create a GitHub pull request for the current worktree branch
  - Use `-b` to specify base branch
  - Use `-t` for custom PR title
  - Use `--body` for custom PR description
  - Use `--fill` to auto-populate title and body from commits
  - Use `-d` to create as draft
  - Use `--web` to open in browser after creation

## Common Workflows

### Feature Branch Development
```bash
# Create feature worktree
wt add -b main feature/user-authentication features/user-authentication

# Switch and work
wt sw features/user-authentication
git add . && git commit -m "feat: add authentication"
git push origin feature/user-authentication

# Merge to main when done
wt merge -t main

# Or create a pull request
wt pr --fill --web

# Switch back when done
wt sw main
```

### Hotfix Workflow
```bash
# Create from production
wt add -b production hotfix/bug-123 hotfix/bug-123

# Fix and merge
cd hotfix/bug-123
git commit -m "fix: resolve production issue"
git push origin hotfix/bug-123

# Merge to main and production using wt merge
wt sw main
wt merge -t hotfix/bug-123
wt sw production
wt merge -t hotfix/bug-123
```

### Multiple Parallel Features
```bash
# Create multiple worktrees
wt add -b main feature/api-v2 features/api-v2
wt add -b main feature/ui-redesign features/ui-redesign

# Switch between them as needed
wt sw features/api-v2
# ... work on API ...
wt sw features/ui-redesign
# ... work on UI ...
```

### Pull Request Workflow
```bash
# Create feature worktree
wt add -b main feature/new-feature features/new-feature

# Make changes and push
wt sw features/new-feature
git add . && git commit -m "feat: add new feature"
git push origin feature/new-feature

# Create PR with auto-filled title and body
wt pr --fill --web

# Or create as draft first
wt pr -d --fill
```

## Project Organization Patterns

### Feature-Based Structure
```
project/
├── main/
├── feature/login/
├── feature/dashboard/
└── fix/bug-123/
```

### Environment-Based Structure
```
project/
├── development/
├── staging/
├── production/
└── experimental/
```

## Best Practices

### When to Use Worktrees
- Parallel development on multiple features
- Keeping main/master branch clean
- Isolated development environments
- Team collaboration scenarios
- Long-running features

### Naming Conventions
- Use descriptive branch names: `feature/user-authentication`
- Include issue numbers: `fix/issue-123`
- Organize paths logically: `features/`, `fixes/`

### Common Pitfalls to Avoid
- Don't create worktrees with existing branch names
- Regularly prune deleted worktrees
- Use `--force` only when necessary
- Track all active worktrees with `wt ls -v`

### Using Merge and PR Commands
- Always preview merges with `--dry-run` before executing
- Use `wt pr --fill` to auto-generate PR descriptions from commits
- Use `wt pr -d` to create draft PRs for initial review
- The `merge` command integrates seamlessly with your git workflow

## Resources

### Command Reference
For detailed command documentation, see [references/command_reference.md](references/command_reference.md)

### Best Practices Guide
For comprehensive best practices, see [references/best_practices.md](references/best_practices.md)

### Workflow Examples
For real-world workflow examples, see [references/workflow_examples.md](references/workflow_examples.md)