# Best Practices

Recommendations for working with conventional commits in your workflow.

## Commit Granularity

### One Thing Per Commit

Each commit should do one thing. This makes:
- Code review easier
- Bisection for bugs simpler
- Cherry-picking to branches cleaner

**Good:**
```
feat(api): add user authentication
fix(api): resolve token expiration issue
docs(api): document auth endpoints
```

**Bad:**
```
feat: add auth and fix bugs and update docs
```

### When to Squash

Squash commits when:
- Creating PRs from many WIP commits
- Merging feature branches to main
- Cleaning up "fix typo" follow-up commits

Don't squash when:
- Each commit is a meaningful step
- You want to preserve atomic revert capability
- The commit history tells a story

### When to Rebase

Rebase when:
- Keeping linear history is important
- You want to integrate upstream changes before merging
- Cleaning up local commits before pushing

Don't rebase when:
- Commits have been pushed to shared branches
- The exact commit history matters for audit
- Working on a shared branch with others

## Branch Naming

Pair branch names with commit types:

| Branch Pattern | Commit Type |
|----------------|-------------|
| `feat/` | `feat` commits |
| `fix/` | `fix` commits |
| `docs/` | `docs` commits |
| `refactor/` | `refactor` commits |
| `hotfix/` | `fix` commits |

Examples:
- `feat/add-oauth-authentication` → `feat(auth): add OAuth`
- `fix/token-expiration` → `fix(auth): resolve token expiration`

## Commit Message Flow

1. **Stage changes**: `git add <files>`
2. **Write commit**: `git commit` (opens editor for multi-line)
3. **Push**: `git push`

### Editor Configuration

Set up Git to use your preferred editor:

```bash
# VS Code
git config --global core.editor "code --wait"

# Vim
git config --global core.editor "vim"

# Nano
git config --global core.editor "nano"
```

## Hooks and Automation

### Commit Message Linting

Use `commitlint` to enforce conventional commits:

```bash
npm install -D @commitlint/cli @commitlint/config-conventional
echo "export default { extends: ['@commitlint/config-conventional'] };" > commitlint.config.js
```

### Pre-commit Hook

Enforce formatting before committing:

```bash
# .husky/pre-commit
npm run lint
npm run format
```

### Commit-msg Hook

Validate commit message format:

```bash
# .husky/commit-msg
npx commitlint --edit $1
```

## Working with Teams

### Agree on Scopes

Document common scopes for your project:

```markdown
# .github/COMMITS.md

## Valid Scopes

- `api` - Backend API changes
- `ui` - Frontend UI changes
- `auth` - Authentication/authorization
- `database` - Database schema/migrations
- `docs` - Documentation
- `config` - Configuration changes
```

### Commit Template

Provide a team commit template:

```bash
# .gitmessage
# <type>(<scope>): <subject>
# |<----  Using a Maximum Of 50 Characters  ---->|

# Explain why this change is being made
# |<----   Try To Limit Each Line to a Maximum Of 72 Characters   ---->|

# Provide links or keys to any relevant tickets, articles or other resources
# Example: Fixes #23
```

Enable it:
```bash
git config --global commit.template .gitmessage
```

## Automatic Changelogs

Use semantic versioning with conventional commits:

- `feat`: triggers MINOR version bump
- `fix`: triggers PATCH version bump
- `BREAKING CHANGE`: triggers MAJOR version bump

Generate changelogs automatically:

```bash
npm install -D conventional-changelog-cli
npx conventional-changelog -p angular -i CHANGELOG.md -s
```

## Searching Git History

Find commits by type:

```bash
# All features
git log --oneline --grep="^feat"

# All fixes
git log --oneline --grep="^fix"

# All breaking changes
git log --oneline --grep="BREAKING CHANGE"
```

Find commits by scope:

```bash
# All auth changes
git log --oneline --grep="auth"

# All API changes
git log --oneline --grep="api"
```
