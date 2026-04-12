defmodule Geo.Turf.Classification do
  @moduledoc """
  A collection of classification and boolean spatial functions.
  """

  @doc """
  Takes a Point and a Polygon (or MultiPolygon) and determines whether the
  Point lies inside the shape. Points on the boundary are considered inside
  unless `:ignore_boundary` is set to `true`.

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

  def point_in_polygon?(
        %Geo.Point{coordinates: {px, py}},
        %Geo.Polygon{coordinates: [outer | holes]},
        opts
      ) do
    ignore_boundary = Keyword.get(opts, :ignore_boundary, false)

    case ring_status({px, py}, outer) do
      :outside -> false
      :boundary -> not ignore_boundary
      :inside -> inside_with_holes({px, py}, holes, ignore_boundary)
    end
  end

  def point_in_polygon?(
        %Geo.Point{} = point,
        %Geo.MultiPolygon{coordinates: polys},
        opts
      ) do
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
    Enum.filter(points, &point_in_polygon?(&1, polygon))
  end

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
