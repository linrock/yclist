class CompaniesController < ActionController::Base
  layout 'application'

  # Homepage - list all companies, dynamically loaded
  #
  def index
    @last_update = Date.today.strftime("%b %d, %Y")
    @company_rows = CompanyRow.all
    @use_favicons = valid_favicon_spritesheet?
    @use_favicon_sprites = true
    # @cached_favicons_only = true
  end

  private

  def valid_favicon_spritesheet?
    FaviconSpritesheet.new.n_companies_processed == @company_rows.size
  end
end
