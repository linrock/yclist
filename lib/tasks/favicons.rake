namespace :favicons do

  # Favicon grabbing services:
  # http://g.etfv.co/
  # http://a.fvicon.com/google.com
  desc "Fetch favicons for each site"
  task :fetch => :environment do
    dir = Rails.root.join("data/favicons")
    Dir.mkdir dir rescue nil
    Company.find_each &:fetch_favicon
  end

  desc "Generate a tileset from favicons"
  task :merge => :environment do

    merge_list = [Rails.root.join("data/misc/transparent-16x16.png")]
    i = 1
    css = ".c-icon { background: url(/favicons.png) no-repeat; width: 16px; height: 16px; }\n"
    Company.all.each do |company|
      favicon_file = Rails.root.join("data/favicons/#{company.id}.png")
      if File.exists? favicon_file
        merge_list << favicon_file
        css += ".c-#{company.id} { background-position-x: -#{i*16}px; }\n"
        i += 1
      else
        css += ".c-#{company.id} { background-position-x: 0px; }\n"
      end
    end
    `convert #{merge_list.join " "} -colorspace RGB +append png24:#{Rails.root.join("public/favicons.png")}`
    puts "Merged #{merge_list.length} favicons into favicons.png"
    open Rails.root.join("app/assets/stylesheets/favicons.css"), 'w' do |f|
      f.write css
    end

  end

end
