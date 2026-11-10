#!/usr/bin/env node
// Runs every workflow's control flow against fake agents: no tokens, no tools.
// Usage: node tests/mock-workflows.mjs   (exit code 1 if any scenario misbehaves)
import { readFileSync } from 'node:fs'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'

const root = join(dirname(fileURLToPath(import.meta.url)), '..')
const AsyncFunction = Object.getPrototypeOf(async function () {}).constructor
const load = (name) => readFileSync(join(root, 'workflows', `${name}.js`), 'utf8').replace(/^export const meta/m, 'const meta')

const BUILD = { done: true, worktreePath: '/wt', branch: 'b', summary: 's', filesChanged: ['f'], testsPassed: true, commit: 'c', notes: '' }
const FIX = { fixed: true, summary: 's', filesChanged: ['x.ts'], testPassed: true, commit: 'abc', notes: '' }
const REPLIES = {
  locate: (o) => (o.noRepo ? { ok: false, repo: '', factory: '', error: 'no activepieces checkout' } : { ok: true, repo: '/home/user/activepieces', factory: o.noFactory ? '' : '/opt/my-factory', error: '' }),
  triage: () => ({ proceed: true, blockReason: '', ticketKey: 'ENG-1', title: 't', expected: 'e', actual: 'a', suspectedFiles: ['x.ts'], slug: 'bad-sort', isPublicTicket: false, tooBigForSmallBug: false }),
  worktree: (o, p) => ({ ok: true, worktreePath: (p.match(/add -b \S+ (\S+)/) || [])[1] || '/wt', branch: 'b', error: '' }),
  reproduce: () => ({ reproduced: true, testPath: 't.test.ts', command: 'npm test', failingLine: 'x', notes: '' }),
  fix: () => FIX,
  collect: () => ({ ok: true, error: '', branch: 'feat/x', worktreePath: '/wt', headSha: 'abc', threads: [{ threadId: 'T1', commentId: '1', author: 'a', path: 'a/b.ts', line: 3, body: 'rename' }, { threadId: 'T2', commentId: '2', author: 'a', path: 'a/c.ts', body: 'why?' }] }),
  'apply fixes': () => ({ committed: true, commit: 'c1', applied: ['T1'], skipped: [], checks: 'ok' }),
  push: () => 'pushed',
  'read ticket': () => ({ ok: true, error: '', title: 't', report: 'r', edition: 'cloud', isPublic: true, hasLogsOrRunIds: false }),
  investigate: () => ({ verdict: 'bug', rootCause: 'rc', evidence: ['x.ts:1'], files: ['x.ts'], confidence: 'high', workaround: '', smallFix: true }),
  skeptic: () => ({ refuted: false, why: '', betterExplanation: '' }),
  'draft comment': () => ({ comment: 'c', posted: false }),
  plan: () => ({ proceed: true, blockReason: '', ticketKey: 'AI-9', title: 't', slug: 'new-chip', screens: ['/x'], files: ['f.tsx'], reuse: ['Badge'], steps: ['s'], isPublicTicket: false }),
  build: () => BUILD,
  'draft PR': () => ({ prUrl: 'u', galleryUrl: 'g', linearCommented: true, progressSaved: true, notes: '' }),
  'draft PRD': () => ({ ok: true, error: '', summary: '' }),
  'revise PRD': () => ({ ok: true, error: '', summary: '' }),
  'save state': () => ({ ok: true, error: '', summary: 'pushed' }),
  split: () => ({ ok: true, error: '', ticketWritten: true, prs: [{ n: 1, title: 'schema', slug: 's', scope: 'x', acceptanceCriteria: ['AC1'], touchesWeb: false, dependsOn: [], size: 'S' }, { n: 2, title: 'ui', slug: 'u', scope: 'y', acceptanceCriteria: ['AC2'], touchesWeb: true, dependsOn: [1], size: 'M' }] }),
  'pick next PR': () => ({ ok: true, error: '', allDone: false, n: 2, total: 2, title: 'ui', slug: 'u', scope: 'y', acceptanceCriteria: ['AC2'], touchesWeb: true, baseBranch: 'feat/eng-1-pr1-s', isLast: true }),
}

async function run(name, args, opts, expect) {
  const calls = []
  let reviews = 0
  const agent = async (prompt, o) => {
    const l = o.label
    calls.push(l)
    if (l.startsWith('sort')) return l.includes('b.ts') ? { kind: 'clear-fix', reasoning: '', change: 'rename', draftReply: 'Fixed' } : { kind: 'question', reasoning: '', change: '', draftReply: 'Because' }
    if (/^(security|quality|tests|ui)( r\d)?$/.test(l)) {
      reviews++
      const bad = opts.badOnce && reviews === 1
      return { verdict: bad ? 'fail' : 'pass', mustFix: bad ? [{ file: 'x', where: 'x', line: 1, problem: 'p', fix: 'f' }] : [], other: [], screenshots: l.startsWith('ui') ? ['s.png'] : undefined, securityImpact: l.startsWith('security') ? 'no' : undefined }
    }
    if (l.startsWith('address')) return name === 'small-bug' ? FIX : BUILD
    if (l.startsWith('build PR')) return BUILD
    if (l.endsWith('critic')) return { ok: true, problems: [] }
    if (l.startsWith('research')) return { findings: ['f1'], risks: [], openQuestions: [] }
    const reply = REPLIES[l]
    if (!reply) throw new Error(`unmocked agent label "${l}"`)
    return reply(opts, prompt)
  }
  const parallel = async (thunks) => Promise.all(thunks.map((t) => t().catch(() => null)))
  const pipeline = async (items, ...stages) => Promise.all(items.map(async (item, i) => { let r = item; for (const s of stages) r = await s(r, item, i); return r }))
  const workflow = async (n) => { calls.push(`WF:${n}`); return { status: 'done' } }
  const result = await new AsyncFunction('agent', 'parallel', 'pipeline', 'phase', 'log', 'args', 'budget', 'workflow', load(name))(agent, parallel, pipeline, () => {}, () => {}, args, {}, workflow)
  const ok = result.status === expect && (opts.check ? opts.check(calls, result) : true)
  console.log(`${ok ? 'ok  ' : 'FAIL'} ${name.padEnd(16)} ${String(JSON.stringify(args)).slice(0, 44).padEnd(46)} ${result.status.padEnd(17)} ${calls.join(',')}`)
  return ok
}

const locatedFirst = (calls) => calls[0] === 'locate'
const cases = [
  ['small-bug', { ticket: 'ENG-1' }, { check: locatedFirst }, 'done'],
  ['small-bug', { ticket: 'ENG-1', repo: '/r' }, { check: (c) => !c.includes('locate') }, 'done'],
  ['small-bug', { ticket: 'ENG-1' }, { badOnce: true, check: (c) => c.includes('address r1') }, 'done'],
  ['small-bug', { ticket: 'ENG-1', dryRun: true }, {}, 'dry-run-complete'],
  ['small-bug', { ticket: 'ENG-1' }, { noRepo: true }, 'blocked'],
  ['small-bug', undefined, { check: (c) => c.length === 0 }, 'blocked'],
  ['small-bug', 'ENG-1', {}, 'done'],
  ['colleague-review', { pr: 'https://github.com/x/y/pull/17339' }, { check: (c, r) => r.pr === '17339' && !c.includes('push') }, 'done'],
  ['colleague-review', { pr: 17339, push: true }, { check: (c) => c.includes('push') }, 'done'],
  ['colleague-review', {}, {}, 'blocked'],
  ['support-ticket', { ticket: 'GIT-1' }, {}, 'done'],
  ['support-ticket', { ticket: 'GIT-1', fix: true, dryRun: true }, { check: (c) => c.includes('WF:my-factory:small-bug') }, 'done'],
  ['ui-update', { ticket: 'AI-9', dryRun: true }, {}, 'dry-run-complete'],
  ['ui-update', 'make chips bigger', { badOnce: true, check: (c) => c.includes('address r1') }, 'done'],
  ['big-feature', { ticket: 'ENG-1' }, {}, 'awaiting-approval'],
  ['big-feature', { ticket: 'ENG-1', stage: 'split' }, {}, 'awaiting-approval'],
  ['big-feature', { ticket: 'ENG-1', stage: 'build' }, {}, 'done'],
  ['big-feature', { ticket: 'ENG-1', stage: 'plan' }, { noFactory: true }, 'blocked'],
  ['big-feature', { ticket: 'ENG-1', stage: 'ship' }, {}, 'blocked'],
]

let failed = 0
for (const [name, args, opts, expect] of cases) {
  try {
    if (!(await run(name, args, opts, expect))) failed++
  } catch (error) {
    failed++
    console.log(`FAIL ${name} ${JSON.stringify(args)}: ${error.message}`)
  }
}
console.log(failed ? `\n${failed} scenario(s) failed` : `\nall ${cases.length} scenarios passed`)
process.exit(failed ? 1 : 0)
