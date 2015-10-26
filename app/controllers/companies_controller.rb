class CompaniesController < ApplicationController
  before_filter :get_companies, :except => [ :dynamic ]

  # Homepage - list all companies
  def index
    @last_update = Date.today.strftime("%b %d, %Y")
  end

  def dynamic
    @company_rows = []
    all_data = GoogleSheetsParser.load_yearly_data_from_most_recent_zip_file
    all_data.sort.reverse.each do |year, yearly_data|
      yearly_data.sorted_companies.each do |company|
        next unless company.url.present?
        @company_rows << company
      end
    end
  end

  # Page to edit company information
  def edit
  end

  # Route for updating information
  def update
    count = 0
    names = []
    info = params[:companies]
    @companies.each do |c|
      c.attributes = info[c.id.to_s]
      if c.changed?
        count += 1
        names << c
        c.save
      end
    end
    flash[:success] = "<p>#{count} changed companies!</p><br><ul>"
    names.each {|c| flash[:success] += "<li>#{c.id} - #{c.name}</li>" }
    flash[:success] += "</ul>"
    redirect_to :edit
  end

  private

  def get_companies
    @companies = Company.all.sort_by do |c|
      [
        -Date.strptime(c.cohort,"%m/%Y").to_time.to_i,
        c.name.downcase.gsub(/^\d+/,'zzz')
      ]
    end
  end

end
