require 'nokogiri'


# out = parser.entries.map {|row| parser.parse_row(row) }.select {|c| c[:cohort_date] == "6/2013" || c[:cohort_date] == "1/2014" }

class SeeddbParser


  # Each entry corresponds to a row in the seed db table
  #
  class Entry

    attr_accessor :data

    def initialize(row)
      td = row.css("td")
      @data = {
        :name                     => td[1].text.strip,
        :state                    => td[0].text.strip,
        :seeddb_url               => (td[1].css("a")[0].attributes["href"].value rescue nil),
        :company_url              => (td[2].css("a")[0].attributes["href"].value rescue nil),
        :crunchbase_url           => (td[2].css("a")[1].attributes["href"].value rescue nil),
        :cohort_date              => td[3].text.strip,
        :exit_value               => (td[4].text.gsub(/[^\d]/,'') rescue nil),
        :exit_value_confidence    => (td[5].text.strip rescue nil),
        :funding_amount           => (td[6].text.gsub(/[^\d]/,'') rescue nil),
        :employee_count           => td[7].text.strip,
      }
    end

    def save!
      c = Company.find_or_create_by_name @data[:name]
      c.url = @data[:company_url]
      c.cohort = @data[:cohort_date]
      c.status = @data[:state]
      c.data.merge!({
        :crunchbase_url  => @data[:crunchbase_url],
        :seeddb_url      => @data[:seeddb_url],
        :funding_amount  => @data[:funding_amount]
      })
      c.save!
    end

    def to_h
      @data
    end

    def to_s
      "<SeedDBEntry name: \"#{@data[:name]}\", cohort: \"#{@data[:cohort_date]}\">"
    end

  end


  attr_accessor :html, :doc, :rows, :entries

  def initialize
  end

  def fetch
    @html = `curl -sL http://www.seed-db.com/accelerators/view?acceleratorid=1011`
    @doc = Nokogiri::HTML @html
    @rows = @doc.css("table > tbody > tr")
    @entries = @rows.map {|row| Entry.new(row) }
  end

end
