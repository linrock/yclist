class CompaniesController < ApplicationController

  def index
    @companies = Company.all.sort_by {|c| Date.strptime c.cohort, "%m/%Y" }.reverse
  end

end
