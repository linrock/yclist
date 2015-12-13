class FaviconFetcher

  def initialize(companies)
    @companies = companies.select(&:need_favicon?)
    puts "#{@companies.length} of #{companies.length} companies need favicons"
  end

  def fetch_parallel
    Parallel.each(@companies, :in_threads => 10) do |company|
      log_fetch_attempt(company)
    end
    puts "Tried fetching favicons for #{@companies.count} companies"
  end

  def fetch_one_by_one
    @companies.each do |company|
      log_fetch_attempt(company)
    end
    puts "Tried fetching favicons for #{@companies.count} companies"
  end

  def log_fetch_attempt(company)
    $stdout.write "Fetching favicon for #{company.url}... "
    if (favicon = company.favicon).present?
      $stdout.write "success\n"
      return true
    else
      $stdout.write "NOT FOUND\n"
      return false
    end
  end

end
