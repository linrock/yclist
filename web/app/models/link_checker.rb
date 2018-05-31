# Check validity of the listed URL
#
class LinkChecker

  def initialize(companies)
    @companies = companies
  end

  def check_link(url)
    final_url = `curl -sLI -o /dev/null -m 10 -w %{url_effective} "#{url}"`
    if final_url.gsub(/\/\z/, '') != url
      [url, final_url]
    end
  end

  def check_all
    diff_links = []
    c = companies_to_check
    Parallel.each(c, :in_threads => 10) do |company|
      result = check_link(company.url)
      if result
        puts result.join(" -> ")
        diff_links << result
      end
    end
    puts "#{diff_links.length} out of #{c.length} companies have different links"
    diff_links
  end

  # Rewrites company urls if to/from www and https url changes
  def rewrite_https_and_www_links
    different_links = Hash[check_all]
    @companies.each do |company|
      new_link = different_links[company.url]
      next unless new_link.present?
      new_link = new_link.gsub(/:443/, '')
      non_www_hostname = company.url.gsub(/\Ahttps?:\/\/(www\.)?/, '')
      next unless new_link.ends_with?("/") and new_link.count("/") == 3
      if new_link.gsub(/\Ahttps?:\/\/(www\.)?/, '').starts_with?(non_www_hostname) and
         company.url != new_link
        puts "Rewriting #{company.url} to #{new_link}"
        company.url = new_link
      end
      if new_link.starts_with?(company.url.gsub(/\Ahttp:/, 'https:')) && company.url != new_link
        puts "Rewriting #{company.url} to #{new_link}"
        company.url = new_link
      end
    end
    @companies
  end

  private

  def companies_to_check
    @companies.select {|c| c.url.present? && !c.dead? }
  end
end
