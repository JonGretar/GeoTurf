# Plans

Plans are the actionable queue. A plan must be small enough for one focused
change set and complete enough that an agent can verify it independently.

## Active

- [Quality Foundations](2026-08-quality-foundations.md) - `Ready`

## Proposed

- [Line Analysis Foundations](2026-09-line-analysis-foundations.md) - `Proposed`, blocked by Quality Foundations

## Naming

Use `YYYY-MM-short-outcome.md`. Keep completed plans in this directory until a
housekeeping pass moves them to `completed/`, preserving links from the
roadmap.

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
