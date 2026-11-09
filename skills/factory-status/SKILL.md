---
name: factory-status
description: Show what the my-factory plugin currently contains (agents, workflows, skills) and which rollout phase it is in. Use when asked "factory status", "what's in my factory", or to check the plugin loaded (for example from a phone session).
---

# Factory status

1. List the files under `${CLAUDE_PLUGIN_ROOT}/agents`, `${CLAUDE_PLUGIN_ROOT}/workflows` and `${CLAUDE_PLUGIN_ROOT}/skills`.
2. Read the "Rollout" table in `${CLAUDE_PLUGIN_ROOT}/PLAN.md` and find the first phase not marked done.
3. Reply in at most 6 lines: plugin version, counts of agents / workflows / skills with their names, the current phase, and the single next step from that phase.
