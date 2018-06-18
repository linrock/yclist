# Checks validity of DNS entries

class DnsChecker
  CONCURRENCY = 10

  def initialize(companies)
    @companies = companies
  end

  # true if successful, false if dns failure
  def self.check_dns(url)
    host = url =~ /\Ahttps?:\/\// ? URI.parse(url).host : url
    host_query = `host "#{host}" 2>&1`.strip
    host_query.present?
  end

  def check!
    results = {
      successes: [],
      failures: [],
    }
    Parallel.each(companies_to_check, in_threads: CONCURRENCY) do |company|
      url = company.url
      if self.class.check_dns(url)
        results[:successes] << url
      else
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
