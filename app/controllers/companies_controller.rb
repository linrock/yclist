class CompaniesController < ApplicationController

  # Homepage - list all companies dynamically loaded from a
  # downloaded google spreadsheets zipball
  #
  def index
    @last_update = Date.today.strftime("%b %d, %Y")
    @company_rows = GoogleSheetsParser.sorted_all_company_rows
    @use_favicon_sprites = true
    # @cached_favicons_only = true
  end

end
