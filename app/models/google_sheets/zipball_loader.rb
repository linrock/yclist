require 'nokogiri'


module GoogleSheets
  
  module ZipballLoader

    TMP_DIR = "/tmp/yclist"

    def load_yearly_data_from_most_recent_zip_file
      load_yearly_data_from_zip_file most_recent_zip_file
    end

    def most_recent_zip_file
      zip_files = Dir.glob("/tmp/YC List*.zip")
      raise "No .zip file found" unless zip_files.length > 0
      zip_files.sort_by {|filename| filename[/\d+/] || "0" }.last
    end

    def load_yearly_data_from_zip_file(filename)
      `unzip -o "#{filename}" -d #{TMP_DIR}`
      data = {}
      Dir.glob("#{TMP_DIR}/*.html").each do |filename|
        year = filename[/\d+/].to_i
        data[year] = YearlyCompanies.new(load_company_rows_from_sheet_file(filename))
      end
      data
    end

    def load_company_rows_from_sheet_file(filename)
      html = open(filename, 'r').read
      doc = Nokogiri::HTML.fragment html
      doc.css("tr")[3..-1].map do |tr|
        next if tr.css("td").map(&:text).all?(&:blank?)
        row = CompanyRow.new(attributes_from_tr(tr))
        unless row.valid?
          binding.pry
          raise "Invalid company data"
        end
        row
      end.compact
    end

    def attributes_from_tr(tr)
      data = tr.css("td").map(&:text)
      {
        :name => data[0],
        :url => data[1].present? && data[1] || nil,
        :cohort => data[2],
        :status => data[3].present? && data[3] || "Operating",
        :description => data[4].present? && data[4]
      }
    end

    def sorted_all_company_rows
      company_rows = []
      load_yearly_data_from_most_recent_zip_file.sort.reverse.each do |year, data|
        data.sorted_companies.each do |company|
          # next unless company.url.present?
          company_rows << company
        end
      end
      company_rows
    end

    extend self

  end

end
