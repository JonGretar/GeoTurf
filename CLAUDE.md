# GeoTurf — Claude Code Context

Elixir spatial analysis library ported from [TurfJS](https://turfjs.org/). Operates on `Geo` structs, targets WGS84 coordinates. All public geodesic functions guard against non-WGS84 SRIDs via `Helpers.assert_wgs84!/1`.

## Modules

| Module                    | Purpose                                          |
| ------------------------- | ------------------------------------------------ |
| `Geo.Turf`                | Root namespace, shared types                     |
| `Geo.Turf.Measure`        | Distance, bearing, area, length, along, centroid |
| `Geo.Turf.Classification` | Point-in-polygon, nearest point, containment     |
| `Geo.Turf.Transformation` | Geometry construction (circle, etc.)             |
| `Geo.Turf.Helpers`        | BBox, WGS84 assertion, coordinate utilities      |
| `Geo.Turf.Math`           | Internal geodesic math, unit conversions         |

## Conventions

- If a comparable version of the function is found in TurfJS, we try to adhere to the API of that function as long as it does not break Elixir conventions.
- Predicate functions use `?` suffix (`point_in_polygon?`), not a `boolean_` prefix — TurfJS uses `boolean*` as a JS workaround for the same intent.
- Do not get stuck on the exact methodology of how TurfJS accomplishes the solution. The result is the goal. These are different languages with different strengths.
- Tests use GeoJSON fixture files in `priv/fixtures/` parsed via `test/support/fixture_parser.ex`.
- TurfJS source is copied into `temp/TurfJS/` (gitignored) — use it as reference for implementations, tests, and fixture data.

## Changelog

Follows [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/).

- New work goes under `## [Unreleased]` with subsections (`### Added`, `### Fixed`, etc.)
- Generate a release **ONLY** when instructed to do so.
- On release: replace `## [Unreleased]` with `## [x.y.z] - YYYY-MM-DD` and bump `version:` in `mix.exs`. Create a tag with "v" prefix (`vx.y.z`) in the repository.

## Commands

```bash
mix test              # run tests
mix precommit         # full CI pipeline: compile, format, test, dialyzer, credo
mix credo --strict    # lint
mix dialyzer          # static analysis
```
