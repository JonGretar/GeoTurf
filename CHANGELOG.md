# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `Classification.nearest_point_on_line/3` snaps WGS84 points to LineString
  and MultiLineString segments with raw distance and route-location metadata
- `Classification.point_on_line?/3` tests line membership with an inclusive,
  unit-aware geodesic tolerance
- `Measure.point_to_line_distance/3` measures the raw distance using the same
  snapping semantics

## [0.5.0] - 2026-09-01

### Added

- `Measure.final_bearing/2` — computes the bearing at the destination point (as opposed to `bearing/2` which gives the initial bearing at the origin)
- `Helpers.assert_wgs84!/1` and guards on all public geodesic functions against non-WGS84 SRIDs
- `Math.approx/2` for rounding Point coordinates to a given precision

### Changed

- `Measure.distance/3` now returns raw geodesic values; callers can use `Math.rounded/2` for display rounding
- `Measure.close_to/4` uses raw distance and includes points exactly at the maximum threshold
- `Classification.nearest_point/3` ranks candidates by raw distance
- Empty geometries now return zero for aggregate measurements, `:error` for point-producing measurements, and `false` for polygon containment
- WGS84 validation now checks every member of geometry and point collections recursively
- Length and area APIs now reject unsupported units with explicit `ArgumentError` messages
- Newly constructed WGS84 geometry and measurement-derived points now carry `srid: 4326`; coordinate-only transformations preserve the source SRID
- Circle and destination options consistently use `:units`; unknown option names now raise instead of silently using defaults
- The supported runtime floor is now Elixir 1.15 / OTP 26, with CI coverage through Elixir 1.18 / OTP 28
- Non-WGS84 SRID errors now explain reprojection, the `nil` assumption, and how to correct stale WGS84 metadata explicitly

### Fixed

- `Measure.along/3` now geodesically interpolates mid-segment points instead of snapping to the nearest vertex
- `Measure.length_of/2` now measures independent geometry paths without adding fictitious segments between them

## [0.4.0] - 2026-04-12

### Added

- `Classification.point_in_polygon?/3`
- `Classification.points_within_polygon/2`
- `Classification.nearest_point/3`
- `Measure.centroid/1`
- `Helpers.bbox_polygon/1`

## [0.3.1] - 2025-08-19

### Added

- Geo 0.4.x support

## [0.3.0] - 2025-03-24

### Added

- `Measure.destination/3`
- `Transformation.circle/3`

## [0.2.0] - 2024-03-05

### Added

- `Measure.area/1`
- `Measure.bearing/2`

### Fixed

- Bad `mod/2` error

### Changed

- Library cleanup

## [0.1.0] - 2019-05-01

First release.
