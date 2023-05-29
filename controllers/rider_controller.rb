require "./integrations/payment_provider"

class RiderController < Sinatra::Base
  post "/:id/payment-methods" do
    rider = Rider[params[:id]]
    halt 404, { error: "Rider not found" }.to_json unless rider
    begin
      body = JSON.parse(request.body.read)
      acceptance_token = PaymentProviderHandler.new.get_acceptance_token
      payment_method_external_id = PaymentProviderHandler.new.create_payment_method(
        body["tokenized_card"],
        rider.email,
        acceptance_token
      )
      payment_method = PaymentMethod.create(
        rider_id: rider.id,
        payment_provider_id: payment_method_external_id
      )
      status 201
      payment_method.to_json
    rescue PaymentProviderException => e
      halt 400, { error: e.message }.to_json
    end
  end
end
