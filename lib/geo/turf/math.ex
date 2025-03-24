defmodule Geo.Turf.Math do
  @moduledoc """
  All sorts of mathematical functions
  """

  @type si_length_uk :: :meters | :kilometers | :centimeters | :millimeters
  @type si_length_us :: :metres | :kilometres | :centimetres | :millimetres
  @type imperial_length :: :miles | :nauticalmiles | :inches | :yards | :feet
  @type length_unit :: si_length_uk | si_length_us | imperial_length

  @earth_radius 6_371_008.8
  @factors %{
    centimeters: @earth_radius * 100,
    centimetres: @earth_radius * 100,
    degrees: @earth_radius / 111_325,
    feet: @earth_radius * 3.28084,
    inches: @earth_radius * 39.370,
    kilometers: @earth_radius / 1000,
    kilometres: @earth_radius / 1000,
    meters: @earth_radius,
    metres: @earth_radius,
    miles: @earth_radius / 1609.344,
    millimeters: @earth_radius * 1000,
    millimetres: @earth_radius * 1000,
    nauticalmiles: @earth_radius / 1852,
    radians: 1,
    yards: @earth_radius / 1.0936
  }
  @units_factors %{
    centimeters: 100,
    centimetres: 100,
    degrees: 1 / 111_325,
    feet: 3.28084,
    inches: 39.370,
    kilometers: 1 / 1000,
    kilometres: 1 / 1000,
    meters: 1,
    metres: 1,
    miles: 1 / 1609.344,
    millimeters: 1000,
    millimetres: 1000,
    nauticalmiles: 1 / 1852,
    radians: 1 / @earth_radius,
    yards: 1 / 1.0936
  }
  @area_factors %{
    acres: 0.000247105,
    centimeters: 10_000,
    centimetres: 10_000,
    feet: 10.763910417,
    inches: 1550.003100006,
    kilometers: 0.000001,
    kilometres: 0.000001,
    meters: 1,
    metres: 1,
    miles: 3.86e-7,
    millimeters: 1_000_000,
    millimetres: 1_000_000,
    yards: 1.195990046
  }
  @tau :math.pi() * 2

  @doc false
  @spec factor(:atom) :: Number.t()
  def factor(factor), do: @factors[factor]

  @doc false
  @spec units_factors(:atom) :: Number.t()
  def units_factors(factor), do: @units_factors[factor]

  @doc false
  @spec area_factors(:atom) :: Number.t()
  def area_factors(factor), do: @area_factors[factor]

  @doc false
  @spec earth_radius() :: Number.t()

  def earth_radius(), do: @earth_radius

  @spec radians_to_length(number(), length_unit) :: number()
  def radians_to_length(radians, unit \\ :kilometers) when is_number(radians) do
    radians * @factors[unit]
  end

  @spec length_to_radians(number(), length_unit) :: float()
  def length_to_radians(length, unit \\ :kilometers) when is_number(length) do
    length / @factors[unit]
  end

  @spec length_to_degrees(number(), length_unit) :: float()
  def length_to_degrees(length, units \\ :kilometers) when is_number(length) do
    radians_to_degrees(length_to_radians(length, units))
  end

  @spec radians_to_degrees(number()) :: float()
  def radians_to_degrees(radians) when is_number(radians) do
    degrees = mod(radians, @tau)
    degrees * 180 / :math.pi()
  end

  @spec degrees_to_radians(number()) :: float()
  def degrees_to_radians(degrees) when is_number(degrees) do
    radians = mod(degrees, 360)
    radians * :math.pi() / 180
  end

  @spec bearing_to_azimuth(number()) :: number()
  def bearing_to_azimuth(bearing) when is_number(bearing) do
    angle = mod(bearing, 360)
    if angle < 0, do: angle + 360, else: angle
  end

  @doc """
  Round number to precision

  ## Example

      iex> Geo.Turf.Math.rounded(120.4321)
      120

      iex> Geo.Turf.Math.rounded(120.4321, 3)
      120.432

  """
  def rounded(number, precision \\ 0)
      when is_number(number) and is_integer(precision) and precision >= 0 do
    multiplier = :math.pow(10, precision)

    case precision do
      0 -> round(round(number * multiplier) / multiplier)
      _ -> round(number * multiplier) / multiplier
    end
  end

  @spec convert_length(number, length_unit, length_unit) :: number
  def convert_length(length, from \\ :kilometers, to \\ :kilometers)
      when is_number(length) and length >= 0 do
    radians_to_length(length_to_radians(length, from), to)
  end

  @spec convert_area(number, length_unit, length_unit) :: number
  def convert_area(area, from \\ :meters, to \\ :kilometers) when is_number(area) and area >= 0 do
    area / @area_factors[from] * @area_factors[to]
  end

  @doc """
  Calculates the modulo of a number (integer or float).

  Note that this function uses `floored division` whereas the builtin `rem`
  function uses `truncated division`. See `Decimal.rem/2` if you want a
  `truncated division` function for Decimals that will return the same value as
  the BIF `rem/2` but in Decimal form.

  See [Wikipedia](https://en.wikipedia.org/wiki/Modulo_operation) for an
  explanation of the difference.

  Taken from [cldr_utils](https://hex.pm/packages/cldr_utils) with thanks and gratitude.

  ## Examples

      iex> Geo.Turf.Math.mod(1234.0, 5)
      4.0

  """
  @spec mod(number(), number()) :: number()

  def mod(number, modulus) when number < 0, do: -mod(abs(number), modulus)

  def mod(number, modulus) when is_float(number) and is_number(modulus) do
    number - Float.floor(number / modulus) * modulus
  end

  def mod(number, modulus) when is_integer(number) and is_integer(modulus) do
    modulo =
      number
      |> Integer.floor_div(modulus)
      |> Kernel.*(modulus)

    number - modulo
  end

  def mod(number, modulus) when is_integer(number) and is_number(modulus) do
    modulo =
      number
      |> Kernel./(modulus)
      |> Float.floor()
      |> Kernel.*(modulus)

    number - modulo
  end
end
