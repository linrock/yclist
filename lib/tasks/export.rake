namespace :app do

  namespace :export do

    desc "Generate a static page from companies#index"
    task :html => :environment do
      raise "Use production environment!" unless Rails.env.production?
      Rake::Task["assets:clean"].invoke
      Rake::Task["assets:precompile"].invoke
      output_file = Rails.root.join('public/exported.html')
      `rm -f #{output_file} #{output_file}.gz`
      app = ActionDispatch::Integration::Session.new(Yclist::Application)
      status_code = app.get '/'
      html = app.body
      raise "HTML export failed - #{status_code}" unless html.length > 0
      open(output_file, 'w') {|f| f.write html }
      `gzip -c -9 #{output_file} > #{output_file}.gz`
      puts "exported.html:     #{`du -hs #{output_file}`}"
      puts "exported.html.gz:  #{`du -hs #{output_file}.gz`}"
      puts "Generated all static files!"
    end

  end
end
