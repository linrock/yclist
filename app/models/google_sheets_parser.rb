require 'nokogiri'


class GoogleSheetsParser

  TMP_DIR = "/tmp/yclist"

  def self.most_recent_zip_file
    zip_files = Dir.glob("/tmp/YC List*.zip")
    raise "No .zip file found" unless zip_files.length > 0
    zip_files.sort_by {|filename| filename[/\d+/] || "0" }.last
  end

  def self.load_yearly_data_from_most_recent_zip_file
    load_yearly_data_from_zip_file most_recent_zip_file
  end

  def self.load_yearly_data_from_zip_file(filename)
    `unzip -o "#{filename}" -d #{TMP_DIR}`
    data = {}
    Dir.glob("#{TMP_DIR}/*.html").each do |filename|
      year = filename[/\d+/].to_i
      data[year] = YearlyCompanies.new(load_company_rows_from_sheet_file(filename))
    end
    data
  end

  def self.load_company_rows_from_sheet_file(filename)
    html = open(filename, 'r').read
    doc = Nokogiri::HTML.fragment html
    doc.css("tr")[3..-1].map do |tr|
      next if tr.css("td").map(&:text).all?(&:blank?)
      row = CompanyRow.new.init_from_tr(tr)
      unless row.valid?
        binding.pry
        raise "Invalid company data"
      end
      row
    end.compact
  end

end
