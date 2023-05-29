require "minitest/autorun"
require "sequel"

require_relative "../../services/ride_services"
require_relative "../../models/rider"
require_relative "../../models/driver"

class RideServicesTest < Minitest::Test
  def setup
    DB[:rides].delete
    DB[:payment_methods].delete
    DB[:riders].delete
    DB[:drivers].delete

    @rider = Rider.create(
      name: "Ride",
      lastname: "Lastname",
      email: "name@email.com",
      phone: "+1234567890"
    )
    @driver = Driver.create(
      name: "Driver",
      lastname: "Lastname",
      email: "driver@email.com",
      phone: "+1234567890",
      latitude: 0,
      longitude: 0,
      available: true
    )
    puts "Driver: #{@driver.errors}"
    @latitude = 0.1
    @longitude = 0.1
  end

  def test_create_ride
    ride = RideServices.create_ride(@rider, @latitude, @longitude)
    assert_equal ride.rider_id, @rider.id
    assert_equal ride.driver_id, @driver.id

  end


end
