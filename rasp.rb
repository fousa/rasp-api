require 'rubygems'
require 'mechanize'
require 'logger'
require 'pp'
require 'benelux'

class Rasp
	attr_accessor :agent, :language, :country

	def initialize(language, country)
		self.agent = Mechanize.new { |a| a.follow_meta_refresh = true }

		self.language = language || "en"
		self.country  = country  || "benl"
	end

	def charts
		klazz = get_country_klazz.new

		page = self.agent.get(klazz.base_uri + self.language.capitalize)

		klazz.parse_rows page
	end

	private
	
	def get_country_klazz
		case self.country
		when "benl"
			Benelux
		end
	end
end
