require 'rubygems'
require 'sinatra'
require 'json'
require 'haml'
require './rasp.rb'
require './uk.rb'

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
    headers 'Access-Control-Allow-Origin' => '*'

    class_name = Rasp
    #class_name = Uk if params[:region] == "uk"
    rasp = class_name.new params[:region]
		
    halt 400, { :error => "Region incorrect or not supplied" }.to_json unless rasp.exists?

    rasp.charts.to_json
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
