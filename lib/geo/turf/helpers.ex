defmodule Geo.Turf.Helpers do
  @moduledoc """
  A collection of helper utilities.
  Usually users will not have to refer to this directly but it is here
  if the need arises.
  """

  @min_bounds {+1.0e+10, +1.0e+10, -1.0e+10, -1.0e+10}


  @doc """
  Create a bounding box for a given `t:Geo.geometry/0`.

  ## Examples

      iex> Geo.Turf.Helpers.bbox(%Geo.Polygon{coordinates: [{1,1}, {1,3}, {3,3}, {3,1}]})
      {1,1,3,3}

      iex> Geo.Turf.Helpers.bbox([{1,1},{2,2},{3,3}])
      {1,1,3,3}

  """
  @spec bbox([{number(), number()}] | Geo.geometry()) :: {number(), number(), number(), number()}
  def bbox(geometries) when is_map(geometries) do
    flatten_coords(geometries)
      |> List.foldl(@min_bounds, &bbox_folder/2)
  end
  def bbox(geometries) when is_list(geometries) do
    List.foldl(geometries, @min_bounds, &bbox_folder/2)
  end
  defp bbox_folder({x,y}, {min_x, min_y, max_x, max_y}) do
    {
      (if (x < min_x), do: x, else: min_x),
      (if (y < min_y), do: y, else: min_y),
      (if (x > max_x), do: x, else: max_x),
      (if (y > max_y), do: y, else: max_y)
    }
  end

  @doc """
  Flatten a `t:Geo.geometry()` to a simple list of coordinates

  ## Examples

      iex> Geo.Turf.Helpers.flatten_coords(%Geo.GeometryCollection{geometries: [
      ...>  %Geo.Point{coordinates: {1,1}},
      ...>  %Geo.Point{coordinates: {2,2}}
      ...> ]})
      [{1,1}, {2,2}]

  """
  @spec flatten_coords(Geo.geometry()) :: [{number(), number()}]
  def flatten_coords(geometry), do: flatten_coords(geometry, [])
  defp flatten_coords(%Geo.Point{coordinates: coords}, acc), do: acc ++ [coords]
  defp flatten_coords(%Geo.MultiPoint{coordinates: coords}, acc), do: acc ++ List.flatten(coords)
  defp flatten_coords(%Geo.Polygon{coordinates: coords}, acc), do: acc ++ List.flatten(coords)
  defp flatten_coords(%Geo.LineString{coordinates: coords}, acc), do: acc ++ List.flatten(coords)
  defp flatten_coords(%Geo.MultiLineString{coordinates: coords}, acc),
    do: acc ++ List.flatten(coords)
  defp flatten_coords(%Geo.MultiPolygon{coordinates: coords}, acc),
    do: acc ++ List.flatten(coords)
  defp flatten_coords(%Geo.GeometryCollection{geometries: geom}, acc),
    do: acc ++ Enum.map(geom, &flatten_coords/1) |> List.flatten()


end
