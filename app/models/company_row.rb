class CompanyRow
  include ActiveModel::Validations

  attr_accessor :name, :url, :status, :cohort, :description,
                :metadata, :options, :annotation

  validates_presence_of :name
  validates_format_of :url, :with => /\Ahttps?:\/\//, :allow_blank => true
  validates_format_of :cohort, :with => /\A(S|F|W)\d+\z/
  validates_inclusion_of :status, :in => %w( Operating Dead Exited ), :allow_blank => true


  def self.all
    # GsZipballLoader.sorted_all_company_rows
    # GsPublishedPageLoader.sorted_all_company_rows
    YamlLoader.sorted_all_company_rows
  end

  def initialize(attributes = {})
    attributes.each do |attr, value|
      if %w( options annotation ).include?(attr)
        self.send("#{attr}=", value.symbolize_keys)
      else
        self.send("#{attr}=", value.to_s)
      end
    end
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

  def show_url?
    return false if dead?
    return false if options && options[:hide_url]
    true
  end

  def dead?
    status == "Dead"
  end

  def cohort_season
    case cohort[0]
    when "W" then "winter"
    when "S" then "summer"
    when "F" then "fellowship"
    end
  end

  def status_class
    status&.downcase || "operating"
  end

  def status_str
    status == "Operating" && "" || status
  end

end
