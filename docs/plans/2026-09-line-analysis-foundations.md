# Line Analysis Foundations

State: `In progress`
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
- [ ] Define an explicit tolerance option for coordinate-on-segment checks.
- [ ] Add TurfJS-derived fixtures for endpoint, interior, duplicate-vertex,
      degenerate, and MultiLineString cases.

### 2. Snap And Distance

- [x] Implement `nearest_point_on_line/3` for LineString and MultiLineString.
- [x] Return the snapped point plus documented route-location metadata that
      suits `Geo` structs and Elixir conventions.
- [x] Implement `point_to_line_distance/3` using the same segment semantics.
- [ ] Verify that ranking and thresholds use raw distance values.

### 3. Predicate And Slicing

- [ ] Implement `point_on_line?/3` using the same tolerance policy.
- [ ] Implement `line_slice/3` after deciding whether it accepts only points
      on the line or snaps its inputs first.
- [ ] Add docs and examples that make the chosen behavior visible.

## Acceptance Criteria

- [ ] Separate line members are never joined for traversal, distances, or
      along-line metadata.
- [ ] Snapping a point to a segment returns the nearest WGS84 point and stable
      location metadata.
- [ ] Point-to-line distance equals the snap point's raw point distance.
- [ ] The point-on-line predicate has documented endpoint and tolerance rules.
- [ ] Line slicing preserves route direction and has defined behavior for
      out-of-order or off-line input points.
- [ ] All new public functions have TurfJS comparison fixtures where an
      equivalent TurfJS function exists.

## Verification

- `mix format --check-formatted`
- `mix test`
- `mix coveralls`
- `mix dialyzer`
- `mix credo --strict`
- `mix docs`

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

## Handoff

Implemented snapping and point-to-line distance with focused LineString,
MultiLineString, and empty-line tests. The next action is a TDD slice for
`point_on_line?/3`, including its `:tolerance` contract.
