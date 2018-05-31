class TextDataFileLoader

  def get_cohort(cohort)
    sorted_all_company_rows.select {|c| c.cohort == cohort }
  end

  def load_yearly_data_from_text_files
    (2005..2017).to_a.map do |year|
      companies = []
      %w( winter summer ).each do |season|
        options = get_options(year, season)
        next unless options && File.exists?(options[:filename])
        companies << company_rows_from_options(options)
      end
      # quick hack for fellowship companies
      if year == 2016
        options = get_options(2015, "fellowship")
        if File.exists?(options[:filename])
          companies << company_rows_from_options(options)
        end
        options = get_options(2016, "fellowship")
        if File.exists?(options[:filename])
          companies << company_rows_from_options(options)
        end
      end
      YearlyCompanies.new(companies.flatten)
    end.flatten
  end

  def sorted_all_company_rows
    load_yearly_data_from_text_files.reverse.map(&:sorted_companies).flatten
  end

  private

  def company_rows_from_options(options)
    TextDataFile.new(options[:filename]).company_rows_from_file
  end

  def get_options(year, season)
    if season == "fellowship"
      fellowship_class = year - 2014
      return unless fellowship_class > 0
      {
        filename: "../companies/fellowship.v#{fellowship_class}.txt",
        cohort: "F#{fellowship_class}"
      }
    else
      {
        filename: "../companies/#{year}.#{season}.txt",
        cohort: "#{season[0].capitalize}#{year.to_s[-2..-1]}"
      }
    end
  end
end
