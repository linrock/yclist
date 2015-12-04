class FaviconAccessor

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
  end

  def fetch_and_cache!
    favicon = fetch
    @cache.set(favicon) if favicon.present?
  end

  def fetch_from_cache
    @cache.get
  end

  def fetch_from_service
    favicon = FaviconParty.fetch(@host)
    favicon.to_png if favicon.present?
  end

end
