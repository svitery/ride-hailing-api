require "minitest/autorun"
require "sequel"

require_relative "../../models/payment_method"

class PaymentMethodTest < Minitest::Test
  def setup
    @rider = Rider.create(
      name: "Ride",
      lastname: "Lastname",
      email: "name@email.com",
      phone: "+1234567890"
    )
    @driver = PaymentMethod.create(
      rider_id: @rider.id,
      payment_provider_id: "1234567890",
      created_at: Time.now
    )
  end

  def teardown
    DB[:rides].delete
    DB[:payment_methods].delete
    DB[:drivers].delete
    DB[:riders].delete
  end

  def test_create_payment_method
    assert_equal @driver.rider_id, @rider.id
    assert_equal @driver.payment_provider_id, "1234567890"
  end

  def test_update_payment_method
    rider = Rider.create(
      name: "Ride",
      lastname: "Lastname",
      email: "lastname@email.com",
      phone: "+1234567899"
    )
    @driver.rider_id = rider.id
    @driver.payment_provider_id = "0987654321"
    @driver.save
    db_driver = PaymentMethod[@driver.id]
    assert_equal db_driver.rider_id, rider.id
    assert_equal db_driver.payment_provider_id, "0987654321"
  end

end
