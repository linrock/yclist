namespace :app do

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
    css = ".c-icon { background: url(<%= asset_path 'favicons.png' %>) no-repeat;
                     width: 16px;
                     height: 16px; }\n"
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
    merged_file = Rails.root.join("app/assets/images/favicons.png")
    `convert #{merge_list.join " "} -colorspace RGB +append png:#{merged_file}`
    puts "Merged #{merge_list.length} favicons into favicons.png"
    puts `du -hs #{merged_file}`
    open Rails.root.join("app/assets/stylesheets/favicons.css.erb"), 'w' do |f|
      f.write css
    end

  end

  desc "Fetch favicons for each company if they don't exist"
  task :fetch2 => :environment do
    i = 0
    GoogleSheetsParser.sorted_all_company_rows.each do |company_row|
      next unless company_row.need_favicon?
      puts "Fetching favicon for #{company_row.url}"
      favicon = company_row.favicon
      puts "Favicon not found" unless favicon.present?
      i += 1
    end
    puts "Tried fetching favicons for #{i} companies"
  end

  desc "Fetch favicons for each company if they don't exist in parallel"
  task :fetch_parallel => :environment do
    i = 0
    companies = GoogleSheetsParser.sorted_all_company_rows.select(&:need_favicon?)
    puts "#{companies.length} companies need favicons"
    Parallel.each(companies, :in_threads => 10) do |company|
      puts "Fetching favicon for #{company.url}"
      accessor = FaviconAccessor.new(company.url)
      if accessor.fetch_and_cache!
        puts "Fetched favicon for #{company.url}"
      else
        puts "Failed to fetch favicon for #{company.url}"
      end
      i += 1
    end
    puts "Fetched favicons for #{i} companies"
  end

  desc "Generate a spritesheet (image + css) from favicons"
  task :merge2 => :environment do
    `mkdir -p /tmp/yclist/favicons/`

    merge_list = [Rails.root.join("data/misc/transparent-16x16.png")]
    sprite_index = 1
    i = 0
    css = ".c-icon { background: url(<%= asset_path 'favicons.png' %>) no-repeat;
                     width: 16px;
                     height: 16px; }\n"

    GoogleSheetsParser.sorted_all_company_rows.each do |company_row|
      if !company_row.url.present?
        i += 1
        next
      end
      favicon_data = company_row.favicon(:cache_only => true)
      if favicon_data
        filename = "/tmp/yclist/favicons/#{i}.png"
        open(filename, 'wb') { |f| f.write favicon_data }
        merge_list << filename
        css += ".c-#{i} { background-position-x: -#{sprite_index*16}px; }\n"
        sprite_index += 1
      end
      i += 1
    end
    merged_file = Rails.root.join("app/assets/images/favicons.png")
    `convert #{merge_list.join " "} -colorspace RGB +append png:#{merged_file}`
    puts "Merged #{merge_list.length} favicons into favicons.png"
    puts `du -hs #{merged_file}`
    open Rails.root.join("app/assets/stylesheets/favicons.css.erb"), 'w' do |f|
      f.write css
    end
  end

end

end
