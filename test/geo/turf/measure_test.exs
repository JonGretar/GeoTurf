defmodule Geo.Test.MeasureTest do
  use ExUnit.Case
  use Fixate.Case
  alias Geo.Turf.Measure, as: M
  alias Geo.Turf.Math, as: Math
  doctest Geo.Turf.Measure

  @fixture dcline: "along/dc-line.geojson"
  @fixture dcpoints: "along/dc-points.geojson"
  test "Along", ctx do
    # 9 km
    # assert M.along(ctx.dcline, 1.2, :miles) == ctx.dcpoints[0]
    # assert M.along(ctx.dcline, 1, :miles) == ctx.dcpoints[1]
    assert M.along(ctx.dcline, 1, :miles) != M.along(ctx.dcline, 20, :miles)
    assert M.along(ctx.dcline, 1, :miles) != M.along(ctx.dcline, 1, :kilometers)
    assert M.along(ctx.dcline, 1, :miles) == M.along(ctx.dcline, 1.6, :kilometers)
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
    assert M.distance(start, finish) == 97.13
    assert M.distance(start, finish, :kilometers) == 97.13
    assert M.distance(start, finish, :meters) == 97_129.22
    assert M.distance(start, finish, :miles) == 60.35
    assert M.distance(start, finish, :nauticalmiles) == 52.45
    assert M.distance(start, finish, :radians) == 0.02
    assert M.distance(start, finish, :degrees) == 0.87
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
end
