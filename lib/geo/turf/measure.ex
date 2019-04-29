defmodule Geo.Turf.Measure do
  @moduledoc """
  A collection of measurement related tools
  """
  import Geo.Turf.Helpers, only: [bbox: 1, flatten_coords: 1]
  alias Geo.Turf.Math

  @doc """
  Takes a LineString and returns a Point at a specified distance along the line.

  ## Examples

    #iex> %Geo.LineString{coordinates: [{-83, 30}, {-84, 36}, {-78, 41}]}
    #...>   |> Geo.Turf.Measure.along(200)
    #%Geo.Point{coordinates: {1, 1}}
  """
  @spec along(Geo.LineString.t(), number() | :midpoint, atom()) :: Geo.Point.t()
  def along(%Geo.LineString{coordinates: coords}, distance, unit \\ :kilometers)
  when is_number(distance) do
    walk_along(coords, distance, unit, 0)
  end
  defp walk_along([from, to| next], distance, unit, acc) when distance > acc do
    travel = get_distance(from, to, unit)
    walk_along([to| next], distance, unit, acc+travel)
  end
  defp walk_along([from| _next], distance, _unit, acc) when distance < acc do
    # TODO: overshot
    %Geo.Point{coordinates: from}
  end
  defp walk_along([{x,y}], _distance, _unit, _acc), do: %Geo.Point{coordinates: {x,y}}
  defp walk_along([], _distance, _unit, _acc), do: :error

  @doc """
  Find the center of a `Geo.geometry()` item and give us a `Geo.Point`

  ## Examples

      iex> Geo.Turf.Measure.center(%Geo.Polygon{coordinates: [{0,0}, {0,10}, {10,10}, {10,0}]})
      %Geo.Point{ coordinates: {5, 5} }

  """
  @spec center(Geo.geometry()) :: Geo.Point.t()
  def center(geometry) when is_map(geometry) do
    {min_x, min_y, max_x, max_y} = bbox(geometry)
    if (is_integer(min_x) && is_integer(min_y) && is_integer(max_x) && is_integer(max_y)) do
      %Geo.Point{ coordinates: {
        round((min_x + max_x) / 2),
        round((min_y + max_y) / 2)
      } }
    else
      %Geo.Point{ coordinates: {
        (min_x + max_x) / 2,
        (min_y + max_y) / 2
      } }
    end
  end

  @doc """
  Verifies that two points are close to each other. Defaults to 100 meters.

  ## Examples

    iex> %Geo.Point{coordinates: {-22.653375, 64.844254}}
    ...> |> Geo.Turf.Measure.close_to(%Geo.Point{coordinates: {-22.654042, 64.843656}})
    true

    iex> %Geo.Point{coordinates: {-22.653375, 64.844254}}
    ...> |> Geo.Turf.Measure.close_to(%Geo.Point{coordinates: {-23.803020, 64.730435}}, 100, :kilometers)
    true

  """
  def close_to(point_a, point_b, maximum \\ 100, units \\ :meters) do
    distance(point_a, point_b, units) < maximum
  end

  @doc """
  Calculates the distance between two points in degrees, radians, miles, or kilometers.
  This uses the [Haversine formula](http://en.wikipedia.org/wiki/Haversine_formula) to account for global curvature.

  ## Examples

    iex> Geo.Turf.Measure.distance(
    ...>   %Geo.Point{coordinates: {-75.343, 39.984}},
    ...>   %Geo.Point{coordinates: {-75.534, 39.123}},
    ...>   :kilometers)
    97.13
  """
  @spec distance(Geo.Turf.point(), Geo.Turf.point(), atom()) :: number()
  def distance(from, to, unit \\ :kilometers) do
    get_distance(from, to, unit)
    |> Math.rounded(2)
  end

  defp get_distance(from, to, unit \\ :kilometers)
  defp get_distance(%Geo.Point{coordinates: a}, %Geo.Point{coordinates: b}, unit), do: distance(a, b, unit)
  defp get_distance({x1, y1}, {x2, y2}, unit) do
    d_lat = Math.degrees_to_radians((y2 - y1));
    d_lon = Math.degrees_to_radians((x2 - x1));
    lat1 = Math.degrees_to_radians(y1);
    lat2 = Math.degrees_to_radians(y2);

    a = :math.pow(:math.sin(d_lat / 2), 2) +
      :math.pow(:math.sin(d_lon / 2), 2) * :math.cos(lat1) * :math.cos(lat2)
    Math.radians_to_length(2 * :math.atan2(:math.sqrt(a), :math.sqrt(1 - a)), unit)
  end

  @doc """
  Takes a `t:Geo.geometry()` and measures its length in the specified units.
  """
  @spec length(Geo.geometry(), :atom) :: number()
  def length(feature, unit \\ :kilometers) do
    feature
    |> flatten_coords()
    |> walk_length(unit, 0)
    |> Math.rounded(2)
  end

  defp walk_length([from, to| next], unit, acc) do
    travel = get_distance(from, to, unit)
    walk_length([to| next], unit, acc+travel)
  end
  defp walk_length([{_,_}], _unit, acc), do: acc
  defp walk_length([], _unit, acc), do: acc


end
