namespace :import do

  desc "Import company data from http://www.seed-db.com"
  task :companies => :environment do
    require 'nokogiri'
    require 'open-uri'

    def parse_row(row)
      # company name
      # state (operating, exited, etc.)
      # seed-db link
      # website url
      # crunchbase url
      # cohort date
      # exit value
      # funding amount
      # number of employees
      
      td = row.css("td")
      h = {}
      h[:name] = td[1].text.strip
      h[:state] = td[0].text.strip
      h[:seeddb_url] = td[1].css("a")[0].attributes["href"].value rescue nil
      h[:company_url] = td[2].css("a")[0].attributes["href"].value rescue nil
      h[:crunchbase_url] = td[2].css("a")[1].attributes["href"].value rescue nil
      h[:cohort_date] = td[3].text.strip
      h[:exit_value] = td[4].text.gsub(/[^\d]/,'') rescue nil
      h[:exit_value_confidence] = td[5].text.strip rescue nil
      h[:funding_amount] = td[6].text.gsub(/[^\d]/,'') rescue nil
      h[:employee_count] = td[7].text.strip
      h
    end

    Company.destroy_all

    @data = open('list.html').read
    @doc = Nokogiri::HTML @data
    @entries = @doc.css("table > tbody > tr")
    @entries.each do |entry|
      h = parse_row(entry)
      next if h[:name][/#\d+/]
      c = Company.find_or_create_by_name h[:name]
      c.url = h[:company_url]
      c.cohort = h[:cohort_date]
      c.status = h[:state]
      c.data.merge!({
        :crunchbase_url => h[:crunchbase_url],
        :seeddb_url => h[:seeddb_url],
        :funding_amount => h[:funding_amount]
      })
      c.save
    end

    puts "Loaded #{Company.count} companies!"
  end


  desc "Import descriptions from http://crunchbase.com"
  task :descriptions do
    Company.find_each &:set_description_from_crunchbase
  end

end

