require "minitest/autorun"
require "sequel"
require "faker"

require_relative "../../models/driver"

class DriverTest < Minitest::Test
  def setup
    @name = Faker::Name.first_name
    @lastname = Faker::Name.last_name
    @email = Faker::Internet.email
    @phone = Faker::PhoneNumber.cell_phone_in_e164
    @latitude = Faker::Address.latitude.round(6)
    @longitude = Faker::Address.longitude.round(6)
    @driver = Driver.create(
      name: @name,
      lastname: @lastname,
      email: @email,
      phone: @phone,
      latitude: @latitude,
      longitude: @longitude,
      available: true
    )
  end

  def teardown
    DB[:rides].delete
    DB[:payment_methods].delete
    DB[:drivers].delete
    DB[:riders].delete
  end

  def test_create_driver
    assert_equal @driver.name, @name
    assert_equal @driver.lastname, @lastname
    assert_equal @driver.email,@email
    assert_equal @driver.phone, @phone
    assert_equal @driver.latitude, @latitude
    assert_equal @driver.longitude, @longitude
  end

  def test_update_driver
    @driver.name = Faker::Name.first_name
    @driver.lastname = Faker::Name.last_name
    @driver.email = Faker::Internet.email
    @driver.phone = Faker::PhoneNumber.cell_phone_in_e164
    @driver.latitude = Faker::Address.latitude.round(6)
    @driver.longitude = Faker::Address.longitude.round(6)
    @driver.save
    db_driver = Driver[@driver.id]
    assert_equal db_driver.name, @driver.name
    assert_equal db_driver.lastname, @driver.lastname
    assert_equal db_driver.email, @driver.email
    assert_equal db_driver.phone, @driver.phone
    assert_equal db_driver.latitude, @driver.latitude
    assert_equal db_driver.longitude, @driver.longitude
  end

end
