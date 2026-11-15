---
name: ext-tdd
description: Red-green test-driven loop for Activepieces changes - test behaviour at agreed seams, one vertical slice at a time. Use ONLY when a my-factory workflow points to it, or Louai says "factory tdd".
---

# TDD (adapted from mattpocock/skills `tdd`, MIT, © Matt Pocock)

## Seams
Test only at public seams (an endpoint, a service's exported function, a page the user sees). In the factory, the seams are the acceptance criteria in the plan file; if the plan names none, use one test per criterion at the highest seam that is still fast.

## Good tests
- Test behaviour through public interfaces, not internals; the test survives a refactor.
- Expected values come from an independent source (a literal, a worked example, the ticket), never recomputed the way the code does.
- No mocking internal collaborators; mock only what crosses the process boundary.

## The loop
1. **Red:** one failing test for one slice. Run it and see it fail for the right reason.
2. **Green:** the least code that passes it. Nothing speculative.
3. Repeat per slice. Never write all tests first, then all code.
4. Refactoring belongs to the review stage, not this loop.

Activepieces: API tests use `setupTestEnvironment()` + `createTestContext(app)`; E2E tests follow `packages/tests-e2e/README.md` ("What to test"), and each acceptance criterion names its test title.
