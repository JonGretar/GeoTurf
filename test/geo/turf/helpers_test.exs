defmodule Geo.Turf.Helpers.Test do
  use ExUnit.Case
  alias Geo.Turf.Helpers, as: H
  use Fixate.Case
  doctest Geo.Turf.Helpers

  @square %Geo.Polygon{coordinates: [[{0, 0}, {0, 10}, {10, 10}, {10, 0}]]}
  @square_float %Geo.Polygon{coordinates: [[{0.0, 0.0}, {0.0, 10.0}, {10.0, 10.0}, {10.0, 0.0}]]}
  @triangle %Geo.Polygon{coordinates: [[{-10, 10}, {0, 0}, {10, 10}]]}
  @triangle_float %Geo.Polygon{coordinates: [[{-10, 10}, {0, 0}, {10, 10}]]}
  @collection %Geo.GeometryCollection{geometries: [@square, @triangle]}

  test "Bounding Box" do
    assert H.bbox(@square) == {0, 0, 10, 10}
    assert H.bbox(@square_float) == {0.0, 0.0, 10.0, 10.0}
    assert H.bbox(@triangle) == {-10, 0, 10, 10}
    assert H.bbox(@collection) == {-10, 0, 10, 10}
  end

  test "Bounding Box returns :error without coordinates" do
    assert H.bbox(%Geo.GeometryCollection{geometries: []}) == :error
    assert H.bbox([]) == :error
  end

  test "Bounding Box polygon has an explicit WGS84 SRID" do
    assert %Geo.Polygon{srid: 4326} = H.bbox_polygon({0, 0, 1, 1})
  end

  test "WGS84 validation recurses through geometry collections and lists" do
    invalid = %Geo.Point{coordinates: {0, 0}, srid: 3857}

    error =
      assert_raise ArgumentError, fn ->
        H.assert_wgs84!(%Geo.GeometryCollection{geometries: [invalid]})
      end

    assert error.message =~ "received SRID 3857"
    assert error.message =~ "Reproject the geometry"
    assert error.message =~ "%{geometry | srid: 4326}"

    assert_raise ArgumentError, fn -> H.assert_wgs84!([invalid]) end
  end

  test "Flatten Coordinates" do
    assert H.flatten_coords(@triangle) == [{-10, 10}, {0, 0}, {10, 10}]
    assert H.flatten_coords(@triangle_float) == [{-10.0, 10.0}, {0.0, 0.0}, {10.0, 10.0}]

    assert H.flatten_coords(@collection) == [
             {0, 0},
             {0, 10},
             {10, 10},
             {10, 0},
             {-10, 10},
             {0, 0},
             {10, 10}
           ]
  end
end
