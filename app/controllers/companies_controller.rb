class CompaniesController < ActionController::Metal
  include AbstractController::Rendering
  include ActionView::Layouts

  append_view_path "#{Rails.root}/app/views"
  layout "application"

  # Homepage - list all companies, dynamically loaded
  #
  def index
    @last_update = Date.today.strftime("%b %d, %Y")
    @company_rows = CompanyRow.all
    @use_favicons = valid_favicon_spritesheet?
    @use_favicon_sprites = true
    # @cached_favicons_only = true
    render "companies/index"
  end

  private

  def valid_favicon_spritesheet?
    FaviconSpritesheet.new.n_companies_processed == @company_rows.size
  end
end
