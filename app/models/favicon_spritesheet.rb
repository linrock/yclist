class FaviconSpritesheet

  attr_accessor :png, :css

  def initialize
    `mkdir -p /tmp/yclist/favicons/`
  end

  def generate!
    merge_list = [Rails.root.join("data/misc/transparent-16x16.png")]
    sprite_index = 1
    i = 0
    @css = ".c-icon { background: url(<%= asset_path 'favicons.png' %>) no-repeat;
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
        @css += ".c-#{i} { background-position-x: -#{sprite_index * 16}px; }\n"
        sprite_index += 1
      end
      i += 1
    end
    @png = `convert #{merge_list.join " "} -colorspace RGB +append png:fd:1`
    puts "Merged #{merge_list.length} favicons into favicons.png"
    export_png!
    export_css!
  end

  def export_png!
    spritesheet_png = Rails.root.join("app/assets/images/favicons.png")
    open(spritesheet_png, 'wb') do |f|
      f.write @png
    end
    file_size = `du -hs #{spritesheet_png}`
    puts "favicons.png - #{file_size}"
  end

  def export_css!
    open Rails.root.join("app/assets/stylesheets/favicons.css.erb"), 'w' do |f|
      f.write @css
    end
  end

end
