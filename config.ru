require "sinatra/base"
require "./ride_handling_app"

Dir.glob("./{config,controllers,models}/*.rb").sort.each { |file| require file }

map("/") { run HomeController }
map("/riders") { run RiderController }
map("/rides") { run RideController }
