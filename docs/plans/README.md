# Plans

Plans in this directory are the actionable queue. A plan must be small enough
for one focused change set and complete enough that an agent can verify it
independently. Read only plans relevant to the current task; consult
`completed/` when a dependency or earlier decision requires it.

## Active

No active plans.

## Completed

- [Quality Foundations](completed/2026-08-quality-foundations.md) - `Done`,
  released in `0.5.0`
- [Line Analysis Foundations](completed/2026-09-line-analysis-foundations.md) -
  `Done`, released in `0.6.0`

## Naming

Use `YYYY-MM-short-outcome.md`. After the associated milestone release, move
`Done` plans to `completed/`, preserving links from the roadmap and this index.
Archived plans remain the repository-visible record of scope, decisions, and
verification, but are not part of routine task discovery.

## Template

```md
# Outcome

State: `Proposed | Ready | In progress | Blocked | Done | Dropped`
Priority: `P0 | P1 | P2`
Owner: `Unassigned | name`
Dependencies: `None | plan links`

## Outcome

One observable result.

## Non-goals

- Explicitly excluded work.

## Checklist

- [ ] Small, ordered action.

## Acceptance Criteria

- [ ] Observable behavior.

## Verification

- `exact command`

## Decision Log

- YYYY-MM-DD: decision and reason.

## Handoff

Current state, files touched, checks run, and one next action.
```
