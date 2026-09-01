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

- [x] Add failing fixtures for separated `MultiLineString` members, polygon
      holes, MultiPolygon members, and GeometryCollection members.
- [x] Replace the flattened traversal used by `length_of/2` with a traversal
      that yields independent coordinate paths.
- [x] Keep bbox and centroid coordinate aggregation behavior explicit and
      covered by their own tests.
- [x] Update the module documentation to state which geometry paths contribute
      to length.

### 2. Raw Geodesic Metrics

- [x] Add a threshold test showing that display rounding must not affect
      `close_to/4`.
- [x] Add a nearest-point test where two candidates round to the same visible
      distance but have different raw distances.
- [x] Introduce one internal raw-distance implementation shared by
      measurements, predicates, and ranking.
- [x] Decide and document the public `distance/3` precision contract before
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
- [ ] Decide the canonical public length interface and compatibility path from
      `length_of/2`, as required by the `0.5` contract reset.
- [ ] Declare an Elixir support floor compatible with all language features in
      the implementation.
- [ ] Make CI run formatting and strict Credo in addition to compile, test,
      and Dialyzer.
- [ ] Add a supported Elixir/OTP matrix after selecting the minimum version.
- [ ] Update `CHANGELOG.md` under `Unreleased` for user-visible behavior.

## Acceptance Criteria

- [x] `length_of/2` never measures an invented segment between independent
      coordinate paths.
- [x] Threshold and nearest-point behavior use raw geodesic values.
- [ ] Empty/invalid geometry and unit behavior are intentional, tested, and
      documented.
- [ ] Circle and destination options agree across implementation, types, docs,
      and tests.
- [ ] The canonical length interface and any `length_of/2` compatibility path
      are documented and tested.
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
- 2026-09-01: Length sums LineString paths, polygon rings, and collection child
  paths independently. Point and MultiPoint geometries contribute no length;
  bbox and centroid continue aggregating all applicable coordinates.
- 2026-09-01: Track 1 passed formatting, tests (57 tests, 29 doctests),
  Coveralls (89.8%), Dialyzer, strict Credo, and docs. Docs retain two existing
  warnings about private `Math.length_unit/0` references outside this track.
- 2026-09-01: `distance/3` returns raw floating-point geodesic values, as
  required by the `0.5` contract reset. Display rounding is an explicit caller
  decision through `Math.rounded/2`.
- 2026-09-01: `close_to/4` compares raw values and treats its maximum threshold
  as inclusive. `nearest_point/3` ranks by the same raw distance calculation.
- 2026-09-01: Track 2 passed formatting, tests (60 tests, 29 doctests),
  Coveralls (89.8%), Dialyzer, strict Credo, and docs. The two existing
  `Math.length_unit/0` documentation warnings remain for track 4.
- 2026-09-01: Added the canonical length-interface decision to track 4 so the
  Quality Foundations plan covers every `0.5` contract-reset gate in `V1.md`.

## Handoff

Tracks 1 and 2 are complete. Begin track 3 by deciding empty geometry behavior
for each accepted geometry family, then capture the decisions in focused tests.
