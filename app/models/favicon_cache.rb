class FaviconCache

  def initialize(hostname)
    @hostname = hostname
    @cache = Rails.cache
  end

  def get
    @cache.read cache_key("data")
  end

  def set(favicon_data)
    @cache.write cache_key("data"), favicon_data
    @cache.write cache_key("updated_at"), Time.now.to_i
    favicon_data
  end

  def updated_at
    @cache.read cache_key("updated_at")
  end

  def age
    return unless updated_at
    (Time.now.to_i - updated_at).seconds
  end

  def cache_key(suffix)
    "favicon:#{@hostname}:#{suffix}"
  end

end
