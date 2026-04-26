# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `Measure.final_bearing/2` — computes the bearing at the destination point (as opposed to `bearing/2` which gives the initial bearing at the origin)
- `Helpers.assert_wgs84!/1` and guards on all public geodesic functions against non-WGS84 SRIDs
- `Math.approx/2` for rounding Point coordinates to a given precision

### Fixed

- `Measure.along/3` now geodesically interpolates mid-segment points instead of snapping to the nearest vertex

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
