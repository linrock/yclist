class YamlLoader

  def get_cohort(cohort) # S05, F1
    sorted_all_company_rows.select {|c| c.cohort == cohort }
  end

  def load_yearly_data_from_yaml_files
    (2005..2017).to_a.map do |year|
      companies = []
      %w( winter summer ).each do |season|
        options = get_options(year, season)
        next unless options && File.exists?(options[:filename])
        companies << load_companies_from_options(options)
      end
      # quick hack for fellowship companies
      if year == 2016
        companies << load_companies_from_options(get_options(2015, "fellowship"))
        companies << load_companies_from_options(get_options(2016, "fellowship"))
      end
      YearlyCompanies.new(companies.flatten)
    end.flatten
  end

  def sorted_all_company_rows
    load_yearly_data_from_yaml_files.reverse.map(&:sorted_companies).flatten
  end

  private

  def load_companies_from_options(options)
    YAML.load_file(options[:filename]).map do |attrs|
      CompanyRow.new(attrs.merge({ cohort: options[:cohort] }))
    end
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
end
