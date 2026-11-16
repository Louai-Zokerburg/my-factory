---
name: review-pr
description: Review an Activepieces pull request the way Louai does - four reviewer agents in parallel, check the serious claims yourself. A teammate's PR gets one friendly draft review, posted only after a yes; Louai's own PR gets the verified findings applied, committed and pushed. Use ONLY when Louai says "factory review-pr <n>", "factory review PR <n>" or /my-factory:review-pr. A plain "review this PR" is normal work: do not load this skill for it.
---

# Review a PR

## 0. Plan first

This skill runs after the plan session (`factory review-pr <n>`), which writes `~/work/plans/tasks/review-<n>/plan.md` with Louai's focus, depth and tone (5+ questions). Read it first; if it is missing, stop and run the plan session.

## 1. Look at it

- `gh api repos/activepieces/activepieces/pulls/<n>` for title, author, base branch and size, plus `.../pulls/<n>/files` and the body. Use `gh api` with a `timeout`; `gh pr view` can hang.
- The base branch is often **not** `main` (stacked PRs). Always diff against the PR's own base.
- **Whose PR?** If the author is `Louai-Zokerburg` (`gh api user --jq .login`), this is **own-PR mode**: steps 2–4 change as noted, step 5 is replaced by "5b. Apply, commit, push", and nothing is posted on GitHub. Anyone else: teammate mode, as written.

## 2. Check it out

```sh
cd <activepieces repo> && git fetch -q origin <base> <head>
git worktree add --detach <repo>-wt/review-pr-<n> origin/<head>
cd <repo>-wt/review-pr-<n> && bun install --frozen-lockfile \
  && npx turbo run build --filter=api^... --filter=worker^... --filter=worker --output-logs=errors-only
```

Own-PR mode: check out the **branch**, not a detached head, so you can push. If `git worktree list` shows `<head>` already checked out and that checkout is clean and level with `origin/<head>`, work there. Otherwise `git worktree add -B <head> <repo>-wt/review-pr-<n> origin/<head>`. A dirty checkout or a local branch ahead of origin: stop and ask.

## 3. Four reviewers in parallel

Start these at once, each pointed at the worktree and `git diff origin/<base>...HEAD`, each told to edit nothing:
- `my-factory:security-reviewer`: add the PR's specific risks to the prompt (billing, auth, abuse, races).
- `my-factory:quality-reviewer`: also ask it to check the description matches the code.
- `my-factory:ui-reviewer`: only when `packages/web` changed. Code-only unless the plan says to run their branch; then it boots the worktree with `ap-dev` under the app lock (`<factory>/scripts/app-lock.sh`) and checks the pages with `<factory>/skills/ext-browser-devtools/SKILL.md`.
- `my-factory:test-verifier`: read-only verify. Run the tests the author claims, eslint without `--fix`, and list untested behaviour.
- **Own-PR mode only:** Greptile, the reviewer CI runs. In the worktree, `git fetch -q origin && greptile review -b $(git rev-parse origin/<base>) --agent` (committed changes only; about 8 minutes, run it in the background). Never pass a bare branch name: Greptile then diffs against the stale local branch. Its findings go through step 4 like everyone else's.

## 4. Check before you trust

Reviewers overstate. Before anything goes in the review, check every blocker and every surprising claim yourself in the code: open the file, read the lines, follow the call. Drop or downgrade what doesn't hold. Tell Louai which claims you corrected.

## 5b. Own PR: apply, commit, push

Instead of step 5, when the PR is Louai's:
1. Apply every blocker and non-blocker that survived step 4. Skip one only when it is a judgment call (design change, scope growth, disagrees with the plan) and list it as skipped with a one-line reason.
2. Run eslint on the touched packages and the tests that cover the changed code. A failure you caused: fix it or revert that change.
3. Commit on the PR branch: one commit, lowercase conventional subject ≤100 chars (`fix(<area>): address review findings`), body = one line per applied finding. No `Co-Authored-By` trailer.
4. `git push --no-verify origin HEAD:<head>`. Never force-push; if the push is rejected, stop and say so.
5. Tell Louai: the commit SHA, applied findings, skipped findings with reasons, what ran and its result. Skip step 6 when you used his existing checkout.

If the plan says "don't push", stop after the commit.

## 5. Draft, show, post (teammate mode)

Show the draft to Louai first. Post only after a yes, with `gh api -X POST repos/activepieces/activepieces/pulls/<n>/reviews` (`commit_id` = PR head SHA, `event` = `REQUEST_CHANGES` if there are blockers, otherwise `COMMENT`). Put an inline comment on each blocker whose line is inside the diff; GitHub rejects inline comments on lines the PR didn't touch, so mention those in the body.

## 6. Clean up right after posting

As soon as the review POST succeeds, in the same turn, delete the review worktree and say so in the reply:

```sh
git -C <activepieces repo> worktree remove --force <repo>-wt/review-pr-<n>
```

The review worktree is never reused: a re-review starts from a fresh checkout of the new head. If Louai decides not to post, ask once whether to delete it too.

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
