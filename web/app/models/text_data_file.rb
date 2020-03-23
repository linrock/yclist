# Read/write company data in text data files

class TextDataFile

  def initialize(filename)
    @filename = filename
    @cohort = get_cohort(filename)
  end

  def company_rows_from_file
    open(@filename, 'r') do |f|
      f.read.strip.split(/\n\n/).map do |company_data|
        company_row = data_to_company_row company_data
        company_row.cohort = @cohort
        company_row
      end
    end
  end

  def export_company_rows!(company_rows)
    data = company_rows.sort_by {|c| c.name.downcase }.map(&:to_text_data).join("\n\n")
    open(@filename, 'w') do |f|
      f.write data + "\n"
    end
  end

  private

  def get_cohort(filename)
    cohort = filename[/(winter|summer|fellowship)/, 1]
    if cohort == "fellowship"
      "F#{filename[/v(\d)/, 1]}"
    else
      "#{cohort[0].capitalize}#{get_year(filename)[2..-1]}"
    end
  end

  def get_year(filename)
    year = filename[/(20[012][\d])/, 1]
    return year if year.present?
    raise "Unable to extract year from filename - #{filename}"
  end

  def parse_metadata_rows(rows)
    options = {}
    rows.each do |data_row|
      split = data_row.split(":")
      options[split[0].strip] = split[1..-1].join(":").strip
    end
    options
  end

  def data_to_company_row(company_data)
    company_data_rows = company_data.strip.split(/\n/).map(&:strip)
    options = {
      name: company_data_rows.shift
    }
    if company_data_rows[0] =~ /\Ahttps?:\/\//
      options[:url] = company_data_rows[0]
      company_data_rows.shift
    end
    if company_data_rows[0] !~ /(status|exit|hide_url|note):/
      options[:description] = company_data_rows[0]
      company_data_rows.shift
    end
    options.merge!(parse_metadata_rows(company_data_rows))
    CompanyRow.new(options)
  end
end
