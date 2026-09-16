---
name: land-geoturf-changes
description: Land requested GeoTurf changes on origin/main with Jujutsu and verified GitHub Actions CI.
metadata:
  delta-action: land
---

# Land GeoTurf changes

Use this workflow only when the developer explicitly requests landing the
current thread's changes. Invocation through **Land Changes** or
`/land-geoturf-changes` is that request; proceed without asking again.

The destination is `origin/main`. Land directly with a non-force push; if
branch policy no longer permits that, stop and report the blocker rather than
bypassing it.

## 1. Establish scope and policy

1. Read `AGENTS.md`, `docs/WORKFLOW.md`, and any applicable nested
   instructions. Read the relevant active plan for roadmap outcomes, public
   behavior changes, and substantive library work. Routine repository upkeep,
   including agent configuration, formatting, and small documentation
   corrections, does not require a plan unless the developer asks for one.
2. Inspect `jj status`, `jj diff --stat`, `jj diff`, relevant commits and
   bookmarks, plus `jj git remote list`. Include only requested changes.
3. Confirm `origin` is the intended repository, `main` is its default branch,
   and a direct push remains permitted. Do not weaken branch protections.
4. Stop and ask one focused question if there are no requested changes, scope
   is ambiguous, or unrelated changes cannot be safely separated.
5. Apply GeoTurf's public-contract conventions: WGS84 guards for public
   geodesic functions, `?` predicate names, and named upstream fixtures or
   references for TurfJS parity. New public behavior needs an `Unreleased`
   changelog entry. Do not create a release, tag, or publish a package unless
   explicitly requested.

## 2. Update onto the destination

1. Fetch with `jj git fetch --remote origin`.
2. Rebase only the requested change or stack onto `main@origin`.
3. If a conflict occurs, stop without resolving it. Report the files and wait
   for the developer; never force-push, abandon unrelated work, or guess.
4. Reinspect the rebased diff and commits. Ensure there are no conflict
   markers, generated build output, credentials, or unrelated files.

## 3. Prepare and verify the commit

1. Give the requested change a concise imperative description with
   non-interactive `jj describe -m`.
2. Run `mix precommit`, the authoritative local gate.
3. If verification changes files, inspect and include only intentional results,
   then rerun `mix precommit` against the final commit.
4. Failed, pending, skipped, or unverifiable required checks block landing.
   Fix only clear, in-scope failures; otherwise report the blocker.
5. Recheck `jj status`, the final diff, and exact commit ID.

## 4. Land and verify CI

1. Move `main` to the verified revision with
   `jj bookmark set main -r <verified-revision>`.
2. Push with `jj git push --remote origin --bookmark main`.
3. Treat divergence, rejection, authentication failure, or a potential
   overwrite as a blocker. Do not force-push.
4. Obtain the Git commit SHA and verify `origin/main` resolves to that exact
   commit.
5. Find the `CI` GitHub Actions run whose `headSha` exactly matches the landed
   SHA. Allow a short bounded wait for creation, then run
   `gh run watch <run-id> --exit-status`.
6. Succeed only when all jobs for that exact SHA pass. If CI fails, report
   “landed on main; CI failed” with the commit and run links; do not claim the
   push was undone.

## 5. Report

When available in a subthread, report the final result to the parent. Use
`success` only after the exact commit is on `origin/main` and its CI passes;
use `failure` for a blocker or failed CI. State whether nothing landed or the
commit landed with failing CI, and include verified commit and CI links.
