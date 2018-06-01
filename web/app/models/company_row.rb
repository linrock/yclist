class CompanyRow
  include ActiveModel::Validations

  attr_accessor :name, :url, :description, :cohort, :status,
                :exit, :hide_url, :notes

  validates_presence_of :name
  validates_format_of :url, with: /\Ahttps?:\/\//, allow_blank: true
  validates_format_of :status, with: /\A(dead|exited)\z/, allow_blank: true
  validates_format_of :cohort, with: /\A(S|F|W)\d+\z/

  def self.all
    # YamlLoader.new.sorted_all_company_rows
    TextDataFileLoader.new.sorted_all_company_rows
  end

  def initialize(attributes = {})
    @notes = []
    attributes.each do |attr, value|
      self.send("#{attr}=", value.to_s)
    end
  end

  def ==(company)
    %w( name url status cohort description ).all? do |attribute|
      self.send(attribute) == company.send(attribute)
    end
  end

  def note=(note)
    @notes << note
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
    !dead? && url.present? && !has_favicon?
  end

  def show_url?
    !(dead? || hide_url)
  end

  def dead?
    status&.downcase == "dead"
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

  def exit_str
    self.exit.ends_with?(".") ? self.exit : "#{self.exit}."
  end

  def to_text_data
    fields = []
    fields << url.gsub(/\/\z/, '') if url.present?
    fields << description if description.present?
    fields << "status: #{status.downcase}" if status_class != 'operating'
    fields << "exit: #{exit}" if self.exit.present?
    fields << "hide_url: #{hide_url}" if hide_url.present?
    @notes.each do |note|
      fields << "note: #{note}"
    end
    ([name] + fields.map {|f| "  #{f}" }).join("\n")
  end
end
