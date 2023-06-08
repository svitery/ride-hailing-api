require "minitest/autorun"
require "rack/test"
require "faker"

require_relative "../../ride_handling_app"
require_relative "../../services/ride_services"
require_relative "../../handlers/payment_provider_handler"

class RideControllerTest < Minitest::Test
  include Rack::Test::Methods
  def app
    Rack::Builder.parse_file('config.ru').first
  end

  def setup
    @rider = Rider.create(
      name: Faker::Name.first_name,
      lastname: Faker::Name.last_name,
      email: Faker::Internet.email,
      phone: Faker::PhoneNumber.cell_phone_in_e164
    )
    @driver = Driver.create(
      name: Faker::Name.first_name,
      lastname: Faker::Name.last_name,
      email: Faker::Internet.email,
      phone: Faker::PhoneNumber.cell_phone_in_e164,
      latitude: 0,
      longitude: 0,
      available: true
    )
    @mock_rider_service = Minitest::Mock.new
  end

  def teardown
    DB[:rides].delete
    DB[:payment_methods].delete
    DB[:riders].delete
    DB[:drivers].delete
  end

  def test_post_ride
    request_body = {
      "start_latitude": 0.1,
      "start_longitude": 0.1,
      "rider_id": @rider.id,
    }.to_json
    @mock_rider_service.expect(:create_ride, "") do |rider, latitude, longitude|
      puts "Mocking RiderServices.create_ride"
      Ride.create(
        rider_id: @driver.id,
        driver_id: @driver.id,
        start_latitude: latitude,
        start_longitude: longitude
      )
    end
    @mock_rider_service.expect(:to_json, "") do |data|
      puts "Mocking RiderServices.to_json"
      data.to_json
    end

    RideServices.stub(:create_ride, @mock_rider_service) do
      post "/rides/", request_body
      puts last_response.body
      assert_equal 201, last_response.status
    end
  end

  def test_complete_ride
    ride = Ride.create(
      rider_id: @rider.id,
      driver_id: @driver.id,
      start_latitude: 0,
      start_longitude: 0,
      status: "STARTED"
    )
    end_latitude = 0.1
    end_longitude = 0.1
    request_body = {
      "end_latitude": end_latitude,
      "end_longitude": end_longitude,
      "driver_id": @driver.id
    }.to_json
    @mock_rider_service.expect(:complete_ride, "") do |driver, latitude, longitude|
      return ride.update(
        end_latitude: latitude,
        end_longitude: longitude,
        status: "COMPLETED"
      )
    end
    @mock_rider_service.expect(:to_json, "") do |data|
      puts "Mocking RiderServices.to_json"
      data.to_json
    end
    RideServices.stub(:complete_ride, @mock_rider_service) do
      patch "/rides/#{ride.id}/complete", request_body
      puts last_response.body
      assert_equal 200, last_response.status
    end

  end

end
