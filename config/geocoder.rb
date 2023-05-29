require "geocoder"
Geocoder.configure(
  lookup: :nominatim,
  units: :km,
  timeout: 5
)
