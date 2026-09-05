defmodule Geo.Turf.Classification do
  @moduledoc """
  A collection of classification and boolean spatial functions.
  """
  alias Geo.Turf.Measure
  import Geo.Turf.Helpers, only: [assert_wgs84!: 1]

  @doc """
  Takes a Point and a Polygon (or MultiPolygon) and determines whether the
  Point lies inside the shape. Points on the boundary are considered inside
  unless `:ignore_boundary` is set to `true`. Empty polygons return `false`.

  ## Options

  * `:ignore_boundary` - when `true`, points on the polygon boundary return
    `false`. Defaults to `false`.

  ## Examples

      iex> poly = %Geo.Polygon{coordinates: [[{0, 0}, {0, 4}, {4, 4}, {4, 0}, {0, 0}]]}
      ...> Geo.Turf.Classification.point_in_polygon?(%Geo.Point{coordinates: {2, 2}}, poly)
      true

      iex> poly = %Geo.Polygon{coordinates: [[{0, 0}, {0, 4}, {4, 4}, {4, 0}, {0, 0}]]}
      ...> Geo.Turf.Classification.point_in_polygon?(%Geo.Point{coordinates: {5, 5}}, poly)
      false

  """
  @spec point_in_polygon?(
          Geo.Point.t(),
          Geo.Polygon.t() | Geo.MultiPolygon.t(),
          keyword()
        ) :: boolean()
  def point_in_polygon?(point, polygon, opts \\ [])

  def point_in_polygon?(%Geo.Point{} = point, %Geo.Polygon{coordinates: []} = polygon, _opts) do
    assert_wgs84!(point)
    assert_wgs84!(polygon)
    false
  end

  def point_in_polygon?(
        %Geo.Point{} = point,
        %Geo.Polygon{coordinates: [[] | _]} = polygon,
        _opts
      ) do
    assert_wgs84!(point)
    assert_wgs84!(polygon)
    false
  end

  def point_in_polygon?(
        %Geo.Point{} = point,
        %Geo.Polygon{coordinates: [outer | holes]} = polygon,
        opts
      ) do
    assert_wgs84!(point)
    assert_wgs84!(polygon)
    %Geo.Point{coordinates: {px, py}} = point
    ignore_boundary = Keyword.get(opts, :ignore_boundary, false)

    case ring_status({px, py}, outer) do
      :outside -> false
      :boundary -> not ignore_boundary
      :inside -> inside_with_holes({px, py}, holes, ignore_boundary)
    end
  end

  def point_in_polygon?(
        %Geo.Point{} = point,
        %Geo.MultiPolygon{} = mpoly,
        opts
      ) do
    assert_wgs84!(point)
    assert_wgs84!(mpoly)
    %Geo.MultiPolygon{coordinates: polys} = mpoly
    Enum.any?(polys, &point_in_polygon?(point, %Geo.Polygon{coordinates: &1}, opts))
  end

  @doc """
  Filters a list of Points to those falling inside the given Polygon or MultiPolygon.

  ## Examples

      iex> poly = %Geo.Polygon{coordinates: [[{0, 0}, {0, 4}, {4, 4}, {4, 0}, {0, 0}]]}
      ...> points = [%Geo.Point{coordinates: {2, 2}}, %Geo.Point{coordinates: {5, 5}}]
      ...> Geo.Turf.Classification.points_within_polygon(points, poly)
      [%Geo.Point{coordinates: {2, 2}}]

  """
  @spec points_within_polygon(
          [Geo.Point.t()],
          Geo.Polygon.t() | Geo.MultiPolygon.t()
        ) :: [Geo.Point.t()]
  def points_within_polygon(points, polygon) when is_list(points) do
    assert_wgs84!(points)
    assert_wgs84!(polygon)
    Enum.filter(points, &point_in_polygon?(&1, polygon))
  end

  @doc """
  Takes a reference Point and a list of Points and returns the point closest
  to the reference. Distance is calculated geodesically (Haversine).

  Returns `nil` if the list is empty.

  ## Options

  * `:units` - unit for distance calculation, defaults to `:kilometers`.
    See `t:Geo.Turf.Math.length_unit/0` for valid values.

  ## Examples

      iex> target = %Geo.Point{coordinates: {28.965797, 41.010086}}
      ...> points = [
      ...>   %Geo.Point{coordinates: {28.973865, 41.011122}},
      ...>   %Geo.Point{coordinates: {28.948459, 41.024204}},
      ...>   %Geo.Point{coordinates: {28.938674, 41.013324}}
      ...> ]
      ...> Geo.Turf.Classification.nearest_point(target, points)
      %Geo.Point{coordinates: {28.973865, 41.011122}}

      iex> Geo.Turf.Classification.nearest_point(%Geo.Point{coordinates: {0, 0}}, [])
      nil

  """
  @spec nearest_point(Geo.Point.t(), [Geo.Point.t()], keyword()) :: Geo.Point.t() | nil
  def nearest_point(target, points, opts \\ [])

  def nearest_point(target, points, opts) when is_list(points) do
    assert_wgs84!(target)
    assert_wgs84!(points)
    units = Keyword.get(opts, :units, :kilometers)

    case points do
      [] -> nil
      points -> Enum.min_by(points, &Measure.distance(target, &1, units))
    end
  end

  @type line_location :: %{
          distance: float(),
          location: float(),
          segment_index: non_neg_integer(),
          line_index: non_neg_integer()
        }

  @doc """
  Snaps a Point to the nearest point on a LineString or MultiLineString.

  Returns `{:ok, point, metadata}`. `point` has WGS84 SRID `4326`; `metadata`
  contains the raw point-to-line `:distance`, the raw along-line `:location`,
  and zero-based `:segment_index` and `:line_index`. A LineString has
  `line_index` `0`; for a MultiLineString it identifies the member containing
  the snapped segment. `:distance` and `:location` use `:units`, which defaults
  to `:kilometers`.

  Returns `:error` when the line contains no coordinates.
  """
  @spec nearest_point_on_line(
          Geo.Point.t(),
          Geo.LineString.t() | Geo.MultiLineString.t(),
          keyword()
        ) :: {:ok, Geo.Point.t(), line_location()} | :error
  def nearest_point_on_line(point, line, opts \\ [])

  def nearest_point_on_line(
        %Geo.Point{} = point,
        %Geo.LineString{coordinates: coordinates} = line,
        opts
      ) do
    nearest_point_on_paths(point, [{coordinates, 0}], line, opts)
  end

  def nearest_point_on_line(
        %Geo.Point{} = point,
        %Geo.MultiLineString{coordinates: paths} = line,
        opts
      ) do
    nearest_point_on_paths(point, Enum.with_index(paths), line, opts)
  end

  @doc """
  Tests whether a Point lies on a LineString or MultiLineString.

  Endpoints are included. `:tolerance` is an inclusive maximum geodesic
  distance from the line in the requested `:units`; it defaults to zero.
  `:units` defaults to `:kilometers`. Empty lines return `false`.

  ## Examples

      iex> line = %Geo.LineString{coordinates: [{0, 0}, {2, 0}]}
      ...> Geo.Turf.Classification.point_on_line?(
      ...>   %Geo.Point{coordinates: {1, 0}},
      ...>   line
      ...> )
      true

  """
  @spec point_on_line?(
          Geo.Point.t(),
          Geo.LineString.t() | Geo.MultiLineString.t(),
          keyword()
        ) :: boolean()
  def point_on_line?(point, line, opts \\ []) do
    opts = Keyword.validate!(opts, units: :kilometers, tolerance: 0)
    tolerance = opts[:tolerance]

    unless is_number(tolerance) and tolerance >= 0 do
      raise ArgumentError, "tolerance must be a non-negative number"
    end

    case nearest_point_on_line(point, line, units: opts[:units]) do
      {:ok, _snapped_point, %{distance: distance}} -> distance <= tolerance
      :error -> false
    end
  end

  defp nearest_point_on_paths(point, paths, line, opts) do
    assert_wgs84!(point)
    assert_wgs84!(line)
    opts = Keyword.validate!(opts, units: :kilometers)
    units = opts[:units]

    paths
    |> Enum.flat_map(fn {coordinates, line_index} ->
      snap_candidates(point, coordinates, line_index, units)
    end)
    |> case do
      [] ->
        :error

      candidates ->
        %{point: snapped_point, metadata: metadata} =
          Enum.min_by(candidates, & &1.metadata.distance)

        {:ok, snapped_point, metadata}
    end
  end

  defp snap_candidates(point, [coordinate], line_index, units) do
    [snap_candidate(point, coordinate, 0, 0, line_index, units)]
  end

  defp snap_candidates(_point, [], _line_index, _units), do: []

  defp snap_candidates(point, coordinates, line_index, units) do
    coordinates
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.with_index()
    |> Enum.flat_map(fn {[start, finish], segment_index} ->
      segment_length = Measure.distance(point_at(start), point_at(finish), units)
      location = path_location(coordinates, segment_index, units)

      [
        snap_candidate(point, start, location, segment_index, line_index, units),
        snap_candidate(point, finish, location + segment_length, segment_index, line_index, units)
        | interior_snap_candidate(
            point,
            start,
            finish,
            segment_length,
            location,
            segment_index,
            line_index,
            units
          )
      ]
    end)
  end

  defp snap_candidate(point, coordinate, location, segment_index, line_index, units) do
    snapped_point = point_at(coordinate)

    %{
      point: snapped_point,
      metadata: %{
        distance: Measure.distance(point, snapped_point, units),
        location: location,
        segment_index: segment_index,
        line_index: line_index
      }
    }
  end

  defp interior_snap_candidate(
         _point,
         _start,
         _finish,
         0,
         _location,
         _segment_index,
         _line_index,
         _units
       ),
       do: []

  defp interior_snap_candidate(
         point,
         start,
         finish,
         segment_length,
         location,
         segment_index,
         line_index,
         units
       ) do
    start_point = point_at(start)
    segment_bearing = Measure.bearing(start_point, point_at(finish))
    point_bearing = Measure.bearing(start_point, point)

    point_distance =
      point
      |> Measure.distance(start_point, units)
      |> Geo.Turf.Math.length_to_radians(units)

    along_segment =
      :math.atan2(
        :math.sin(point_distance) *
          :math.cos(degrees_to_radians(point_bearing - segment_bearing)),
        :math.cos(point_distance)
      )
      |> Geo.Turf.Math.radians_to_length(units)

    if along_segment > 0 and along_segment < segment_length do
      snapped_point =
        Measure.destination(start_point, along_segment, segment_bearing, units: units)

      cross_track_distance =
        point_distance
        |> :math.sin()
        |> Kernel.*(:math.sin(degrees_to_radians(point_bearing - segment_bearing)))
        |> clamp(-1, 1)
        |> :math.asin()
        |> abs()
        |> Geo.Turf.Math.radians_to_length(units)

      [
        %{
          point: snapped_point,
          metadata: %{
            distance: cross_track_distance,
            location: location + along_segment,
            segment_index: segment_index,
            line_index: line_index
          }
        }
      ]
    else
      []
    end
  end

  defp path_location(coordinates, segment_index, units) do
    coordinates
    |> Enum.take(segment_index + 1)
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.reduce(0, fn [start, finish], location ->
      location + Measure.distance(point_at(start), point_at(finish), units)
    end)
  end

  defp point_at(coordinates), do: %Geo.Point{coordinates: coordinates, srid: 4326}

  defp clamp(value, minimum, maximum), do: value |> max(minimum) |> min(maximum)

  defp degrees_to_radians(degrees), do: degrees * :math.pi() / 180

  # Returns :outside, :boundary, or :inside for a point against a single ring.
  # Handles both open and closed rings (where last point equals first).
  defp ring_status({px, py}, ring) do
    ring =
      if length(ring) > 1 and List.last(ring) == hd(ring),
        do: Enum.drop(ring, -1),
        else: ring

    len = length(ring)
    j_indices = [len - 1 | Enum.to_list(0..(len - 2))]

    result =
      Enum.zip(0..(len - 1), j_indices)
      |> Enum.reduce_while({false, false}, fn {i, j}, {inside, _} ->
        {xi, yi} = Enum.at(ring, i)
        {xj, yj} = Enum.at(ring, j)

        if on_segment?({px, py}, {xj, yj}, {xi, yi}) do
          {:halt, {inside, true}}
        else
          cross = yi > py != yj > py and px < (xj - xi) * (py - yi) / (yj - yi) + xi
          {:cont, {if(cross, do: not inside, else: inside), false}}
        end
      end)

    case result do
      {_, true} -> :boundary
      {true, false} -> :inside
      {false, false} -> :outside
    end
  end

  # Point is inside the outer ring: check holes.
  # Hole :inside → outside polygon. Hole :boundary → same treatment as outer boundary.
  defp inside_with_holes({px, py}, holes, ignore_boundary) do
    Enum.reduce_while(holes, true, fn hole, _acc ->
      case ring_status({px, py}, hole) do
        :outside -> {:cont, true}
        :inside -> {:halt, false}
        :boundary -> {:halt, not ignore_boundary}
      end
    end)
  end

  # Checks if point pt lies on the segment from j to i using dot product.
  defp on_segment?({px, py}, {xj, yj}, {xi, yi}) do
    ab_x = xi - xj
    ab_y = yi - yj
    ap_x = px - xj
    ap_y = py - yj
    cross = ab_x * ap_y - ab_y * ap_x

    if cross != 0 do
      false
    else
      dot_ab = ab_x * ab_x + ab_y * ab_y
      dot_ap = ab_x * ap_x + ab_y * ap_y
      dot_ap >= 0 and dot_ap <= dot_ab
    end
  end
end
