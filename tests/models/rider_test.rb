require "minitest/autorun"
require "sequel"
require "faker"

require_relative "../../models/rider"

class RiderTest < Minitest::Test
  def setup
    @name = Faker::Name.first_name
    @lastname = Faker::Name.last_name
    @email = Faker::Internet.email
    @phone = Faker::PhoneNumber.cell_phone_in_e164
    @rider = Rider.create(
      name: @name,
      lastname: @lastname,
      email: @email,
      phone: @phone
    )
  end

  def teardown
    DB[:rides].delete
    DB[:payment_methods].delete
    DB[:drivers].delete
    DB[:riders].delete
  end

  def test_create_rider
    assert_equal @rider.name, @name
    assert_equal @rider.lastname, @lastname
    assert_equal @rider.email, @email
    assert_equal @rider.phone, @phone
  end

  def test_update_rider
    @rider.name = Faker::Name.first_name
    @rider.lastname = Faker::Name.last_name
    @rider.email = Faker::Internet.email
    @rider.phone = Faker::PhoneNumber.cell_phone_in_e164
    @rider.save
    db_rider = Rider[@rider.id]
    assert_equal db_rider.name, @rider.name
    assert_equal db_rider.lastname, @rider.lastname
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
