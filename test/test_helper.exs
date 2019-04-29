ExUnit.start()
Fixate.start()

Fixate.add_parser("geojson", &FixtureParser.parse_geojson/1)
