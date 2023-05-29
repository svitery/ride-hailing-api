require "./schemas/ride_schemas"
require "./services/ride_services"

class RideController < Sinatra::Base
  post "/" do
    body = JSON.parse(request.body.read)
    result = CreateRideSchema.new.call(body)
    halt 400, result.errors.to_json unless result.success?
    start_latitude = body["start_latitude"]
    start_longitude = body["start_longitude"]
    rider = Rider[body["rider_id"]]
    halt 404, { error: "Rider not found" }.to_json unless rider
    ride = RideServices.create_ride(rider, start_latitude, start_longitude)
    status 201
    ride.to_json
  end

  patch "/:id/complete" do
    ride = Ride[:id]
    halt 404, { error: "Ride not found" }.to_json unless ride
    body = JSON.parse(request.body.read)
    result = CompleteRideSchema.new.call(body)
    halt 400, result.errors.to_h.to_json unless result.success?
    end_longitude = body["end_longitude"]
    end_latitude = body["end_latitude"]
    begin
      ride = RideServices.complete_ride(ride, end_latitude, end_longitude)
    rescue RideServicesError => e
      halt 400, { error: e.message }.to_json
    end
    ride.to_json
  end
end
