class FaviconAccessor

  FETCHER_PREFIX = "http://localhost:9292/favicons?q="

  attr_accessor :url, :host, :cache

  def initialize(url)
    @url = url
    @host = URI.parse(url).host
    @cache = FaviconCache.new(@host)
    raise "Invalid url - #{url}" if @host.nil?
  end

  def fetch
    favicon = fetch_from_cache
    return favicon if favicon.present?
    favicon = fetch_from_service
    return unless favicon.present?
    @cache.set favicon
  end

  def fetch_from_cache
    @cache.get
  end

  def fetch_from_service
    easy = Ethon::Easy.new(:url => "#{FETCHER_PREFIX}#{@host}")
    easy.perform
    return easy.response_body if easy.response_code == 200
  end

  def typhoeus_request
    Typhoeus::Request.new(favicon_url, :followlocation => true,
                                       :timeout => 5,
                                       :accept_encoding => "gzip")
  end

  private

  def favicon_url
    "#{FETCHER_PREFIX}#{@host}"
  end

end
