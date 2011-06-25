require 'rubygems'
require 'sinatra'
require 'json'
require 'haml'
require 'rasp'
require 'mongoid'
require 'stat'

configure :production do
	Mongoid.load!("config/mongoid.yml")
end

configure :development do
	Mongoid.configure do |config|
    name = "demo"
    host = "localhost"
    config.master = Mongo::Connection.new.db(name)
    config.slaves = [
      Mongo::Connection.new(host, 27017, :slave_ok => true).db(name)
    ]
    config.persist_in_safe_mode = false
  end
end


class App < Sinatra::Base
  set :haml, { :format => :html5 }
	set :root, File.dirname(__FILE__)

  get '/' do
    haml :index
  end

  get '/regions' do
    haml :regions
  end

  get '/regions/:region' do
    content_type :json, 'charset' => 'utf-8'

		stat = Stat.find_or_create_by( :region => params[:region])
		stat.update_attribute :total_calls, (stat.total_calls || 0) + 1

		rasp = Rasp.new params[:region]
		
		halt 400, { :error => "Region incorrect or not supplied" }.to_json unless rasp.exists?

    rasp.charts.to_json
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
