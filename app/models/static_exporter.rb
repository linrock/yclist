# Exports static files for deployment

class StaticExporter

  def initialize
    raise "Use production environment" unless Rails.env.production?
    @output_html_file = Rails.root.join('public/exported.html')
  end

  def export!
    precompilation_output = precompile_assets!
    `rm -f #{@output_html_file} #{@output_html_file}.gz`
    puts precompilation_output
    begin
      html = get_html_output
      ensure_asset_integrity(precompilation_output, html)
    rescue
      # retry generating html output once
      html = get_html_output
      ensure_asset_integrity(precompilation_output, html)
    end
    export_html!(html)
  end

  private

  def precompile_assets!
    puts `RAILS_ENV=production bundle exec rake assets:clean`
    `RAILS_ENV=production bundle exec rake assets:precompile 2>&1`
  end

  def export_html!(html)
    open(@output_html_file, 'w') {|f| f.write html }
    `gzip -c -9 #{@output_html_file} > #{@output_html_file}.gz`
    puts "exported.html:     #{`du -hs #{@output_html_file}`}"
    puts "exported.html.gz:  #{`du -hs #{@output_html_file}.gz`}"
    puts "Generated all static files!"
  end

  def get_html_output
    app = ActionDispatch::Integration::Session.new(Yclist::Application)
    sleep 1
    status_code = app.get '/'
    html = app.body
    raise "HTML export failed - #{status_code}" unless html.length > 0
    html
  end

  def ensure_asset_integrity(precompilation, html)
    html_js_hash = html[/\/application-([a-z0-9]{64})\.js"/, 1]
    html_css_hash = html[/\/application-([a-z0-9]{64})\.css"/, 1]
    unless html_js_hash.present? && html_css_hash.present?
      raise "HTML export failed - asset hashes missing in html"
    end
    exported_js_hash = precompilation[/\/application-([a-z0-9]{64})\.js/, 1]
    exported_css_hash = precompilation[/\/application-([a-z0-9]{64})\.css/, 1]
    unless html_js_hash == exported_js_hash
      raise "JS asset hash mismatch - #{html_js_hash} #{exported_js_hash}"
    end
    unless html_css_hash == exported_css_hash
      raise "CSS asset hash mismatch - #{html_css_hash} #{exported_css_hash}"
    end
  end
end
