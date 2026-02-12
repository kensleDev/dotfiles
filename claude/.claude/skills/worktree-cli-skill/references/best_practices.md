# Worktree CLI Best Practices

## When to Use Worktrees

Worktrees shine in these scenarios:
- **Parallel development**: Work on multiple features simultaneously without switching branches
- **Clean environments**: Isolate different contexts (feature, hotfix, experimental)
- **Team collaboration**: Separate personal work from shared branches
- **Long-running features**: Keep main/master branch clean while developing
- **Multiple contexts**: Switch between different tasks without losing your place

## Project Organization Patterns

### 1. Feature-Based Organization
```
project/
├── main/              # Main branch worktree
├── feature/login/     # Login feature worktree
├── feature/dashboard/ # Dashboard feature worktree
└── fix/bug-123/       # Bug fix worktree
```

### 2. Environment-Based Organization
```
project/
├── development/       # Development environment
├── staging/          # Staging environment
├── production/       # Production environment
└── experimental/     # Experimental features
```

### 3. Time-Based Organization
```
project/
├── current/          # Current active work
├── 2024-q4/          # Q4 2024 work
└── legacy/           # Legacy maintenance
```

## Naming Conventions

### Branch Names
- Use descriptive names: `feature/user-authentication`, `fix/login-bug`
- Include issue numbers: `fix/issue-123`
- Use slashes for hierarchy: `feature/api/v2-integration`

### Worktree Paths
- Keep paths relative to project root
- Use consistent naming: `features/`, `fixes/`, `docs/`
- Avoid spaces in paths (use hyphens or underscores)

## Workflows

### Basic Feature Development
1. Create worktree: `wt add -b main feature/new-feature features/new-feature`
2. Switch to worktree: `wt sw features/new-feature`
3. Make changes and commit
4. Push to remote: `git push origin feature/new-feature`
5. Create pull request: `wt pr --fill --web`
6. Switch back: `wt sw main`
7. Delete when done: `wt rm features/new-feature`

### Hotfix Workflow
1. Create from production: `wt add -b production hotfix/urgent-fix hotfix/urgent-fix`
2. Fix the issue
3. Merge back to production and main using `wt merge`
4. Delete worktree

### Multiple Features
1. Create separate worktrees for each feature
2. Work independently without conflicts
3. Integrate when ready using `wt merge` or `wt pr`
4. Clean up completed worktrees

### Using the Merge Command
The `wt merge` command simplifies merging your current worktree branch into a target branch:

```bash
# Preview the merge before executing
wt merge --dry-run -t main

# Merge to main branch
wt merge -t main

# Merge to develop branch
wt merge -t develop
```

### Using the PR Command
The `wt pr` command streamlines pull request creation:

```bash
# Auto-fill title and body from commits
wt pr --fill

# Create draft PR for review
wt pr -d --fill

# Create PR and open in browser
wt pr --fill --web

# Specify base branch
wt pr --fill -b develop
```

## Common Pitfalls to Avoid

### 1. Don't Lose Track
- Use `wt ls -v` to see all worktrees
- Regularly prune deleted worktrees: `wt prune`
- Document worktree purpose if needed

### 2. Manage Shared History
- Rebase frequently to stay updated with base branch
- Be careful when force pushing worktree branches
- Use `git pull --rebase` to keep history clean

### 3. Avoid Name Conflicts
- Don't create worktrees with existing branch names
- Use unique paths for each worktree
- Clean up unused worktrees promptly

### 4. Handle Conflicts
- Resolve conflicts in the worktree context
- Use `wt merge --dry-run` to preview merges before executing
- Test worktree changes before integration

### 5. Merge Best Practices
- Always use `--dry-run` first to preview merge impact
- Ensure your worktree branch is up to date before merging
- Resolve any conflicts locally before running `wt merge`
- The merge command works on your current branch, so verify your location

### 6. PR Best Practices
- Use `--fill` to auto-generate descriptions from commit messages
- Create draft PRs (`-d`) for initial review
- Write clear, descriptive commit messages for better auto-fill results
- Use `--web` to review the PR in browser immediately after creation

## Tips

### Performance
- Worktrees share git history, so they're space-efficient
- Initial checkout takes time, but subsequent operations are fast
- Use `wt ls --json` for scripting

### Safety
- Always check worktree status before deletion
- Use `--force` option only when necessary
- Backup important work before removing worktrees
- Use `wt merge --dry-run` before actual merges

### Integration
- Work with regular git commands inside worktrees
- Use `git branch -a` to see all branches
- Switch worktrees with `cd` or `wt sw`
- The `wt merge` and `wt pr` commands integrate with your existing GitHub workflow

### Command Preference
- Use `wt` instead of the legacy `worktree` command
- The `wt` command is shorter and more modern
- All `worktree` commands are aliased under `wt`
- Both commands work the same, but `wt` is preferred

## Git Integration

### Inside a Worktree
All standard git commands work normally:
```bash
cd features/new-feature
git status
git add .
git commit -m "feat: implement new feature"
git push origin feature/new-feature
```

### Using wt merge with Git
```bash
# Inside your feature worktree
cd features/new-feature

# Update your branch first
git pull --rebase origin feature/new-feature

# Merge to main using wt merge
wt merge -t main
```

### Using wt pr with Git
```bash
# Inside your feature worktree
cd features/new-feature

# Make sure your branch is pushed
git push origin feature/new-feature

# Create PR using wt pr
wt pr --fill --web
```
