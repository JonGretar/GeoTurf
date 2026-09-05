defmodule Geo.Turf.ClassificationTest do
  use ExUnit.Case
  use Fixate.Case
  alias Geo.Turf.Classification, as: C
  doctest Geo.Turf.Classification

  # ---------------------------------------------------------------------------
  # point_in_polygon? — simple and concave polygons
  # Mirrors: TurfJS "boolean-point-in-polygon -- featureCollection"
  # ---------------------------------------------------------------------------

  @simple_poly %Geo.Polygon{
    coordinates: [
      [{0, 0}, {0, 100}, {100, 100}, {100, 0}, {0, 0}]
    ]
  }
  @concave_poly %Geo.Polygon{
    coordinates: [
      [{0, 0}, {50, 50}, {0, 100}, {100, 100}, {100, 0}, {0, 0}]
    ]
  }

  test "point inside simple polygon" do
    assert C.point_in_polygon?(%Geo.Point{coordinates: {50, 50}}, @simple_poly) == true
  end

  test "point outside simple polygon" do
    assert C.point_in_polygon?(%Geo.Point{coordinates: {140, 150}}, @simple_poly) == false
  end

  test "point is outside empty polygons" do
    point = %Geo.Point{coordinates: {0, 0}}

    refute C.point_in_polygon?(point, %Geo.Polygon{coordinates: []})
    refute C.point_in_polygon?(point, %Geo.Polygon{coordinates: [[]]})
    refute C.point_in_polygon?(point, %Geo.MultiPolygon{coordinates: []})
  end

  test "point inside concave polygon" do
    assert C.point_in_polygon?(%Geo.Point{coordinates: {75, 75}}, @concave_poly) == true
  end

  test "point outside concave polygon" do
    assert C.point_in_polygon?(%Geo.Point{coordinates: {25, 50}}, @concave_poly) == false
  end

  # ---------------------------------------------------------------------------
  # point_in_polygon? — polygon with hole
  # Mirrors: TurfJS "boolean-point-in-polygon -- poly with hole"
  # ---------------------------------------------------------------------------

  @fixture poly_hole: "point_in_polygon/poly-with-hole.geojson"
  test "point in hole is outside polygon", ctx do
    pt_in_hole = %Geo.Point{coordinates: {-86.69208526611328, 36.20373274711739}}
    assert C.point_in_polygon?(pt_in_hole, ctx.poly_hole) == false
  end

  @fixture poly_hole: "point_in_polygon/poly-with-hole.geojson"
  test "point in poly but not hole is inside", ctx do
    pt_in_poly = %Geo.Point{coordinates: {-86.72229766845702, 36.20258997094334}}
    assert C.point_in_polygon?(pt_in_poly, ctx.poly_hole) == true
  end

  @fixture poly_hole: "point_in_polygon/poly-with-hole.geojson"
  test "point outside poly-with-hole is outside", ctx do
    pt_outside = %Geo.Point{coordinates: {-86.75079345703125, 36.18527313913089}}
    assert C.point_in_polygon?(pt_outside, ctx.poly_hole) == false
  end

  # ---------------------------------------------------------------------------
  # point_in_polygon? — multipolygon with hole
  # Mirrors: TurfJS "boolean-point-in-polygon -- multipolygon with hole"
  # ---------------------------------------------------------------------------

  @fixture multipoly_hole: "point_in_polygon/multipoly-with-hole.geojson"
  test "point in hole of multipoly is outside", ctx do
    pt_in_hole = %Geo.Point{coordinates: {-86.69208526611328, 36.20373274711739}}
    assert C.point_in_polygon?(pt_in_hole, ctx.multipoly_hole) == false
  end

  @fixture multipoly_hole: "point_in_polygon/multipoly-with-hole.geojson"
  test "point in multipoly ring (not hole) is inside", ctx do
    pt_in_poly = %Geo.Point{coordinates: {-86.72229766845702, 36.20258997094334}}
    assert C.point_in_polygon?(pt_in_poly, ctx.multipoly_hole) == true
  end

  @fixture multipoly_hole: "point_in_polygon/multipoly-with-hole.geojson"
  test "point in first sub-polygon (no hole) is inside", ctx do
    pt_in_poly2 = %Geo.Point{coordinates: {-86.75079345703125, 36.18527313913089}}
    assert C.point_in_polygon?(pt_in_poly2, ctx.multipoly_hole) == true
  end

  @fixture multipoly_hole: "point_in_polygon/multipoly-with-hole.geojson"
  test "point outside all multipoly rings is outside", ctx do
    pt_outside = %Geo.Point{coordinates: {-86.75302505493164, 36.23015046460186}}
    assert C.point_in_polygon?(pt_outside, ctx.multipoly_hole) == false
  end

  # ---------------------------------------------------------------------------
  # point_in_polygon? — boundary behaviour
  # Mirrors: TurfJS "boolean-point-in-polygon -- Boundary test"
  # Covers a representative subset of TurfJS's 37 boundary sub-cases.
  # ---------------------------------------------------------------------------

  @poly1 %Geo.Polygon{
    coordinates: [
      [{10, 10}, {30, 20}, {50, 10}, {30, 0}, {10, 10}]
    ]
  }
  @poly2 %Geo.Polygon{
    coordinates: [
      [{10, 0}, {30, 20}, {50, 0}, {30, 10}, {10, 0}]
    ]
  }
  @poly3 %Geo.Polygon{
    coordinates: [
      [{10, 0}, {30, 20}, {50, 0}, {30, -20}, {10, 0}]
    ]
  }
  @poly5 %Geo.Polygon{
    coordinates: [
      [{0, 20}, {20, 40}, {40, 20}, {20, 0}, {0, 20}],
      [{10, 20}, {20, 30}, {30, 20}, {20, 10}, {10, 20}]
    ]
  }

  # vertices are on boundary — included by default, excluded with ignore_boundary
  test "boundary: vertex on boundary included by default" do
    assert C.point_in_polygon?(%Geo.Point{coordinates: {10, 10}}, @poly1) == true
    assert C.point_in_polygon?(%Geo.Point{coordinates: {30, 20}}, @poly1) == true
    assert C.point_in_polygon?(%Geo.Point{coordinates: {50, 10}}, @poly1) == true
  end

  test "boundary: vertex on boundary excluded with ignore_boundary" do
    assert C.point_in_polygon?(%Geo.Point{coordinates: {10, 10}}, @poly1, ignore_boundary: true) ==
             false

    assert C.point_in_polygon?(%Geo.Point{coordinates: {30, 20}}, @poly1, ignore_boundary: true) ==
             false
  end

  test "boundary: strictly inside is always true" do
    assert C.point_in_polygon?(%Geo.Point{coordinates: {30, 10}}, @poly1) == true

    assert C.point_in_polygon?(%Geo.Point{coordinates: {30, 10}}, @poly1, ignore_boundary: true) ==
             true
  end

  test "boundary: strictly outside is always false" do
    assert C.point_in_polygon?(%Geo.Point{coordinates: {0, 10}}, @poly1) == false
    assert C.point_in_polygon?(%Geo.Point{coordinates: {60, 10}}, @poly1) == false
  end

  # poly2: vertex {30, 0} lies on the interior of an edge, not a corner — result is false
  test "boundary: tricky poly2 point on inner vertex is outside" do
    assert C.point_in_polygon?(%Geo.Point{coordinates: {30, 0}}, @poly2) == false
  end

  # poly3: {30, 0} is the bottom vertex — result is inside
  test "boundary: poly3 bottom vertex is inside" do
    assert C.point_in_polygon?(%Geo.Point{coordinates: {30, 0}}, @poly3) == true
  end

  # poly5 (diamond with diamond hole): hole boundary is a boundary
  test "boundary: hole boundary included by default" do
    assert C.point_in_polygon?(%Geo.Point{coordinates: {20, 20}}, @poly5) == false
  end

  test "boundary: outer ring boundary of poly5 included by default" do
    assert C.point_in_polygon?(%Geo.Point{coordinates: {20, 30}}, @poly5) == true
  end

  # ---------------------------------------------------------------------------
  # point_in_polygon? — issue #15 regression
  # https://github.com/Turfjs/turf-inside/issues/15
  # ---------------------------------------------------------------------------

  test "issue #15 regression" do
    pt = %Geo.Point{coordinates: {-9.9964077, 53.8040989}}

    poly = %Geo.Polygon{
      coordinates: [
        [
          {5.080336744095521, 67.89398938540765},
          {0.35070899909145403, 69.32470003971179},
          {-24.453622256504122, 41.146696777884564},
          {-21.6445524714804, 40.43225902006474},
          {5.080336744095521, 67.89398938540765}
        ]
      ]
    }

    assert C.point_in_polygon?(pt, poly) == true
  end

  # ---------------------------------------------------------------------------
  # points_within_polygon — fixture-based
  # Mirrors: TurfJS "turf-points-within-polygon -- point" structure
  # ---------------------------------------------------------------------------

  @fixture points: "points_within_polygon/points.geojson"
  @fixture poly: "points_within_polygon/poly.geojson"
  test "points within polygon", ctx do
    result = C.points_within_polygon(ctx.points, ctx.poly)
    assert length(result) == 3
  end

  @fixture points: "points_within_polygon/points.geojson"
  @fixture multipoly: "points_within_polygon/multipoly.geojson"
  test "points within multipolygon", ctx do
    result = C.points_within_polygon(ctx.points, ctx.multipoly)
    assert length(result) == 4
  end

  # ---------------------------------------------------------------------------
  # nearest_point
  # Mirrors: TurfJS "turf-nearest-point -- points"
  # Target: [-75.4, 39.4], expected nearest: [-75.33, 39.44] (index 14)
  # ---------------------------------------------------------------------------

  @fixture points: "nearest_point/points.geojson"
  test "nearest point from fixture matches TurfJS output", ctx do
    target = %Geo.Point{coordinates: {-75.4, 39.4}}
    assert %Geo.Point{coordinates: {-75.33, 39.44}} = C.nearest_point(target, ctx.points)
  end

  test "nearest_point returns nil for empty list" do
    assert C.nearest_point(%Geo.Point{coordinates: {0, 0}}, []) == nil
  end

  test "empty point collections still validate WGS84 inputs" do
    invalid_target = %Geo.Point{coordinates: {0, 0}, srid: 3857}
    invalid_polygon = %Geo.Polygon{coordinates: [], srid: 3857}

    assert_raise ArgumentError, fn -> C.nearest_point(invalid_target, []) end
    assert_raise ArgumentError, fn -> C.points_within_polygon([], invalid_polygon) end
  end

  test "nearest_point returns the only point in a singleton list" do
    pt = %Geo.Point{coordinates: {10.0, 20.0}}
    assert C.nearest_point(%Geo.Point{coordinates: {0, 0}}, [pt]) == pt
  end

  test "nearest_point ranks candidates by raw distance rather than display rounding" do
    target = %Geo.Point{coordinates: {0, 0}}
    farther = %Geo.Point{coordinates: {0, 0.0008993563365390871}}
    nearer = %Geo.Point{coordinates: {0, 0.0008993293569281753}}

    assert C.nearest_point(target, [farther, nearer], units: :meters) == nearer
  end

  # ---------------------------------------------------------------------------
  # nearest_point_on_line — interior segment snap
  # Mirrors: TurfJS "@turf/nearest-point-on-line" simple LineString case
  # ---------------------------------------------------------------------------

  test "nearest_point_on_line snaps to an interior segment and returns route metadata" do
    point = %Geo.Point{coordinates: {1, 1}}
    line = %Geo.LineString{coordinates: [{0, 0}, {2, 0}]}

    assert {:ok, %Geo.Point{coordinates: {longitude, latitude}, srid: 4326}, metadata} =
             C.nearest_point_on_line(point, line)

    assert_in_delta longitude, 1.0, 1.0e-10
    assert_in_delta latitude, 0.0, 1.0e-10
    assert metadata.segment_index == 0
    assert metadata.line_index == 0
    assert_in_delta metadata.distance, 111.1950802335329, 1.0e-9
    assert_in_delta metadata.location, 111.1950802335329, 1.0e-9
  end

  test "nearest_point_on_line does not join MultiLineString members" do
    point = %Geo.Point{coordinates: {5, 0}}

    line =
      %Geo.MultiLineString{
        coordinates: [
          [{0, 0}, {1, 0}],
          [{10, 0}, {11, 0}]
        ]
      }

    assert {:ok, %Geo.Point{coordinates: {1, 0}, srid: 4326}, metadata} =
             C.nearest_point_on_line(point, line)

    assert metadata.line_index == 0
    assert metadata.segment_index == 0
    assert_in_delta metadata.distance, 444.7803209341316, 1.0e-10
    assert_in_delta metadata.location, 111.1950802335329, 1.0e-10
  end

  test "nearest_point_on_line returns an error for lines without coordinates" do
    assert :error =
             C.nearest_point_on_line(
               %Geo.Point{coordinates: {0, 0}},
               %Geo.LineString{coordinates: []}
             )
  end

  # ---------------------------------------------------------------------------
  # point_on_line? — endpoint and tolerance semantics
  # Mirrors: TurfJS "@turf/boolean-point-on-line"
  # ---------------------------------------------------------------------------

  test "point_on_line? includes endpoints and segment interiors" do
    line = %Geo.LineString{coordinates: [{0, 0}, {2, 0}]}

    assert C.point_on_line?(%Geo.Point{coordinates: {0, 0}}, line)
    assert C.point_on_line?(%Geo.Point{coordinates: {1, 0}}, line)
    refute C.point_on_line?(%Geo.Point{coordinates: {1, 1}}, line)
  end

  test "point_on_line? applies an inclusive tolerance in the requested units" do
    line = %Geo.LineString{coordinates: [{0, 0}, {2, 0}]}
    point = %Geo.Point{coordinates: {1, 0.000008_993_203_637_245_38}}

    assert C.point_on_line?(point, line, tolerance: 1, units: :meters)
    refute C.point_on_line?(point, line, tolerance: 0.99, units: :meters)
  end

  test "point_on_line? returns false for an empty line" do
    refute C.point_on_line?(
             %Geo.Point{coordinates: {0, 0}},
             %Geo.LineString{coordinates: []}
           )
  end

  @fixture points: "nearest_point/points.geojson"
  test "nearest_point respects units option — miles vs kilometers same winner", ctx do
    target = %Geo.Point{coordinates: {-75.4, 39.4}}

    assert C.nearest_point(target, ctx.points, units: :miles) ==
             C.nearest_point(target, ctx.points, units: :kilometers)
  end
end
