require 'json'
require 'yaml'

class Rasp
	attr_accessor :region

	def initialize(region)
		self.region  = region
	end

	def exists?
		self.region && File.exist?(region_yml)
	end

	def charts
		charts = YAML.load(File.read(region_yml))[self.region]
		charts_with_urls(charts)
	end

	private

	def region_yml
		"regions/#{self.region}.yml"
	end

	def charts_with_urls(charts)
		charts.keys.each do |header|
			unless header == "config"
				charts[header].keys.each do |chart|
					has_periods = charts[header][chart]["has_periods"]
					["yesterday", "today", "tomorrow", "the_day_after"].each do |day|
						url = charts[header][chart][day]
						unless url.nil?
							urls = []
							if has_periods
								periods = charts["config"]["#{day}_periods"] || charts["config"]["periods"]
								periods.each do |period|
									if charts["config"]["only_hours_in_url"]
										link = url.gsub("%02d", "%02d" % (period/100))
									else
										link = url.gsub("%04d", "%04d" % period)
									end
									urls << link
								end
							else
								urls << url
							end
							charts[header][chart][day] = urls
						end
					end
				end
			end
		end
		charts
	end
end
