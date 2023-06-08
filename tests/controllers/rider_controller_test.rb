require "minitest/autorun"
require "rack/test"
require "faker"

require_relative "../../ride_handling_app"
require_relative "../../services/rider_services"
require_relative "../../handlers/payment_provider_handler"

class RiderControllerTest < Minitest::Test
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
    @mock_rider_service = Minitest::Mock.new
    @mock_payment_provider_handler = Minitest::Mock.new
  end

  def teardown
    DB[:rides].delete
    DB[:payment_methods].delete
    DB[:riders].delete
    DB[:drivers].delete
  end

  def test_create_payment_method
    request_body = {
      "tokenized_card": "tokenized_card"
    }.to_json
    @mock_rider_service.expect(:create_payment_method, "") do |rider, tokenized_card|
      puts "Mocking RiderServices.create_payment_method"
      return PaymentMethod.create(
        rider_id: rider.id,
        payment_provider_id: "payment_source_id",
        tokenized_card: tokenized_card
      )
    end
    @mock_rider_service.expect(:to_json, "") do |data|
      puts "Mocking RiderServices.to_json"
      data.to_json
    end
    @mock_payment_provider_handler.expect(:create_payment_source, "") do |tokenized_card|
      puts "Mocking PaymentProviderHandler.create_payment_source"
      "payment_source_id"
    end

    RiderServices.stub(:create_payment_method, @mock_rider_service) do
      post "/riders/#{@rider.id}/payment-methods", request_body
      puts last_response.body
      assert_equal 201, last_response.status
    end
  end

  def test_create_payment_method_invalid_request
    request_body = {}
    post "/riders/#{@rider.id}/payment-methods", request_body.to_json
    assert_equal 400, last_response.status
  end

  def test_create_payment_method_rider_not_found
    request_body = {
      "tokenized_card": "tokenized_card"
    }.to_json
    Rider.stub(:[], nil) do
      post "/riders/1/payment-methods", request_body
      assert_equal 404, last_response.status
    end
  end

  def test_create_payment_method_service_error
    request_body = {
      "tokenized_card": "tokenized_card"
    }.to_json
    @mock_rider_service.expect(:create_payment_method, "") do |rider, tokenized_card|
      puts "Mocking RiderServices.create_payment_method"
      raise Standard
    end
    RiderServices.stub(:create_payment_method, @mock_rider_service) do
      post "/riders/1/payment-methods", request_body
      assert_equal 400, last_response.status
    end
  end
end
