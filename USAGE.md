# Using the factory

Lost? Type **`factory help`** in a Claude session in `~/work/activepieces`. The factory only acts when a message says **"factory"** or names a recipe; everything else stays normal Claude Code.

## How a run works

```
 you: "factory small-bug ENG-123"
   │
   ▼
 1. Plan session (your terminal)     grills you: 5+ questions (30 for big-feature)
    └─ writes ~/work/plans/tasks/eng-123/plan.md → you say "go"
   │
   ▼
 2. Recipe (background workflow)     refuses to start without a grilled plan
    ├─ build in a fresh worktree      (Chrome DevTools as its eyes)
    ├─ verify in the running app      app lock → ap-dev up → Playwright spec + DevTools → ap-dev stop
    ├─ review: security · quality · tests (+ ui)   up to 2 fix rounds
    └─ ship: draft PR with a Proof section, Linear comment
   │
   ▼
 3. Next actions: 1–3 numbered steps, first one doable in 2 minutes
```

Nothing is merged or posted without you.

## What to type

| When | Type | Questions | Ends with |
|---|---|---|---|
| Small bug | `factory small-bug ENG-123` | 5+ | Draft PR with proof |
| Cause unknown | `factory support-ticket GIT-1234` | 7+ | Draft ticket reply (reproduced in the app); `fix` chains into small-bug |
| Comments on your PR | `factory colleague-review PR 17339` | 5+ | Local fix commit + draft replies |
| Review a teammate's PR | `factory review-pr 14895` | 5+ | Draft review, posted on your yes |
| Review your own PR | `factory review-pr <yours>` | 5+ | Findings applied, committed, pushed |
| UI change | `factory ui-update AI-200` | 5+ | Draft PR + screenshot gallery |
| Big feature | `factory big-feature ENG-1401` | 30+ | `master-plan.md` |
| … then | `factory big-feature ENG-1401 stage split` | – | `ledger.md` + one `pr-N` stub per PR |
| … then, per PR | `factory big-feature ENG-1401 plan PR 1` | 5+ | One draft PR, ledger ticked, stop |
| Status | `factory status` | – | Version, app lock, running stack |

Add `dryRun: true` when you say "go" to stop before anything is pushed. The AI digest still runs on its own on Fridays.

## Where things live

- **Plans:** `~/work/plans/tasks/<ticket>/plan.md` for single tasks, `~/work/plans/<feature>/` (brief, master-plan, ledger, pr-N) for features.
- **Worktrees:** `~/work/activepieces-wt/<branch-ish>`. Each runs its own app with its own database (ap-dev slots).
- **Screenshots:** `~/work/screenshots/<branch>/`.
- **The app:** `ap-dev` (`~/.local/bin/ap-dev`). Runs take turns through `scripts/app-lock.sh`; `factory status` shows who holds it.
- **Browser:** `scripts/ensure-chrome.sh` starts headless Chrome on :4222 for the DevTools MCP (its own profile, never yours).

## A normal day

1. A ticket lands: type its `factory …` line and answer the questions (5–10 minutes).
2. Say "go" and do something else. A small bug takes about 20–40 minutes including the in-app check.
3. When it finishes, do the first next action.

Keep two or three runs going at most: they share one app through the lock, and each ends with something for you to review.

## When something goes wrong

- **`blocked`:** read `reason`, do the next action. Usual causes: no plan file, too few questions, ticket not approved (co-owned project), Linear not connected (`/mcp`).
- **`needs-human`:** a must-fix survived 2 rounds; it lists what's left.
- **Stuck waiting for the app lock:** `bash scripts/app-lock.sh status`. A lock older than 45 minutes is taken over automatically.
- **A reviewer is wrong:** say why in the session; the next round skips it.

## Change the factory

Edit here, run `node tests/mock-workflows.mjs`, commit, push, then `claude plugin marketplace update my-factory && claude plugin update my-factory@my-factory` and start a new session. Something every agent should know about Activepieces belongs in the team's `brain/`, not here.

## Later (not used now)

Box (`box setup`), cloud sessions (`cloud/`) and Remote Control (`remote/`) still exist but are not part of the laptop flow.
