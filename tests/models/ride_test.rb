require "minitest/autorun"
require "sequel"
require "faker"

require_relative "../../models/ride"

class RideTest < Minitest::Test
  def setup
    @driver = Driver.create(
      name: Faker::Name.first_name,
      lastname: Faker::Name.last_name,
      email: Faker::Internet.email,
      phone: Faker::PhoneNumber.cell_phone_in_e164,
      latitude: Faker::Address.latitude.round(6),
      longitude: Faker::Address.longitude.round(6),
      available: true
    )
    @rider = Rider.create(
      name: Faker::Name.first_name,
      lastname: Faker::Name.last_name,
      email: Faker::Internet.email,
      phone: Faker::PhoneNumber.cell_phone_in_e164
    )
    @start_latitude = Faker::Address.latitude.round(6)
    @start_longitude = Faker::Address.longitude.round(6)
    @ride = Ride.create(
      rider_id: @rider.id,
      driver_id: @driver.id,
      start_latitude: @start_latitude,
      start_longitude: @start_longitude,
      status: "STARTED",
    )
  end

  def teardown
    DB[:rides].delete
    DB[:payment_methods].delete
    DB[:drivers].delete
    DB[:riders].delete
  end

  def test_create_ride
    assert_equal @ride.rider_id, @rider.id
    assert_equal @ride.driver_id, @driver.id
    assert_equal @ride.status, "STARTED"
    assert_equal @ride.start_latitude, @start_latitude
    assert_equal @ride.start_longitude, @start_longitude
  end

  def test_update_ride
    end_latitude = Faker::Address.latitude.round(6)
    end_longitude = Faker::Address.longitude.round(6)
    @ride.status = "COMPLETED"
    @ride.end_latitude = end_latitude
    @ride.end_longitude = end_longitude
    @ride.save
    db_ride = Ride[@ride.id]
    assert_equal db_ride.status, @ride.status
    assert_equal db_ride.end_latitude, end_latitude
    assert_equal db_ride.end_longitude, end_longitude
  end

end
