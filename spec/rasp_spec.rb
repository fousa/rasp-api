require_relative 'spec_helper'

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
end

