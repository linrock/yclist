# Checks validity of DNS entries

class DnsChecker
  CONCURRENCY = 10

  def initialize(companies)
    @companies = companies
  end

  # true if successful, false if dns failure
  def self.valid_dns?(url)
    host = url =~ /\Ahttps?:\/\// ? URI.parse(url).host : url
    host_query = `host -W 5 "#{host}" 2>&1`.strip
    host_query.present?
  end

  def check
    results = {
      successes: [],
      failures: [],
    }
    Parallel.each(companies_to_check, in_threads: CONCURRENCY) do |company|
      url = company.url
      puts "Checking #{url}"
      if self.class.valid_dns?(url)
        results[:successes] << url
      else
        puts "#{url} is invalid!"
        results[:failures] << url
      end
    end
    results
  end

  private

  def companies_to_check
    @companies.select {|c| c.url.present? && !c.dead? }
  end
end
