# my-factory

A Claude Code plugin that turns a ticket or a pull request into a reviewed draft PR, for work on [Activepieces](https://github.com/activepieces/activepieces).

You name a recipe ("factory small-bug ENG-123"). Claude asks you a few questions, writes a plan, and then runs the work in the background: it builds in a fresh git worktree, checks the change in the running app, has separate reviewer agents look at it, fixes what they find, and stops at a draft. **Nothing is merged or posted without you.**

It is one engineer's daily setup, published so others can read it or borrow from it. It is not a general-purpose tool: it expects the Activepieces repo and a few local tools (see [Requirements](#requirements)).

## Recipes

| Recipe | Use it for | Ends with |
|---|---|---|
| `small-bug` | A small bug in a known area | Draft PR with a failing-then-passing test and in-app proof |
| `support-ticket` | A report where the cause is unknown | Root cause + a draft reply; can chain into `small-bug` |
| `ui-update` | A visual change in the web app | Draft PR with before/after screenshots |
| `big-feature` | Work too big for one PR | Master plan → PR list → one draft PR per run |
| `colleague-review` | Review comments on your own PR | Local fix commit + draft replies |
| `review-pr` | Reviewing someone else's PR | A draft review, posted only after you say yes |
| `pick` | Not sure which recipe fits | The recipe and the exact line to type |

Every recipe starts with a **plan session** that asks at least 5 questions (30 for `big-feature`) and writes the plan to `~/work/plans/`. Recipes refuse to start without it.

## How a run works

```
"factory small-bug ENG-123"
  1. plan session   questions → plan.md → you say "go"
  2. build          fresh worktree, failing test first, smallest fix
  3. verify         boots the app, Playwright spec + Chrome DevTools
  4. review         security · quality · tests · Greptile (+ UI), up to 2 fix rounds
  5. ship           draft PR with a Proof section
  6. next actions   1–3 steps for you, the first doable in 2 minutes
```

Add `dryRun: true` when you say "go" to stop before anything is pushed.

## What's inside

- `skills/`: the entry points (`factory`, `pick`, `plan-session`, `review-pr`) and four adapted skills (`ext-*`: diagnose, TDD, task breakdown, browser checks).
- `workflows/`: one script per recipe. They orchestrate sub-agents and are tested with fake agents in `tests/mock-workflows.mjs`.
- `agents/`: read-only reviewers for security, code quality and UI, plus a test verifier that may only add tests.
- `scripts/`: an app lock so parallel runs share one local stack, and a headless Chrome starter for the DevTools MCP.

Skills and agents only run when a message says "factory" or names a recipe, so normal Claude Code work is left alone.

## Requirements

- Claude Code with workflows enabled.
- A checkout of `activepieces/activepieces` and the `gh` CLI, signed in.
- The Linear MCP server, for ticket-driven recipes.
- `ap-dev`, a small personal CLI that boots the local stack. **It is not published.** Swap the verify step for your own way of starting the app.
- Optional: the [Greptile](https://www.greptile.com) CLI and Chrome for the DevTools MCP.

Some default paths point at the author's machine (`/home/louai/work/...`). Expect to edit them.

## Install

```sh
claude plugin marketplace add Louai-Zokerburg/my-factory
claude plugin install my-factory@my-factory --scope user
```

Then, in a Claude Code session inside your Activepieces checkout, type `factory help`. The full guide is [USAGE.md](USAGE.md); the original design notes are in [PLAN.md](PLAN.md).

## Change it

Edit the files, run `node tests/mock-workflows.mjs`, push, then:

```sh
claude plugin marketplace update my-factory && claude plugin update my-factory@my-factory
```

Running a workflow headless with `claude -p`? Background work is cut off after 10 minutes unless you set `CLAUDE_CODE_PRINT_BG_WAIT_CEILING_MS=0`:

```sh
CLAUDE_CODE_PRINT_BG_WAIT_CEILING_MS=0 claude -p --permission-mode auto 'Run the saved workflow my-factory:small-bug with args {"ticket": "ENG-123"}'
```

## Credits

The `ext-*` skills are adapted from [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) and [mattpocock/skills](https://github.com/mattpocock/skills), both MIT. See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
