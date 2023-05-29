require "json"
require "./models/driver"

# TODO Move this to a json file
data = [
  {
    "id": "1",
    "name": "Dominic",
    "lastname": "Toretto",
    "email": "dominic_toretto@email.com",
    "phone": "+1000000000",
    "latitude": "40.7128",
    "longitude": "74.0060",
    "available": true
  },
  {
    "id": "2",
    "name": "Brian",
    "lastname": "O'Conner",
    "email": "brian_oconner@email.com",
    "phone": "+57000000000",
    "latitude": "46.7128",
    "longitude": "77.0060",
    "available": true
  }
]


data.each do |driver|
  begin
    Driver.create(
    name: driver[:name],
    lastname: driver[:lastname],
    email: driver[:email],
    phone: driver[:phone],
    latitude: driver[:latitude],
    longitude: driver[:longitude],
    available: driver[:available]
  )
  rescue
    puts "Driver #{driver[:name]} already exists"
  end
end

