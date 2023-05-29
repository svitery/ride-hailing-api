require "geocoder"

class RideServicesError < StandardError; end

class RideServices
  BASIC_CHARGE = 3500
  PRICE_PER_KM = 1000
  PRICE_PER_MINUTE = 200

  private
  def self.assign_driver(inital_latitude, inital_longitude)
    available_drivers = Driver.where(available: true)
    if available_drivers.count == 0
      return nil
    end
    closest_driver = available_drivers.min_by do |driver|
      distance = Geocoder::Calculations.distance_between(
        [driver.latitude, driver.longitude],
        [inital_latitude, inital_longitude]
      )
      distance
    end
  end

  private
  def self.calculate_ride_price(start_latitude, start_longitude, end_latitude, end_longitude, start_date, end_date)
    distance = Geocoder::Calculations.distance_between(
      [start_latitude, start_longitude],
      [end_latitude, end_longitude]
    )
    minutes = (end_date - start_date) / 60
    puts "Start date: #{start_date}"
    puts "End date: #{end_date}"
    puts end_date - start_date
    puts "Distance: #{distance}"
    puts "Minutes: #{minutes}"
    BASIC_CHARGE + (distance * PRICE_PER_KM) + (minutes * PRICE_PER_MINUTE)
  end

  def self.create_ride(rider, start_latitude, start_longitude)
    driver = assign_driver(start_latitude, start_longitude)
    if driver.nil?
      return nil
    end
    ride = Ride.create(
      driver_id: driver.id,
      rider_id: rider.id,
      start_latitude: start_latitude,
      start_longitude: start_longitude,
      status: "STARTED"
    )
  end

  def self.complete_ride(ride, end_latitude, end_longitude)
    ride.update(
      driver_id: ride.driver_id,
      end_latitude: end_latitude,
      end_longitude: end_longitude,
      completed_at: Time.now,
      status: "COMPLETED"
    )
    price_in_cents = calculate_ride_price(
      ride.start_latitude,
      ride.start_longitude,
      ride.end_latitude,
      ride.end_longitude,
      ride.created_at,
      ride.completed_at
    )*100
    price_in_cents = price_in_cents.to_i
    puts "Price in cents: #{price_in_cents}"
    rider = Rider[ride.rider_id]
    prefered_payment_method = rider.get_prefered_payment_method
    if prefered_payment_method.nil?
      raise RiderServicesError, "Rider does not have a payment method"
    end
    payment_provider_handler = PaymentProviderHandler.new
    begin
      payment_provider_handler.create_transaction(
        price_in_cents,
        Time.now.to_i.to_s,
        rider.email,
        rider.get_prefered_payment_method.payment_provider_id,
        1 #Since we are not implementing installments, we will always use 1
      )
      ride
    rescue PaymentProviderException => e
      # We don't want to raise an error here because the driver is doing the request and the
      # transactions are created for the rider. We should log this error and notify the
      # rider that the payment was not processed.
      puts "Error creating transaction in payment provider"
    rescue => e
      raise RiderServicesError, "Error creating transaction"
    end
  end
end
