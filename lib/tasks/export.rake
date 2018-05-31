namespace :app do
  namespace :export do
    desc "Generate a static page from companies#index"
    task :html => :environment do
      raise "Use production environment!" unless Rails.env.production?
      Rake::Task["assets:clean"].invoke
      precompilation = `RAILS_ENV=production bundle exec rake assets:precompile 2>&1`
      puts precompilation
      output_file = Rails.root.join('public/exported.html')
      `rm -f #{output_file} #{output_file}.gz`
      app = ActionDispatch::Integration::Session.new(Yclist::Application)
      sleep 1
      status_code = app.get '/'
      html = app.body
      raise "HTML export failed - #{status_code}" unless html.length > 0
      html_js_hash = html[/\/application-([a-z0-9]{64})\.js"/, 1]
      html_css_hash = html[/\/application-([a-z0-9]{64})\.css"/, 1]
      unless html_js_hash.present? && html_css_hash.present?
        raise "HTML export failed - asset hashes missing"
      end
      exported_js_hash = precompilation[/\/application-([a-z0-9]{64})\.js/, 1]
      exported_css_hash = precompilation[/\/application-([a-z0-9]{64})\.css/, 1]
      unless html_js_hash == exported_js_hash
        raise "JS asset hash mismatch - #{html_js_hash} #{exported_js_hash}"
      end
      unless html_css_hash == exported_css_hash
        raise "CSS asset hash mismatch - #{html_css_hash} #{exported_css_hash}"
      end
      open(output_file, 'w') {|f| f.write html }
      `gzip -c -9 #{output_file} > #{output_file}.gz`
      puts "exported.html:     #{`du -hs #{output_file}`}"
      puts "exported.html.gz:  #{`du -hs #{output_file}.gz`}"
      puts "Generated all static files!"
    end
  end
end
