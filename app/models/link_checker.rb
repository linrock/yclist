# Check validity of the listed URL
#
class LinkChecker

  def initialize(companies)
    @companies = companies.select {|c| c.url.present? }
  end

  def check_link(url)
    final_url = `curl -sLI -o /dev/null -m 10 -w %{url_effective} "#{url}"`
    if final_url.gsub(/\/\z/, '') != url
      puts "#{url} -> #{final_url}"
    end
  end

  def check_all
    Parallel.each(@companies, :in_threads => 10) do |company|
      check_link(company.url)
    end
    true
  end

end
