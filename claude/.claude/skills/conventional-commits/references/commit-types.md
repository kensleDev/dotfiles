# Commit Types

Detailed explanations of each conventional commit type and when to use them.

## Types

### `feat` — New Feature
A new feature for the user. This introduces a new capability or functionality.

**Examples:**
- `feat(api): add user authentication endpoint`
- `feat(ui): implement dark mode toggle`
- `feat(database): add support for PostgreSQL`

### `fix` — Bug Fix
A bug fix for the user. This changes existing behavior to fix a problem.

**Examples:**
- `fix(auth): resolve token expiration issue`
- `fix(ui): correct button alignment on mobile`
- `fix(api): handle null response from server`

### `docs` — Documentation
Documentation only changes. This includes updating README, inline comments, or API docs.

**Examples:**
- `docs(readme): update installation instructions`
- `docs(api): add JSDoc comments to auth module`
- `docs(guide): fix typo in contributing guide`

### `style` — Style Changes
Changes that don't affect code meaning: whitespace, formatting, semicolons, etc.

**Examples:**
- `style(components): fix indentation in Button.tsx`
- `style(utils): format with Prettier`
- `style(css): convert to single quotes`

### `refactor` — Code Refactoring
A code change that neither fixes a bug nor adds a feature. This improves code structure without changing behavior.

**Examples:**
- `refactor(api): extract validation to separate module`
- `refactor(utils): simplify date parser logic`
- `refactor(components): convert to functional components`

### `perf` — Performance Improvement
A code change that improves performance.

**Examples:**
- `perf(api): add response caching`
- `perf(database): add index to user table`
- `perf(ui): implement virtual scrolling for lists`

### `test` — Tests
Adding or updating tests. This includes unit, integration, and e2e tests.

**Examples:**
- `test(auth): add unit tests for login`
- `test(api): add integration tests for endpoints`
- `test(e2e): update user flow tests`

### `build` — Build System
Changes that affect the build system or external dependencies.

**Examples:**
- `build(gradle): update dependencies`
- `build(webpack): add plugin for code splitting`
- `build(docker): optimize image size`

### `ci` — CI Configuration
Changes to CI configuration files and scripts.

**Examples:**
- `ci(github): add workflow for automated tests`
- `ci(circleci): update build cache settings`
- `ci(jenkins): add deployment pipeline`

### `chore` — Chores
Other changes that don't modify src or test files. This includes dependency updates, config changes, etc.

**Examples:**
- `chore(deps): bump lodash to v4.17.21`
- `chore(config): update .eslintrc rules`
- `chore(tools): update prettier config`

### `revert` — Revert
Reverts a previous commit. The subject should reference the commit being reverted.

**Examples:**
- `revert: feat(api): remove experimental endpoint`
- `revert: fix(auth): revert token fix due to regression`

## Choosing the Right Type

| Scenario | Type |
|----------|------|
| Adding a new feature | `feat` |
| Fixing a bug | `fix` |
| Updating documentation | `docs` |
| Formatting/cleanup | `style` |
| Restructuring code | `refactor` |
| Improving performance | `perf` |
| Adding tests | `test` |
| Build changes | `build` |
| CI/CD changes | `ci` |
| Dependency updates | `chore` |
| Reverting changes | `revert` |

## Scopes

Scopes are optional but provide additional context. Common scopes include:

- Module names: `api`, `auth`, `database`, `utils`
- Layer names: `client`, `server`, `middleware`
- Component names: `button`, `modal`, `navbar`
- Functional areas: `logging`, `caching`, `validation`

Choose scopes that match your project structure.
