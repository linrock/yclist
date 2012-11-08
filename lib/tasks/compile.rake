namespace :app do

  namespace :compile do

    desc "Generate a static page from companies#index"
    task :static do
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

  end

end
