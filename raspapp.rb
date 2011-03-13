require 'sinatra'
require 'rasp'
require 'json'
require 'haml'

class Raspapp

  set :haml, { :format => :html5 }

  before do
    @rasp = Rasp.new
  end

  get '/' do
    haml :index
  end

  get '/menu' do
    content_type :json
    @rasp.menu(params[:language]).to_json
  end
end
