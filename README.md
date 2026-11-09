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
