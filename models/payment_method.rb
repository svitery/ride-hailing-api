require "sequel"

class PaymentMethod < Sequel::Model
  plugin :validation_helpers
  plugin :json_serializer
  many_to_one :rider
  def validate
    super
    validates_presence [:payment_provider_id, :rider_id, :created_at]
    validates_unique [:payment_provider_id]
  end
end
