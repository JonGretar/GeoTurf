# Architecture Review - August 2026

## Current State

The codebase is compact and well-focused: six implementation modules around
`Geo` structs, GeoJSON fixtures, and a direct TurfJS reference source. Local
quality checks pass: 52 tests, 29 doctests, formatting, Dialyzer, and strict
Credo. Relevant-line coverage is 89.9%.

The published package and local release state need reconciliation: the local
project is `0.4.0` with additions under `Unreleased`, while the public package
listing showed `0.3.1` during this review. No release is scheduled by this
document.

## Confirmed Risks

1. `length_of/2` flattens geometry coordinates before measuring, which joins
   distinct coordinate paths and returns fictitious length.
2. `distance/3` rounds before `close_to/4` and `nearest_point/3` consume it,
   so presentation precision affects boolean and ranking behavior.
3. Empty or degenerate geometries lack intentional contracts; empty centroid
   currently divides by zero.
4. Transformation option docs, types, and tests disagree on `:unit` versus
   `:units`.
5. The declared Elixir floor predates `then/1`, which the implementation uses.

## Architectural Direction

Preserve the existing domain modules. Deepen their interfaces by separating
topology-preserving coordinate paths from flat coordinate aggregation, raw
geodesic metrics from presentation rounding, and shared geometry/unit
validation from individual public functions.

## Feature Direction

After the quality foundations, start the Line Analysis Foundations milestone:
nearest-point-on-line, point-to-line-distance, point-on-line, and line-slice.
They share coordinate-path traversal, segment semantics, raw distance, and a
tolerance policy. Follow with line-intersect and the core boolean predicates.
Delay spatial indexing and Feature property preservation until a real caller
requires them.
