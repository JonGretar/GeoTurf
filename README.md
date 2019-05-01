# Geo.Turf
[![Build Status](https://www.travis-ci.org/JonGretar/GeoTurf.svg?branch=master)](https://www.travis-ci.org/JonGretar/GeoTurf)
[![Coverage Status](https://coveralls.io/repos/github/JonGretar/GeoTurf/badge.svg?branch=master)](https://coveralls.io/github/JonGretar/GeoTurf?branch=master)

A spatial analysis tool for Elixir's [Geo](https://github.com/bryanjos/geo) library ported from [TurfJS](http://turfjs.org/).

## Installation

*At the moment the library is in early development mode. The API could, and propably will, change on any moment.*

```elixir
def deps do
  [
    {:geo_turf, git: "https://github.com/JonGretar/GeoTurf.git"}
  ]
end
```

## Usage

The library can perform functions on [Geo](https://github.com/bryanjos/geo) objects as well as basic mathematic functions useful in spatial analysis. At the moment Geo.Turf expects WGS84 coordinates.

For example:

 * `Geo.Turf.Measure.along/3`: Make a `%Geo.Point{}` at a definded distance from the start of a `%Geo.LineString{}` .
*  `Geo.Turf.Measure.along_midpoint/1`: Make a `%Geo.Point{}` at a the middle of a `%Geo.LineString{}` .
 * `Geo.Turf.Measure.center/1`: Makes a `%Geo.Point{}` at the center of a Feature.
 * `Geo.Turf.Measure.close_to/4`: Check if 2 `%Geo.Point{}` items are close to each other.
 * `Geo.Turf.Measure.distance/3`: Check the distance between 2 `%Geo.Point{}` items.
 * `Geo.Turf.Measure.length_of/2`: Gives the length of a `%Geo.LineString{}` or the circumference of a `%Geo.Polygon{}`

## Suggestions

If there are functions you need from [TurfJS](http://turfjs.org/) or just things you thought of please just make an issue for it. Including a test for it would be great.