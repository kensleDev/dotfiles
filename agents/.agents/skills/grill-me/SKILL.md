---
name: grill-me
description: Interview the user one decision at a time to remove ambiguity from a coding feature, refactor, architecture change, or implementation idea, then produce a decision-complete implementation plan. Use explicitly before implementation when requirements, UX, scope, edge cases, or technical tradeoffs need to be resolved. Do not implement code while this skill is active.
---

# Grill Me

Treat the user's text after this skill invocation as the objective to refine into an implementation-ready plan.

## Outcome

Reach shared understanding with the user, then produce a plan detailed enough that `$luna-orchestrator` can execute it without inventing product decisions.

Do not implement the feature, edit product code, or begin the orchestration phase while this skill is active.

## Interview workflow

1. Investigate before questioning.
   - Read applicable `AGENTS.md` files and relevant project documentation.
   - If `graphify` is available, scan the repository before manual inspection with `graphify extract . --no-cluster --out <temporary-directory>`. If semantic extraction needs an API key, retry with `--code-only`; never install graphify or wait for credentials. Use any graph output to orient the investigation, then continue normally if graphify is unavailable, fails, or finds nothing.
   - Inspect the existing implementation, architecture, conventions, tests, schemas, and Git status.
   - Use repository evidence to answer factual or technical questions yourself.
   - Never ask the user for information that can be discovered reliably from the codebase, configuration, documentation, or available tools.

2. Establish the current hypothesis.
   - Briefly state what you currently believe the user wants.
   - Identify the most consequential unresolved decision.
   - Do not dump a full questionnaire or premature plan.

3. Interview relentlessly but efficiently.
   - Ask exactly one question per turn.
   - Walk the decision tree in dependency order so earlier answers narrow later questions.
   - For every question, provide a clearly marked recommended answer and a concise reason.
   - When practical, offer two to four concrete choices, with the recommendation first.
   - Accept a simple confirmation when your recommendation is suitable.
   - Challenge vague answers, contradictions, hidden assumptions, unnecessary complexity, and scope creep.
   - Ask a follow-up when an answer still leaves a material implementation decision unresolved.

4. Cover only relevant decision areas.
   Consider these branches, but skip any that repository evidence or prior answers already settle:
   - user outcome and success criteria;
   - in-scope behavior and explicit non-goals;
   - user journeys, interaction details, and responsive behavior;
   - domain rules, state transitions, and edge cases;
   - data model, persistence, migrations, and lifecycle;
   - API, event, action-router, and integration contracts;
   - authentication, authorization, privacy, and destructive actions;
   - validation, errors, retries, offline behavior, and failure recovery;
   - compatibility, rollout, observability, and rollback;
   - testing expectations and acceptance evidence.

5. Avoid over-interviewing.
   - Stop when remaining uncertainty is low-risk, reversible, or already governed by repository convention.
   - Do not ask taste questions with no meaningful effect on the implementation.
   - Prefer the smallest coherent scope that achieves the user's outcome.

## Final synthesis

When all material branches are resolved:

1. Restate the agreed intent and ask for one final confirmation before producing the plan.
2. After confirmation, produce a decision-complete implementation plan containing:
   - objective and user-visible outcome;
   - confirmed decisions;
   - scope and non-goals;
   - relevant existing architecture and constraints;
   - ordered implementation phases;
   - concrete work packages with likely files or modules;
   - data, API, UI, and integration contracts where applicable;
   - edge cases and failure behavior;
   - migrations, compatibility, rollout, and rollback where applicable;
   - acceptance criteria;
   - targeted and broader validation commands;
   - risks and any explicitly deferred follow-ups.
3. Mark assumptions clearly. There should be no unresolved decision that would force an implementation agent to guess about user intent.
4. Do not include speculative extras merely because they might be useful later.

## Optional saved plan

If the invocation includes `--save`:

- Save the approved final plan under `.codex/plans/<descriptive-slug>.md`.
- Create `.codex/plans/` if necessary.
- Use a stable descriptive filename rather than a generic `plan.md`.
- Report the exact path.
- Do not modify any other repository files.

Without `--save`, return the final plan in the conversation only.

## Handoff

End with the exact next invocation appropriate to the chosen mode:

- Conversation plan: `$luna-orchestrator Execute the agreed plan above.`
- Saved plan: `$luna-orchestrator Execute the plan in .codex/plans/<descriptive-slug>.md.`
