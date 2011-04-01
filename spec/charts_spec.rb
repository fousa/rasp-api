require File.dirname(__FILE__) + '/spec_helper'

describe 'The charts' do
  include Rack::Test::Methods

  it "should have valid links" do
		["benelux", "westernswissalps"].each do |country|
			rasp = Rasp.new country
			charts = rasp.charts
			puts "=== COUNTRY: #{country}"
			charts.keys.each do |header|
				puts "====== HEADER: #{header}"
				unless header == "config"
					charts[header].keys.each do |chart|
						puts "========= CHART: #{chart}"
						urls = charts[header][chart]["today"]
						urls.each do |url|
							puts "=============== URL: #{url}"
							Net::HTTP.get_response(URI.parse(url)).class.should == Net::HTTPOK
						end
					end
				end
			end
		end
  end
end
