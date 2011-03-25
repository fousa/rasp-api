require 'benelux'
require 'sinatra'
require 'sinatra/sequel'
require 'json'
require 'haml'
require 'rasp'

migration "create connection_requests table" do
  database.create_table :connection_requests do
    primary_key :id
    text        :name,       :allow_null => false
    timestamp   :created_at, :allow_null => false
  end
end

class ConnectionRequest < Sequel::Model
end

class App < Sinatra::Base
  set :haml, { :format => :html5 }
	set :root, File.dirname(__FILE__)

  get '/' do
    ConnectionRequest.create(:name => "root", :created_at => Time.now)

    haml :index
  end

  get '/menu' do
    content_type :json

    ConnectionRequest.create(:name => "menu", :created_at => Time.now)

    @rasp = Rasp.new params[:language], params[:country]
    @rasp.charts.to_json
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
