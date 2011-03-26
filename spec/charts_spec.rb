require File.dirname(__FILE__) + '/spec_helper'

describe 'The charts' do
  include Rack::Test::Methods

  it "should have valid links" do
		["benl"].each do |country|
			rasp = Rasp.new country
			charts = rasp.charts

			charts[country].keys.each do |header|
				puts "=== HEADER: #{header}"
				unless header == "config"
					charts[country][header].keys.each do |chart|
						puts "====== CHART: #{chart}"
						has_periods = charts[country][header][chart]["has_periods"]
						url = charts[country][header][chart]["today"]
						if has_periods
							charts[country]["config"]["periods"].each do |period|
								link = url.gsub("%04d", "%04d" % period)
								puts "============ URL: #{link}"
								Net::HTTP.get_response(URI.parse(link)).class.should == Net::HTTPOK
							end
						else
							puts "============ URL: #{url}"
							Net::HTTP.get_response(URI.parse(url)).class.should == Net::HTTPOK
						end
					end
				end
			end
		end
  end
end

