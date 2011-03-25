require 'rubygems'
require 'mechanize'
require 'logger'
require 'pp'

class Rasp
	attr_accessor :agent, :name, :headers, :cells

	def initialize
		self.agent = Mechanize.new { |a| a.follow_meta_refresh = true }
	end

	def menu(language)
		language = "en" unless language
		page = self.agent.get(english_base_uri + language.capitalize)

		parse_rows page
	end

	def parse_rows(page)
		self.cells = []
		self.headers = []
		self.name = nil

		rows = page.search("//tbody").first.children()
		rows.each { |row| parse_row(row.search("td")) unless rows.first == row }
		self.headers << [self.name, self.cells]
		self.headers
	end

	def parse_row(row)
		if row[0].at("font")["color"] == "#cc0000"
			parse_header(row)
		else
			parse_normal_row(row)
		end
	end

	def parse_header(row)
		unless self.cells.empty?
			self.headers << [self.name, self.cells]
			self.cells = []
		end
		self.name = row[0].at("font/b").inner_text.gsub(":", "")
	end

	def parse_normal_row(row)
		inner_name     = row[0].at("font/a")
		total_link     = row[2] ? row[2].at("font/a") : nil
		if with_hours?(total_link)
			link = total_link["href"]
			self.cells << parse_cell(link, inner_name, true)
		elsif total?(total_link)
			link = total_link["href"]
			self.cells << parse_cell(link, inner_name, false)
		end
	end

	def with_hours?(animation_link)
		self.name && animation_link && (animation_link.inner_text == "0830")
	end

	def total?(total_link)
		self.name && total_link && (total_link.inner_text == "Total" || total_link.inner_text == "Totaal")
	end

	def parse_cell(link, inner_name, animated)
		{
			:name        => inner_name.inner_text,
			:yesterday   => parse_yesterday_url(link, animated),
			:today       => parse_today_url(link, animated),
			:tomorrow    => parse_tomorrow_url(link, animated),
			:in_two_days => parse_the_day_after_url(link, animated),
			:animated    => animated
		}
	end

	def parse_yesterday_url(link, animated)
		parse_day "plaatjes_gisteren", link, "curr", animated
	end

	def parse_today_url(link, animated)
		parse_day "plaatjes", link, "curr", animated
	end

	def parse_tomorrow_url(link, animated)
		parse_day "plaatjes_morgen", link, "curr+1", animated
	end

	def parse_the_day_after_url(link, animated)
		parse_day "plaatjes_overmorgen", link, "curr+2", animated
	end

	def parse_day(period, link, curr, animated)
			url = "#{base_uri}"
		if animated
			url << "#{period}/" if period 
			if link.match /showsounding/
				url << link.gsub("showsounding.php?SoundingIndex=", "sounding").split("&").first
			else
				url << link.gsub("showblipmap.php?Param=", "").split("&").first
			end
			url << ".#{curr}.%04dlst.d2.png"
		else
			url << link.gsub("plaatjes", period).gsub("curr", curr)
		end
		url
	end
end
