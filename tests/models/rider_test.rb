require "minitest/autorun"
require "sequel"

require_relative "../../models/rider"

class RiderTest < Minitest::Test
  def setup
    @rider = Rider.create(
      name: "Ride",
      lastname: "Lastname",
      email: "name@email.com",
      phone: "+1234567890"
    )
  end

  def teardown
    DB[:rides].delete
    DB[:payment_methods].delete
    DB[:drivers].delete
    DB[:riders].delete
  end

  def test_create_rider
    assert_equal @rider.name, "Ride"
    assert_equal @rider.lastname, "Lastname"
    assert_equal @rider.email, "name@email.com"
    assert_equal @rider.phone, "+1234567890"
  end

  def test_update_rider
    @rider.name = "New Name"
    @rider.lastname = "New Lastname"
    @rider.email = "new@email.com"
    @rider.phone = "+0987654321"
    @rider.save
    db_rider = Rider[@rider.id]
    assert_equal db_rider.name, "New Name"
    assert_equal db_rider.lastname, "New Lastname"
    assert_equal db_rider.email, @rider.email
    assert_equal db_rider.phone, @rider.phone
  end

  def test_get_prefered_payment_method
    payment_method = PaymentMethod.create(
      rider_id: @rider.id,
      payment_provider_id: "1234567890",
      created_at: Time.now
    )
    assert_equal @rider.get_prefered_payment_method, payment_method
  end

  def test_get_prefered_payment_method_no_payment_methods
    assert_nil @rider.get_prefered_payment_method
  end

end
