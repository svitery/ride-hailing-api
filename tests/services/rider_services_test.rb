require "minitest/autorun"
require "sequel"
require "faker"

require_relative "../../handlers/payment_provider_handler"
require_relative "../../services/rider_services"
require_relative "../../models/rider"

class RiderServicesTest < Minitest::Test
  def setup
    DB[:payment_methods].delete
    DB[:riders].delete

    @rider = Rider.create(
      name: Faker::Name.first_name,
      lastname: Faker::Name.last_name,
      email: Faker::Internet.email,
      phone: Faker::PhoneNumber.cell_phone_in_e164
    )
    @tokenized_card = "tok_visa"
    @mock_payment_provider_handler = Minitest::Mock.new
  end

  def test_create_payment_method
    @mock_payment_provider_handler.expect(
      :get_acceptance_token,
      "acceptance_token",
    )
    @mock_payment_provider_handler.expect(
      :create_payment_method,
      "payment_method_external_id",
      [@tokenized_card, @rider.email, "acceptance_token"]
    )
    PaymentProviderHandler.stub(:new, @mock_payment_provider_handler) do
      payment_method = RiderServices.create_payment_method(@rider, @tokenized_card)
      assert_equal payment_method.rider_id, @rider.id
      assert_equal payment_method.payment_provider_id, "payment_method_external_id"
    end
  end

  def test_create_payment_method_payment_provider_exception
    @mock_payment_provider_handler.expect(
      :get_acceptance_token, -> { raise PaymentProviderException }
    )
    PaymentProviderHandler.stub(:new, @mock_payment_provider_handler) do
      begin
        RiderServices.create_payment_method(@rider, @tokenized_card)
        fail "Should have raised an exception"
      rescue RiderServicesError => e

      end
    end
  end

end
