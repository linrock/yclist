namespace :app do

namespace :favicons do

  desc "Fetch favicons (in parallel) for each company that's missing one"
  task :fetch => :environment do
    FaviconFetcher.fetch_parallel
  end

  desc "Fetch favicons for each company that's missing one"
  task :fetch_one_by_one => :environment do
    FaviconFetcher.fetch_one_by_one
  end

  desc "Generate a spritesheet (image + css) from favicons"
  task :merge => :environment do
    FaviconSpritesheet.new.generate!
  end

end

end
