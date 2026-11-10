---
name: review-pr
description: Review a teammate's Activepieces pull request the way Louai does - four reviewer agents in parallel, check the serious claims yourself, then draft one friendly review with Blockers and Non-blockers and post it only after a yes. Use when asked to "review PR 1234", "review this PR", or given a github.com/activepieces/activepieces/pull/... link that is not Louai's own PR (for comments on his own PR, use the colleague-review workflow).
---

# Review a teammate's PR

## 1. Look at it

- `gh api repos/activepieces/activepieces/pulls/<n>` for title, author, base branch and size, plus `.../pulls/<n>/files` and the body. Use `gh api` with a `timeout`; `gh pr view` can hang.
- The base branch is often **not** `main` (stacked PRs). Always diff against the PR's own base.

## 2. Check it out

```sh
cd <activepieces repo> && git fetch -q origin <base> <head>
git worktree add --detach <repo>-wt/review-pr-<n> origin/<head>
cd <repo>-wt/review-pr-<n> && bun install --frozen-lockfile \
  && npx turbo run build --filter=api^... --filter=worker^... --filter=worker --output-logs=errors-only
```

## 3. Four reviewers in parallel

Start these at once, each pointed at the worktree and `git diff origin/<base>...HEAD`, each told to edit nothing:
- `my-factory:security-reviewer`: add the PR's specific risks to the prompt (billing, auth, abuse, races).
- `my-factory:quality-reviewer`: also ask it to check the description matches the code.
- `my-factory:ui-reviewer`: only when `packages/web` changed. Code-only unless asked to run the app.
- `my-factory:test-verifier`: read-only verify. Run the tests the author claims, eslint without `--fix`, and list untested behaviour.

## 4. Check before you trust

Reviewers overstate. Before anything goes in the review, check every blocker and every surprising claim yourself in the code: open the file, read the lines, follow the call. Drop or downgrade what doesn't hold. Tell Louai which claims you corrected.

## 5. Draft, show, post

Show the draft to Louai first. Post only after a yes, with `gh api -X POST repos/activepieces/activepieces/pulls/<n>/reviews` (`commit_id` = PR head SHA, `event` = `REQUEST_CHANGES` if there are blockers, otherwise `COMMENT`). Put an inline comment on each blocker whose line is inside the diff; GitHub rejects inline comments on lines the PR didn't touch, so mention those in the body. Afterwards remove the worktree.

### Tone

Write like a teammate who read the PR carefully, not a report generator:
- **No praise opener** ("Great work!", "Amazing PR!"). Start with one plain sentence on what the change does well or how it holds together, then get to the point.
- **No questions section.** If something is unclear, either check it yourself or leave it out.
- Short, specific, kind. Say what's wrong, why it matters in one clause, and the fix. "Worth fixing", "should look the same", "fixes it" beat "MUST" and severity tags.
- Name files and lines. No reviewer names, no severity labels, no scores.
- End with one line on what you ran and its result, then `_Reviewed with help from Claude Code._`

### Template

```markdown
Hey @<author>, I went through this one. <One sentence on what holds together well.> <Optional: "Most of what's below is small.">

### Blockers
1. **<Short title>:** <what's wrong, why it matters, the fix>. <"Inline below." if it has an inline comment>
2. ...

### Non-blockers
- **<Short title>:** <what and the fix, one or two sentences>.
- ...

I ran <the tests you listed / what you ran>, and they <result>.

_Reviewed with help from Claude Code._
```

Inline comments: one or two sentences, the fix in code if it's short. No headers.

If there are no blockers, drop that section and post as `COMMENT` with a one-line opener such as "Looks good to merge from my side. A few small things:".
