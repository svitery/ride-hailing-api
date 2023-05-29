require "sequel"

class Rider < Sequel::Model
  plugin :validation_helpers
  def validate
    super
    validates_presence [:name, :lastname, :email, :phone]
    validates_unique [:email, :phone]
    validates_format /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i, :email, message: "is not a valid email"
    validates_format /\A\+\d{8,15}\z/, :phone, message: "is not a valid phone number"
  end

  def get_prefered_payment_method
    begin
      puts "Rider: #{self.id}"
      payment_methods_dataset = PaymentMethod.where(rider_id: self.id).order(:created_at)
      payment_methods_dataset.first
    rescue
      nil
    end
  end
end
