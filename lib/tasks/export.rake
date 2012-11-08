namespace :app do

  namespace :export do

    desc "Generate a static page from companies#index"
    task :html do
      index_tmp = Rails.root.join('public/index.html.tmp')
      index = Rails.root.join('public/index.html')
      `rm -f #{index}`
      `wget -nv localhost:3000 -O #{index_tmp}`
      puts "index.html before:  #{`du -hs #{index_tmp}`}"
      html = open(index_tmp).read
      open(index_tmp,'w') {|f| f.write html.gsub(/\n\s+/,'') }
      puts "index.html after:   #{`du -hs #{index_tmp}`}"
      `mv #{index_tmp} #{index}`
      `gzip -c -9 #{index} > #{index}.gz`
    end

    desc "Export company data to JSON"
    task :json => :environment do
      filename = "#{Date.today.strftime("%Y-%m-%d")}-companies.json"
      output = Rails.root.join("exports/#{filename}").to_s
      open(output,'w').write Company.all.to_json
      puts "Exported company data to exports/#{filename}"
    end

  end
end
