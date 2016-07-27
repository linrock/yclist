module YamlLoader

  def load_yearly_data_from_yaml_files
    data = {}
    (2005..2016).each do |year|
      companies = []
      %w( winter summer ).each do |season|
        filename = "data/companies/#{year}.#{season}.yml"
        next unless File.exists?(filename)
        companies << YAML.load_file(filename).map do |attrs|
          CompanyRow.new(attrs.merge({
            cohort: "#{season[0].capitalize}#{year.to_s[-2..-1]}"
          }))
        end
      end
      data[year] = YearlyCompanies.new(companies.flatten)
    end
    data
  end

  def sorted_all_company_rows
    company_rows = []
    load_yearly_data_from_yaml_files.sort.reverse.each do |year, data|
      data.sorted_companies.each do |company|
        company_rows << company
      end rescue binding.pry
    end
    company_rows
  end

  extend self
end
