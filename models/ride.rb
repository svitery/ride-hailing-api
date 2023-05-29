require "sequel"

class Ride < Sequel::Model
  plugin :validation_helpers
  plugin :json_serializer
  plugin :timestamps, update_on_create: true

  many_to_one :driver
  many_to_one :rider

  def validate
    super
    validates_presence [:driver_id, :rider_id, :status]
    # Since the rider is assigned in the ride creation, we don't need more statuses for now
    validates_includes ["STARTED", "COMPLETED"], :status
    validates_type Integer, :driver_id, message: "is not a valid integer"
    validates_type Integer, :rider_id, message: "is not a valid integer"
  end
end
