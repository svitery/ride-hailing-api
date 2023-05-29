require "json"
require "./models/rider"

# TODO Move this to a json file
data = [
  {
      "id": "1",
      "name": "John",
      "lastname": "Doe",
      "email": "john_doe@email.com",
      "phone": "+1000000001"
  },
  {
      "id": "2",
      "name": "Jane",
      "lastname": "Doe",
      "email": "jane_doe@email.com",
      "phone": "+57000000001"
  }
]

data.each do |rider|
  begin
    Rider.create(
      name: rider[:name],
      lastname: rider[:lastname],
      email: rider[:email],
      phone: rider[:phone]
    )
  rescue
    puts "Rider #{rider[:name]} already exists"
  end
end
