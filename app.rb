require 'sinatra'
require 'json'
require 'haml'
require 'rasp'

class App < Sinatra::Base
  set :haml, { :format => :html5 }
	set :root, File.dirname(__FILE__)

  get '/' do
    haml :index
  end

  get '/countries/:country/charts' do
    content_type :json

		rasp = Rasp.new params[:country]
		
		halt 400, { :error => "Country incorrect or not supplied" }.to_json unless rasp.exists?

    rasp.charts.to_json
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
