require "minitest/autorun"
require "sequel"

require_relative "../../services/rider_services"
require_relative "../../models/rider"

class RiderServicesTest < Minitest::Test
  def setup
    DB[:payment_methods].delete
    DB[:riders].delete

    @rider = Rider.create(
      name: "Ride",
      lastname: "Lastname",
      email: "name@email.com",
      phone: "+1234567890"
    )
    @tokenized_card = "tok_visa"
  end

  def test_create_payment_method
    mock_payment_provider_handler = Minitest::Mock.new
    mock_payment_provider_handler.expect(
      :get_acceptance_token,
      "acceptance_token",
    )
    mock_payment_provider_handler.expect(
      :create_payment_method,
      "payment_method_external_id",
      [@tokenized_card, @rider.email, "acceptance_token"]
    )
    PaymentProviderHandler.stub(:new, mock_payment_provider_handler) do
      payment_method = RiderServices.create_payment_method(@rider, @tokenized_card)
      assert_equal payment_method.rider_id, @rider.id
      assert_equal payment_method.payment_provider_id, "payment_method_external_id"
    end
  end


end
