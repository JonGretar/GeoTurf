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
