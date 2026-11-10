# Using the factory

Lost? Type **`factory help`** in any Claude session, including on your phone.

## How it fits together

```
 YOU (phone or terminal)
   │  "run small-bug on AI-150"
   ▼
 A Claude session ──────────── where it runs ──────────────┐
   │  loads the my-factory plugin                          │
   │                                                       │
   ├─ Workflow  = the recipe: steps, order, stop points    │  Laptop (Remote Control):
   │     └─ Agents = specialists it calls                  │    your files, your dev stack,
   │          security · quality · ui · test-verifier      │    laptop must be on
   │                                                       │  Cloud (factory-activepieces):
   ├─ Skills   = how-to notes (roadmap, factory help)      │    laptop can be off,
   │                                                       │    works from GitHub only
   └─ Team rules from the activepieces repo                │
        CLAUDE.md, .claude/rules, brain/                   │
                                                           ┘
 Output: a draft PR, a draft reply, or a digest. Never merged, never posted, without you.
```

- **Workflow:** a script that runs several agents in a fixed order. It stops at the points where you decide.
- **Agent:** one specialist with one job and a fixed output format. The reviewers can't edit code.
- **Plugin:** this repo, installed into Claude Code so every session has the workflows and agents.

## What to type

Type these on your phone (Claude app → Code → the `factory` session) or in any terminal session in `~/work/activepieces`.

| When | Type | You get back | You decide |
|---|---|---|---|
| Small bug ticket | `run the small-bug workflow on AI-150` | A failing test, the fix, 3 reviews, a **draft PR**, and a Linear comment | Click through, then mark the PR ready |
| Ticket, cause unknown | `run support-ticket on GIT-1234` | Root cause with evidence, a skeptic's check, a **draft** ticket reply | Post the reply; add `fix: true` to chain into small-bug |
| Comments on your PR | `run colleague-review on PR 17339` | Clear fixes committed locally, a **draft reply** for every other thread | Say "push and post" |
| Review someone's PR | `review PR 14895` | 4 reviewers, serious claims checked, one friendly review with Blockers and Non-blockers (skill `review-pr`) | Say "post it" |
| UI change | `run ui-update on AI-200` | Implementation, UI and quality review, screenshots, a **draft PR** with a gallery | Mark the PR ready |
| Big feature | `run big-feature on ENG-1401` | Research and a PRD in `features/eng-1401/prd.md` | Approve the PRD |
| Big feature, step 2 | `run big-feature on ENG-1401 stage split` | AC and Decisions on the ticket, a PR plan in `prs.md` | Approve the plan |
| Big feature, step 3+ | `run big-feature on ENG-1401 stage build` | The next PR, reviewed, as a **draft PR**; progress ticked | Review it, then repeat |
| AI news | Nothing. It runs Fridays at 8:00 | `roadmap/digests/<date>.md` with a "Do first" line | Act on the "Do first" line |

Add `dryRun: true` to small-bug, ui-update or big-feature build to stop before anything is pushed.

## A normal day

1. **Morning, about 2 minutes, on your phone:** look at the Code tab. Overnight runs show as sessions, and draft PRs show in the GitHub app.
2. **When a ticket lands:** type the matching line from the table, then put the phone down. A small bug takes about 10 to 20 minutes. Runs use your Claude subscription's usage limits, not extra money; the `total_cost_usd` a headless run prints is a list-price estimate of its size.
3. **When a run finishes:** read its summary and do the one thing in the "You decide" column.
4. **Friday:** read the digest's **Do first** line.

Keep two or three runs going at once at most. Each one gets its own worktree, so they don't collide, but every one ends with something for you to review.

## Laptop or cloud?

| | Laptop (Remote Control) | Cloud |
|---|---|---|
| Start from | Claude app → Code → `factory` session | Claude app → Code → new session → environment `factory-activepieces`, repo `activepieces` |
| Laptop | Must be on | Can be off |
| Sees | Your files, `.env.dev`, the running app | GitHub only |
| Factory workflows and agents | **Yes** | **Not yet.** Cloud sessions don't have the plugin: a session's safety check blocks installing it ("Code from External"), and adding it to the setup script is your decision |
| Best for | Every workflow in this guide | The Friday digest; plain sessions ("fix this test", "explain this module") with the laptop off |

## On Box

`box setup` has sent the plugin to Box (Settings → Synced setup shows `my-factory`). Agents **you** start get it: `box new -n ai-150`, then type the same lines from the table. Box adds what the laptop lacks: real Postgres and Redis, production logs (ClickHouse) and the read-only production replica.

Box does **not** give it to machines made with *New machine* on the dashboard, or to agents started by an alert, webhook or `@box` mention. Those run the team's recipes.

## When something goes wrong

- **A run stops with `needs-human`:** it couldn't finish a must-fix after 2 rounds. The summary lists exactly what's left.
- **A run stops with `blocked`:** read `reason`. Usually the ticket isn't approved (co-owned project), Linear isn't connected (`/mcp`), or the bug can't be reproduced.
- **The phone shows `factory` as Disconnected:** Remote Control isn't running on the laptop. Start it with the command below.
- **A reviewer is wrong:** it happens. Say why in the session, and the next round skips that finding.

## Keep Remote Control running

Install it as a service once, so it starts at every login and restarts if it crashes:

```sh
~/work/my-factory/remote/install-remote-control-service.sh
```

To stop it: `systemctl --user disable --now claude-remote-control`.

## Change the factory

- **Edit an agent or workflow in this repo**, commit and push, then run `claude plugin marketplace update my-factory && claude plugin update my-factory@my-factory && box setup` and start a new session. The plugin installs from GitHub, so unpushed edits don't reach the laptop or Box.
- **Something a reviewer always misses** belongs in that agent's checklist. **Something every agent should know about activepieces** belongs in the team's `brain/`, not here.
