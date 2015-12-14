class FaviconFetcher

  def initialize(companies)
    @companies = companies.select(&:need_favicon?)
    puts "#{@companies.length} of #{companies.length} companies need favicons"
  end

  def fetch_parallel
    i = 0
    Parallel.each(@companies, :in_threads => 10) do |company|
      puts "Fetching favicon for #{company.url}... "
      if !(favicon = company.favicon).nil?
        puts "Fetch for #{company.url} - SUCCESS\n"
        i += 1
      else
        puts "Fetch for #{company.url} - NOT FOUND\n"
      end
    end
    puts "Found #{i} favicons out of #{@companies.count} companies"
  end

  def fetch_one_by_one
    i = 0
    @companies.each do |company|
      $stdout.write "Fetching favicon for #{company.url}... "
      favicon = company.favicon
      if !(favicon = company.favicon).nil?
        $stdout.write "success\n"
        i += 1
      else
        $stdout.write "NOT FOUND\n"
      end
    end
    puts "Found #{i} favicons out of #{@companies.count} companies"
  end

end
