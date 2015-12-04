module FaviconFetcher

  def fetch_parallel
    i = 0
    companies = GoogleSheetsParser.sorted_all_company_rows.select(&:need_favicon?)
    puts "#{companies.length} companies need favicons"
    Parallel.each(companies, :in_threads => 10) do |company|
      puts "Fetching favicon for #{company.url}"
      accessor = FaviconAccessor.new(company.url)
      if accessor.fetch_and_cache!
        puts "Fetched favicon for #{company.url}"
      else
        puts "Failed to fetch favicon for #{company.url}"
      end
      i += 1
    end
    puts "Fetched favicons for #{i} companies"
  end

  def fetch_one_by_one
    i = 0
    GoogleSheetsParser.sorted_all_company_rows.each do |company_row|
      next unless company_row.need_favicon?
      puts "Fetching favicon for #{company_row.url}"
      favicon = company_row.favicon
      puts "Favicon not found" unless favicon.present?
      i += 1
    end
    puts "Tried fetching favicons for #{i} companies"
  end

  extend self
end
