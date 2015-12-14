class CompanyRow
  include ActiveModel::Validations

  attr_accessor :name, :url, :status, :cohort, :description

  validates_presence_of :name
  validates_format_of :url, :with => /\Ahttps?:\/\//, :allow_blank => true
  validates_format_of :cohort, :with => /\A(S|W)\d+\z/
  validates_inclusion_of :status, :in => %w( Operating Dead Exited ), :allow_blank => true


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
    if options[:cache_only]
      Favicon.find_by_url(self.url)
    else
      Favicon.find_or_create_by_url(self.url)
    end
  end

  def favicon_base64(options = {})
    data = favicon(options)
    Base64.encode64(data).split.join if !data.nil?
  end

  def has_favicon?
    !favicon(:cache_only => true).nil?
  end

  def need_favicon?
    url.present? && !has_favicon?
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
