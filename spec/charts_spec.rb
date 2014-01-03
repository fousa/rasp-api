require_relative 'spec_helper'

describe 'The charts' do
    include Rack::Test::Methods

    chart = ENV["CHART"]
    if chart.inspect
        it "should validate the links for #{chart}" do
            validate_links_for chart
        end
    else
        %w(
            alps
            avenal13km
            avenal4km
            baltic
            benelux
            blackforest
            bryon3km
            bryon750m
            centralfrance
            finland
            germany
            hilltown
            jaca
            kanto2km
            kanto6km
            newsouthwales
            nsw
            nt
            qld
            queensland
            sa
            sierra
            slovakia
            southaustralia
            southerncalifornia
            swsouthafrica
            tas
            uk
            vic
            wa
            westernswissalps
        ).sort.each do |country|
            it "should validate the links for #{country}" do
                validate_links_for country
            end
        end
    end
end

def validate_links_for(country)
    class_name = Rasp
    #class_name = Uk if country == "uk"
    rasp = class_name.new country
    charts = rasp.charts
    puts "\n======> #{country}"
    charts.keys.each do |header|
        unless header == "config"
            charts[header].keys.each do |chart|
                puts "------> #{chart}"
                urls = charts[header][chart]["yesterday"]
                if urls and urls.first
                    puts "---------> yesterday #{urls.first}"
                    Net::HTTP.get_response(URI.parse(urls.first)).class.should == Net::HTTPOK
                end
                urls = charts[header][chart]["today"]
                if urls and urls.first
                    puts "---------> today #{urls.first}"
                    Net::HTTP.get_response(URI.parse(urls.first)).class.should == Net::HTTPOK
                end
                urls = charts[header][chart]["tomorrow"]
                if urls and urls.first
                    puts "---------> tomorrow #{urls.first}"
                    Net::HTTP.get_response(URI.parse(urls.first)).class.should == Net::HTTPOK
                end
                urls = charts[header][chart]["the_day_after"]
                if urls and urls.first
                    puts "---------> the_day_after #{urls.first}"
                    Net::HTTP.get_response(URI.parse(urls.first)).class.should == Net::HTTPOK
                end
            end
        end
    end
end
