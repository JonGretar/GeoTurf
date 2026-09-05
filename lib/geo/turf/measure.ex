defmodule Geo.Turf.Measure do
  @moduledoc """
  A collection of measurement related tools.

  Newly calculated points use the explicit WGS84 SRID `4326`.
  """
  import Geo.Turf.Helpers, only: [bbox: 1, assert_wgs84!: 1]
  alias Geo.Turf.Classification
  alias Geo.Turf.Math

  @type units :: {:units, Math.length_unit()}

  @spec along(Geo.LineString.t(), number(), Math.length_unit()) :: Geo.Point.t() | :error
  @doc """
  Takes a LineString and returns a Point at a specified distance along the line.
  Returns `:error` if the LineString has no coordinates.

  ## Examples

      iex> %Geo.LineString{coordinates: [{-23.621,64.769},{-23.629,64.766},{-23.638,64.766}]}
      ...>   |> Geo.Turf.Measure.along(2, :kilometers)
      %Geo.Point{coordinates: {-23.638,64.766}, srid: 4326}

      iex> Geo.Turf.Measure.along(%Geo.LineString{coordinates: []}, 1, :kilometers)
      :error
  """
  def along(%Geo.LineString{} = line, distance, unit \\ :kilometers)
      when is_number(distance) do
    assert_wgs84!(line)
    %Geo.LineString{coordinates: coords} = line
    walk_along(coords, distance, unit, 0)
  end

  defp walk_along([from, to | next], distance, unit, acc) do
    travel = raw_distance(from, to, unit)
    new_acc = acc + travel

    if distance <= new_acc do
      overshot = distance - new_acc
      direction = bearing(%Geo.Point{coordinates: to}, %Geo.Point{coordinates: from}) - 180
      destination(%Geo.Point{coordinates: to}, overshot, direction, units: unit)
    else
      walk_along([to | next], distance, unit, new_acc)
    end
  end

  defp walk_along([{x, y}], _distance, _unit, _acc),
    do: %Geo.Point{coordinates: {x, y}, srid: 4326}

  defp walk_along([], _distance, _unit, _acc), do: :error

  @spec along_midpoint(Geo.LineString.t()) :: Geo.Point.t() | :error
  @doc """
  Takes a LineString and returns a Point at the middle of the line.

  ## Examples

      iex> %Geo.LineString{coordinates: [{-23.621,64.769},{-23.629,64.766},{-23.638,64.766}]}
      ...>   |> Geo.Turf.Measure.along_midpoint()
      ...>   |> Geo.Turf.Math.approx(4)
      %Geo.Point{coordinates: {-23.6284, 64.7662}, srid: 4326}
  """
  def along_midpoint(%Geo.LineString{} = line) do
    along(line, length_of(line) / 2)
  end

  @spec area(Geo.geometry()) :: number()
  @doc """
  Takes a geometry and returns its area in square meters. Geometries without
  area, including empty geometries, return `0`.

  ## Examples
      iex> %Geo.Polygon{coordinates: [[{125, -15}, {113, -22}, {154, -27}, {144, -15}, {125, -15}]]}
      ...>   |> Geo.Turf.Measure.area()
      3332484969239.2676
  """
  def area(geometry) do
    assert_wgs84!(geometry)
    calc_area(geometry)
  end

  defp calc_area(%Geo.GeometryCollection{geometries: geometries}) do
    geometries
    |> Enum.map(&area/1)
    |> Enum.sum()
  end

  defp calc_area(%Geo.Polygon{coordinates: coords}), do: polygon_area(coords)

  defp calc_area(%Geo.MultiPolygon{coordinates: coords}) do
    coords
    |> Enum.map(&polygon_area/1)
    |> Enum.sum()
  end

  defp calc_area(%Geo.Point{}), do: 0
  defp calc_area(%Geo.MultiPoint{}), do: 0
  defp calc_area(%Geo.LineString{}), do: 0
  defp calc_area(%Geo.MultiLineString{}), do: 0

  defp polygon_area(coords) when coords == [], do: 0

  defp polygon_area(coords) do
    coords_area =
      coords
      |> Enum.map(&ring_area/1)

    hd(coords_area) - Enum.sum(tl(coords_area))
  end

  defp ring_area(coords) when length(coords) <= 2, do: 0

  defp ring_area(coords) do
    factor = Math.earth_radius() * Math.earth_radius() / 2
    abs(ring_area(coords, 0, 0) * factor)
  end

  # We should propably be a bit more efficient
  defp ring_area(coords, index, acc) when index >= length(coords), do: acc

  defp ring_area(coords, index, acc) do
    pi_over_180 = :math.pi() / 180
    {lower_x, _} = Enum.at(coords, index)
    {_, middle_y} = select_middle(coords, index)
    {upper_x, _} = select_upper(coords, index)

    lower_x = lower_x * pi_over_180
    middle_y = middle_y * pi_over_180
    upper_x = upper_x * pi_over_180

    total = acc + (upper_x - lower_x) * :math.sin(middle_y)
    ring_area(coords, index + 1, total)
  end

  defp select_middle(coords, index) when length(coords) == index + 1, do: Enum.at(coords, 0)
  defp select_middle(coords, index), do: Enum.at(coords, index + 1)

  defp select_upper(coords, index) when length(coords) <= index + 2 do
    Enum.at(coords, Math.mod(index + 2, length(coords)))
  end

  defp select_upper(coords, index), do: Enum.at(coords, index + 2)

  @spec bearing(Geo.Point.t(), Geo.Point.t()) :: float()
  @doc """
  Takes two points and finds the geographic bearing between them,
  i.e. the angle measured in degrees from the north line (0 degrees)

  ## Examples
      iex> point1 = %Geo.Point{coordinates: {-75.343, 39.984}}
      ...> point2 = %Geo.Point{coordinates: {-75.534, 39.123}}
      ...> Geo.Turf.Measure.bearing(point1, point2)
      ...>  |> Geo.Turf.Math.rounded(2)
      -170.23
  """
  def bearing(%Geo.Point{} = p1, %Geo.Point{} = p2) do
    assert_wgs84!(p1)
    assert_wgs84!(p2)
    %Geo.Point{coordinates: {x1, y1}} = p1
    %Geo.Point{coordinates: {x2, y2}} = p2
    lon1 = Math.degrees_to_radians(x1)
    lon2 = Math.degrees_to_radians(x2)
    lat1 = Math.degrees_to_radians(y1)
    lat2 = Math.degrees_to_radians(y2)

    a = :math.sin(lon2 - lon1) * :math.cos(lat2)

    b =
      :math.cos(lat1) * :math.sin(lat2) -
        :math.sin(lat1) * :math.cos(lat2) * :math.cos(lon2 - lon1)

    Math.radians_to_degrees(:math.atan2(a, b))
  end

  @spec final_bearing(Geo.Point.t(), Geo.Point.t()) :: float()
  @doc """
  Takes two points and finds the final bearing between them, i.e. the bearing
  as it arrives at the destination point. Returns degrees in the range [-180, 180].

  ## Examples
      iex> point1 = %Geo.Point{coordinates: {-75.343, 39.984}}
      ...> point2 = %Geo.Point{coordinates: {-75.534, 39.123}}
      ...> Geo.Turf.Measure.final_bearing(point1, point2)
      ...>  |> Geo.Turf.Math.rounded(2)
      -170.35
  """
  def final_bearing(%Geo.Point{} = p1, %Geo.Point{} = p2) do
    assert_wgs84!(p1)
    assert_wgs84!(p2)
    b = bearing(p2, p1) + 180
    if b > 180, do: b - 360, else: b
  end

  @spec centroid(Geo.geometry()) :: Geo.Point.t() | :error
  @doc """
  Computes the centroid of a geometry as the mean position of all vertices.
  Closed polygon rings have their repeated closing vertex excluded, matching
  the behaviour of `turf.centroid`.
  Returns `:error` when the geometry contains no coordinates.

  ## Examples

      iex> Geo.Turf.Measure.centroid(%Geo.Polygon{coordinates: [[{-81, 41}, {-88, 36}, {-84, 31}, {-80, 33}, {-77, 39}, {-81, 41}]]})
      %Geo.Point{coordinates: {-82.0, 36.0}, srid: 4326}

      iex> Geo.Turf.Measure.centroid(%Geo.LineString{coordinates: [{0, 0}, {4, 0}, {4, 4}]})
      %Geo.Point{coordinates: {2.6666666666666665, 1.3333333333333333}, srid: 4326}

      iex> Geo.Turf.Measure.centroid(%Geo.Point{coordinates: {1.0, 2.0}})
      %Geo.Point{coordinates: {1.0, 2.0}, srid: 4326}

  """
  def centroid(geometry) do
    assert_wgs84!(geometry)

    case centroid_coords(geometry) do
      [] ->
        :error

      coords ->
        len = length(coords)
        {sum_x, sum_y} = Enum.reduce(coords, {0, 0}, fn {x, y}, {sx, sy} -> {sx + x, sy + y} end)
        %Geo.Point{coordinates: {sum_x / len, sum_y / len}, srid: 4326}
    end
  end

  defp centroid_coords(%Geo.Point{coordinates: coord}), do: [coord]
  defp centroid_coords(%Geo.MultiPoint{coordinates: coords}), do: coords
  defp centroid_coords(%Geo.LineString{coordinates: coords}), do: coords
  defp centroid_coords(%Geo.MultiLineString{coordinates: lines}), do: Enum.concat(lines)

  defp centroid_coords(%Geo.Polygon{coordinates: rings}),
    do: Enum.flat_map(rings, &open_ring/1)

  defp centroid_coords(%Geo.MultiPolygon{coordinates: polys}),
    do: Enum.flat_map(polys, fn rings -> Enum.flat_map(rings, &open_ring/1) end)

  defp centroid_coords(%Geo.GeometryCollection{geometries: geoms}),
    do: Enum.flat_map(geoms, &centroid_coords/1)

  defp open_ring([]), do: []

  defp open_ring([first | _] = ring) do
    if List.last(ring) == first, do: Enum.drop(ring, -1), else: ring
  end

  @spec center(Geo.geometry()) :: Geo.Point.t() | :error
  @doc """
  Finds the center of a `Geo.geometry()` bounding box and returns a `Geo.Point`.
  Returns `:error` when the geometry contains no coordinates.

  ## Examples

      iex> Geo.Turf.Measure.center(%Geo.Polygon{coordinates: [{0,0}, {0,10}, {10,10}, {10,0}]})
      %Geo.Point{coordinates: {5, 5}, srid: 4326}

  """
  def center(geometry) when is_map(geometry) do
    assert_wgs84!(geometry)

    case bbox(geometry) do
      :error ->
        :error

      {min_x, min_y, max_x, max_y} ->
        center_from_bounds({min_x, min_y, max_x, max_y})
    end
  end

  defp center_from_bounds({min_x, min_y, max_x, max_y})
       when is_integer(min_x) and is_integer(min_y) and is_integer(max_x) and is_integer(max_y) do
    %Geo.Point{
      coordinates: {
        round((min_x + max_x) / 2),
        round((min_y + max_y) / 2)
      },
      srid: 4326
    }
  end

  defp center_from_bounds({min_x, min_y, max_x, max_y}) do
    %Geo.Point{
      coordinates: {
        (min_x + max_x) / 2,
        (min_y + max_y) / 2
      },
      srid: 4326
    }
  end

  @spec close_to(Geo.Point.t(), Geo.Point.t(), number(), Math.length_unit()) :: boolean()
  @doc """
  Verifies that two points are within a maximum raw geodesic distance of each
  other. The maximum is inclusive and defaults to 100 meters.

  ## Examples

      iex> %Geo.Point{coordinates: {-22.653375, 64.844254}}
      ...> |> Geo.Turf.Measure.close_to(%Geo.Point{coordinates: {-22.654042, 64.843656}})
      true

      iex> %Geo.Point{coordinates: {-22.653375, 64.844254}}
      ...> |> Geo.Turf.Measure.close_to(%Geo.Point{coordinates: {-23.803020, 64.730435}}, 100, :kilometers)
      true

  """
  def close_to(point_a, point_b, maximum \\ 100, units \\ :meters) do
    distance(point_a, point_b, units) <= maximum
  end

  @doc """
  Measures the raw geodesic distance from a Point to its nearest point on a
  LineString or MultiLineString.

  Uses the same segment traversal and `:units` option as
  `Geo.Turf.Classification.nearest_point_on_line/3`; units default to
  `:kilometers`. Returns `:error` when the line contains no coordinates.
  """
  @spec point_to_line_distance(
          Geo.Point.t(),
          Geo.LineString.t() | Geo.MultiLineString.t(),
          keyword()
        ) :: float() | :error
  def point_to_line_distance(point, line, opts \\ []) do
    case Classification.nearest_point_on_line(point, line, opts) do
      {:ok, _snapped_point, %{distance: distance}} -> distance
      :error -> :error
    end
  end

  @doc """
  Calculates the distance between two points in degrees, radians, miles, or kilometers.
  This uses the [Haversine formula](http://en.wikipedia.org/wiki/Haversine_formula) to account for global curvature.
  Returns the raw floating-point result; use `Geo.Turf.Math.rounded/2` when
  display rounding is needed.

  ## Examples

      iex> Geo.Turf.Measure.distance(
      ...>   %Geo.Point{coordinates: {-75.343, 39.984}},
      ...>   %Geo.Point{coordinates: {-75.534, 39.123}},
      ...>   :kilometers)
      97.12922118967835
  """
  @spec distance(Geo.Point.t(), Geo.Point.t(), Math.length_unit()) :: float()
  def distance(
        %Geo.Point{coordinates: from} = point_a,
        %Geo.Point{coordinates: to} = point_b,
        unit \\ :kilometers
      ) do
    assert_wgs84!(point_a)
    assert_wgs84!(point_b)

    raw_distance(from, to, unit)
  end

  defp raw_distance({x1, y1}, {x2, y2}, unit) do
    d_lat = Math.degrees_to_radians(y2 - y1)
    d_lon = Math.degrees_to_radians(x2 - x1)
    lat1 = Math.degrees_to_radians(y1)
    lat2 = Math.degrees_to_radians(y2)

    a =
      :math.pow(:math.sin(d_lat / 2), 2) +
        :math.pow(:math.sin(d_lon / 2), 2) * :math.cos(lat1) * :math.cos(lat2)

    Math.radians_to_length(2 * :math.atan2(:math.sqrt(a), :math.sqrt(1 - a)), unit)
  end

  @spec length_of(Geo.geometry(), Math.length_unit()) :: number()
  @doc """
  Takes a `t:Geo.geometry()` and measures its length in the specified units.
  `length_of/2` is the canonical name because it avoids ambiguity with
  `Kernel.length/1`.

  LineString paths and every independent MultiLineString member, polygon ring,
  MultiPolygon ring, and GeometryCollection child path contribute to the
  result. Separate paths are measured independently and are never joined.
  Point and MultiPoint geometries contribute no length.
  Empty geometries return `0`.

  ## Examples

      iex> %Geo.LineString{coordinates: [{-23.621,64.769},{-23.629,64.766},{-23.638,64.766}]}
      ...>   |> Geo.Turf.Measure.length_of()
      0.93
  """
  def length_of(feature, unit \\ :kilometers) do
    assert_wgs84!(feature)

    feature
    |> coordinate_paths()
    |> Enum.reduce(0, fn path, length -> walk_length(path, unit, length) end)
    |> Math.rounded(2)
  end

  defp coordinate_paths(%Geo.Point{}), do: []
  defp coordinate_paths(%Geo.MultiPoint{}), do: []
  defp coordinate_paths(%Geo.LineString{coordinates: coordinates}), do: [coordinates]
  defp coordinate_paths(%Geo.MultiLineString{coordinates: paths}), do: paths
  defp coordinate_paths(%Geo.Polygon{coordinates: rings}), do: rings

  defp coordinate_paths(%Geo.MultiPolygon{coordinates: polygons}),
    do: Enum.flat_map(polygons, & &1)

  defp coordinate_paths(%Geo.GeometryCollection{geometries: geometries}),
    do: Enum.flat_map(geometries, &coordinate_paths/1)

  @doc """
  Takes in an **origin** `%Geo.Point{}` and calculates the destination of a new `%Geo.Point{}` at a given distance and bearing away from the **origin** point.

  This uses the [Haversine formula](http://en.wikipedia.org/wiki/Haversine_formula) to account for global curvature.
  See the `turf.destination` [documentation](http://turfjs.org/docs/#destination) for more information.

  ## Parameters
  * `origin` - the origin point
  * `distance` - the distance from the origin point to the destination point
  * `bearing` - the angle from the origin point to the destination point
  * `opts` - a keyword list of options

  ## Options
  * `:units` - the unit of the distance, defaults to `:kilometers`

  ## Examples

      iex> %Geo.Point{coordinates: {-75.343, 39.984}}
      ...>   |> Geo.Turf.Measure.destination(100, 180, units: :kilometers)
      %Geo.Point{coordinates: {-75.343, 39.08467963627546}, srid: 4326}
  """
  @spec destination(
          origin :: Geo.Point.t(),
          distance :: number(),
          bearing :: number(),
          options :: [units()]
        ) :: Geo.Point.t()
  def destination(%Geo.Point{} = origin, distance, bearing, opts \\ []) do
    assert_wgs84!(origin)
    %Geo.Point{coordinates: {x, y}} = origin
    opts = Keyword.validate!(opts, units: :kilometers)
    units = opts[:units]

    lat1 = Math.degrees_to_radians(y)
    lon1 = Math.degrees_to_radians(x)

    angular_bearing = Math.degrees_to_radians(bearing)
    angular_distance = Math.length_to_radians(distance, units)

    lat2 =
      :math.asin(
        :math.sin(lat1) * :math.cos(angular_distance) +
          :math.cos(lat1) * :math.sin(angular_distance) * :math.cos(angular_bearing)
      )

    lon2 =
      lon1 +
        :math.atan2(
          :math.sin(angular_bearing) * :math.sin(angular_distance) * :math.cos(lat1),
          :math.cos(angular_distance) - :math.sin(lat1) * :math.sin(lat2)
        )

    %Geo.Point{
      coordinates: {
        Math.radians_to_degrees(lon2),
        Math.radians_to_degrees(lat2)
      },
      srid: 4326
    }
  end

  defp walk_length([from, to | next], unit, acc) do
    travel = raw_distance(from, to, unit)
    walk_length([to | next], unit, acc + travel)
  end

  defp walk_length([{_, _}], _unit, acc), do: acc
  defp walk_length([], _unit, acc), do: acc
end
