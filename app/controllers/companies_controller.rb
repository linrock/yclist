class CompaniesController < ApplicationController
  before_filter :get_companies, :except => [ :dynamic ]

  # Homepage - list all companies
  def index
    @last_update = Date.today.strftime("%b %d, %Y")
  end

  def dynamic
    @last_update = Date.today.strftime("%b %d, %Y")
    @company_rows = GoogleSheetsParser.sorted_all_company_rows
    @use_favicon_sprites = true
    # @cached_favicons_only = true
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
