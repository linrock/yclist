class CompanyRow
  include ActiveModel::Validations

  attr_accessor :name, :url, :status, :cohort, :description

  validates_presence_of :name
  validates_format_of :url, :with => /\Ahttps?:\/\//, :allow_blank => true
  validates_format_of :cohort, :with => /\A(S|W)\d+\z/
  validates_inclusion_of :status, :in => %w( Dead Exited ), :allow_blank => true
  # validates_presence_of :url


  def initialize
  end

  def init_from_tr(tr)
    data = tr.css("td").map(&:text)
    self.name = data[0]
    self.url = data[1] if data[1].present?
    self.cohort = data[2]
    self.status = data[3]
    self.description = data[4] if data[4].present?
    self
  end

  def favicon(options = {})
    accessor = FaviconAccessor.new(url)
    if options[:cache_only]
      accessor.fetch_from_cache
    else
      accessor.fetch
    end
  end

  def favicon_base64(options = {})
    data = favicon(options)
    Base64.encode64(data).split.join if data.present?
  end

  def cached_favicon?
    FaviconAccessor.new(url).fetch_from_cache.present?
  end

  def dead?
    status == "Dead"
  end

  def cohort_season
    cohort[0] == "W" ? "winter" : "summer"
  end

  def status_str
    status == "Operating" && "" || status
  end

end
