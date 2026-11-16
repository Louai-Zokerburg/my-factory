# my-factory plan

Personal software factory on Claude Code, for Louai's work on Activepieces (AI center owner).
Personal, not team: lives in this repo as a user-scope plugin. It reads the team's rules in the
activepieces repo (`CLAUDE.md`, `.claude/rules/`, `brain/`) and never forks them.

## Principles

- Reviewers enforce the activepieces repo's own rules, not generic advice.
- Hard checks gate "done": tests, typecheck, lint. A `Stop` hook enforces them.
- A separate reviewer agent judges the work; the builder never grades itself.
- Human approval points are explicit and reachable from the phone.
- Small bugs get a small flow. The big multi-phase flow is only for big features.

## Agents

| Agent | Job |
|---|---|
| orchestrator | A workflow script, not an agent. Runs phases, stops at approval points. |
| ui-reviewer | Before/after screenshots (`pr-screenshots` skill), checks `brain/knowledge/design-system`. |
| security-reviewer | Edition leaks, `safeHttp` (SSRF), `projectId`/`platformId` filters, `securityAccess`, no secrets on public GIT tickets. |
| quality-reviewer | `CLAUDE.md` conventions and simplification. |
| test-verifier | Failing test first, runs it, checks E2E markers per the Linear rule. |
| researcher | Research + PRD for big features. |

## Workflows

1. **small-bug**: ticket, failing test, fix, quality + security review, PR (`Fixes ENG-x`).
2. **colleague-review**: unresolved threads via `gh`, sort into clear fix / question / disagree; push clear fixes, draft replies for approval. Never resolve a disagreement alone.
3. **support-ticket**: read ticket, `/debug-failed-run` + `/analyze-logs`, decide bug / config / feature, findings to ticket. Bugs go to small-bug. GIT tickets are public.
4. **ui-update**: before screenshots, change, after screenshots, ui-reviewer, PR with gallery.
5. **big-feature**: research, PRD into ticket `Acceptance criteria` / `Decisions`, split into PRs, then per PR: worktree, implement, 4 reviewers in parallel, fix, PR. Approval after PRD, after split, before each PR goes to review.

## Phone

- Cloud sessions (claude.ai/code, mobile app) for factory runs.
- Remote Control (`claude remote-control`) for local runs needing the dev stack.
- Push notifications when a run finishes or needs approval.

## Adopt / borrow

- Install: official `pr-review-toolkit`, `feature-dev`, `ralph-loop`.
- Borrow: HumanLayer research, plan, implement; Anthropic "long-running agents" (progress file, one feature per session); spec-kit phases.
- Skip: BMAD (token-heavy), whole collections like wshobson/agents.
- Verify before relying on: Linear native coding sessions, `/autofix-pr`.

## Rollout

| Phase | What | Estimate | Status |
|---|---|---|---|
| 0 | Plugin repo, Remote Control, notifications, tested from phone | 30 min | done (notifications: manual toggle in `/config`) |
| 1 | 4 reviewer agents + small-bug workflow | 3 to 4 h | done |
| 2 | Cloud environment for activepieces (setup script) | half a day, riskiest | done: live cloud run 380/380 tests pass (install 3 s, build 54 s); node 24 fixed and verified in cloud |
| 3 | colleague-review, support-ticket, ui-update workflows | half a day | built + mock-tested; live runs pending |
| 4 | big-feature workflow | 1 day + tuning | built + mock-tested (plan / split / build stages); live run pending |
| 5 | Daily use: USAGE.md, `factory` help skill, Remote Control service installer | 1 h | done; service install is Louai's to run; cloud sessions still lack the plugin (decision pending) |
| 6 | 0.11.0 upgrade (plan: ~/work/plans/factory-upgrade/): explicit-only triggers, plan session + question minimums, big-feature one PR per run in ~/work/plans, app lock + in-app verify (ap-dev, Playwright, DevTools), reviewer gaps closed, next actions on every ending, laptop-first docs | 1 day | built + mock-tested (26 scenarios); live runs pending |
