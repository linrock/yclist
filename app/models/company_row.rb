class CompanyRow
  include ActiveModel::Validations

  attr_accessor :name, :url, :status, :cohort, :description

  validates_presence_of :name
  validates_format_of :url, :with => /\Ahttps?:\/\//, :allow_blank => true
  validates_format_of :cohort, :with => /\A(S|W)\d+\z/
  validates_inclusion_of :status, :in => %w( Operating Dead Exited ), :allow_blank => true
  # validates_presence_of :url


  def self.all
    GoogleSheets::ZipballLoader.sorted_all_company_rows
  end

  def initialize(attributes = {})
    attributes.each {|attr, value|
      self.send("#{attr}=", value)
    }
  end

  def ==(company)
    %w( name url status cohort description ).all? do |attribute|
      self.send(attribute) == company.send(attribute)
    end
  end

  def favicon(options = {})
    accessor = FaviconAccessor.new(url)
    if options[:cache_only]
      accessor.fetch_from_cache
    else
      accessor.fetch_and_cache!
    end
  end

  def favicon_base64(options = {})
    data = favicon(options)
    Base64.encode64(data).split.join if data.present?
  end

  def cached_favicon?
    favicon(:cache_only => true).present?
  end

  def need_favicon?
    url.present? && !cached_favicon?
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
