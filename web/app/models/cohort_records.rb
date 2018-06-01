# For reading/writing records for one cohort

class CohortRecords

  def initialize(cohort)
    @cohort = cohort
  end

  def company_rows_from_file
    TextDataFileLoader.new.get_cohort(@cohort)
  end

  def rewrite!(company_rows = nil)
    company_rows ||= company_rows_from_file
    TextDataFile.new(cohort_filename).export_company_rows! company_rows_from_file
  end

  private

  def cohort_filename
    case @cohort[0]
    when "S"
      "../companies/20#{@cohort[1..-1]}.summer.txt"
    when "W"
      "../companies/20#{@cohort[1..-1]}.winter.txt"
    when "F"
      "../companies/fellowship.v#{@cohort[1]}.txt"
    end
  end
end
