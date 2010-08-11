require 'sinatra'
require 'rasp'
require 'json'

class Raspapp

  before do
    content_type :json
    @rasp = Rasp.new
  end

  get '/' do
    "RASP iPhone API"
  end

  get '/menu' do
    @rasp.menu.to_json
  end
end
