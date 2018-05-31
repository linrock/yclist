# Generates a favicon png spritesheet + corresponding css
#
class FaviconSpritesheet

  attr_accessor :png, :css

  def initialize
    @companies = CompanyRow.all
  end

  def n_companies_processed
    png_desc = `identify -verbose #{spritesheet_png} | grep Desc`
    return unless png_desc.present?
    png_desc[/(\d+) companies/, 1].to_i
  end

  def valid?
    n_companies_processed == @companies.length
  end

  def generate!
    `mkdir -p /tmp/yclist/favicons/`
    merge_list = [Rails.root.join("data/favicons/transparent-16x16.png")]
    sprite_index = 1
    i = 0
    @css = ".c-icon { background: url(/assets/#{merged_favicons_filename}) no-repeat;
                      width: 16px;
                      height: 16px; }\n"
    @companies.each do |company_row|
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
    puts "Merged #{merge_list.length} favicons into a spritesheet"
  end

  def export_png!
    open(spritesheet_png, 'wb') do |f|
      f.write @png
    end
    write_metadata!
    file_size = `du -hs #{spritesheet_png}`
    puts "favicons.png - #{file_size}"
  end

  def export_css!
    spritesheet_css = Rails.root.join("app/assets/stylesheets/favicons.css")
    open(spritesheet_css, 'w') do |f|
      f.write @css
    end
    file_size = `du -hs #{spritesheet_css}`
    puts "favicons.css - #{file_size}"
  end

  private

  def spritesheet_png
    Rails.root.join("public/assets/#{merged_favicons_filename}")
  end

  def favicons_md5_digest
    @favicons_md5_digest ||= favicons_md5_digest!
  end

  def favicons_md5_digest!
    `cd #{Rails.root} && tar cf - data/favicons/ | openssl md5`[/([a-f0-9]{32})/, 1]
  end

  def merged_favicons_filename
    "favicons-#{favicons_md5_digest}.png"
  end

  def write_metadata!
    txt = "#{@companies.size} companies processed"
    `convert #{spritesheet_png} -set Desc "#{txt}" #{spritesheet_png}`
  end
end
