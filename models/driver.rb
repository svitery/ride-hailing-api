require "sequel"

class Driver < Sequel::Model
  plugin :validation_helpers
  def validate
    super
    validates_presence [:name, :lastname, :email, :phone, :latitude, :longitude, :available]
    validates_unique [:email, :phone]
    validates_format /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i, :email, message: "is not a valid email"
    validates_format /\A\+\d{8,15}\z/, :phone, message: "is not a valid phone number"
    validates_type Float, :latitude, message: "is not a valid latitude"
    validates_type Float, :longitude, message: "is not a valid longitude"
    validates_type TrueClass, :available, message: "is not a valid boolean"
  end
end
