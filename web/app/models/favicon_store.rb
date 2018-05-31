class FaviconStore
  include FaviconParty::Utils

  def initialize(url)
    @key = store_key(url)
    @base_dir = Rails.root.join("data/favicons")
  end

  def get
    return unless File.exist?(image_name)
    File.open(image_name, "rb") {|f| f.read }
  end

  def set(data)
    image = FaviconParty::Image.new(data)
    raise "Must be a PNG" unless image.mime_type == "image/png"
    open(image_name, "wb") {|f| f.write data }
  end

  def image_name
    @base_dir.join("#{@key}.png").to_s
  end

  def store_key(url)
    URI(prefix_url(url)).host.gsub(/^www\./, '')
  end

end
