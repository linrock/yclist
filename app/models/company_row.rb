class CompanyRow
  include ActiveModel::Validations

  attr_accessor :name, :url, :status, :cohort, :description,
                :hide_url, :metadata, :notes, :options, :annotation

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
      if %w( options annotation ).include?(attr)
        self.send("#{attr}=", value.symbolize_keys)
        if attr == "options" && value["hide_url"]
          self.hide_url = true
        end
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

  def note=(note)
    @notes << note
  end

  def exit=(exit_info)
    if self.annotation
      self.annotation[:exit] = exit_info
    else
      self.annotation = { exit: exit_info }
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
    !dead? && url.present? && !has_favicon?
  end

  def show_url?
    return false if dead?
    return false if hide_url
    return false if options && options[:hide_url]
    true
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

  def to_text_data
    fields = []
    fields << url if url.present?
    fields << description if description.present?
    fields << "status: #{status.downcase}" if status_class != 'operating'
    if annotation && annotation[:exit].present?
      fields << "exit: #{annotation[:exit]}"
    end
    fields << "hide_url: #{hide_url}" if hide_url.present?
    if metadata.present?
      if metadata.include? "=>"
        fields << "note: #{eval(metadata).map {|k,v| "#{k}: #{v}" }.join(", ")}"
      else
        fields << "note: #{metadata}"
      end
    end
    @notes.each do |note|
      fields << "note: #{note}"
    end
    ([name] + fields.map {|f| "  #{f}" }).join("\n")
  end
end
