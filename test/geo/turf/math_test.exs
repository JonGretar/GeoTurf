defmodule Geo.Turf.Math.Test do
  use ExUnit.Case
  alias Geo.Turf.Math, as: M
  doctest Geo.Turf.Math

  test "factors" do
    assert M.earth_radius == 6371008.8
    assert M.factor(:kilometers) ==  6371.0088
    assert M.units_factors(:kilometers) == 1.0e-3
    assert M.area_factors(:kilometers) == 1.0e-6
  end

  test "radiansToLength" do
    assert M.radians_to_length(1, :radians) == 1
    assert M.radians_to_length(1, :kilometers) == M.earth_radius / 1000
    assert M.radians_to_length(1, :miles) == M.earth_radius / 1609.344
  end

  test "lengthToRadians" do
    assert M.length_to_radians(1, :radians) == 1
    assert M.length_to_radians(M.earth_radius / 1000, :kilometers) == 1
    assert M.length_to_radians(M.earth_radius / 1609.344, :miles) == 1
  end

  test "lengthToDegrees" do
    assert M.length_to_degrees(1, :radians) == 57.29577951308232
    assert M.length_to_degrees(100, :kilometers) == 0.899320363724538
    assert M.length_to_degrees(10, :miles) == 0.1447315831437903
  end

  test "radiansToDegrees" do
    assert M.rounded(M.radians_to_degrees(:math.pi / 3), 6) == 60
    assert M.radians_to_degrees(3.5 * :math.pi) == 270
    assert M.radians_to_degrees(-(:math.pi)) == -180
  end

  test "degreesToRadians" do
    assert M.degrees_to_radians(60) == :math.pi / 3
    assert M.degrees_to_radians(270) == 1.5 * :math.pi
    assert M.degrees_to_radians(-180) == -(:math.pi)
  end

  test "bearingToAzimuth" do
    assert M.bearing_to_azimuth(40) == 40
    assert M.bearing_to_azimuth(-105) == 255
    assert M.bearing_to_azimuth(410) == 50
    assert M.bearing_to_azimuth(-200) == 160
    assert M.bearing_to_azimuth(-395) == 325
  end

  test "rounded" do
    assert M.rounded(125.123) == 125
    assert M.rounded(123.123, 1) == 123.1
    assert M.rounded(123.5) == 124
    # t.throws(() => rounded(34.5, 'precision'), 'invalid precision');
    # t.throws(() => rounded(34.5, -5), 'invalid precision');
  end

  test "convertLength" do
    assert M.convert_length(1000, :meters) == 1
    assert M.convert_length(1, :kilometers, :miles) == 0.621371192237334
    assert M.convert_length(1, :miles, :kilometers) == 1.609344
    assert M.convert_length(1, :nauticalmiles) == 1.852
    assert M.convert_length(1, :meters, :centimeters) == 100.00000000000001
  end

  test "convertArea" do
    assert M.convert_area(1000) == 0.001
    assert M.convert_area(1, :kilometres, :miles) == 0.386
    assert M.convert_area(1, :miles, :kilometers) == 2.5906735751295336
    assert M.convert_area(1, :meters, :centimetres) == 10000
    assert M.convert_area(100, :metres, :acres) == 0.0247105
    assert M.convert_area(100, :metres, :feet) == 1076.3910417
  end

  test "modulo" do
    assert M.mod(10, 1) == 0
    assert M.mod(10.0, 2.0) == 0.0
    assert M.mod(10, 3) == 2.0
    assert M.mod(10.0, 4) == 2.0
  end



end
