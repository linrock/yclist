# Loads company data from public Google sheets links
#
require 'nokogiri'


module GsPublishedPageLoader

  URL = "https://docs.google.com/spreadsheets/d/1OoT1PjIQHLsBZ955rceXN8Sy2_49fuc_MOl2sTQw_hc/pub"

  def fetch_html
    `curl -sL "#{URL}"`
  end

  def html_parser
    Nokogiri.parse fetch_html
  end

  def get_attributes_from_tr(tr)
    columns = tr.css("td")
    return unless columns.present? && columns.length >= 5
    data = columns.map(&:text)
    attrs = {
      :name => data[0].strip,
      :url => data[1].present? && data[1].strip || nil,
      :cohort => data[2].strip,
      :status => data[3].present? && data[3].strip || "Operating",
      :description => data[4].present? && data[4].strip
    }
    return unless attrs[:name].present?
    return unless attrs[:cohort].present? && attrs[:cohort] =~ /(W|S)\d{2}/
    attrs
  end

  def sorted_all_company_rows
    doc = html_parser
    all_companies = []
    (2005..2015).to_a.reverse.each_with_index do |year, i|
      yearly = YearlyCompanies.new(get_company_rows(doc.css(".waffle")[i]))
      all_companies += yearly.sorted_companies
    end
    all_companies
  end

  def get_company_rows(table)
    companies = []
    table.css("tr").each do |tr|
      attributes = get_attributes_from_tr(tr)
      next unless attributes
      companies << CompanyRow.new(attributes)
    end
    companies
  end

  extend self
end
