require 'nokogiri'


class GoogleSheetsParser

  TMP_DIR = "/tmp/yclist"

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
      row = CompanyRow.new.init_from_tr(tr)
      unless row.valid?
        binding.pry
        raise "Invalid company data"
      end
      row
    end.compact
  end

end
