---
name: factory
description: Louai's my-factory help desk - what the plugin can do, which recipe fits a task, what to type, current status. Use ONLY when the message contains the word "factory" ("factory help", "factory status", "factory small-bug ENG-1") or /my-factory:factory. Never for normal coding, review or planning requests.
---

# Factory

The cheat sheet lives in `${CLAUDE_PLUGIN_ROOT}/USAGE.md`. Read it before answering. The factory runs from Louai's laptop only.

## "factory <recipe> <target>"
Load the `plan-session` skill and follow it. Every recipe starts there: it grills Louai, writes the plan file, and launches the run on "go".

## "factory help" / "what can it do"
Reply with the "What to type" table from USAGE.md, unchanged, and one line: "Tell me the ticket or PR and I'll pick the recipe."

## Louai describes a task and says "factory" (no recipe named)
Load the `pick` skill and follow it.

## "factory status"
1. List `${CLAUDE_PLUGIN_ROOT}/agents`, `workflows`, `skills` and `scripts`.
2. Run `bash ${CLAUDE_PLUGIN_ROOT}/scripts/app-lock.sh status` and `ap-dev status`.
3. Reply in at most 6 lines: plugin version, recipes, the app lock holder, whether a stack is running.

End every answer with 1–3 numbered next actions.
