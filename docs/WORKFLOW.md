# Work System

## Purpose

Use this workflow for every code change. The goal is a small, current work
queue where another person or agent can safely pick up a task without needing
conversation history.

## Work States

| State         | Meaning                                       | Required next action           |
| ------------- | --------------------------------------------- | ------------------------------ |
| `Proposed`    | A useful idea, not yet scheduled.             | Refine or move to the roadmap. |
| `Ready`       | Bounded work with acceptance criteria.        | An agent may start it.         |
| `In progress` | One owner is actively changing it.            | Keep the plan current.         |
| `Blocked`     | Progress needs a decision or external change. | Record the exact blocker.      |
| `Done`        | Implementation and verification are complete. | Mark checks and outcome.       |
| `Dropped`     | Deliberately not pursuing.                    | Record the reason.             |

Only one plan should be `In progress` unless its file explicitly names
independent tracks and their owners.

## Lifecycle

1. Capture outcomes in [ROADMAP.md](ROADMAP.md), not as unbounded TODOs.
2. Turn the selected outcome into a file in `docs/plans/` using the plan
   template.
3. Mark it `Ready` only when scope, acceptance criteria, dependencies, and
   verification are explicit.
4. Before coding, the agent reads `AGENTS.md`, this file, the plan, and any
   linked ADRs or domain context.
5. During implementation, update the plan when a material fact changes.
   Do not silently widen scope.
6. Complete every verification command named by the plan. Record the result
   and any check that could not run.
7. Mark the plan `Done`, `Blocked`, or `Dropped`. Move completed plans to
   `docs/plans/completed/` only during a periodic housekeeping pass.

## Plan Requirements

Every plan contains:

- a single outcome and a non-goal;
- state, priority, owner, and dependencies;
- small ordered checklist items;
- acceptance criteria stated as observable behavior;
- a verification section with exact commands;
- a decision log for discoveries that changed the work.

Use existing TurfJS fixtures or upstream test vectors whenever parity is part
of the outcome. New public behavior also needs a changelog entry under
`Unreleased`.

## Agent Rules

An agent may start a `Ready` plan without further planning permission. It must
not start a `Proposed` plan, change a `Blocked` plan's direction, create a
release, or publish an external issue without explicit authority.

Agents should prefer one complete vertical slice over broad preparatory
refactors. A slice is complete when its implementation, tests, documentation,
and changelog impact are handled together.

For a bug fix or feature with meaningful behavior risk, use a TDD loop:

1. Add a focused failing regression or acceptance test.
2. Implement the smallest behavior that makes it pass.
3. Refactor only after the full relevant test suite is green.

TDD is not required for mechanical documentation, formatting, or generated
artifact work. The plan must explain any deliberate exception for behavior
changes.

## Decisions And Handoffs

Create an ADR only for a hard-to-reverse, non-obvious choice made after a real
trade-off. Link it from the relevant plan. Do not use ADRs as a task log.

When stopping unfinished work, update the plan's handoff section with the
current state, files touched, commands run, and the single next action. This
is the handoff; do not rely on chat history.
