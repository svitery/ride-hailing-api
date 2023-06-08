require "minitest/autorun"
require "sequel"
require "faker"

require_relative "../../models/payment_method"

class PaymentMethodTest < Minitest::Test
  def setup
    @rider = Rider.create(
      name: Faker::Name.first_name,
      lastname: Faker::Name.last_name,
      email: Faker::Internet.email,
      phone: Faker::PhoneNumber.cell_phone_in_e164
    )
    @payment_provider_id = Faker::Number.number(digits: 10).to_s
    @driver = PaymentMethod.create(
      rider_id: @rider.id,
      payment_provider_id: @payment_provider_id,
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
    assert_equal @driver.payment_provider_id, @payment_provider_id
  end

  def test_update_payment_method
    rider = Rider.create(
      name: Faker::Name.first_name,
      lastname: Faker::Name.last_name,
      email: Faker::Internet.email,
      phone: Faker::PhoneNumber.cell_phone_in_e164
    )
    payment_provider_id = Faker::Number.number(digits: 10).to_s
    @driver.rider_id = rider.id
    @driver.payment_provider_id = payment_provider_id
    @driver.save
    db_driver = PaymentMethod[@driver.id]
    assert_equal db_driver.rider_id, rider.id
    assert_equal db_driver.payment_provider_id, payment_provider_id
  end

end
