# Geo.Turf

[![CI](https://github.com/JonGretar/GeoTurf/actions/workflows/ci.yml/badge.svg)](https://github.com/JonGretar/GeoTurf/actions/workflows/ci.yml)
[![hex.pm](https://img.shields.io/hexpm/v/geo_turf.svg)](https://hex.pm/packages/geo_turf)

Spatial analysis for Elixir, ported from [TurfJS](http://turfjs.org/). Operates on [Geo](https://github.com/bryanjos/geo) structs using WGS84 coordinates.

## Usage

All functions accept and return standard `Geo` structs:

```elixir
point = %Geo.Point{coordinates: {-75.343, 39.984}}
other = %Geo.Point{coordinates: {-75.534, 39.123}}

# Measurements
Geo.Turf.Measure.distance(point, other, :kilometers)  # => 97.13
Geo.Turf.Measure.bearing(point, other)                # => -170.23
Geo.Turf.Measure.close_to(point, other, 100, :kilometers)  # => true

# Navigation
Geo.Turf.Measure.destination(point, 50, 90, units: :kilometers)  # => %Geo.Point{...}

# Line and area analysis
route = %Geo.LineString{coordinates: [{-23.621, 64.769}, {-23.629, 64.766}, {-23.638, 64.766}]}
Geo.Turf.Measure.length_of(route, :kilometers)   # => 0.93
Geo.Turf.Measure.along(route, 0.5, :kilometers)  # => %Geo.Point{...}

polygon = %Geo.Polygon{coordinates: [[{125, -15}, {113, -22}, {154, -27}, {144, -15}, {125, -15}]]}
Geo.Turf.Measure.area(polygon)    # => 3332484969239.27 (m²)
Geo.Turf.Measure.center(polygon)  # => %Geo.Point{...}

# Transformations
Geo.Turf.Transformation.circle(point, 10, units: :kilometers)  # => %Geo.Polygon{...}
```

See the [full API docs](https://hexdocs.pm/geo_turf) for all available functions.

## Works with geo_postgis

If you query a PostGIS database via [`geo_postgis`](https://github.com/felt/geo_postgis), the structs it returns work directly with GeoTurf — no conversion needed:

```elixir
# Ecto query returns %Geo.Point{} and %Geo.Polygon{} fields automatically.
# Pass them straight into GeoTurf:
locations
|> Enum.filter(&Geo.Turf.Measure.close_to(&1.geom, origin, 50, :kilometers))
|> Enum.sort_by(&Geo.Turf.Measure.distance(&1.geom, origin))
```

## Suggestions

Missing a function from [TurfJS](http://turfjs.org/)? Open an issue — a test case alongside it is always welcome.
