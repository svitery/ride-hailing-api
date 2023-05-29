# Controller to test if the app is running properly
class HomeController < Sinatra::Base
  get "/" do
    "App is running!"
  end

end
