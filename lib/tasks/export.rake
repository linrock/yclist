namespace :app do

  namespace :export do

    desc "Generates all static files"
    task :all => :environment do
      raise Exception.new("Use production environment!") unless Rails.env.production?
      Rake::Task["assets:clean"].invoke
      Rake::Task["assets:precompile"].invoke
      Rake::Task["app:export:html"].invoke
      Rake::Task["app:export:json"].invoke
    end

    desc "Generate a static page from companies#index"
    task :html => :environment do
      index = Rails.root.join('public/index.html')
      `rm -f #{index}`
      `rm -f #{index}.gz`
      app = ActionController::Integration::Session.new(Yclist::Application)
      app.get '/'
      html = app.body.gsub(/\n\s+/,'')
      raise Exception.new("wtf") unless html.length > 0
      open(index,'w') {|f| f.write html }
      `gzip -c -9 #{index} > #{index}.gz`
      puts "index.html:  #{`du -hs #{index}`}"
      puts "Generated all static files!"
    end

    desc "Export company data to JSON"
    task :json => :environment do
      filename = "#{Date.today.strftime("%Y-%m-%d")}-companies.json"
      output = Rails.root.join("exports/#{filename}").to_s
      open(output,'w').write Company.export_json
      puts "Exported company data to exports/#{filename}"
    end

  end
end
