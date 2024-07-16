defmodule FixtureParser do
  @moduledoc false
  def parse_geojson(data) when is_binary(data) do
    data
    |> Jason.decode!()
    |> decode_geojson
  end

  defp decode_geojson(%{"type" => "Feature", "geometry" => geometry}) do
    geometry |> Geo.JSON.decode!()
  end

  defp decode_geojson(%{"type" => "FeatureCollection", "features" => features}) do
    features |> Enum.map(fn feature -> decode_geojson(feature) end)
  end

  defp decode_geojson(%{} = json) do
    json |> Geo.JSON.decode!()
  end
end
