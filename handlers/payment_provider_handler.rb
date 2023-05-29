require "httparty"

class PaymentProviderException < StandardError
end

class PaymentProviderHandler
  def initialize
    @base_url = ENV["PAYMENT_PROVIDER_BASE_URL"]
  end

  def get_acceptance_token
    url = "#{@base_url}/merchants/#{ENV["PAYMENT_PROVIDER_PUBLIC_KEY"]}"
    begin
      response = HTTParty.get(url)
      JSON.parse(response.body)["data"]["presigned_acceptance"]["acceptance_token"]
    rescue
      raise PaymentProviderException, "Error getting acceptance token"
    end
  end

  def create_payment_method(tokenized_card, user_email, acceptance_token)
    url = "#{@base_url}/payment_sources"
    headers = {
      "Authorization" => "Bearer #{ENV["PAYMENT_PROVIDER_PRIVATE_KEY"]}",
      "Content-Type" => "application/json"
    }
    body = {
      "type" => "CARD", #Since tokenize payment method are out of scope, we will always use CARD
      "token" => tokenized_card,
      "customer_email" => user_email,
      "acceptance_token" => acceptance_token
    }
    response = HTTParty.post(url, headers: headers, body: body.to_json)
    puts response.body
    puts response.code
    if response.code == 201
      data = JSON.parse(response.body)
      return data["data"]["id"]
    elsif response.code == 422
      raise PaymentProviderException, "Error creating payment method"
    end
  end

  def create_transaction(amount_in_cents, reference, email, payment_source_id, installments)
    url = "#{@base_url}/transactions"
    headers = {
      "Authorization" => "Bearer #{ENV["PAYMENT_PROVIDER_PRIVATE_KEY"]}",
      "Content-Type" => "application/json"
    }
    body = {
      "amount_in_cents" => amount_in_cents,
      "currency" => "COP",
      "customer_email" => email,
      "payment_method" => {
        "installments" => 1
      },
      "reference" => reference,
      "payment_source_id" => payment_source_id
    }
    response = HTTParty.post(url, headers: headers, body: body.to_json)
    puts response.body
    puts response.code
    if response.code == 201
      return true
    else
      raise PaymentProviderException, "Error creating transaction"
    end
  end
end
