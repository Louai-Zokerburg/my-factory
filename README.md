# my-factory

Louai's personal Claude Code plugin: reviewer agents, workflows and an AI-center roadmap agent.
See [PLAN.md](PLAN.md) for the design and rollout.

## Install (user scope)

```sh
claude plugin marketplace add ~/work/my-factory
claude plugin install my-factory@my-factory --scope user
```

After editing files here: `claude plugin marketplace update my-factory && claude plugin update my-factory@my-factory`.

## Check it loaded

In any session: "factory status".

## Running workflows headless

`claude -p` kills background work after 10 minutes. Workflows run in the background, so set:

```sh
CLAUDE_CODE_PRINT_BG_WAIT_CEILING_MS=0 claude -p --permission-mode auto 'Run the saved workflow my-factory:small-bug with args {"ticket": "ENG-123"}'
```

Interactive and Remote Control sessions don't have this limit.
