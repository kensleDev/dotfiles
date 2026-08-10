# Commit Message Format

The Conventional Commits specification defines a standard format for commit messages.

## Structure

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

## Subject Line

The subject line contains a succinct description of the change:

- **Required**: type and description
- **Optional**: scope
- **Format**: `<type>[optional scope]: <description>`
- **Colon**: required after type/scope
- **Space**: required after colon

### Rules

1. **Use imperative mood**: "add feature" not "added feature" or "adds feature"
2. **Don't capitalize first letter**: "add feature" not "Add feature"
3. **No period at end**: "add feature" not "add feature."
4. **Limit to 50 characters**: Keep it concise and scannable
5. **Lowercase type**: `feat` not `Feat` or `FEAT`

### Examples

```
feat(api): add user authentication endpoint
fix(ui): resolve button alignment issue
docs(readme): update installation steps
style(components): fix indentation
```

## Body

The body should include the motivation for the change and contrast this with previous behavior:

- **Optional**: Only for significant changes
- **Format**: Free text, wrap at 72 characters
- **Content**: What changed and why
- **Separation**: Blank line between subject and body

### Examples

```
feat(api): add user authentication endpoint

Implement OAuth2 flow with support for Google and GitHub providers.
Tokens are stored securely in httpOnly cookies with automatic refresh.
```

```
fix(database): resolve connection pool exhaustion

The previous implementation kept connections open indefinitely.
Now connections are properly released after query execution.
```

## Footer

The footer should contain any metadata about the commit, such as:

- **Breaking changes**: `BREAKING CHANGE: description`
- **Closes issues**: `Closes #123`, `Fixes #456`
- **References**: `Refs #789`

### Breaking Changes

A breaking change is indicated by a `!` before the `:` in the subject line, OR by adding `BREAKING CHANGE: ` in the footer.

```
feat(api)!: remove legacy endpoint

The old /v1/users endpoint has been removed.
Use /v2/users instead.

BREAKING CHANGE: the /v1/users endpoint no longer exists
```

### Issue References

```
feat(auth): add password reset flow

Closes #123
Fixes #456
Refs #789
```

## Complete Example

```
feat(auth): add password reset flow

Users can now request a password reset email which contains
a secure token valid for 24 hours. The token is stored in
Redis for fast validation.

Closes #123
```

## Line Length Guidelines

| Section | Max Length |
|---------|------------|
| Subject | 50 characters |
| Body lines | 72 characters |
| Footer lines | 72 characters |

## Why Imperative Mood?

Using imperative mood ("add" not "added") makes commits consistent with Git's
auto-generated messages: `Merge branch 'feature'` vs `Merged branch 'feature'`.

It also makes git history more readable and searchable.
