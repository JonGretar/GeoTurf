# Roadmap

## Completed: Quality Foundations

**Outcome:** GeoTurf's existing public functions have intentional edge-case,
precision, topology, SRID, and option contracts.

- [x] [Fix topology-preserving length](plans/2026-08-quality-foundations.md#1-topology-preserving-length)
- [x] [Separate raw measurement from display rounding](plans/2026-08-quality-foundations.md#2-raw-geodesic-metrics)
- [x] [Define invalid and empty geometry contracts](plans/2026-08-quality-foundations.md#3-geometry-and-unit-contracts)
- [x] [Align options, types, docs, and supported runtimes](plans/2026-08-quality-foundations.md#4-delivery-contract)

## Now: Spatial Fundamentals

**Outcome:** callers can solve common nearest, line, and boolean relationship
queries without reaching for another library.

- [x] [Line analysis foundations](plans/2026-09-line-analysis-foundations.md)
  - nearest point on line
  - point-to-line distance
  - point-on-line predicate
  - line slice
- [ ] Boolean relationships: contains, within, intersects, disjoint, crosses,
      and touches
- [ ] Geometry hygiene: clean coordinates, rewind, truncate, simplify,
      explode/combine, polygon-to-line, and bbox clip

## Later: Advanced Geodesics

**Outcome:** callers can model common navigation and route shapes with clear
accuracy expectations.

- [ ] Rhumb distance, bearing, and destination
- [ ] Great circle, line arc, and square
- [ ] Point-to-polygon distance
- [ ] Deliberate buffer strategy, including projection/dependency decision
- [ ] Polygon set operations: union, difference, intersect, and dissolve

## Explore When Needed

- Preserve GeoJSON Feature and FeatureCollection properties and identifiers.
- Add bulk-query indexing only after a demonstrated workload needs it.
- Add a second work-system adapter, such as GitHub Issues, only after the
  repository-native workflow becomes stable.

## Not Scheduled

- A broad module reorganization. The current Measure, Classification,
  Transformation, Helpers, and Math modules fit the domain; improve their
  interfaces first.

## Path To 1.0

The target is a stable, dependable measurement, predicate, and route-analysis
library, not full TurfJS parity. See [V1.md](V1.md) for the release milestones,
breaking-change window, and explicit `1.0` gates.
