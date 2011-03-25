require File.dirname(__FILE__) + '/spec_helper'

class ConnectionRequest < Sequel::Model
end

describe 'The RASP API' do
  include Rack::Test::Methods

  def app
		@app ||= App
  end

  it "should render a splash page" do
    get '/'

    last_response.should be_ok
    last_response.body.should match '<h1>RASP iPhone API</h1>'
  end

	it "should present the json" do
		get '/menu'

		correct_array = Rack::Test::UploadedFile.new(File.dirname(__FILE__) + '/fixtures/result.json', 'text/json').read
		correct_json  = JSON.parse(correct_array)

		last_response.should be_ok

		parsed_json = JSON.parse(last_response.body)
		parsed_json.count       == 6
		parsed_json[0][1].count == 8
		parsed_json[1][1].count == 6
		parsed_json[2][1].count == 5
		parsed_json[3][1].count == 3
		parsed_json[4][1].count == 15
		parsed_json[5][1].count == 1
	end

	it "should count the requests" do
		old_count = ConnectionRequest.count
		get '/'
		ConnectionRequest.count.should == old_count + 1

		get '/menu'
		get '/menu'
		ConnectionRequest.count.should == old_count + 3
	end
end

