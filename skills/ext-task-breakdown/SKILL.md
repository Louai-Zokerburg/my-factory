---
name: ext-task-breakdown
description: Break an approved Activepieces master plan into ordered, vertically sliced PRs with dependencies and checkpoints, in Louai's ledger format. Use ONLY when the my-factory big-feature workflow (stage split) points to it, or Louai says "factory breakdown".
---

# Task breakdown (adapted from addyosmani/agent-skills `planning-and-task-breakdown`, MIT, © Addy Osmani)

1. **Dependency graph:** list what must exist before what (schema → service → endpoint → UI).
2. **Slice vertically:** each PR ships one working path end to end and can merge alone. Never "all backend" then "all frontend".
3. **Size:** S (≤1 day) or M (≤3 days). An L PR gets split.
4. **Each PR gets:** number, title, slug, scope (2–3 sentences), acceptance criteria with E2E markers (``E2E: `<title>` `` or `no-e2e: <reason>`), depends-on, touchesWeb, size.
5. **Checkpoints:** after each PR the app still builds, tests pass, and nothing user-facing is half-done (hide it behind a flag or keep it unreachable).
6. **Write the files** in `~/work/plans/<feature>/`:
   - `ledger.md`: Louai's ledger format (status-truth header, States line, Phase, PRs table, Log table), every PR `planned`.
   - `pr-<n>-<slug>.md` stub per PR: scope, criteria, depends-on, and an empty `## Questions` section the per-PR plan session fills.
7. List risks and open questions at the end of `master-plan.md`.
