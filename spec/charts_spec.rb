require File.dirname(__FILE__) + '/spec_helper'

describe 'The charts' do
  include Rack::Test::Methods

	%w(
		alps
		avenal13km
		avenal4km
		benelux
		bryon750m
		bryon3km
		germany
		southerncalifornia
		swsouthafrica
		westernswissalps
		baltic
		centralfrance
		slovakia
	).each do |country|
		it "should validate the links for #{country}" do
			validate_links_for country
		end
	end
end

def validate_links_for(country)
	rasp = Rasp.new country
	charts = rasp.charts
	puts "\n======> #{country}"
	charts.keys.each do |header|
		unless header == "config"
			charts[header].keys.each do |chart|
				puts "------> #{chart}"
				urls = charts[header][chart]["today"]
				if urls.first
					puts "---------> #{urls.first}"
					Net::HTTP.get_response(URI.parse(urls.first)).class.should == Net::HTTPOK
				end
			end
		end
	end
end
