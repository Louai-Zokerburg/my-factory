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
| roadmap | Weekly AI-center digest (see below). |

## Workflows

1. **small-bug**: ticket, failing test, fix, quality + security review, PR (`Fixes ENG-x`).
2. **colleague-review**: unresolved threads via `gh`, sort into clear fix / question / disagree; push clear fixes, draft replies for approval. Never resolve a disagreement alone.
3. **support-ticket**: read ticket, `/debug-failed-run` + `/analyze-logs`, decide bug / config / feature, findings to ticket. Bugs go to small-bug. GIT tickets are public.
4. **ui-update**: before screenshots, change, after screenshots, ui-reviewer, PR with gallery.
5. **big-feature**: research, PRD into ticket `Acceptance criteria` / `Decisions`, split into PRs, then per PR: worktree, implement, 4 reviewers in parallel, fix, PR. Approval after PRD, after split, before each PR goes to review.
6. **roadmap** (weekly cloud routine), three sections:
   - New models: OpenRouter `/models` + models.dev vs the 19 providers and Fast/Expert/Heavy tiers; suggest tier moves.
   - Unblockers: open follow-ups from `brain/knowledge/ai-intelligence` (e.g. `ai` SDK pinned at 7.0.44, Agent OpenAI web search).
   - Features and refactors: Anthropic / OpenAI / Gemini changelogs, AI SDK releases, Simon Willison; diff against last week's snapshot.

## Phone

- Cloud sessions (claude.ai/code, mobile app) for factory runs.
- Remote Control (`claude remote-control`) for local runs needing the dev stack.
- Routines (`/schedule`) for cron and GitHub-triggered jobs.
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
| 1 | 4 reviewer agents + small-bug workflow + roadmap routine | 3 to 4 h | agents done, tested on fix/ai-usage-platform-filter |
| 2 | Cloud environment for activepieces (setup script) | half a day, riskiest | |
| 3 | colleague-review, support-ticket, ui-update workflows | half a day | |
| 4 | big-feature workflow | 1 day + tuning | |
