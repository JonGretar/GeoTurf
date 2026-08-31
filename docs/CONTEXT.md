# GeoTurf

GeoTurf is an Elixir spatial-analysis library for `Geo` structs. It ports
useful TurfJS behavior while preserving Elixir conventions and WGS84 scope.

## Language

**WGS84 Geometry**:
A `Geo` struct whose SRID is `4326` or `nil`, with coordinates interpreted as
longitude and latitude.
_Avoid_: projected geometry, arbitrary SRID

**Geodesic Operation**:
A calculation whose result depends on WGS84 spherical-earth math, such as
distance, bearing, destination, length, area, or circle.
_Avoid_: planar operation

**Spatial Predicate**:
A function returning whether a geometric relationship holds, such as point in
polygon.
_Avoid_: classification rule

**Coordinate Path**:
One continuous ordered sequence of coordinates that may be measured without
joining it to another line, ring, polygon, or collection member.
_Avoid_: flattened coordinates when topology matters

**TurfJS Parity**:
Behavior aligned with a named TurfJS function where that behavior fits Elixir
and Geo structs.
_Avoid_: byte-for-byte port

## Relationships

- A **Geodesic Operation** accepts only **WGS84 Geometry**.
- A **Coordinate Path** belongs to one continuous geometry member.
- A **Spatial Predicate** may operate on WGS84 coordinates with a documented
  planar algorithm.
- **TurfJS Parity** is verified through focused fixtures or test vectors.

## Example Dialogue

> **Developer:** "Can `length_of/2` flatten a MultiLineString first?"
> **Maintainer:** "No. Each member is a separate **Coordinate Path**; joining
> them changes the **Geodesic Operation**."

## Flagged Ambiguities

- "length" can mean a single line, a polygon perimeter, or a sum of geometry
  members. Plans must name the intended **Coordinate Path** behavior.
