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

  @spec bbox([{number(), number()}] | Geo.geometry()) ::
          {number(), number(), number(), number()}
  def bbox(geometries) when is_map(geometries) do
    flatten_coords(geometries)
    |> List.foldl(@min_bounds, &bbox_folder/2)
  end

  def bbox(geometries) when is_list(geometries) do
    List.foldl(geometries, @min_bounds, &bbox_folder/2)
  end

  defp bbox_folder({x, y}, {min_x, min_y, max_x, max_y}) do
    {
      if(x < min_x, do: x, else: min_x),
      if(y < min_y, do: y, else: min_y),
      if(x > max_x, do: x, else: max_x),
      if(y > max_y, do: y, else: max_y)
    }
  end

  @doc """
  Takes a bounding box tuple and returns it as a `%Geo.Polygon{}`.

  The ring winds: SW → SE → NE → NW → SW.

  ## Examples

      iex> Geo.Turf.Helpers.bbox_polygon({0, 0, 10, 10})
      %Geo.Polygon{coordinates: [[{0, 0}, {10, 0}, {10, 10}, {0, 10}, {0, 0}]]}

      iex> Geo.Turf.Helpers.bbox_polygon({-180, -90, 180, 90})
      %Geo.Polygon{coordinates: [[{-180, -90}, {180, -90}, {180, 90}, {-180, 90}, {-180, -90}]]}

  """
  @spec bbox_polygon({number(), number(), number(), number()}) :: Geo.Polygon.t()
  def bbox_polygon({west, south, east, north}) do
    %Geo.Polygon{
      coordinates: [[{west, south}, {east, south}, {east, north}, {west, north}, {west, south}]]
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
    do: (acc ++ Enum.map(geom, &flatten_coords/1)) |> List.flatten()

  @doc """
  Raises `ArgumentError` if the geometry's SRID is set to anything other than
  WGS84 (EPSG:4326) or `nil` (which is treated as WGS84). All GeoTurf
  calculations assume WGS84 coordinates.
  """
  @spec assert_wgs84!(term()) :: :ok
  def assert_wgs84!(%{srid: srid}) when srid not in [nil, 4326] do
    raise ArgumentError, "GeoTurf only supports WGS84 (EPSG:4326), got SRID #{srid}"
  end

  def assert_wgs84!(_), do: :ok
end
