# Worktree CLI Workflow Examples

## Example 1: Feature Branch Development

### Scenario
You need to work on a new user authentication feature while keeping your main branch clean for production releases.

### Commands
```bash
# Create a new worktree for the feature
wt add -b main feature/user-authentication features/user-authentication

# Switch to the worktree
wt sw features/user-authentication

# Make changes (inside the worktree directory)
git add .
git commit -m "feat: add user authentication components"
git push origin feature/user-authentication

# Create a pull request with auto-filled details
wt pr --fill --web

# After merge, switch back to main branch
wt sw main

# Continue with other work
```

### Cleanup
```bash
# When the feature is complete and merged
wt rm features/user-authentication
```

## Example 2: Hotfix Workflow

### Scenario
An urgent bug fix is needed in production that can't wait for the next release cycle.

### Commands
```bash
# Create worktree from production branch
wt add -b production hotfix/login-bug hotfix/login-bug

# Fix the bug
cd hotfix/login-bug
git add .
git commit -m "fix: resolve login error in production"

# Push to remote
git push origin hotfix/login-bug

# Use wt merge to merge to main
wt merge -t main

# Switch to production and merge
wt sw production
wt merge -t hotfix/login-bug

# Push production branch
git push origin production

# Cleanup
wt rm hotfix/login-bug
```

## Example 3: Multiple Parallel Features

### Scenario
You need to work on two different features simultaneously without context switching.

### Commands
```bash
# Create first feature worktree
wt add -b main feature/payment-integration features/payment-integration

# Create second feature worktree
wt add -b main feature/search-api features/search-api

# Switch between worktrees as needed
wt sw features/payment-integration
# ... work on payment integration ...

wt sw features/search-api
# ... work on search API ...

# List all worktrees to see status
wt ls -v

# Create PRs when ready
wt sw features/payment-integration
wt pr --fill --web

wt sw features/search-api
wt pr --fill --web

# Clean up when done
wt rm features/payment-integration
wt rm features/search-api
```

## Example 4: Environment Management

### Scenario
You need separate environments for development, staging, and testing.

### Commands
```bash
# Create environment worktrees
wt add -b main development environments/development
wt add -b main staging environments/staging
wt add -b main testing environments/testing

# Switch to environment as needed
wt sw environments/development
# ... development work ...

wt sw environments/staging
# ... staging deployment ...

# Cleanup when project is complete
wt prune  # Remove administrative files for deleted worktrees
```

## Example 5: Code Review Integration

### Scenario
You need to review a colleague's branch changes before merging.

### Commands
```bash
# Create worktree from the colleague's branch
wt add colleague/feature-x review/feature-x review/feature-x

# Review the code
cd review/feature-x
git log --oneline -10
git diff main...HEAD

# Make comments or suggestions
git checkout -b review-comments
# Add comments or fixes
git add .
git commit -m "review: add suggestions for feature-x"

# Push review branch
git push origin review-comments

# Switch back and clean up
wt sw main
wt rm review/feature-x
```

## Example 6: Experimental Development

### Scenario
You want to try out a new approach without affecting your current work.

### Commands
```bash
# Create experimental worktree
wt add -b main experimental/new-approach experimental/new-approach

# Try out new ideas
cd experimental/new-approach
git checkout -b experiment-v1

# When experiment fails, easily clean up
cd ..
wt rm experimental/new-approach

# Or if experiment shows promise
git add .
git commit -m "experiment: initial implementation"
git push origin experiment-v1

# Create PR for review
wt pr -d --fill  # Create as draft first
```

## Example 7: Documentation Updates

### Scenario
You need to update documentation while keeping your main branch clean.

### Commands
```bash
# Create documentation worktree
wt add -b main docs/api-upgrade docs/api-upgrade

# Update documentation
cd docs/api-upgrade
# Edit markdown files
git add .
git commit -m "docs: update API documentation for v2"

# Preview changes
git show

# When ready, merge and clean up
wt sw main
wt merge -t docs/api-upgrade
git push origin main
wt rm docs/api-upgrade
```

## Example 8: Using Merge Command Effectively

### Scenario
You want to safely merge your feature branch to main using the built-in merge command.

### Commands
```bash
# Create and work on feature
wt add -b main feature/database-migration features/database-migration
wt sw features/database-migration

# Make changes
git add .
git commit -m "feat: add database migration scripts"
git push origin feature/database-migration

# Preview merge before executing
wt merge --dry-run -t main

# If preview looks good, execute the merge
wt merge -t main

# Push the merged changes to main
wt sw main
git push origin main
```

## Example 9: Pull Request Workflow

### Scenario
Complete PR workflow from feature creation to review.

### Commands
```bash
# Create feature worktree
wt add -b main feature/oauth-integration features/oauth-integration
wt sw features/oauth-integration

# Make changes with descriptive commits
git add .
git commit -m "feat: add OAuth2 authentication provider"
git commit -m "feat: add token refresh logic"
git commit -m "test: add integration tests for OAuth"

# Push to remote
git push origin feature/oauth-integration

# Create PR with auto-filled title and body from commits
wt pr --fill

# Or create as draft for initial review
wt pr -d --fill

# Create PR and open in browser to review
wt pr --fill --web

# After review, make amendments and push
git add .
git commit -m "fix: address review comments"
git push origin feature/oauth-integration

# Merge when approved
wt merge -t main
```

## Example 10: PR with Custom Details

### Scenario
You need to create a PR with custom title and description.

### Commands
```bash
# Create worktree and make changes
wt add -b main feature/caching-layer features/caching-layer
wt sw features/caching-layer

# Make changes
git add .
git commit -m "feat: implement Redis caching layer"
git push origin feature/caching-layer

# Create PR with custom title and body
wt pr -t "Add Redis Caching Layer" \
    --body "This PR implements a Redis-based caching layer to improve API response times.

## Changes
- Added Redis client configuration
- Implemented cache middleware
- Added cache invalidation logic
- Updated documentation

## Testing
- Added unit tests for cache operations
- Manual testing with Redis local instance

## Checklist
- [x] Tests pass
- [x] Documentation updated
- [x] No breaking changes"

# Or create draft and open in browser to finish
wt pr -d --web
```

## Example 11: Multi-Base Branch PR

### Scenario
You're working on a feature that should be merged to a development branch first, not main.

### Commands
```bash
# Create feature from develop branch
wt add -b develop feature/new-api-endpoint features/new-api-endpoint
wt sw features/new-api-endpoint

# Make changes
git add .
git commit -m "feat: add user profile API endpoint"
git push origin feature/new-api-endpoint

# Create PR against develop branch
wt pr --fill -b develop

# After merging to develop, you can later merge to main
wt sw main
wt merge -t develop
```

## Example 12: Batch Worktree Management

### Scenario
You have multiple completed worktrees to clean up.

### Commands
```bash
# List all worktrees with details
wt ls -v

# Remove completed worktrees
wt rm features/completed-feature-1
wt rm features/completed-feature-2
wt rm hotfix/resolved-bug

# Prune to clean up any orphaned metadata
wt prune

# Verify cleanup
wt ls -v
```

## Tips for Workflows

1. **Always check worktree status before deletion**
   ```bash
   wt ls -v
   ```

2. **Use descriptive names** for both branches and worktree paths

3. **Regularly prune** to clean up administrative files:
   ```bash
   wt prune
   ```

4. **Keep worktrees organized** with consistent directory structure

5. **Document complex worktrees** if multiple team members use them

6. **Preview merges** before executing:
   ```bash
   wt merge --dry-run -t main
   ```

7. **Use auto-fill for PRs** to save time:
   ```bash
   wt pr --fill
   ```

8. **Create draft PRs** for initial reviews:
   ```bash
   wt pr -d --fill
   ```

9. **Use the modern `wt` command** instead of legacy `worktree`

10. **Combine with git commands** inside worktrees for full workflow control
