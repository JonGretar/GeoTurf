defmodule Geo.Turf do
  @moduledoc """
  A spatial analysis tool for Elixir's [Geo](https://github.com/bryanjos/geo) library
  ported from [TurfJS](http://turfjs.org/).
  """

  @type coordinates :: {Number.t(), Number.t()}
  @type point :: Geo.Point.t() | coordinates()

end
