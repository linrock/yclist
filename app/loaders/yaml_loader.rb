module YamlLoader

  def load_yearly_data_from_yaml_files
    data = {}
    (2005..2016).each do |year|
      companies = []
      %w( winter fellowship summer ).each do |season|
        options = get_options(year, season)
        next unless options && File.exists?(options[:filename])
        companies << YAML.load_file(options[:filename]).map do |attrs|
          CompanyRow.new(attrs.merge({ cohort: options[:cohort] }))
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
      end
    end
    company_rows
  end

  def get_options(year, season)
    options = {}
    if season == "fellowship"
      klass = year - 2014
      return unless klass > 0
      options[:filename] = "data/companies/fellowship.v#{klass}.yml"
      options[:cohort] = "F#{klass}"
    else
      options[:filename] = "data/companies/#{year}.#{season}.yml"
      options[:cohort] = "#{season[0].capitalize}#{year.to_s[-2..-1]}"
    end
    options
  end

  extend self
end
