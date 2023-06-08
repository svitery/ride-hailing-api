require "minitest/autorun"
require "sequel"

require_relative "../../services/ride_services"
require_relative "../../models/rider"
require_relative "../../models/driver"
require_relative "../../handlers/payment_provider_handler"

class RideServicesTest < Minitest::Test
  def setup
    DB[:rides].delete
    DB[:payment_methods].delete
    DB[:riders].delete
    DB[:drivers].delete

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
    @latitude = 0.1
    @longitude = 0.1
    @mock_payment_provider_handler = Minitest::Mock.new
  end

  def teardown
    DB[:rides].delete
    DB[:payment_methods].delete
    DB[:riders].delete
    DB[:drivers].delete
  end

  def test_create_ride
    ride = RideServices.create_ride(@rider, @latitude, @longitude)
    assert_equal ride.rider_id, @rider.id
    assert_equal ride.driver_id, @driver.id
  end

  def test_create_ride_unavailable_drivers
    Driver.dataset.delete
    ride = RideServices.create_ride(@rider, @latitude, @longitude)
    assert_nil ride
  end

  def test_complete_ride
    end_latitude = 0.2
    end_longitude = 0.2
    PaymentMethod.create(
      rider_id: @rider.id,
      payment_provider_id: "payment_source_id",
      created_at: Time.now,
    )
    @mock_payment_provider_handler.expect(:create_transaction, true) do |amount_in_cents, reference, email, payment_source_id, installments|
      true
    end
    ride = Ride.create(
      rider_id: @rider.id,
      driver_id: @driver.id,
      start_latitude: @latitude,
      start_longitude: @longitude,
      status: "STARTED",
    )
    PaymentProviderHandler.stub(:new, @mock_payment_provider_handler) do
      ride = RideServices.complete_ride(ride, end_latitude, end_longitude)
      assert_equal ride.status, "COMPLETED"
      assert_equal ride.end_latitude, end_latitude
      assert_equal ride.end_longitude, end_longitude
    end

  end

  def test_complete_ride_no_payment_method
    end_latitude = 0.2
    end_longitude = 0.2
    @mock_payment_provider_handler.expect(:create_transaction, true) do |amount_in_cents, reference, email, payment_source_id, installments|
      true
    end
    ride = Ride.create(
      rider_id: @rider.id,
      driver_id: @driver.id,
      start_latitude: @latitude,
      start_longitude: @longitude,
      status: "STARTED",
    )
    PaymentProviderHandler.stub(:new, @mock_payment_provider_handler) do
      begin
        ride = RideServices.complete_ride(ride, end_latitude, end_longitude)
        fail "Should have raised RiderServicesError"
      rescue RiderServicesError => e
        assert_equal e.message, "Rider does not have a payment method"
      end
    end
  end

  def test_complete_ride_payment_provider_error
    end_latitude = 0.2
    end_longitude = 0.2
    PaymentMethod.create(
      rider_id: @rider.id,
      payment_provider_id: "payment_source_id",
      created_at: Time.now,
    )
    @mock_payment_provider_handler.expect(:create_transaction, true) do |amount_in_cents, reference, email, payment_source_id, installments|
      raise PaymentProviderException.new("Payment provider error")
    end
    ride = Ride.create(
      rider_id: @rider.id,
      driver_id: @driver.id,
      start_latitude: @latitude,
      start_longitude: @longitude,
      status: "STARTED",
    )
    PaymentProviderHandler.stub(:new, @mock_payment_provider_handler) do
      ride = RideServices.complete_ride(ride, end_latitude, end_longitude)
      assert_nil ride
    end
  end

  def test_complete_ride_standard_error
    end_latitude = 0.2
    end_longitude = 0.2
    PaymentMethod.create(
      rider_id: @rider.id,
      payment_provider_id: "payment_source_id",
      created_at: Time.now,
    )
    @mock_payment_provider_handler.expect(:create_transaction, true) do |amount_in_cents, reference, email, payment_source_id, installments|
      raise StandardError.new("Standard error")
    end
    ride = Ride.create(
      rider_id: @rider.id,
      driver_id: @driver.id,
      start_latitude: @latitude,
      start_longitude: @longitude,
      status: "STARTED",
    )
    PaymentProviderHandler.stub(:new, @mock_payment_provider_handler) do
      begin
        ride = RideServices.complete_ride(ride, end_latitude, end_longitude)
        fail "Should have raised RiderServicesError"
      rescue RiderServicesError => e
      end
    end
  end

end
