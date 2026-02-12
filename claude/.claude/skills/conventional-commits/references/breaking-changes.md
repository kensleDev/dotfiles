# Breaking Changes

How to properly annotate and document breaking changes in your commits.

## What is a Breaking Change?

A breaking change is any change that modifies the public API or behavior in a way
that would require existing consumers to update their code.

Examples:
- Removing or renaming a function, parameter, or field
- Changing a function signature
- Modifying the return type of a function
- Changing behavior that code might depend on
- Removing configuration options

## Syntax

There are **two ways** to indicate a breaking change:

### Method 1: Exclamation Point

Place a `!` before the colon `:` in the subject line:

```
feat(api)!: remove legacy endpoint

The /v1/users endpoint has been removed.
Use /v2/users instead.
```

### Method 2: BREAKING CHANGE Footer

Add `BREAKING CHANGE: ` followed by a description in the footer:

```
feat(api): remove legacy endpoint

BREAKING CHANGE: the /v1/users endpoint no longer exists.
Use /v2/users instead.
```

You can also use both methods for clarity:

```
feat(api)!: remove legacy endpoint

BREAKING CHANGE: the /v1/users endpoint no longer exists.
Use /v2/users instead.
```

## Migration Path

When documenting breaking changes, include:

1. **What changed**: Describe what was removed or modified
2. **Why it changed**: Brief justification
3. **How to migrate**: Steps for consumers to update

```
feat(api)!: change user response structure

User responses now use snake_case for all fields.

BREAKING CHANGE: User object fields renamed from camelCase to snake_case.
- `firstName` → `first_name`
- `lastName` → `last_name`
- `userId` → `user_id`

Migration: Update all field references to use snake_case.
```

## Examples by Type

### Removing a Feature

```
feat(auth)!: remove basic authentication

BREAKING CHANGE: Basic auth is no longer supported.
Migrate to OAuth2 or API key authentication.
```

### Changing a Function Signature

```
fix(utils)!: parseDate now requires timezone

BREAKING CHANGE: parseDate() now requires a timezone argument.
Previously defaulted to UTC. Update all calls to include timezone.

Before: parseDate('2024-01-01')
After:  parseDate('2024-01-01', 'UTC')
```

### Renaming a Field

```
feat(api)!: rename userId to id

BREAKING CHANGE: User object `userId` field renamed to `id`.
Update all API consumers to use the new field name.
```

### Modifying Behavior

```
fix(validation)!: throw on invalid input

BREAKING CHANGE: Validation functions now throw on invalid input
instead of returning false. Update error handling accordingly.

Before:
if (!validate(data)) { handle(); }

After:
try { validate(data); }
catch { handle(); }
```

## Multiple Breaking Changes

If a commit has multiple breaking changes, list each one:

```
feat(api)!: restructure user endpoints

BREAKING CHANGE: Multiple user endpoint changes:

1. GET /users - now requires authentication
2. POST /users - email is now required
3. DELETE /users/:id - now returns 204 instead of 200

Update all API consumers accordingly.
```

## Commits vs Release Notes

- **Commit breaking changes**: Document specific API changes for that commit
- **Release notes**: Aggregate breaking changes for the entire release

Use tools like `conventional-changelog` to automatically generate
CHANGELOG.md from your commit messages.
