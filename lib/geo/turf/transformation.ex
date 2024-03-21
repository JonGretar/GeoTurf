defmodule Geo.Turf.Transformation do
  @moduledoc """
  A collection of functions to transform given geometries
  """

  alias Geo.Turf.Math
  alias Geo.Turf.Measure

  @type units :: {:unit, Math.length_unit()}
  @type steps :: {:steps, non_neg_integer()}

  @type circle_options :: [units() | steps()]

  @doc """
  Create a circle polygon from a given center and radius.
  The circle is created by generating a number of points around the center
  and then connecting them to form a polygon.

  ## Parameters
  * `center` - the center of the circle
  * `radius` - the radius of the circle
  * `opts` - a keyword list of options

  ## Options
  * `:units` - the unit of the radius, defaults to `:kilometers`. see `Geo.Turf.Math.length_unit/0`
  * `:steps` - the number of steps to use to create the circle, defaults to `64`
    * `steps` must be a positive integer or an `ArgumentError` will be raised
    * Note the higher the number of steps, the smoother the circle will be, but the more points it will have
  """
  @spec circle(center :: Geo.Point.t(), radius :: non_neg_integer(), opts :: circle_options()) ::
          Geo.Polygon.t()
  def circle(%Geo.Point{coordinates: a} = center, radius, opts \\ [])
      when radius > 0 and is_tuple(a) do
    units = Keyword.get(opts, :units, :kilometers)

    steps =
      case Keyword.get(opts, :steps, 64) do
        steps when is_integer(steps) and steps > 0 -> steps
        _ -> raise ArgumentError, "steps must be a positive integer"
      end

    coordinates =
      0..(steps - 1)
      |> Enum.map(&Measure.destination(center, radius, &1 * -360 / steps, units: units).coordinates)
      |> then(&(&1 ++ [hd(&1)]))

    %Geo.Polygon{coordinates: [coordinates]}
  end
end
