class CompaniesController < ApplicationController

  # Homepage - list all companies dynamically loaded from a
  # downloaded google spreadsheets zipball
  #
  def index
    @last_update = Date.today.strftime("%b %d, %Y")
    @company_rows = CompanyRow.all
    @use_favicon_sprites = true
    # @cached_favicons_only = true
  end

end
