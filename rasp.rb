require 'rubygems'
require 'mechanize'
require 'logger'
require 'pp'

 class Rasp
   @@base_uri = "http://rasp.kzc.nl/"
   @@english_uri = "http://rasp.kzc.nl/index.php?Lang="

   def initialize
     @agent = Mechanize.new { |agent|
       agent.follow_meta_refresh = true
     }
   end

   def agent
     @agent
   end

   def menu(language = "en")
     page = agent.get(@@english_uri + language.capitalize)
     rows = page.search("//tbody")

     count = 0
     headers = []
     header_list = []
     name = nil
     rows.first.children().each do |row|
       if count > 0
         columns = row.search("td")
         if columns[0].at("font")["color"] == "#cc0000"
           if !header_list.empty?
             headers << [name, header_list]
             header_list = []
           end
           name = columns[0].at("font/b").inner_text.gsub(":", "")
         else
           inner_name = columns[0].at("font/a")
            animation_link = columns[1] ? columns[1].at("font/a") : nil
            total_link = columns[2] ? columns[2].at("font/a") : nil
            if name && animation_link && (animation_link.inner_text == "Animation" || animation_link.inner_text == "Animatie")
              link = animation_link["href"]
              header_list << {
                :name => inner_name.inner_text,
                :yesterday  => "#{@@base_uri}#{link.gsub("plaatjes", "plaatjes_gisteren").gsub("loop", "%04dlst").gsub("gif", "png")}",
                :today  => "#{@@base_uri}#{link.gsub("loop", "%04dlst").gsub("gif", "png")}",
                :tomorrow  => "#{@@base_uri}#{link.gsub("plaatjes", "plaatjes_morgen").gsub("curr.", "curr+1.").gsub("loop", "%04dlst").gsub("gif", "png")}",
                :in_two_days  => "#{@@base_uri}#{link.gsub("plaatjes", "plaatjes_overmorgen").gsub("curr.", "curr+2.").gsub("loop", "%04dlst").gsub("gif", "png")}",
                :animated => true
              }
            elsif name && total_link && (total_link.inner_text == "Total" || total_link.inner_text == "Totaal")
              link = total_link["href"]
              header_list << {
                :name => inner_name.inner_text, 
                 :yesterday  => "#{@@base_uri}#{link.gsub("plaatjes", "plaatjes_gisteren")}",
                 :today  => "#{@@base_uri}#{link}",
                 :tomorrow  => "#{@@base_uri}#{link.gsub("plaatjes", "plaatjes_morgen").gsub("curr.", "curr+1.")}",
                 :in_two_days  => "#{@@base_uri}#{link.gsub("plaatjes", "plaatjes_overmorgen").gsub("curr.", "curr+2.")}",
                 :animated => false
              }
            end
         end
       end
       count += 1
     end
     headers << [name, header_list]
     headers
   end

 end
