# Check validity of the listed URL
#
class LinkChecker

  def initialize(companies)
    @companies = companies.select {|c| c.url.present? && !c.dead? }
  end

  def check_link(url)
    final_url = `curl -sLI -o /dev/null -m 10 -w %{url_effective} "#{url}"`
    if final_url.gsub(/\/\z/, '') != url
      "#{url} -> #{final_url}"
    end
  end

  def check_all
    different_links = []
    Parallel.each(@companies, :in_threads => 10) do |company|
      result = check_link(company.url)
      if result
        puts result
        different_links << result
      end
    end
    puts "#{different_links.length} out of #{@companies.length} companies have different links"
    true
  end
end
