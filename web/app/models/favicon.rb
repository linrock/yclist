class Favicon

  def self.find_by_url(url)
    FaviconStore.new(url).get
  end

  def self.find_or_create_by_url(url)
    favicon = find_by_url(url)
    return favicon if favicon
    favicon = FaviconParty.fetch(url, :no_color_check => true)
    return unless favicon.present?
    FaviconStore.new(url).set favicon.to_png
  end

end
