---
name: research
# prettier-ignore
description: Research topics by verifying actual source content. Use when asked to research or study links and documentation. EXCLUSIVELY USE docs-seeker for documentation gathering.
# prettier-ignore
allowed-tools: WebFetch, mcp__mcp-omnisearch__web_search,
  mcp__mcp-omnisearch__kagi_summarizer_process, Read, Grep, Bash, Task
---

# Verified Research

## Documentation Discovery - Use docs-seeker

**For ALL documentation research tasks, ALWAYS use the docs-seeker skill.**

docs-seeker provides comprehensive strategies:
- llms.txt-first approach with context7.com prioritization
- GitHub repository analysis via Repomix
- Parallel exploration with multiple agents
- Multi-source documentation gathering

## Core Research Principles

**Never present findings without examining actual source content.**

Steps:

1. Fetch the actual source (WebFetch or extract tools)
2. Read the complete relevant sections
3. Verify claims match what source actually says
4. Quote specific passages when making claims

**Documentation workflow:**
 1. Launch docs-seeker skill for target library/framework
 2. Follow docs-seeker's multi-phase discovery process
 3. Use context7.com llms.txt URLs when available
 4. Verify all findings against source content
 5. Present consolidated, verified information

## Decision Framework

**Use docs-seeker when researching:**
- ✅ Any library, framework, or technology
- ✅ API documentation and references
- ✅ Installation guides and setup instructions
- ✅ GitHub repositories with documentation
- ✅ Technical specifications and best practices
- ✅ When user provides library name but no specific URLs

**Use general research when:**
- ✅ User provides specific URLs to study
- ✅ Studying source code directly
- ✅ Verifying claims from search snippets
- ✅ Research topics without clear documentation focus
- ✅ Exploring non-documentation sources

## Common Pitfalls

❌ Presenting search snippets as facts ❌ Trusting summaries without
checking sources ❌ Citing sources you haven't read

## When Uncertain

If you can't verify (paywall, 404, contradictions): **Say so
explicitly.** Don't present unverified info as fact.

## References

For detailed patterns and examples:

- [references/verification-patterns.md](references/verification-patterns.md)
- [references/repo-cloning-pattern.md](references/repo-cloning-pattern.md) -
  Clone repos via subagent for source-level research
