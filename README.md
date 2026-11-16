# my-factory

Louai's personal Claude Code plugin for working on Activepieces: reviewer agents and workflows.
See [PLAN.md](PLAN.md) for the design and rollout.

## Install (user scope)

```sh
claude plugin marketplace add Louai-Zokerburg/my-factory
claude plugin install my-factory@my-factory --scope user
box setup   # sends it to Box, so agents you start with `box new` get it
```

The marketplace is the GitHub repo, not this folder: Box only syncs plugins whose marketplace lives in `~/.claude`.
After editing files here: commit and push, then
`claude plugin marketplace update my-factory && claude plugin update my-factory@my-factory && box setup`.

## Check it loaded

In any session: "factory help" (what to type) or "factory status" (what is installed). Full guide: [USAGE.md](USAGE.md).

## Running workflows headless

`claude -p` kills background work after 10 minutes. Workflows run in the background, so set:

```sh
CLAUDE_CODE_PRINT_BG_WAIT_CEILING_MS=0 claude -p --permission-mode auto 'Run the saved workflow my-factory:small-bug with args {"ticket": "ENG-123"}'
```

Interactive and Remote Control sessions don't have this limit.
