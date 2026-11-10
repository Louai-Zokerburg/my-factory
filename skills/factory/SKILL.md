---
name: factory
description: Louai's factory help desk - what the my-factory plugin can do, which workflow fits a task, what to type, and the current status. Use when asked "factory help", "factory status", "what can my factory do", "which workflow should I use", "how do I fix/review/build X with the factory", or to check the plugin loaded (for example from a phone session).
---

# Factory

The cheat sheet lives in `${CLAUDE_PLUGIN_ROOT}/USAGE.md`. Read it before answering.

## If asked for help or "what can it do"

Reply with the "What to type" table from USAGE.md, unchanged, and one line: "Tell me the ticket or PR and I'll pick the workflow."

## If the person describes a task

Pick the one workflow that fits from the "What to type" table. Say which and why in one line, show the exact args, and ask "Run it?" before starting. Use these rules:

- A small bug in an existing feature → `my-factory:small-bug`
- A ticket whose cause is unknown → `my-factory:support-ticket` first
- Comments on Louai's own PR → `my-factory:colleague-review`
- Someone else's PR to review → run the four reviewer agents (security, quality, ui if web changed, test-verifier with no file edits) against the PR's base branch, then draft one review; post nothing without a yes
- A visual change in packages/web → `my-factory:ui-update`
- More than one PR of work → `my-factory:big-feature`, stage `plan` first

## If asked for status

1. List `${CLAUDE_PLUGIN_ROOT}/agents`, `${CLAUDE_PLUGIN_ROOT}/workflows` and `${CLAUDE_PLUGIN_ROOT}/skills`.
2. Read the Rollout table in `${CLAUDE_PLUGIN_ROOT}/PLAN.md`.
3. Reply in at most 6 lines: plugin version, the agent / workflow / skill names, and anything in Rollout not marked done.
