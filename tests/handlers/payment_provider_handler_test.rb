require "minitest/autorun"
require "webmock/minitest"
require "httparty"

require_relative "../../handlers/payment_provider_handler"

class PaymentProviderHandlerTest < Minitest::Test
  def setup
    @payment_provider_handler = PaymentProviderHandler.new
    @payment_provider_handler.instance_variable_set(:@base_url, "http://localhost:3000")
  end

  def teardown
    WebMock.allow_net_connect!
  end

  def test_get_acceptance_token
    response_body = {
      "data": {
        "presigned_acceptance": {
          "acceptance_token": "acceptance_token"
        }
      }
    }.to_json.to_s
    stub_request(:get, "http://localhost:3000/merchants/").to_return(body: response_body, status: 200)
    acceptance_token = @payment_provider_handler.get_acceptance_token
    assert_equal acceptance_token, "acceptance_token"
  end

  def test_get_acceptance_token_error
    response_body = {}.to_json.to_s
    stub_request(:get, "http://localhost:3000/merchants/").to_return(body: response_body, status: 500)
    assert_raises PaymentProviderException do
      @payment_provider_handler.get_acceptance_token
    end
  end

  def test_create_payment_method
    response_body = {
      "data": {
        "id": "payment_method_external_id"
      }
    }.to_json.to_s
    stub_request(:post, "http://localhost:3000/payment_sources").to_return(body: response_body, status: 201)
    payment_method_external_id = @payment_provider_handler.create_payment_method(
      "tokenized_card",
      "rider_email",
      "acceptance_token"
    )
    assert_equal payment_method_external_id, "payment_method_external_id"
  end

  def test_create_payment_method_error
    response_body = {}.to_json.to_s
    stub_request(:post, "http://localhost:3000/payment_sources").to_return(body: response_body, status: 422)
    assert_raises PaymentProviderException do
      @payment_provider_handler.create_payment_method(
        "tokenized_card",
        "rider_email",
        "acceptance_token"
      )
    end
  end

  def test_create_transaction
    response_body = {}.to_json.to_s
    stub_request(:post, "http://localhost:3000/transactions").to_return(body: response_body, status: 201)
    transaction_id = @payment_provider_handler.create_transaction(
      1000,
      "reference",
      "email",
      "payment_method_external_id",
      1
    )
    assert_equal transaction_id, true
  end

  def test_create_transaction_error
    response_body = {}.to_json.to_s
    stub_request(:post, "http://localhost:3000/transactions").to_return(body: response_body, status: 422)
    assert_raises PaymentProviderException do
      @payment_provider_handler.create_transaction(
        1000,
        "reference",
        "email",
        "payment_method_external_id",
        1
      )
    end
  end
end
