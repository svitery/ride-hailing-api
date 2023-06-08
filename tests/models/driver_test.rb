require "minitest/autorun"
require "sequel"

require_relative "../../models/driver"

class DriverTest < Minitest::Test
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
  end

  def teardown
    DB[:rides].delete
    DB[:payment_methods].delete
    DB[:drivers].delete
    DB[:riders].delete
  end

  def test_create_driver
    assert_equal @driver.name, "Driver"
    assert_equal @driver.lastname, "Lastname"
    assert_equal @driver.email, "driver@email.com"
    assert_equal @driver.phone, "+1234567890"
    assert_equal @driver.latitude, 0
    assert_equal @driver.longitude, 0
  end

  def test_update_driver
    @driver.name = "New Name"
    @driver.lastname = "New Lastname"
    @driver.email = "new_email@email.com"
    @driver.phone = "+0987654321"
    @driver.latitude = 1
    @driver.longitude = 1
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
