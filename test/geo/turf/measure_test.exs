defmodule Geo.Test.MeasureTest do
  use ExUnit.Case
  use Fixate.Case
  alias Geo.Turf.Math, as: Math
  alias Geo.Turf.Measure, as: M
  doctest Geo.Turf.Measure

  @fixture dcline: "along/dc-line.geojson"
  @fixture dcpoints: "along/dc-points.geojson"
  test "Along", ctx do
    # 9 km
    # assert M.along(ctx.dcline, 1.2, :miles) == ctx.dcpoints[0]
    # assert M.along(ctx.dcline, 1, :miles) == ctx.dcpoints[1]
    assert M.along(ctx.dcline, 1, :miles) != M.along(ctx.dcline, 20, :miles)
    assert M.along(ctx.dcline, 1, :miles) != M.along(ctx.dcline, 1, :kilometers)
  end

  @fixture geometry: "area/polygon.geojson"
  test "Area", ctx do
    assert M.area(ctx.geometry) |> round() == 7_748_891_609_977
  end

  test "Bearing" do
    start_point = %Geo.Point{coordinates: {-75.0, 45.0}}
    end_point = %Geo.Point{coordinates: {20.0, 60.0}}

    assert M.bearing(start_point, end_point) |> Math.rounded(2) == 37.75
  end

  test "Center" do
    box = %Geo.Polygon{coordinates: [{0, 0}, {0, 10}, {10, 10}, {10, 0}]}
    floating_box = %Geo.Polygon{coordinates: [{0.0, 0.0}, {0.0, 10.0}, {10.0, 10.0}, {10.0, 0.0}]}
    assert Geo.Turf.Measure.center(box) == %Geo.Point{coordinates: {5, 5}}
    assert Geo.Turf.Measure.center(floating_box) == %Geo.Point{coordinates: {5.0, 5.0}}
  end

  @fixture points: "distance/points.geojson"
  test "Distance", ctx do
    [start, finish] = ctx.points
    assert_in_delta M.distance(start, finish), 97.12922118967835, 1.0e-12
    assert_in_delta M.distance(start, finish, :kilometers), 97.12922118967835, 1.0e-12
    assert_in_delta M.distance(start, finish, :meters), 97_129.22118967834, 1.0e-9
    assert_in_delta M.distance(start, finish, :miles), 60.35329997171415, 1.0e-12
    assert_in_delta M.distance(start, finish, :nauticalmiles), 52.44558379572265, 1.0e-12
    assert_in_delta M.distance(start, finish, :radians), 0.015245501024842149, 1.0e-15
    assert_in_delta M.distance(start, finish, :degrees), 0.8724834600465156, 1.0e-15
  end

  test "close_to compares its threshold against raw distance" do
    origin = %Geo.Point{coordinates: {0, 0}}
    just_over_100_meters = %Geo.Point{coordinates: {0, 0.0008993563365390871}}

    refute M.close_to(origin, just_over_100_meters, 100.001, :meters)
  end

  test "close_to includes points exactly at its threshold" do
    origin = %Geo.Point{coordinates: {0, 0}}
    point = %Geo.Point{coordinates: {0, 1}}
    threshold = M.distance(origin, point, :meters)

    assert M.close_to(origin, point, threshold, :meters)
  end

  test "destination", _ctx do
    start_point = %Geo.Point{coordinates: {-75.0, 39.0}}

    assert M.destination(start_point, 100, 180, units: :kilometers) == %Geo.Point{
             coordinates: {-75.00000000000001, 38.10067963627546}
           }

    assert M.destination(start_point, 100, 180, units: :miles) == %Geo.Point{
             coordinates: {-75.00000000000001, 37.552684168562095}
           }
  end

  # ---------------------------------------------------------------------------
  # centroid
  # Mirrors: TurfJS "turf-centroid" fixture suite
  # Expected coordinates taken from TurfJS test/out/*.geojson (first feature)
  # ---------------------------------------------------------------------------

  @fixture polygon: "centroid/polygon.geojson"
  test "centroid of polygon matches TurfJS", ctx do
    assert %Geo.Point{coordinates: {x, y}} = M.centroid(ctx.polygon)
    assert_in_delta x, 4.841194152832031, 1.0e-10
    assert_in_delta y, 45.75807143030368, 1.0e-10
  end

  @fixture imbalanced_polygon: "centroid/imbalanced_polygon.geojson"
  test "centroid of imbalanced polygon matches TurfJS", ctx do
    assert %Geo.Point{coordinates: {x, y}} = M.centroid(ctx.imbalanced_polygon)
    assert_in_delta x, 4.851791984156558, 1.0e-10
    assert_in_delta y, 45.78143055383553, 1.0e-10
  end

  @fixture linestring: "centroid/linestring.geojson"
  test "centroid of linestring matches TurfJS", ctx do
    assert %Geo.Point{coordinates: {x, y}} = M.centroid(ctx.linestring)
    assert_in_delta x, 4.860076904296875, 1.0e-10
    assert_in_delta y, 45.75919915723537, 1.0e-10
  end

  @fixture point: "centroid/point.geojson"
  test "centroid of point returns the point itself", ctx do
    assert %Geo.Point{coordinates: {x, y}} = M.centroid(ctx.point)
    assert_in_delta x, 4.831961989402771, 1.0e-10
    assert_in_delta y, 45.75764678012361, 1.0e-10
  end

  test "centroid of feature collection (4 points) matches TurfJS" do
    # TurfJS test/in/feature-collection.geojson — 4 points, expected centroid:
    # [4.8336222767829895, 45.76051644154402]
    points = [
      %Geo.Point{coordinates: {4.833351373672485, 45.760809294695534}},
      %Geo.Point{coordinates: {4.8331475257873535, 45.760296567821456}},
      %Geo.Point{coordinates: {4.833984374999999, 45.76073818687033}},
      %Geo.Point{coordinates: {4.834005832672119, 45.76022171678877}}
    ]

    gc = %Geo.GeometryCollection{geometries: points}
    assert %Geo.Point{coordinates: {x, y}} = M.centroid(gc)
    assert_in_delta x, 4.8336222767829895, 1.0e-10
    assert_in_delta y, 45.76051644154402, 1.0e-10
  end

  test "centroid aggregates vertices from separate MultiLineString members" do
    multiline = %Geo.MultiLineString{
      coordinates: [[{0, 0}, {2, 0}], [{10, 10}, {12, 10}]]
    }

    assert M.centroid(multiline) == %Geo.Point{coordinates: {6.0, 5.0}}
  end

  @fixture "length/polygon.geojson"
  @fixture "length/route1.geojson"
  @fixture "length/hike.geojson"
  test "Length", ctx do
    assert M.length_of(ctx.hike) == 3.05
    assert M.length_of(ctx.hike, :miles) == 1.90
    assert M.length_of(ctx.hike, :feet) == 10_007.75
    assert M.length_of(ctx.route1, :feet) == 1_068_691.81
    assert M.length_of(ctx.polygon, :feet) == 18_363.92
  end

  @fixture separated_multiline: "length/separated-multiline.geojson"
  test "length does not join separate MultiLineString members", ctx do
    assert M.length_of(ctx.separated_multiline) == 222.39
  end

  @fixture polygon_with_hole: "length/polygon-with-hole.geojson"
  test "length measures polygon rings independently", ctx do
    %Geo.Polygon{coordinates: rings} = ctx.polygon_with_hole

    expected =
      rings
      |> Enum.map(&M.length_of(%Geo.LineString{coordinates: &1}))
      |> Enum.sum()

    assert_in_delta M.length_of(ctx.polygon_with_hole), expected, 0.02
  end

  @fixture separated_multipolygon: "length/separated-multipolygon.geojson"
  test "length measures MultiPolygon rings independently", ctx do
    %Geo.MultiPolygon{coordinates: polygons} = ctx.separated_multipolygon

    expected =
      polygons
      |> Enum.flat_map(& &1)
      |> Enum.map(&M.length_of(%Geo.LineString{coordinates: &1}))
      |> Enum.sum()

    assert_in_delta M.length_of(ctx.separated_multipolygon), expected, 0.02
  end

  @fixture separated_geometry_collection: "length/separated-geometry-collection.geojson"
  test "length measures GeometryCollection children independently", ctx do
    %Geo.GeometryCollection{geometries: geometries} = ctx.separated_geometry_collection

    expected =
      geometries
      |> Enum.map(&M.length_of/1)
      |> Enum.sum()

    assert_in_delta M.length_of(ctx.separated_geometry_collection), expected, 0.02
  end
end
