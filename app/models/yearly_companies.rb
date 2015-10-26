class YearlyCompanies
  include ActiveModel::Validations

  validate :validate_cohorts

  attr_accessor :companies


  def initialize(company_rows)
    @companies = company_rows
  end

  def year
    "20#{year_suffix}".to_i
  end

  def inspect
    fields = [
      %(@year="#{year}"),
      %(@n="#{@companies.length}"),
      %(@n_summer="#{summer_companies.length}"),
      %(@n_winter="#{winter_companies.length}")
    ]
    %(#<YearlyCompanies: #{fields.join(", ")}>)
  end

  def summer_companies
    @companies.select {|c| c.cohort == "S#{year_suffix}" }
  end

  def winter_companies
    @companies.select {|c| c.cohort == "W#{year_suffix}" }
  end

  def sorted_companies
    summer_companies.sort_by(&:name) + winter_companies.sort_by(&:name)
  end

  private

  def year_suffix
    @companies.map(&:cohort).uniq.first[/\d+/]
  end

  def validate_cohorts
    @companies.map {|c| c.cohort[/d+/] }.compact.uniq.length == 1
  end

end
