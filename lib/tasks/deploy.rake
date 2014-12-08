namespace :app do

namespace :deploy do

  desc "Deploy files from public to production"
  task :all => :environment do
    puts "Syncing assets to production..."
    `rsync -avzP #{Rails.root.join("public").to_s}/ root@asgard:/srv/http/yclist/public`
  end

end

end
