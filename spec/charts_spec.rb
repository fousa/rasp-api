require File.dirname(__FILE__) + '/spec_helper'

describe 'The charts' do
  include Rack::Test::Methods

	%w(benelux alps westernswissalps).each do |country|
		it "should validate the links for #{country}" do
			validate_links_for country
		end
	end
end

def validate_links_for(country)
	rasp = Rasp.new country
	charts = rasp.charts
	puts "======> #{country}"
	charts.keys.each do |header|
		unless header == "config"
			charts[header].keys.each do |chart|
				puts "------> #{chart}"
				urls = charts[header][chart]["today"]
				urls.each do |url|
					puts "---------> #{url}"
					Net::HTTP.get_response(URI.parse(url)).class.should == Net::HTTPOK
				end
			end
		end
	end
end
