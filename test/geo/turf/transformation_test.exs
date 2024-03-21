defmodule Geo.Test.TransformationTest do
  use ExUnit.Case
  use Fixate.Case

  alias Geo.Turf.Transformation, as: T

  @fixture circle: "transformation/circle.geojson"
  test "circle", ctx do
    [center, result_circle] = ctx.circle

    assert T.circle(center, 1, steps: 10, unit: :kilometers) == result_circle
  end
end
