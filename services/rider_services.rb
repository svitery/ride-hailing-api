require "./handlers/payment_provider_handler"

class RiderServicesError < StandardError; end

class RiderServices
  def self.create_payment_method(rider, tokenized_card)
    begin
      payment_provider_handler = PaymentProviderHandler.new
      acceptance_token = payment_provider_handler.get_acceptance_token
      payment_method_external_id = payment_provider_handler.create_payment_method(
        tokenized_card,
        rider.email,
        acceptance_token
      )
      payment_method = PaymentMethod.create(
        rider_id: rider.id,
        payment_provider_id: payment_method_external_id,
        created_at: Time.now
      )
    rescue PaymentProviderException => e
      raise RiderServicesError, "Error creating payment method in payment provider"
    rescue => e
      raise RiderServicesError, "Error creating payment method"
    end
  end
end
