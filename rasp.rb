require 'json'
require 'yaml'

class Rasp
	attr_accessor :country

	def initialize(country)
		self.country  = country
	end

	def exists?
		self.country && File.exist?(country_yml)
	end

	def charts
		YAML.load(File.read(country_yml))[self.country]
	end

	private

	def country_yml
		"countries/#{self.country}.yml"
	end
end
