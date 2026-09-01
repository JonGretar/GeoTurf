# Quality Foundations

State: `In progress`
Priority: `P0`
Owner: `Delta`
Dependencies: `None`

## Outcome

Existing public GeoTurf behavior is correct across independent coordinate
paths, preserves measurement precision for predicates and ranking, and has
documented contracts for invalid input.

## Non-goals

- Adding new TurfJS feature families.
- Changing the public return shape of every existing function without a
  compatibility decision.
- Publishing a release.

## Checklist

### 1. Topology-Preserving Length

- [ ] Add failing fixtures for separated `MultiLineString` members, polygon
      holes, MultiPolygon members, and GeometryCollection members.
- [ ] Replace the flattened traversal used by `length_of/2` with a traversal
      that yields independent coordinate paths.
- [ ] Keep bbox and centroid coordinate aggregation behavior explicit and
      covered by their own tests.
- [ ] Update the module documentation to state which geometry paths contribute
      to length.

### 2. Raw Geodesic Metrics

- [ ] Add a threshold test showing that display rounding must not affect
      `close_to/4`.
- [ ] Add a nearest-point test where two candidates round to the same visible
      distance but have different raw distances.
- [ ] Introduce one internal raw-distance implementation shared by
      measurements, predicates, and ranking.
- [ ] Decide and document the public `distance/3` precision contract before
      changing its return value.

### 3. Geometry And Unit Contracts

- [ ] Choose intentional behavior for empty Point collections, lines, rings,
      polygons, and GeometryCollections; record the choice here.
- [ ] Add focused tests for the chosen behavior.
- [ ] Validate WGS84 recursively where a function accepts a collection.
- [ ] Centralize valid length and area units with clear errors for unsupported
      atoms.
- [ ] Decide whether GeoTurf constructors and derived points return `srid:
4326` or preserve the current nil convention; apply it consistently.

### 4. Delivery Contract

- [ ] Correct `:unit` / `:units` documentation, types, and tests.
- [ ] Declare an Elixir support floor compatible with all language features in
      the implementation.
- [ ] Make CI run formatting and strict Credo in addition to compile, test,
      and Dialyzer.
- [ ] Add a supported Elixir/OTP matrix after selecting the minimum version.
- [ ] Update `CHANGELOG.md` under `Unreleased` for user-visible behavior.

## Acceptance Criteria

- [ ] `length_of/2` never measures an invented segment between independent
      coordinate paths.
- [ ] Threshold and nearest-point behavior use raw geodesic values.
- [ ] Empty/invalid geometry and unit behavior are intentional, tested, and
      documented.
- [ ] Circle and destination options agree across implementation, types, docs,
      and tests.
- [ ] Local and CI quality checks enforce the same required checks.

## Verification

- `mix format --check-formatted`
- `mix test`
- `mix coveralls`
- `mix dialyzer`
- `mix credo --strict`
- `mix docs`

## Decision Log

- 2026-08-31: `docs/` is the authoritative work queue. External issue
  publishing is deferred until there is a deliberate decision to add a second
  work-system adapter.
- 2026-08-31: The work is split into four independently verifiable tracks,
  but only one should be in progress at a time until ownership is explicit.
- 2026-09-01: Delta started track 1, Topology-Preserving Length.

## Handoff

Track 1 is in progress. Begin with a failing MultiLineString length regression
test that demonstrates the fictitious join.
