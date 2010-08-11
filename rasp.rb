require 'rubygems'
require 'mechanize'
require 'logger'
require 'pp'

 class Rasp
   @@base_uri = "http://rasp.kzc.nl/"
   @@english_uri = "http://rasp.kzc.nl/index.php?Lang=En"

   def initialize
     @agent = Mechanize.new { |agent|
       agent.follow_meta_refresh = true
     }
   end

   def agent
     @agent
   end

   def menu
     page = agent.get(@@english_uri)
     rows = page.search("//tbody")

     count = 0
     list = []
     rows.first.children().each do |row|
       if count > 1
         columns = row.search("td")
         name = columns[0].at("font/a")
         animation_link = columns[1] ? columns[1].at("font/a") : nil
         total_link = columns[2] ? columns[2].at("font/a") : nil
         if name && animation_link && animation_link.inner_text == "Animation"
           link = animation_link["href"]
           list << {
             :name => name.inner_text,
             :yesterday  => "#{@@base_uri}#{link.gsub("plaatjes", "plaatjes_gisteren")}",
             :today  => "#{@@base_uri}#{link}",
             :tomorrow  => "#{@@base_uri}#{link.gsub("plaatjes", "plaatjes_morgen").gsub("curr.", "curr+1.")}",
             :in_two_days  => "#{@@base_uri}#{link.gsub("plaatjes", "plaatjes_overmorgen").gsub("curr.", "curr+2.")}"
           }
         elsif name && total_link && total_link.inner_text == "Total"
           link = total_link["href"]
           list << {
             :name => name.inner_text, 
              :yesterday  => "#{@@base_uri}#{link.gsub("plaatjes", "plaatjes_gisteren")}",
              :today  => "#{@@base_uri}#{link}",
              :tomorrow  => "#{@@base_uri}#{link.gsub("plaatjes", "plaatjes_morgen").gsub("curr.", "curr+1.")}",
              :in_two_days  => "#{@@base_uri}#{link.gsub("plaatjes", "plaatjes_overmorgen").gsub("curr.", "curr+2.")}"
           }
         end
       end
       count += 1
     end
     list
   end

   # def account_balance
   #      { :balance => self.login.at("//span[@class='darkBig']").inner_text.strip}
   #    end
   #    # Public: This will return the dashboard of the home page of the user on the
   #    # tradedoubler website.
   #    #
   #    # site_id - The id of the site to query (see `websites`) (default: -1)
   #    # date_period - The date period to select (see `constants`) (default: TODAY)
   #    # Returns a hash with name as key and amount as value
   #    def overview(site_id=-1, date_period = TODAY)
   #      data = { }
   #      frame = frame_with_overview_on
   #      form = frame.forms.first
   #      form.affiliateId = site_id
   #      form.period = date_period
   #      result = form.submit
   # 
   #      parse_dashboard_result(result, site_id)
   #    end
   # 
   #    # Public: This will return the list of websites the customer has on the
   #    # TradeDoubler website
   #    #
   #    # TODO: This needs to get its information from https://www.tradedoubler.com/pan/aAffiliateSitesList.action
   #    # Returns a hash with name as key and id as value
   #    def websites
   #      data = { }
   #      frame = frame_with_overview_on
   #      select = frame.at("//select[@id='accountSnapshotForm_affiliateId']")
   #      children = select.children()
   #      children.shift
   #      children.each do |option_element|
   #        name = option_element.inner_text
   #        value = option_element['value']
   #        data[name] = value
   #      end
   #      data
   #    end
   # 
   #    #Public: Will return a site's name and website
   #    # TODO: Make this work
   #    def website_info site_id
   #      data = { }
   #      url = "#{@@base_uri}pan/aAffiliateSitesList.action"
   #      page = agent.get(url)
   #      rows = page.search("//table[@class='tablebox']/tr")
   #      headers = []
   #      rows.first.children().each do |td|
   #        headers << td.inner_text
   #      end
   #      rows.shift
   #      rows.each do |tr|
   #        tds = tr.children()
   #        data[tds[3].to_s] = { headers[0] => tds[0], headers[1] => tds[1], headers[2] => tds[2], headers[4] => tds[4]}
   #      end
   #      data
   #    end
   #    # Public: This will return all monthly data for all sites for the user
   #    #
   #    # options - The Hash options used to refine the date selection(default: {}):
   #    #           :start_month - Month to start.
   #    #           :start_year - Year to start.
   #    #           :start_month - Month to stop.
   #    #           :end_year - Year to stop.
   #    #
   #    # Returns a hash containing the dates
   #    def data_for_all_sites(options={})
   #      self.login
   #      site_data = {}
   #      options = default_date_selection_options if options.empty?
   #      start_date = Date.parse("#{options[:start_month]}/01/#{options[:start_year]}")
   #      end_date = Date.parse("#{options[:end_month]}/01/#{options[:end_year]}")
   # 
   #      if start_date > end_date
   #        raise "End date occurs before start date"
   #      end
   # 
   # 
   #      # Since tradedoubler doesn't actually listen to end_month
   #      # doing this by hand.
   #      # TODO: Make december work.
   #      date = {}
   #      options[:start_month].upto(options[:end_month]) do | month_index |
   #        url = "#{@base_uri}pan/aReport3.action?reportName=aAffiliateMonthlyOverviewReport&currencyId=EUR&organizationId=#{self.organization_id}&startYear=#{options[:start_year]}&startMonth=#{options[:start_month]}&endYear=#{options[:end_year]}&endMonth=#{options[:end_month]}&isMonthlyBreakdown=false&columns=impNrOf&columns=uimpNrOf&columns=clickNrOf&columns=clickRate&columns=uvNrOf&columns=leadNrOf&columns=leadRate&columns=saleNrOf&columns=saleCommission&columns=conversionRate&columns=totalOrderValue&columns=affiliateCommission&columns=link&columns=date"
   #        page = agent.get(url)
   #        month_data = parse_site_data_page page
   #        site_data.merge!(month_data)
   #      end
   #      site_data
   #    end
   # 
   #    # Public: This will return all data in the selected date period for the given
   #    # site.
   #    #
   #    # options - The Hash options used to refine the date selection(default: {}):
   #    #           :start_month - Month to start.
   #    #           :start_year - Year to start.
   #    #           :end_month - Month to stop.
   #    #           :end_year - Year to stop.
   #    # site_id - The id of the site (mostly received from the websites function)
   #    #
   #    # Returns a hash containing the dates
   #    def data_for_site site_id, options={}
   #      self.login
   #      site_data = {}
   #      options = default_date_selection_options if options.empty?
   #      start_date = Date.parse("#{options[:start_month]}/01/#{options[:start_year]}")
   #      end_date = Date.parse("#{options[:end_month]}/01/#{options[:end_year]}")
   # 
   #      if start_date > end_date
   #        raise "End date occurs before start date"
   #      end
   # 
   # 
   #      # Since tradedoubler doesn't actually listen to end_month
   #      # doing this by hand.
   #      # TODO: Make december work.
   #      date = {}
   #      options[:start_month].upto(options[:end_month]) do | month_index |
   #        url = "#{@base_uri}pan/aReport3.action?reportName=aAffiliateMonthlyOverviewReport&currencyId=EUR&affiliateId=#{site_id}&organizationId=#{self.organization_id}&startYear=#{options[:start_year]}&startMonth=#{month_index}&endYear=#{options[:end_year]}&endMonth=#{options[:end_month]}&isMonthlyBreakdown=false&columns=impNrOf&columns=uimpNrOf&columns=clickNrOf&columns=clickRate&columns=uvNrOf&columns=leadNrOf&columns=leadRate&columns=saleNrOf&columns=saleCommission&columns=conversionRate&columns=totalOrderValue&columns=affiliateCommission&columns=link&columns=date"
   #        page = agent.get(url)
   #        month_data = parse_site_data_page page
   #        site_data.merge!(month_data)
   #      end
   #      site_data
   #    end
   # 
   #    # This is just a way to create a link in Mechanize, I kept it in because
   #    # I spent quite some time figuring it out.
   #    #
   #    # text - The text you want the link to have
   #    # href - The URL you want the link to have
   #    # page - The Mechanize::Page you want the link on
   #    #
   #    # Returns a Mechanize::Page::Link
   #    def create_link_on_page(text, href, page)
   #      node = Struct.new(:inner_text, :href).new(text, href)
   #      mech = login.mech
   #      page = login
   #      link = Mechanize::Page::Link.new(node,login.mech,login)
   #    end
   # 
   #    protected
   # 
   #    # Retrieve the current users organizations id. This is used for all calls
   #    # where reports have to be created
   #    #
   #    # Return an integer (organization_id)
   #    def organization_id
   #      self.login
   #      page = agent.get("#{@base_uri}/pan/aReport3Selection.action?reportName=aAffiliateMonthlyOverviewReport")
   # 
   #      selection_form = page.form_with(:name => "selectionForm")
   #      # Limit to current month (smallest data possible)
   #      selection_form.datePeriod = 1
   #      # change the form action from javascript to something useful
   #      selection_form.action = "aReport3Internal.action"
   #      result = selection_form.submit
   # 
   #      # This is pretty sketchy as the text is vulnerable to change
   #      # but it'll have to do unless we can find the organization ID
   #      # in a simpler way
   #      link = result.link_with(:text => "Further drilldown by day 'Day by day'")
   #      s = /organizationId=([0-9]+)/.match(link.href)
   #      s[1]
   #    end
   # 
   #    # This will return the frame on the homepage of the user
   #    def frame_with_overview_on
   #      unless @frame
   #        @frame = login.iframes.first.click()
   #      end
   #      @frame
   #    end
   # 
   #    # This will parse the header row of the month overview page
   #    #
   #    # header - The <tr> of the header on the page
   #    #
   #    # Will return an array with titles
   #    def parse_month_overview_header header
   #      tds = header.children()
   #      tds.shift # Empty column
   #      tds.shift # Empty column
   #      # TODO: Filter out the garbage (e.g. \t and \302\240)
   #      data = tds.map { |td| td.inner_text}
   #    end
   # 
   #    # This will parse the tbody found on the month_overview page
   #    #
   #    # tbody - The tbody
   #    #
   #    # Returns a hash with dates, where each date contains a hash with the data
   #    def parse_month_overview_tbody tbody
   #      data = { }
   #      tbody.css("tr").each do |tr|
   #        # 0 : Link
   #        # 1 : Date
   #        # 2 : Impressions
   #        # 3 : Unique_impressions
   #        # 4 : Clicks
   #        # 5 : Clicks (CTR)
   #        # 6 : Unique_visitors
   #        # 7 : Leads
   #        # 8 : Leads (LR)
   #        # 9 : Sales
   #        # 10 : Sales (EUR)
   #        # 11 : Sales (CR)
   #        # 12 : Order Value
   #        # 13 : Commission
   #        tds = tr.css("td").map { |td| td.inner_text}
   #        data[tds[1]] = { :impressions => tds[2],
   #          :clicks => tds[4],
   #          :unique_visitors => tds[6],
   #          :leads => tds[7],
   #          :sales => tds[10],
   #          :commission => tds[13].gsub(/EUR/,"").strip()
   #        }
   #      end
   #      data
   #    end
   # 
   #    def parse_site_data_page page
   #      table = page.search("//table[contains(@class, 'reportTable')]")
   #      headers = parse_month_overview_header(table.css('tr.groupHeader'))
   #      # TODO: Do something with these headers
   #      tbody = page.search("//table[contains(@class,'reportTable')]/tbody")
   #      parse_month_overview_tbody(tbody)
   #    end
   # 
   #    # Will parse the result of the form on the dashboard frame
   #    #
   #    # result - The result of the submitted form
   #    # site_id - The id of the site to parse
   #    #
   #    # Returns a hash containing the data
   #    def parse_dashboard_result result, site_id
   #      data = {}
   #      tr_elements = result.search("//table[@class='listTable']/tr")
   #      tr_elements.shift # Removing the header row
   #      data["site_id"] = site_id
   #      tr_elements.each do |tr_element|
   #        name = tr_element.css("td:first").inner_text
   #        value = tr_element.css("td:last").inner_text.gsub(/EUR/,"").strip
   #        data[name] = value
   #      end
   #      data
   #    end
   # 
   #    # Creates a default date selection time which starts in the previous month
   #    # and ends in the current month (this way we always have at least 4 weeks
   #    # data to pick from.
   #    #
   #    # Returns an options hash
   #    def default_date_selection_options
   #      options = {}
   #      current_date = Date.parse(Time.now.to_s)
   #      current_date_minus_one_month = current_date << 1
   #      options[:start_year] = current_date_minus_one_month.year
   #      options[:start_month] = current_date_minus_one_month.month
   #      options[:end_year] = current_date.year
   #      options[:end_month] = current_date.month
   #      options
   #    end
   # 
   #    class << self
   #      def valid_login_and_pass? username, password
   #        t = self.new(username,password)
   #        t.is_logged_in?
   #      end
   #    end
 end

 # Usage
 #
 #username  = "be@tradedoubler.com"
 #password = "Astridplein41"

 #tradedoubler = TradeDoubler.new("be@tradedoubler.com", "Astridplein41")
 # site =    tradedoubler.websites.first
 # puts "Getting data for #{site.first}"
 # pp tradedoubler.month_data_for_site site.last
