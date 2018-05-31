# Read/write company data in text data files

class TextDataFile

  def initialize(filename)
    @filename = filename
    @cohort = get_cohort(filename)
  end

  def company_rows
    open(@filename, 'r') do |f|
      f.read.strip.split(/\n\n/).map do |company_data|
        company_row = data_to_company_row company_data
        company_row.cohort = @cohort
        company_row
      end
    end
  end

  def to_text_data
    company_rows.map { |row| company_row_to_data(row) }.join("\n\n")
  end

  def export_company_rows!(company_rows)
    open(@filename, 'w') do |f|
      f.write company_rows.map(&:to_text_data).join("\n\n") + "\n"
    end
  end

  private

  def get_cohort(filename)
    cohort = filename[/(winter|summer|fellowship)/, 1]
    "#{cohort[0].capitalize}#{get_year(filename)[2..-1]}"
  end

  def get_year(filename)
    year = filename[/(20[01][\d])/, 1]
    return year if year.present?
    return 2016 if filename =~ /\/fellowship/
    raise "Unable to extract year from filename"
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
    if company_data_rows[0] !~ /(status|exit|metadata|annotation|hide_url|notes):/
      options[:description] = company_data_rows[0]
      company_data_rows.shift
    end
    options.merge!(parse_metadata_rows(company_data_rows))
    CompanyRow.new(options)
  end

  def company_row_to_data(company_row)
    fields = []
    fields << company_row.url if company_row.url.present?
    fields << company_row.description if company_row.description.present?
    fields << "status: #{company_row.status.downcase}" if company_row.status_class != 'operating'
    if company_row.annotation && company_row.annotation[:exit].present?
      fields << "exit: #{company_row.exit}"
    end
    fields << "metadata: #{company_row.metadata}" if company_row.metadata.present?
    ([company_row.name] + fields.map {|f| "  #{f}" }).join("\n")
  end
end
