# Check validity of the listed URL
#
class LinkChecker

  def initialize(companies)
    @companies = companies.select {|c| c.url.present? }
  end

  def check_all
    Parallel.each(@companies, :in_threads => 10) do |company|
      final_url = `curl -sLI -o /dev/null -m 10 -w %{url_effective} "#{company.url}"`
      if final_url.gsub(/\/\z/, '') != company.url
        puts "#{company.url} -> #{final_url}"
      end
    end
    true
  end

end
