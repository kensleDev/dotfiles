---
name: conventional-commits
# IMPORTANT: Keep description on ONE line for Claude Code compatibility
# prettier-ignore
description: "Conventional Commits guidance. Create structured, semantic commits. Types include feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert."
---

# Conventional Commits

## Quick Start

**Format:** `type(scope?): subject` + body + footer

**Types:** `feat` (feature), `fix` (bug), `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`

**Rules:** Lowercase type, imperative mood ("add" not "added"), limit subject to 50 chars

```bash
feat(api): add user authentication endpoint

Implement OAuth2 flow with token refresh support.

Closes #123
```

## Quick Reference

| Type | Usage | Example |
|------|-------|---------|
| `feat` | New feature | `feat(auth): add OAuth login` |
| `fix` | Bug fix | `fix(api): resolve token expiration` |
| `docs` | Documentation | `docs(readme): update install steps` |
| `style` | Formatting | `style(components): fix indentation` |
| `refactor` | Code change | `refactor(utils): simplify parser` |
| `perf` | Performance | `perf(api): add response caching` |
| `test` | Tests | `test(auth): add unit tests` |
| `build` | Build system | `build(gradle): update deps` |
| `ci` | CI config | `ci(github): add workflow` |
| `chore` | Misc | `chore(deps): bump lodash` |
| `revert` | Revert | `revert: feat(api): old feature` |

## Reference Files

- [commit-types.md](references/commit-types.md) - Detailed type explanations
- [commit-message-format.md](references/commit-message-format.md) - Subject, body, footer rules
- [breaking-changes.md](references/breaking-changes.md) - How to annotate breaking changes
- [best-practices.md](references/best-practices.md) - When to squash, rebase, etc.

## Notes

- Use imperative mood: "add feature" not "added feature" or "adds feature"
- Scope is optional but recommended for mono-repos
- Breaking changes: add `!` after type/scope: `feat(api)!: remove legacy endpoint`
- **Last verified:** 2025-01-17

<!--
PROGRESSIVE DISCLOSURE GUIDELINES:
- Keep this file ~50 lines total (max ~150 lines)
- Use 1-2 code blocks only (recommend 1)
- Keep description <200 chars for Level 1 efficiency
- Move detailed docs to references/ for Level 3 loading
- This is Level 2 - quick reference ONLY, not a manual

LLM WORKFLOW (when editing this file):
1. Write/edit SKILL.md
2. Format (if formatter available)
3. Run: claude-skills-cli validate <path>
4. If multi-line description warning: run claude-skills-cli doctor <path>
5. Validate again to confirm
-->
