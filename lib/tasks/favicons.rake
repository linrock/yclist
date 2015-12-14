namespace :app do

namespace :favicons do

  desc "Fetch favicons (in parallel) for each company that's missing one"
  task :fetch => :environment do
    FaviconFetcher.new(CompanyRow.all).fetch_parallel
  end

  desc "Fetch favicons for each company that's missing one"
  task :fetch_one_by_one => :environment do
    FaviconFetcher.new(CompanyRow.all).fetch_one_by_one
  end

  desc "Generate a spritesheet (image + css) from favicons"
  task :merge => :environment do
    spritesheet = FaviconSpritesheet.new
    spritesheet.generate!
    spritesheet.export_png!
    spritesheet.export_css!
  end

end

end
