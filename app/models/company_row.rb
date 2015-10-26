class CompanyRow
  include ActiveModel::Validations

  attr_accessor :name, :url, :status, :cohort, :description

  validates_presence_of :name
  validates_format_of :cohort, :with => /(S|W)\d+/
  validates_inclusion_of :status, :in => %w( Dead Exited ), :allow_blank => true
  # validates_presence_of :url


  def initialize
  end

  def init_from_tr(tr)
    data = tr.css("td").map(&:text)
    self.name = data[0]
    self.url = data[1]
    self.cohort = data[2]
    self.status = data[3]
    self.description = data[4]
    self
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
