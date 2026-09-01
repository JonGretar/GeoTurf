# Quality Foundations

State: `Blocked`
Priority: `P0`
Owner: `Delta`
Dependencies: `Quality Foundations CI must run on the supported version matrix`

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

- [x] Choose intentional behavior for empty Point collections, lines, rings,
      polygons, and GeometryCollections; record the choice here.
- [x] Add focused tests for the chosen behavior.
- [x] Validate WGS84 recursively where a function accepts a collection.
- [x] Centralize valid length and area units with clear errors for unsupported
      atoms.
- [x] Decide whether GeoTurf constructors and derived points return `srid:
4326` or preserve the current nil convention; apply it consistently.

### 4. Delivery Contract

- [x] Correct `:unit` / `:units` documentation, types, and tests.
- [x] Decide the canonical public length interface and compatibility path from
      `length_of/2`, as required by the `0.5` contract reset.
- [x] Declare an Elixir support floor compatible with all language features in
      the implementation.
- [x] Make CI run formatting and strict Credo in addition to compile, test,
      and Dialyzer.
- [x] Add a supported Elixir/OTP matrix after selecting the minimum version.
- [x] Update `CHANGELOG.md` under `Unreleased` for user-visible behavior.

## Acceptance Criteria

- [x] `length_of/2` never measures an invented segment between independent
      coordinate paths.
- [x] Threshold and nearest-point behavior use raw geodesic values.
- [x] Empty/invalid geometry and unit behavior are intentional, tested, and
      documented.
- [x] Circle and destination options agree across implementation, types, docs,
      and tests.
- [x] The canonical length interface and any `length_of/2` compatibility path
      are documented and tested.
- [x] Local and CI quality checks enforce the same required checks.

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
- 2026-09-01: Empty geometries return zero from aggregate area/length
  measurements, `:error` from point-producing measurements, and `false` from
  containment predicates. Degenerate paths use their available coordinates:
  insufficient rings have zero area while existing segments still contribute
  length.
- 2026-09-01: WGS84 validation recurses through GeometryCollection children and
  list members, including when a collection is empty.
- 2026-09-01: The geometry/SRID slice passed formatting, tests (69 tests,
  29 doctests), Coveralls (95.6%), Dialyzer, strict Credo, and docs. The two
  existing `Math.length_unit/0` documentation warnings remain for track 4.
- 2026-09-01: Length and area unit factors are centralized in `Math`; all
  consumers raise explicit `ArgumentError` messages for unsupported units.
  Public length and area unit types now match the accepted factor sets.
- 2026-09-01: The unit-contract slice passed formatting, tests (71 tests,
  29 doctests), Coveralls (94.1%), Dialyzer, strict Credo, and docs without
  warnings.
- 2026-09-01: Newly constructed WGS84 geometries and measurement-derived points
  carry explicit `srid: 4326`. Coordinate-only transformations such as
  `Math.approx/2` preserve the source geometry's SRID and properties.
- 2026-09-01: The output-SRID slice passed formatting, tests (74 tests,
  29 doctests), Coveralls (94.5%), Dialyzer, strict Credo, and docs without
  warnings. Track 3 is complete.
- 2026-09-01: Circle and destination consistently accept `:units`; the
  singular `:unit` and other unknown options raise `ArgumentError` instead of
  silently falling back to defaults.
- 2026-09-01: The option-contract slice passed formatting, tests (76 tests,
  29 doctests), Coveralls (94.5%), Dialyzer, strict Credo, and docs without
  warnings.
- 2026-09-01: The supported floor is Elixir 1.15 / OTP 26. CI also verifies
  Elixir 1.18 / OTP 28 and runs compilation, tests, formatting, strict Credo,
  Dialyzer, and documentation generation against `main`.
- 2026-09-01: The delivery slice passed `mix precommit` and warning-free
  documentation generation locally. The version matrix itself requires CI.
- 2026-09-01: `length_of/2` remains the canonical public interface because it
  avoids ambiguity with `Kernel.length/1`. There is no compatibility migration:
  retaining the existing interface follows Elixir naming conventions without
  disrupting callers solely for TurfJS spelling parity.
- 2026-09-01: Implementation and local verification are complete. The plan is
  blocked only on publishing `main` to origin and observing the new Elixir/OTP
  CI matrix; Delta does not publish externally without explicit permission.

## Handoff

Push `main` to origin, verify every CI matrix and quality job passes, then mark
this plan `Done`, check the four Quality Foundations roadmap items, and prepare
the explicitly authorized `0.5.0` release.
