# For finding and making changes to a single company record

class CompanyRecord

  attr_accessor :company_row

  delegate :status=, :exit=, :url=,
           to: :company_row

  def self.all
    TextDataFileLoader.new.sorted_all_company_rows
  end

  def self.find_by_name(name)
    company_row = all.find {|c| c.name.downcase == name.downcase }
    return unless company_row.present?
    self.new(company_row)
  end

  def initialize(company_row)
    @company_row = company_row
    @index = cohort_companies.index company_row
  end

  def save!
    new_cohort_companies = cohort_companies
    new_cohort_companies[@index] = @company_row
    cohort_records.rewrite! new_cohort_companies
    @index = cohort_companies.index company_row
    true
  end

  private

  def cohort_records
    CohortRecords.new(@company_row.cohort)
  end

  def cohort_companies
    cohort_records.company_rows_from_file
  end
end
