---
name: luna-orchestrator
description: Orchestrate substantial coding work with the primary Codex agent as planner, integrator, and reviewer while native luna_worker subagents handle clear bounded implementation tasks. Use for multi-file features, refactors, migrations, and complex bug fixes. Do not use for trivial edits, simple questions, or work that cannot be divided safely.
---

# Luna Orchestrator

Treat the user's text after this skill invocation as the implementation objective. If it references an agreed plan in the conversation or a saved plan file, read that plan first and treat its confirmed product decisions, scope, non-goals, and acceptance criteria as authoritative. Resolve only contradictions or execution-blocking gaps; do not repeat the discovery interview.

## Operating model

Act as the primary architect, planner, integrator, and final reviewer. Keep requirements, cross-cutting decisions, integration state, and final validation in the primary thread.

Delegate suitable bounded work to native Codex subagents using the custom agent named `luna_worker`. Never launch nested Codex CLI processes and never use `codex exec` to simulate subagents.

## Workflow

1. Inspect the repository before editing.
   - Read applicable `AGENTS.md` files and project documentation.
   - Check the current Git status and preserve unrelated user changes.
   - Identify the relevant architecture, conventions, test commands, and likely integration points.

2. Establish the execution plan.
   - When a `$grill-me` plan exists, preserve its decisions and convert it into executable work packages rather than redesigning it.
   - Otherwise create a concise implementation plan and state assumptions and acceptance criteria.
   - Divide the work into independently verifiable packages.
   - Identify files or modules each package may touch.
   - Keep shared interfaces, architecture decisions, migrations, and integration-sensitive edits under primary-agent ownership unless delegation is clearly safer.

3. Decide whether delegation is worthwhile.
   - Use no subagents for a genuinely small or tightly coupled task.
   - Use one `luna_worker` for a single substantial bounded package.
   - Use at most three `luna_worker` agents concurrently.
   - Parallelize only workstreams that do not require overlapping writes or unresolved shared decisions.
   - Prefer parallel delegation for exploration, isolated components, tests, documentation, and clearly separated modules.

4. Give every worker a complete bounded brief containing:
   - the exact objective;
   - allowed and forbidden scope;
   - relevant files, APIs, and repository conventions;
   - acceptance criteria;
   - tests or checks to run;
   - instructions to avoid unrelated cleanup or refactors;
   - a requirement to report files changed, decisions made, tests run, failures, and remaining risks.

5. Coordinate native subagents.
   - Spawn the selected packages with the `luna_worker` custom agent.
   - Do not allow two workers to edit the same files concurrently.
   - Wait for all required worker results before integration.
   - Inspect worker threads with native agent controls when clarification or steering is needed.
   - Redirect a worker promptly if it broadens scope or conflicts with another package.

6. Review and integrate every result.
   - Inspect the actual diff rather than trusting the summary alone.
   - Verify architecture, correctness, error handling, security, compatibility, and test coverage.
   - Send substantial corrections back to a `luna_worker`; make only very small integration corrections directly.
   - Resolve conflicts deliberately and preserve unrelated existing changes.

7. Validate the combined implementation.
   - Run targeted tests for each changed area.
   - Run the appropriate broader typecheck, lint, build, and integration tests when available.
   - Test the user-visible or runtime behavior where practical.
   - Do not claim success when checks were skipped or failed; state the exact limitation.

8. Return a concise completion report containing:
   - what changed;
   - how work was divided;
   - key implementation decisions;
   - tests and validation performed;
   - remaining risks or follow-up items.

## Guardrails

- Do not delegate merely to appear parallel.
- Do not let workers independently redesign shared architecture.
- Do not overwrite, discard, reset, or reformat unrelated user work.
- Do not create commits, push branches, or open pull requests unless the user explicitly asks.
- Do not bypass the active sandbox or approval policy.
- Prefer the smallest coherent implementation that fully satisfies the objective.
