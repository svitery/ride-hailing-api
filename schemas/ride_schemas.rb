require "dry-validation"

class CreateRideSchema < Dry::Validation::Contract
  params do
    required(:rider_id).filled(:integer)
    # We assume that the ride can end anywhere, so we don't validate the end location
    required(:start_latitude).filled(:float)
    required(:start_longitude).filled(:float)
  end
end

class CompleteRideSchema < Dry::Validation::Contract
  params do
    required(:driver_id).filled(:integer)
    required(:end_latitude).filled(:float)
    required(:end_longitude).filled(:float)
  end
end
