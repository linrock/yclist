class Company < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper

  validates_presence_of :name
  validates_uniqueness_of :name

  after_initialize :set_data
  before_validation :standardize_url

  serialize :data, JSON

  attr_accessible :name, :url, :status, :title, :cohort

  def cohort_str
    year = cohort[-2..-1]
    case cohort[0]
    when '6' then "S#{year}"
    when '1' then "W#{year}"
    else return nil
    end
  end

  def status_str
    return "" if status == "Operating"
    status
  end

  def crunchbase_api_url
    return "" unless (cb_url = self.data['crunchbase_url'])
    cb_url.sub('www','api').sub('crunchbase.com','crunchbase.com/v/1') + '.json'
  end

  def fetch_favicon
    return unless url.present?
    dir = Rails.root.join("data/favicons")
    puts "Fetching favicon for... #{url}"
    ico_filename = dir.join("#{id}.ico").to_s
    png_filename = dir.join("#{id}.png").to_s
    `wget -nv http://localhost:4567/#{url} -O #{ico_filename}`
    `convert -resize "16x16!" -flatten #{ico_filename} #{png_filename}`
    `rm #{ico_filename}`
  end

  def fetch_crunchbase_data
    require 'open-uri'

    filename = crunchbase_api_url[/[^\/]+\.json/]
    return {} unless filename
    full_path = data_path.join("crunchbase/#{filename}").to_s
    if !File.exists? full_path || open(full_path).read.empty?
      json = open(crunchbase_api_url).read
      open(full_path,'w') {|f| f.write json }
    end
    JSON.parse open(full_path).read
  end

  # Sets a description using Crunchbase information
  def set_description_from_crunchbase
    return unless fetch_crunchbase_data.present?

    require 'tactful_tokenizer'
    require 'htmlentities'

    m = TactfulTokenizer::Model.new
    h = HTMLEntities.new
    self.title = begin
      text = strip_tags(h.decode(fetch_crunchbase_data['overview']))
      m.tokenize_text(text)[0]
    rescue nil
    end
    self.save
  end

  def dead?
    status == "Dead"
  end

  def exited?
    status == "Exited"
  end

  def self.export_json
    all.to_json only: [:name, :url, :cohort, :status, :title]
  end

  private

  def data_path
    Rails.root.join('data')
  end

  def set_data
    self.data ||= {}
  end

  def standardize_url
    self.url = URI.parse(self.url).to_s.downcase.gsub(/\/$/,'') rescue nil
  end

end
