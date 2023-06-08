require "minitest/autorun"
require "sequel"

require_relative "../../models/ride"

class RideTest < Minitest::Test
  def setup
    @driver = Driver.create(
      name: "Driver",
      lastname: "Lastname",
      email: "driver@email.com",
      phone: "+1234567890",
      latitude: 0,
      longitude: 0,
      available: true
    )
    @rider = Rider.create(
      name: "Ride",
      lastname: "Lastname",
      email: "rider@email.com",
      phone: "+1234567890"
    )
    @ride = Ride.create(
      rider_id: @rider.id,
      driver_id: @driver.id,
      start_latitude: 0,
      start_longitude: 0,
      status: "STARTED",
    )
  end

  def teardown
    DB[:rides].delete
    DB[:payment_methods].delete
    DB[:drivers].delete
    DB[:riders].delete
  end

  def test_create_driver
    assert_equal @ride.rider_id, @rider.id
    assert_equal @ride.driver_id, @driver.id
    assert_equal @ride.status, "STARTED"
  end

  def test_update_driver
    @ride.status = "COMPLETED"
    @ride.save
    db_ride = Ride[@ride.id]
    assert_equal db_ride.status, @ride.status
  end

end
