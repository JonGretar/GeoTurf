# Line Analysis Foundations

State: `Done`
Archived after release: `2026-09-05`
Priority: `P1`
Owner: `Delta`
Dependencies: [Quality Foundations](2026-08-quality-foundations.md)

## Outcome

Callers can snap a WGS84 point to a LineString or MultiLineString, measure the
distance to it, test whether a point is on it, and extract a route subsection
without inventing geometry joins or relying on rounded distances.

## Timing

Start only after Quality Foundations is `Done`, specifically after its
topology-preserving paths, raw metric, geometry/unit contract, and delivery
contract acceptance criteria pass. This is the first P1 milestone.

## Non-goals

- Full GeoJSON Feature property support.
- Polygon intersection or polygon-clipping operations.
- An index for bulk nearest queries.
- Releasing a package version.

## Checklist

### 1. Shared Segment Semantics

- [x] Define a WGS84 line traversal that preserves each MultiLineString member
      as a separate coordinate path.
- [x] Define an explicit tolerance option for coordinate-on-segment checks.
- [x] Add TurfJS-derived fixtures for endpoint, interior, duplicate-vertex,
      degenerate, and MultiLineString cases.

### 2. Snap And Distance

- [x] Implement `nearest_point_on_line/3` for LineString and MultiLineString.
- [x] Return the snapped point plus documented route-location metadata that
      suits `Geo` structs and Elixir conventions.
- [x] Implement `point_to_line_distance/3` using the same segment semantics.
- [x] Verify that ranking and thresholds use raw distance values.

### 3. Predicate And Slicing

- [x] Implement `point_on_line?/3` using the same tolerance policy.
- [x] Implement `line_slice/3` after deciding whether it accepts only points
      on the line or snaps its inputs first.
- [x] Add docs and examples that make the chosen behavior visible.

## Acceptance Criteria

- [x] Separate line members are never joined for traversal, distances, or
      along-line metadata.
- [x] Snapping a point to a segment returns the nearest WGS84 point and stable
      location metadata.
- [x] Point-to-line distance equals the snap point's raw point distance.
- [x] The point-on-line predicate has documented endpoint and tolerance rules.
- [x] Line slicing preserves route direction and has defined behavior for
      out-of-order or off-line input points.
- [x] All new public functions have TurfJS comparison fixtures where an
      equivalent TurfJS function exists.

## Verification

- [x] `mix format --check-formatted`
- [x] `mix test` — 31 doctests and 94 tests pass
- [x] `mix coveralls` — 94.5% total coverage
- [x] `mix dialyzer` — no errors
- [x] `mix credo --strict` — no issues
- [x] `mix docs` — generated successfully

## Decision Log

- 2026-08-31: This is scheduled as the first P1 milestone because all four
  public functions share coordinate-path traversal and segment semantics.
- 2026-08-31: It is blocked by Quality Foundations; do not duplicate or bypass
  its precision, unit, SRID, or topology decisions.
- 2026-09-05: Public seams confirmed: snapping returns
  `{:ok, %Geo.Point{}, metadata}` or `:error`; point-to-line distance and
  slicing live in `Geo.Turf.Measure`; and the point-on-line predicate lives in
  `Geo.Turf.Classification`.
- 2026-09-05: Snapping metadata is
  `%{distance: distance, location: location, segment_index: segment_index,
  line_index: line_index}`. Distances and locations use the requested
  `:units`, defaulting to `:kilometers`; `line_index` is zero for a
  LineString and identifies the member for a MultiLineString.
- 2026-09-05: `point_on_line?/3` accepts `:tolerance` in the requested
  `:units`; `line_slice/3` snaps off-line inputs before slicing.
- 2026-09-05: Nearest-point conformance covers TurfJS's `line1` interior
  fixture and focused upstream regressions for long-arc endpoint selection,
  duplicate vertices, redundant segments, and MultiLineString member indexes.
- 2026-09-05: Distance, predicate, and slicing conformance uses TurfJS
  regressions #2270, #2750, #2023, and #2946 respectively.

## Handoff

Complete. All four interfaces, shared segment semantics, documentation,
changelog entries, and TurfJS comparison fixtures are in place. The full
verification suite passes.
