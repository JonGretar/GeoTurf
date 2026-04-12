defmodule Geo.Test.TransformationTest do
  use ExUnit.Case
  use Fixate.Case

  alias Geo.Turf.Transformation, as: T

  @fixture circle: "transformation/circle.geojson"
  test "circle", ctx do
    [center, result_circle] = ctx.circle

    assert round_polygon(T.circle(center, 1, steps: 10, unit: :kilometers)) ==
             round_polygon(result_circle)
  end

  defp round_polygon(%Geo.Polygon{coordinates: coords} = polygon) do
    rounded =
      Enum.map(coords, fn ring ->
        Enum.map(ring, fn {x, y} -> {Float.round(x, 10), Float.round(y, 10)} end)
      end)

    %{polygon | coordinates: rounded}
  end
end
