class CompaniesController < ApplicationController
  before_filter :get_companies

  # Homepage - list all companies
  def index
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
    @companies = Company.all.sort_by {|c| Date.strptime c.cohort, "%m/%Y" }.reverse
  end
end
